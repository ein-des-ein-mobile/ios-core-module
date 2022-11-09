//
//  URLResponse+Validate.swift
//  Core
//
//  Created by Anton Bal` on 25.09.2022.
//

import Combine
import Foundation

extension HTTPURLResponse {
    func validate() throws {
        guard (200..<300).contains(statusCode) else {
            throw APIError.statusCode(statusCode)
        }
    }
}

extension URLSession.DataTaskPublisher {
    func validate() -> AnyPublisher<URLSession.DataTaskPublisher.Output, Error> {
        tryMap { output -> Output in
            try (output.response as? HTTPURLResponse)?.validate()
            return output
        }.eraseToAnyPublisher()
    }
}
