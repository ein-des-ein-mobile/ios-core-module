//
//  SecureStorage.swift
//  Template
//
//  Created by Anton Bal` on 31.10.2022.
//

import Foundation
import KeychainAccess

public final class KeychainStorage {
    let keychain = Keychain().synchronizable(false)
    
    public static let shared = KeychainStorage()
    
    public init() {}
}

// MARK: - KeychainStorage

extension KeychainStorage: Storagable {

    public func save<T>(_ object: T, key: String) throws where T: Encodable {
        let data = try JSONEncoder().encode(object)
        try keychain.set(data, key: key)
    }

    public func load<T: Decodable>(key: String) throws -> T? {
        guard let data = try keychain.getData(key) else {
            return nil
        }
        return try JSONDecoder().decode(T.self, from: data)
    }

    public func remove(key: String) throws {
        let dataKey = key
        try keychain.remove(dataKey)
    }
}
