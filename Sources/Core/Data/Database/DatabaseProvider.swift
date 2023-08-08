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
    
    func fetchOrCreate<T: Persistable & DatabaseRepresentable>(
        _ type: T.Type,
        forPrimaryKey key: PrimaryKey?,
        context: T.Context
    ) async throws -> T {
        try await perform { database in
            try T(await database.fetchOrCreate(type, forPrimaryKey: key), context: context)
        }
    }

    /// Void Context
    func persist<T: Persistable>(_ value: T) async throws -> T.ManagedObject
    where
    T.Context == Void
    {
        try await persist(value, context: ())
    }
    
    func fetchOrCreate<T: Persistable & DatabaseRepresentable>(
        _ type: T.Type,
        forPrimaryKey key: PrimaryKey?
    ) async throws -> T where T.Context == Void {
        try await perform { database in
            try T(await database.fetchOrCreate(type, forPrimaryKey: key))
        }
    }
}

public extension DatabaseProvider {
    func persistAndWait<T: Persistable>(
        _ value: T,
        context: T.Context,
        callback: ((Result<T.ManagedObject, Error>) -> Void)? = nil
    ) {
        execute(operation: {
            try await persist(value, context: context)
        }, callback: callback)
    }
    
    func fetchOrCreateAndWait<T: Persistable & DatabaseRepresentable>(
        _ type: T.Type,
        forPrimaryKey key: PrimaryKey?,
        context: T.Context
    ) throws -> T {
        try execute {
            try await fetchOrCreate(type, forPrimaryKey: key, context: context)
        }
    }
    
    func persistAndWait<T: Persistable>(
        _ value: T,
        callback: ((Result<T.ManagedObject, Error>) -> Void)? = nil
    )
    where
    T.Context == Void
    {
       persistAndWait(value, context: (), callback: callback)
    }
    
    func performAndWait<Output>(
        _ action: @escaping (DB) async throws -> Output,
        callback: ((Result<Output, Error>) -> Void)? = nil
    ) {
        execute(operation: {
            try await perform(action)
        }, callback: callback)
    }
    
    func fetchOrCreateAndWait<T: Persistable & DatabaseRepresentable>(
        _ type: T.Type,
        forPrimaryKey key: PrimaryKey?
    ) throws -> T where T.Context == Void {
        try execute {
            try await fetchOrCreate(type, forPrimaryKey: key)
        }
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
