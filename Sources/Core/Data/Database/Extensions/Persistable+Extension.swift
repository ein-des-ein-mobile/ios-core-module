//
//  Persistable+Extension.swift
//  
//
//  Created by Anton Bal’ on 22.07.2023.
//

import CoreData

public extension Persistable {
    func persist<D>(to database: D) async throws -> ManagedObject
    where D: DatabaseProvider,
          ManagedObject: NSManagedObject
    {
        try await database.persist(self)
    }
    
}

public extension PersistableCollection {
    func persist<D>(to database: D) async throws -> [Item.ManagedObject]
    where D: DatabaseProvider,
          Item.ManagedObject: NSManagedObject
    {
        try await database.persist(self)
    }
}
