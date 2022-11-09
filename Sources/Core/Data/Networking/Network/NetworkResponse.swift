//
//  NetworkResponse.swift
//  Core
//
//  Created by Anton Bal` on 29.09.2022.
//

import Foundation

public struct NetworkResponse {
    public let data: Data
    public let response: URLResponse
}

public extension NetworkResponse {
    func jsonDecode<T: Decodable>(to type: T.Type, decoder: JSONDecoder = JSONDecoder()) throws -> T {
        try decoder.decode(type, from: data)
    }
}
