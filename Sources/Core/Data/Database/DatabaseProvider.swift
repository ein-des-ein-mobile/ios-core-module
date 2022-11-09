//
//  DatabaseProvider.swift
//  Core
//
//  Created by Anton Bal` on 29.09.2022.
//

import Foundation

public protocol DatabaseProvider {
    associatedtype DB: Database
    
    func perform<Output>(_ action: @escaping (DB) async throws -> Output) async throws -> Output

    func erase() async throws
}

// MARK: - Persistable

public extension DatabaseProvider {

    func persist<T: Persistable>(_ value: T, context: T.Context) async throws -> T.ManagedObject {
        try await perform { database in
            try await database.createOrUpdate(from: value, context: context)
        }
    }

    /// Void Context
    func persist<T: Persistable>(_ value: T) async throws -> T.ManagedObject
    where
    T.Context == Void
    {
        try await persist(value, context: ())
    }
}


// MARK: - PersistableCollection

public extension DatabaseProvider {

    func persist<T: PersistableCollection>(_ values: T,
                                           context: T.Item.Context) async throws -> [T.Item.ManagedObject]
    {
        try await perform { database in
            try await database.createOrUpdate(from: values.items, context: context)
        }
    }

    /// Void Context
    func persist<T: PersistableCollection>(_ values: T) async throws -> [T.Item.ManagedObject]
    where
    T.Item.Context == Void
    {
        try await perform { database in
            try await database.createOrUpdate(from: values.items, context: ())
        }
    }
}
