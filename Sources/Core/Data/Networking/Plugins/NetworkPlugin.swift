//
//  NetworkStrategy.swift
//

import Foundation

/// A Network Plugin receives callbacks to perform side effects wherever a request is sent or received.
///
/// for example, a plugin may be used to
///     - log network requests
///     - inject additional information into a request
public protocol NetworkPlugin {
    /// Called to modify a request before sending.
    func prepare(_ request: URLRequest,
                 target: RequestConvertible) throws -> URLRequest
    
    /// Called after a response has been received, but before the provider has invoked its completion handler.
    func didReceive(_ result: Result<NetworkResponse, Error>,
                    data: Data?,
                    request: URLRequest,
                    target: RequestConvertible)
    
    func should(retry target: RequestConvertible,
                dueTo error: Error) async throws -> Bool
}

public extension NetworkPlugin {
    func prepare(_ request: URLRequest, target: RequestConvertible) -> URLRequest { request }
    func didReceive(_ result: Result<NetworkResponse, Error>,
                    data: Data?,
                    request: URLRequest,
                    target: RequestConvertible) { }
    func should(retry target: RequestConvertible,
                dueTo error: Error) async throws -> Bool {
        false
    }
}
