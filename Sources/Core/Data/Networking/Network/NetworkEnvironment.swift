//
//  NetworkEnvironment.swift
//  Core
//
//  Created by Anton Bal` on 25.09.2022.
//

import Foundation

public protocol NetworkEnvironment {
    var baseURL: URL { get }
    var cachePolicy: URLRequest.CachePolicy { get }
    var timeoutInterval: TimeInterval { get }
}

public extension NetworkEnvironment {
    var cachePolicy: URLRequest.CachePolicy { .useProtocolCachePolicy }
    var timeoutInterval: TimeInterval { 30 }
}
