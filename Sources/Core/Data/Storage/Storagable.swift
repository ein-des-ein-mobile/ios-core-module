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
public final class StorageWrapper<T: Codable> {
    var defaultValue: T
    var key: String
    var storage: Storagable

    public init(key: String, defaultValue: T, storage: Storagable) {
        self.key = key
        self.defaultValue = defaultValue
        self.storage = storage
    }

    public var wrappedValue: T {
        get { (try? storage.load(key: key)) ?? defaultValue }
        set { try? storage.save(newValue, key: key) }
    }
}
