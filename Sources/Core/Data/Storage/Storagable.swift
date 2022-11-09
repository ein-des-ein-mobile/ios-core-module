//
//  Storagable.swift
//  
//
//  Created by Anton Bal` on 09.11.2022.
//

import Foundation

public protocol Storagable {
    init()
    func save<T: Encodable>(_ object: T, key: String) throws
    func load<T: Decodable>(key: String) throws -> T?
    func remove(key: String) throws
}

@propertyWrapper
final class StoragaValue<T: Codable> {
    var defaultValue: T
    var key: String
    var storage: Storagable

    init(key: String, defaultValue: T, storage: Storagable) {
        self.key = key
        self.defaultValue = defaultValue
        self.storage = storage
    }

    var wrappedValue: T {
        get { (try? storage.load(key: key)) ?? defaultValue }
        set { try? storage.save(newValue, key: key) }
    }
}
