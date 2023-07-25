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

    func createOrUpdate<T: Persistable>(from object: T, context: T.Context) async throws
    -> T.ManagedObject

    func fetchOrCreate<T: Persistable>(_ type: T.Type, forPrimaryKey key: PrimaryKey?) async throws
    -> T.ManagedObject
}


public extension Database {
    func createOrUpdate<T: Persistable>(from objects: [T], context: T.Context) async throws
    -> [T.ManagedObject]
    {
        try await withThrowingTaskGroup(of: T.ManagedObject.self) { group in
            for object in objects {
                group.addTask { try await createOrUpdate(from: object, context: context) }
            }
            
            return try await group.reduce(into: [T.ManagedObject]()) { $0.append($1) }
        }
    }
    
    func createOrUpdate<T: Persistable>(from object: T, context: T.Context) async throws -> T.ManagedObject
    {
        let managedObject = try await fetchOrCreate(T.self, forPrimaryKey: object.primaryKey)
        try object.update(managedObject, context: context)
        return managedObject
    }
}
