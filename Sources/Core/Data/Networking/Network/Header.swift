//
//  Header.swift
//  Core
//
//  Created by Anton Bal` on 25.09.2022.
//

import Foundation

public struct NetworkHeader {
    let key: String
    let value: String
}

extension NetworkHeader {

    /// Returns a `Bearer` `Authorization` header using the `bearerToken` provided
    ///
    /// - Parameter bearerToken: The bearer token.
    /// - Returns:               The header.
    public static func authorization(bearerToken: String) -> Self {
        authorization("Bearer \(bearerToken)")
    }

    /// Returns an `Authorization` header.
    ///
    /// Alamofire provides built-in methods to produce `Authorization` headers. For a Basic `Authorization` header use
    /// `HTTPHeader.authorization(username: password:)`. For a Bearer `Authorization` header, use
    /// `HTTPHeader.authorization(bearerToken:)`.
    ///
    /// - Parameter value: The `Authorization` value.
    /// - Returns:         The header.
    public static func authorization(_ value: String) -> Self {
        Self(key: "Authorization", value: value)
    }

    /// Returns a `Content-Type` header.
    ///
    /// All Alamofire `ParameterEncoding`s set the `Content-Type` of the request, so it may not be necessary to manually
    /// set this value.
    ///
    /// - Parameter value: The `Content-Type` value.
    /// - Returns:         The header.
    public static func contentType(_ value: String) -> Self {
        Self(key: "Content-Type", value: value)
    }

    /// Returns an `Accept-Language` header.
    ///
    /// Alamofire offers a default Accept-Language header that accumulates and encodes the system's preferred languages.
    /// Use `HTTPHeader.defaultAcceptLanguage`.
    ///
    /// - Parameter value: The `Accept-Language` value.
    /// - Returns:         The header.
    public static func acceptLanguage(_ value: String) -> Self {
        Self(key: "Accept-Language", value: value)
    }

    /// Returns an `Accept-Encoding` header.
    ///
    /// Alamofire offers a default accept encoding value that provides the most common values. Use
    /// `HTTPHeader.defaultAcceptEncoding`.
    ///
    /// - Parameter value: The `Accept-Encoding` value.
    /// - Returns:         The header
    public static func acceptEncoding(_ value: String) -> Self {
        Self(key: "Accept-Encoding", value: value)
    }

    /// Returns a `User-Agent` header.
    ///
    /// - Parameter value: The `User-Agent` value.
    /// - Returns:         The header.
    public static func userAgent(_ value: String) -> Self {
        Self(key: "User-Agent", value: value)
    }
}

// MARK: - Defaults

extension NetworkHeader {
    /// The default set of `HTTPHeaders` used by Alamofire. Includes `Accept-Encoding`, `Accept-Language`, and
    /// `User-Agent`.
    public static let `default`: [NetworkHeader] = [.defaultAcceptEncoding,
                                                    .defaultAcceptLanguage]
}

extension NetworkHeader {
    /// Returns Alamofire's default `Accept-Encoding` header, appropriate for the encodings supporte by particular OS
    /// versions.
    ///
    /// See the [Accept-Encoding HTTP header documentation](https://tools.ietf.org/html/rfc7230#section-4.2.3) .
    public static let defaultAcceptEncoding: NetworkHeader = {
        let encodings: [String]
        if #available(iOS 11.0, macOS 10.13, tvOS 11.0, watchOS 4.0, *) {
            encodings = ["br", "gzip", "deflate"]
        } else {
            encodings = ["gzip", "deflate"]
        }

        return .acceptEncoding(encodings.qualityEncoded)
    }()

    /// Returns Alamofire's default `Accept-Language` header, generated by querying `Locale` for the user's
    /// `preferredLanguages`.
    ///
    /// See the [Accept-Language HTTP header documentation](https://tools.ietf.org/html/rfc7231#section-5.3.5).
    public static let defaultAcceptLanguage: NetworkHeader = {
        .acceptLanguage(Bundle.main.preferredLocalizations.first ?? Locale.preferredLanguages.prefix(6).qualityEncoded)
    }()
}


extension Collection where Element == String {
    var qualityEncoded: String {
        return enumerated().map { (index, encoding) in
            let quality = 1.0 - (Double(index) * 0.1)
            return "\(encoding);q=\(quality)"
        }.joined(separator: ", ")
    }
}
