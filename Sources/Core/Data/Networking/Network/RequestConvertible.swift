//
//  RequestConvertible.swift
//

import Foundation

public protocol RequestConvertible {
    /// Base URL for request, takes precedence over `baseURL` in `Network` if specified.
    var baseURL: URL? { get }

    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String { get }

    /// The HTTP method used in the request.
    var method: HTTPMethod { get }

    /// The type of HTTP task to be performed.
    var task: NetworkTask { get }

    /// The headers to be used in the request.
    var headers: [NetworkHeader]? { get }

    var cachePolicy: URLRequest.CachePolicy? { get }

    /// Specify authorization strategy for request.
    var authorizationStrategy: AuthorizationStrategy? { get }
}

public extension RequestConvertible {
    var baseURL: URL? { nil }
    var cachePolicy: URLRequest.CachePolicy? { nil }
    var headers: [NetworkHeader]? { nil }
    var authorizationStrategy: AuthorizationStrategy? { .token }
}
