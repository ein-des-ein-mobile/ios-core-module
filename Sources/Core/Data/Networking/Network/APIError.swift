//
//  AppError.swift
//  Core
//
//  Created by Anton Bal` on 25.09.2022.
//

import Foundation

public enum APIError: LocalizedError {
    case deallocated(Any)
    case notImplemented(Any)
    case noData(Any)
    case statusCode(Int, data: Data, response: URLResponse)
    case sessionRequired
    case underlying(Error)

    public var statusCode: Int? {
        if case let .statusCode(code, _, _) = self {
            return code
        }

        return nil
    }

    public var errorDescription: String? {
        switch self {
        case .deallocated(let value):
            return "Object \(value) is deallocated"
        case .noData(let value):
            return "No data of \(value)"
        case .notImplemented(let value):
            return "Method \(value) is not implemented"
        case .statusCode(let int, let data, let response):
            return """
            Status code was \(int),
            ===================================
            \(response.url?.lastPathComponent ?? "")
            ===================================
            \(String(data: data, encoding: .utf8) ?? "")
            """
        case .sessionRequired:
            return "The session is required"
        case .underlying(let error):
            return error.localizedDescription
        }
    }
}
