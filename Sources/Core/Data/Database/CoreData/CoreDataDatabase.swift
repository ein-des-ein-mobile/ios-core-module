//
//  DataBase.swift
//  SnoreFree
//
//  Created by Anton Bal` on 07.11.2022.
//

///
/// [WIP]
///
/// Core data base example
/// not ready
///

import Foundation
import CoreData

public final class CoreDataDatabase {
    
    public enum DatabaseType: String {
        case sqlite
    }
    
    private var storeURL: URL? {
        try? unownedURL()
    }
    
    // MARK: - Properties
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: persistentContainerName)
        
        if let url = storeURL {
            let description = NSPersistentStoreDescription(url: url)
            description.shouldMigrateStoreAutomatically = true
            container.persistentStoreDescriptions = [description]
        }
        
        return container
    }()
    
    var managedObjectContext: NSManagedObjectContext {
        if Thread.isMainThread {
            return viewContext
        } else {
            return backgroundContext
        }
    }
    
    private lazy var viewContext: NSManagedObjectContext = {
        with(persistentContainer.viewContext) {
            $0.automaticallyMergesChangesFromParent = true
            $0.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        }
    }()
    
    private var backgroundContext: NSManagedObjectContext {
        with(persistentContainer.newBackgroundContext()) {
            $0.automaticallyMergesChangesFromParent = true
            $0.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        }
    }
    
    let persistentContainerName: String
    let logger: CoreLogging
    let type: DatabaseType
    
    // MARK: - Initialization
    
    public init(
        persistentContainerName: String,
        logger: CoreLogging = CoreLogger(category: "Core-Data"),
        type: DatabaseType = .sqlite
    ) {
        self.persistentContainerName = persistentContainerName
        self.logger = logger
        self.type = type
        // loading is synchronius
        load { [weak self] error in
            error.map { logger.error("Database load error", $0)}
            
            if error != nil {
                try? self?.erase()
                
                self?.load { error in
                    error.map { logger.error("Database load error", $0)}
                }
            }
        }
    }
    
    // MARK: - Functions
    
    public func load(_ completion: @escaping (Error?) -> Void) {
        persistentContainer.loadPersistentStores { [weak self] value, error in
            self?.logger.log(value.debugDescription)
            completion(error)
        }
    }
    
    private func unownedURL() throws -> URL {
        try FileManager
            .default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("\(persistentContainerName).\(type.rawValue)")
    }

    // MARK: Perform
    
    public func perform(_ block: @escaping (NSManagedObjectContext) throws -> Void) {
        let context = managedObjectContext
        
        context.performAndWait {
            do {
                try block(context)
                
                if context.hasChanges {
                    try context.save()
                }
            } catch {
                logger.error("Database perform error", error)
            }
        }
    }
}

extension CoreDataDatabase: DatabaseProvider {
    
    public typealias DB = CoreDataDatabase
    
    public func perform<Output>(_ action: @escaping (DB, DB.Context) throws -> Output) async throws -> Output {
        try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self = self else {
                continuation.resume(with: .failure(DatabaseError.dealocated(CoreDataDatabase.self)))
                return
            }
            
            self.perform { moc in
                continuation.resume(returning: try action(self, moc))
            }
        }
    }
    
    public func erase() throws {
        try FileManager.default.removeItem(at: unownedURL())
    }
}

extension CoreDataDatabase: Database {
    
    public typealias Context = NSManagedObjectContext
    
    public func fetch<T: Persistable>(
        _ type: T.Type,
        predicate: NSPredicate?,
        sortDescriptors: [NSSortDescriptor]?,
        context: Context
    ) throws -> [T.ManagedObject] {
        guard let ObjectType = type.ManagedObject as? NSManagedObject.Type else {
            throw DatabaseError.typeCasting(type.ManagedObject)
        }
        
        let request = ObjectType.createFetchRequest(
            predicate: predicate,
            sortDescriptors: sortDescriptors
        )
        
        let result = try context.fetch(request)
        return result as! [T.ManagedObject]
    }
    
    public func delete<T: Persistable>(_ object: T, context: Context) throws -> T.ManagedObject? {
        guard let ObjectType = T.ManagedObject.self as? NSManagedObject.Type else {
            throw DatabaseError.typeCasting(T.ManagedObject.self)
        }
        
        let result = try context.fetch(ObjectType.createFetchRequest(predicate: object.primaryKey?.toPredicate()))
        
        if let object = result.first {
            context.delete(object)
        }
        
        return result.first as? T.ManagedObject
    }
    
    public func save<T: Persistable>(_ object: T, context: Context) throws -> T.ManagedObject {
        
        guard let ObjectType = T.ManagedObject.self as? NSManagedObject.Type else {
            throw DatabaseError.typeCasting(T.ManagedObject.self)
        }
        
        let result = try context.fetch(ObjectType.createFetchRequest(predicate: object.primaryKey?.toPredicate()))
        
        if result.isEmpty {
            let newObject = ObjectType.init(context: context)
            
            if let key = object.primaryKey {
                newObject.setPrimaryKey(key)
            }
            
            context.insert(newObject)
            
            let value = newObject as! T.ManagedObject
            
            if let moc = context as? T.Context {
                try object.update(value, context: moc)
            } else if let c = () as? T.Context {
                try object.update(value, context: c)
            }
            
            return value
        } else {
            let newObject = result.first! as! T.ManagedObject
            
            if let moc = context as? T.Context {
                try object.update(newObject, context: moc)
            } else if let c = () as? T.Context {
                try object.update(newObject, context: c)
            }
            
            return newObject
        }
    }
}
