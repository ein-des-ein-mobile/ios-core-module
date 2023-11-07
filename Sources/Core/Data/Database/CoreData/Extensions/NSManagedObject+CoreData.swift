//
//  NSManagedObject+CoreData.swift
//  
//
//  Created by Anton Bal’ on 22.07.2023.
//

import CoreData

public extension NSManagedObject {
    static var entityName: String {
        NSStringFromClass(self)
            .components(separatedBy: ".")
            .last ?? ""
    }
    
    static func createFetchRequest<T: NSManagedObject>(
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil)
        -> NSFetchRequest<T>
    {
        with(NSFetchRequest<T>(entityName: entityName)) {
            $0.predicate = predicate
            $0.sortDescriptors = sortDescriptors
        }
    }
    
    func setCustomValue(_ value: Any?,
                        for key: String)
    {
        willChangeValue(forKey: key)
        defer { didChangeValue(forKey: key) }
        setPrimitiveValue(value, forKey: key)
    }
    
    func customValue(for key: String) -> Any? {
        willAccessValue(forKey: key)
        defer { didAccessValue(forKey: key) }
        
        return primitiveValue(forKey: key)
    }
    
    func setPrimaryKey(_ key: PrimaryKey) {
        setCustomValue(key.value, for: key.key)
    }
}
