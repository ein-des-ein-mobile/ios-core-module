//
//  Persistable+Extension.swift
//  
//
//  Created by Anton Bal’ on 22.07.2023.
//

import CoreData

extension Persistable {
    func persist<D>(to database: D) async throws -> ManagedObject
    where D: DatabaseProvider,
          ManagedObject: NSManagedObject,
          Context == Void {
              try await database.persist(self)
          }
    
}

extension PersistableCollection {
    func persist<D>(to database: D) async throws -> [Item.ManagedObject]
    where D: DatabaseProvider,
          Item.ManagedObject: NSManagedObject,
          Item.Context == Void
    {
        try await database.persist(self)
    }
}

extension NSManagedObject {
    func tryMap<T, D>(to type: T.Type, database: D) async throws -> T?
    where D: DatabaseProvider,
          T: DatabaseRepresentable,
          T.ManagedObject: NSManagedObject,
          T.Context == Void
    {
        try await database.perform { [unowned self] _ -> T? in
            guard !self.isFault else {
                return nil
            }
            return try T(self as! T.ManagedObject)
        }
    }
}

extension Array where Element: NSManagedObject {
    func tryMap<T, D>(to type: T.Type, database: D) async throws -> [T]
    where D: DatabaseProvider,
          T: DatabaseRepresentable,
          T.ManagedObject: NSManagedObject,
          T.Context == Void
    {
        try await database.perform { _ -> [T] in
            try self.compactMap {
                guard !$0.isFault else {
                    return nil
                }
                return try T($0 as! T.ManagedObject)
            }
        }
    }
}

