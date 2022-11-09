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
    case statusCode(Int)
    case sessionRequired
    case urlError(URLError)
    case underlying(Error)

    public var statusCode: Int? {
        if case let .statusCode(code) = self {
            return code
        }

        return 0
    }

    public var errorDescription: String? {
        switch self {
        case .deallocated(let value):
            return "Object \(value) is deallocated"
        case .noData(let value):
            return "No data of \(value)"
        case .notImplemented(let value):
            return "Method \(value) is not implemented"
        case .statusCode(let int):
            return "Status code was \(int), but expected 2xx"
        case .sessionRequired:
            return "The session is required"
        case .urlError(let uRLError):
            return uRLError.localizedDescription
        case .underlying(let error):
            return error.localizedDescription
        }
    }
}
