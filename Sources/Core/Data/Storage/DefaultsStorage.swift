//
//  UserDefaults.swift
//
//  Created by Anton Bal` on 21.09.2022.
//

import Foundation

// MARK: - DefaultsStorage

public final class DefaultsStorage: Storagable {
    
    public init() {}
    
    public static let shared = DefaultsStorage()

    public func save<T>(_ object: T, key: String) throws where T: Encodable {
        let data = try JSONEncoder().encode(object)
        UserDefaults.standard.set(data, forKey: key)
    }

    public func load<T: Decodable>(key: String) throws -> T? {
        guard let data = UserDefaults.standard.value(forKey: key) as? Data else {
            return nil
        }
        return try JSONDecoder().decode(T.self, from: data)
    }

    public func remove(key: String) throws {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
