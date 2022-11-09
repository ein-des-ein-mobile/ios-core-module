//
//  URLRequest.swift
//  Core
//
//  Created by Anton Bal` on 25.09.2022.
//

import Foundation

private extension JSONEncoder  {
    static var contentType: String { "application/json" }
}

extension URLRequest {

    private mutating func encode(_ params: NetworkParameters, for httpMethod: HTTPMethod) -> URLRequest {
        switch httpMethod {
        case .get:
            guard let url = url,
                  var newUrl = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return self }
            newUrl.queryItems = params.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
            guard let queryURL = newUrl.url else { return self }

            return URLRequest(url: queryURL)
        default:
            // TODO: - not a good solution
            if let data = try? JSONSerialization.data(withJSONObject: params) {
                add(header: .contentType(JSONEncoder.contentType))
                httpBody = data
            }
            return self
        }
    }

    mutating func encoded(for target: RequestConvertible) throws -> URLRequest {
        switch target.task {
        case .requestPlain:
            return self
        case .requestData(let body):
            httpBody = body
        case .requestParameters(let parameters):
            return encode(parameters, for: target.method)
        }
        return self
    }
}
