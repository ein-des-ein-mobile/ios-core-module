//
//  URLResponse+Validate.swift
//  Core
//
//  Created by Anton Bal` on 25.09.2022.
//

import Combine
import Foundation

extension HTTPURLResponse {
    func validate(data: Data) throws {
        guard (200..<300).contains(statusCode) else {
            throw APIError.statusCode(statusCode, data: data, response: self)
        }
    }
}

extension URLSession.DataTaskPublisher {
    func validate() -> AnyPublisher<URLSession.DataTaskPublisher.Output, Error> {
        tryMap { output -> Output in
            try (output.response as? HTTPURLResponse)?.validate(
                data: output.data
            )
            return output
        }.eraseToAnyPublisher()
    }
}
