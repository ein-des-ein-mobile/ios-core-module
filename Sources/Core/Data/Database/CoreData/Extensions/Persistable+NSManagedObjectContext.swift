//
//  File.swift
//  
//
//  Created by Anton Bal’ on 07.11.2023.
//

import Foundation
import CoreData

public extension Persistable {
    func createOrUpdate(context: NSManagedObjectContext) throws -> ManagedObject
    where
    Context == NSManagedObjectContext,
    ManagedObject: NSManagedObject {
        let request = ManagedObject.createFetchRequest(predicate: primaryKey?.toPredicate())
        
        let result = try context.fetch(request)
        let object = result.first ?? ManagedObject.init(context: context)
        
        if let key = primaryKey {
            object.setPrimaryKey(key)
        }
        
        try update(object as! Self.ManagedObject, context: context)
        
        return object as! Self.ManagedObject
    }
}
