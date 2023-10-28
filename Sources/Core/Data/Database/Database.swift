//
//  DataBase.swift
//  Core
//
//  Created by Anton Bal` on 29.09.2022.
//

import Foundation
import Combine

public enum DatabaseError: LocalizedError {
    case typeCasting(Any)
    case notFound(type: Any, id: Any)
    case dealocated(Any)
    case underlying(Error)
}

public protocol Database {

    func save<T: Persistable>(from object: T, context: T.Context) async throws -> T.ManagedObject

    func fetchOrCreate<T: Persistable>(_ type: T.Type, for key: PrimaryKey?) async throws -> T.ManagedObject
    func fetch<T: Persistable>(_ type: T.Type) async throws -> [T.ManagedObject]
    func fetch<T: Persistable>(_ type: T.Type, for key: PrimaryKey?) async throws -> T.ManagedObject?
}


public extension Database {
    func save<T: Persistable>(from objects: [T], context: T.Context) async throws
    -> [T.ManagedObject]
    {
        try await withThrowingTaskGroup(of: T.ManagedObject.self) { group in
            for object in objects {
                group.addTask { try await save(from: object, context: context) }
            }
            
            return try await group.reduce(into: [T.ManagedObject]()) { $0.append($1) }
        }
    }
    
    func save<T: Persistable>(from objects: [T]) async throws
    -> [T.ManagedObject] where T.Context == Void
    {
        try await save(from: objects, context: ())
    }
    
    func save<T: Persistable>(from object: T) async throws -> T.ManagedObject where T.Context == Void
    {
        try await save(from: object, context: ())
    }
}
