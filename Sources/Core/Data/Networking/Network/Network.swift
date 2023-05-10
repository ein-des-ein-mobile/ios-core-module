//
//  Network.swift
//  Core
//
//  Created by Anton Bal` on 24.09.2022.
//

import Foundation
import Combine

public final class Network {
    
    let environment: NetworkEnvironment
    private let plugins: [NetworkPlugin]
    private let headers = NetworkHeader.default
    
    public init(environment: NetworkEnvironment, plugins: [NetworkPlugin]) {
        self.environment = environment
        self.plugins = plugins
    }
    
    fileprivate func prepareRequest(for target: RequestConvertible) throws -> URLRequest {
        let environmentTarget = EnvironmentTarget(target: target, environment: environment)
        
        var request = URLRequest(url: environmentTarget.url,
                                 cachePolicy: environment.cachePolicy,
                                 timeoutInterval: environment.timeoutInterval)
        
        request.httpMethod = environmentTarget.method.rawValue
        
        headers.forEach { request.add(header: $0) }
        environmentTarget.headers?.forEach { request.add(header: $0) }
        
        request = try request.encoded(for: target)
        return try prepare(request, target: target)
    }
}

fileprivate struct EnvironmentTarget: RequestConvertible {
    let target: RequestConvertible
    let environment: NetworkEnvironment
    
    var method: HTTPMethod { target.method }
    var task: NetworkTask { target.task }
    var path: String { target.path }
    var baseURL: URL { target.baseURL ?? environment.baseURL }
    var url: URL { baseURL.appendingPathComponent(target.path) }
    var headers: [NetworkHeader]? { target.headers }
    var cachePolicy: URLRequest.CachePolicy? {target.cachePolicy ?? environment.cachePolicy }
}

// MARK: - Networking

extension Network: Networking {
    
    public func data(for target: RequestConvertible) async throws -> NetworkResponse {
        let request = try prepareRequest(for: target)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let networkResponse = NetworkResponse(data: data, response: response)
            
            do {
                try (response as? HTTPURLResponse)?.validate()
                didReceive(.success(networkResponse),
                           data: data,
                           request: request,
                           target: target
                )
                return networkResponse
            } catch {
                didReceive(.failure(error),
                           data: data,
                           request: request,
                           target: target
                )
                throw error
            }
        } catch {
            didReceive(.failure(error), data: nil, request: request, target: target)
            
            if try await should(retry: target, dueTo: error) {
                return try await data(for: target)
            } else {
                switch error {
                case let error as APIError:
                    throw error
                default:
                    throw APIError.underlying(error)
                }
            }
        }
    }
    
    public func task(for target: RequestConvertible) -> AsyncTask<NetworkResponse> {
        Future { [weak self] in
            guard let self  = self else { throw APIError.deallocated(Network.self) }
            return try await self.data(for: target)
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Handle NetworkPlugin methods

extension Network {
    private func prepare(_ request: URLRequest,
                         target: RequestConvertible) throws -> URLRequest {
        return try plugins.reduce(request) { try $1.prepare($0, target: target) }
    }
    
    private func didReceive(_ result: Result<NetworkResponse, Error>,
                            data: Data?,
                            request: URLRequest,
                            target: RequestConvertible) {
        plugins.forEach {
            $0.didReceive(result,
                          data: data,
                          request: request,
                          target: target)
        }
    }
    
    private func should(retry target: RequestConvertible,
                        dueTo error: Error) async throws -> Bool {
        for plugin in plugins {
            if (try await plugin.should(retry: target, dueTo: error)) {
                return true
            }
        }
        return false
    }
}
