//
//  NetworkStrategy.swift
//

import Foundation

public protocol NetworkPlugin {
    func prepare(_ request: URLRequest,
                 target: RequestConvertible) throws -> URLRequest
    func should(retry target: RequestConvertible,
                dueTo error: Error) async throws -> Bool
}

public extension NetworkPlugin {
    func prepare(_ request: URLRequest, target: RequestConvertible) -> URLRequest { request }

    func should(retry target: RequestConvertible,
                dueTo error: Error,
                completion: @escaping (URLResponse) -> Void) {
    }
}
