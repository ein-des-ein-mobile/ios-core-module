//
//  Session.swift
//  Core
//
//  Created by Anton Bal` on 24.09.2022.
//

import Foundation

public final class Session<T: AuthUser>: Codable {
    enum CodingKeys: String, CodingKey {
        case user
        case accessToken
    }

    public let user: T
    public let accessToken: AccessToken

    public init(user: T, accessToken: AccessToken) {
        self.user = user
        self.accessToken = accessToken
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        accessToken = try container.decode(AccessToken.self,
                                           forKey: .accessToken)
        user = try container.decode(T.self, forKey: .user)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(user, forKey: .user)
        try container.encode(accessToken, forKey: .accessToken)
    }
}
