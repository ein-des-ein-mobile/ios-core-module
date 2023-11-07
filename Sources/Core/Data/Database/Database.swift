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
    
    associatedtype Context

    func save<T: Persistable>(from object: T, context: Context) throws -> T.ManagedObject

    func fetch<T: Persistable>(
        _ type: T.Type,
        predicate: NSPredicate?,
        sortDescriptors: [NSSortDescriptor]?,
        context: Context
    ) throws -> [T.ManagedObject]
}

public extension Database {
    func fetch<T: Persistable>(
        _ type: T.Type,
        predicate: NSPredicate?,
        context: Context
    ) throws -> [T.ManagedObject] {
        try fetch(type, predicate: predicate, sortDescriptors: nil, context: context)
    }
    
    func fetch<T: Persistable>(_ type: T.Type, context: Context) throws -> [T.ManagedObject] {
        try fetch(type, predicate: nil, sortDescriptors: nil, context: context)
    }
    
    func save<T: Persistable>(from objects: [T], context: Context) throws -> [T.ManagedObject] {
        try objects.compactMap { try save(from: $0, context: context) }
    }
    
    func save<T: Persistable>(from object: T, context: Context) throws -> T.ManagedObject {
        try save(from: object, context: context)
    }
    
    func fetchLast<T: Persistable>(_ type: T.Type, for key: PrimaryKey?, context: Context) throws -> T.ManagedObject? {
        try fetch(type, predicate: key?.toPredicate(), context: context).last
    }
}
