//
//  DatabaseProvider.swift
//  Core
//
//  Created by Anton Bal` on 29.09.2022.
//

import Foundation

public protocol DatabaseProvider {
    associatedtype DB: Database
    
    func perform<Output>(_ action: @escaping (DB, DB.Context) throws -> Output) async throws -> Output
    
    func erase() throws
}

// MARK: - Persistable

public extension DatabaseProvider {

    @discardableResult
    func persist<T: Persistable>(_ value: T) async throws -> T.ManagedObject 
    {
        try await perform { (database, context) in
            try database.save(from: value, context: context)
        }
    }

    func fetch<T: Persistable & DatabaseRepresentable>(
        _ type: T.Type
    ) async throws -> [T] {
        try await perform { (database, context) in
            try database.fetch(type, context: context).map { try T($0) }
        }
    }
    
    func fetchLast<T: Persistable & DatabaseRepresentable>(
        _ type: T.Type,
        for key: PrimaryKey?
    ) async throws -> T? {
        try await perform { (database, context) in
            try database.fetchLast(type, for: key, context: context).flatMap { try T($0) }
        }
    }
}

public extension DatabaseProvider {
    
    @discardableResult
    func persistAndWait<T: Persistable>(_ value: T) throws -> T.ManagedObject {
        try execute { try await persist(value) }
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
            try await fetchLast(type, for: key)
        }
    }
    
    func performAndWait<Output>(
        _ action: @escaping (DB, DB.Context) throws -> Output,
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
        try await perform { (database, context) in
            try database.save(from: values.items, context: context)
        }
    }
}
