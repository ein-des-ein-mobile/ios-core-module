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

    @discardableResult
    func persist<T: Persistable>(_ value: T) async throws -> T.ManagedObject {
        try await perform { database in
            try await database.save(from: value)
        }
    }
    
    func fetchOrCreate<T: Persistable & DatabaseRepresentable>(
        _ type: T.Type,
        for key: PrimaryKey?
    ) async throws -> T {
        try await perform { database in
            try T(await database.fetchOrCreate(type, for: key))
        }
    }
    
    func fetch<T: Persistable & DatabaseRepresentable>(
        _ type: T.Type
    ) async throws -> [T] {
        try await perform { database in
            try await database.fetch(type).map { try T($0) }
        }
    }
    
    func fetch<T: Persistable & DatabaseRepresentable>(
        _ type: T.Type,
        for key: PrimaryKey?
    ) async throws -> T? {
        try await perform { database in
            try await database.fetch(type, for: key).map { try T($0) }
        }
    }
}

public extension DatabaseProvider {
    func persistAndWait<T: Persistable>(
        _ value: T,
        callback: ((Result<T.ManagedObject, Error>) -> Void)? = nil
    ) {
        execute(operation: {
            try await persist(value)
        }, callback: callback)
    }
    
    func fetchOrCreateAndWait<T: Persistable & DatabaseRepresentable>(
        _ type: T.Type,
        for key: PrimaryKey?
    ) throws -> T {
        try execute {
            try await fetchOrCreate(type, for: key)
        }
    }
    
    func fetchAndWait<T: Persistable & DatabaseRepresentable>(
        _ type: T.Type
    ) throws -> [T] {
        try execute {
            try await fetch(type)
        }
    }
    
    func fetchAndhWait<T: Persistable & DatabaseRepresentable>(
        _ type: T.Type,
        for key: PrimaryKey
    ) throws -> T? {
        try execute {
            try await fetch(type, for: key)
        }
    }
    
    func performAndWait<Output>(
        _ action: @escaping (DB) async throws -> Output,
        callback: ((Result<Output, Error>) -> Void)? = nil
    ) {
        execute(operation: {
            try await perform(action)
        }, callback: callback)
    }
}


// MARK: - PersistableCollection

public extension DatabaseProvider {

    func persist<T: PersistableCollection>(_ values: T) async throws -> [T.Item.ManagedObject]
   {
        try await perform { database in
            try await database.save(from: values.items)
        }
    }
}
