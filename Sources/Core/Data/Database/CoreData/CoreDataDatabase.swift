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
        try? FileManager
            .default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("\(persistentContainerName).\(type.rawValue)")
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
    
    private lazy var viewContext: NSManagedObjectContext = {
        with(persistentContainer.viewContext) {
            $0.automaticallyMergesChangesFromParent = true
            $0.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        }
    }()
    
    private lazy var backgroundContext: NSManagedObjectContext = {
        with(persistentContainer.newBackgroundContext()) {
            $0.automaticallyMergesChangesFromParent = true
            $0.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        }
    }()
    
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
        load { error in
            error.map { logger.error("Database load error", $0)}
        }
    }
    
    // MARK: - Functions
    
    public func load(_ completion: @escaping (Error?) -> Void) {
        persistentContainer.loadPersistentStores { [weak self] value, error in
            self?.logger.log(value.debugDescription)
            completion(error)
        }
    }
    
    // MARK: Perform
    
    public func perform(_ block: @escaping (NSManagedObjectContext) throws -> Void) {
        backgroundContext.performAndWait {
            do {
                try block(backgroundContext)
                
                if backgroundContext.hasChanges {
                    try backgroundContext.save()
                }
            } catch {
                logger.error("Database perform error", error)
            }
        }
    }
}

extension CoreDataDatabase: DatabaseProvider {
    
    public typealias DB = CoreDataDatabase
    
    public func perform<Output>(_ action: @escaping (DB) async throws -> Output) async throws -> Output {
        try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self = self else {
                continuation.resume(with: .failure(DatabaseError.dealocated(CoreDataDatabase.self)))
                return
            }
            
            execute {
                try await action(self)
            } callback: { result in
                continuation.resume(with: result)
            }
        }
    }
    
    public func erase() async throws {
        
    }
}

extension CoreDataDatabase: Database {

    public typealias Context = NSManagedObjectContext
    
    public func save<T>(from object: T) async throws -> T.ManagedObject where T: Persistable {
        guard let ObjectType = T.ManagedObject.self as? NSManagedObject.Type else {
            throw DatabaseError.typeCasting(T.ManagedObject.self)
        }
        
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self = self else {
                continuation.resume(with: .failure(DatabaseError.dealocated(CoreDataDatabase.self)))
                return
            }
            
            self.perform { moc in
                do {
                    var predicate: NSPredicate?
                    
                    if let key = object.primaryKey {
                        predicate = NSPredicate(format: "\(key.key) == %@", "\(key.value)")
                    }
                
                    let result = try moc.fetch(ObjectType.createFetchRequest(predicate: predicate))
                    
                    if result.isEmpty {
                        let newObject = ObjectType.init(context: moc)
                                                
                        if let key = object.primaryKey {
                            newObject.setPrimaryKey(key)
                        }
                        
                        moc.insert(newObject)
                        
                        let value = newObject as! T.ManagedObject
                        
                        if let c = moc as? T.Context {
                            try object.update(value, context: c)
                        } else if let c = () as? T.Context {
                            try object.update(value, context: c)
                        }
                        
                        continuation.resume(with: .success(value))
                    } else {
                        let newObject = result.first! as! T.ManagedObject
                        
                        if let c = moc as? T.Context {
                            try object.update(newObject, context: c)
                        } else if let c = () as? T.Context {
                            try object.update(newObject, context: c)
                        }
                        
                        continuation.resume(with: .success(newObject))
                    }
                } catch {
                    continuation.resume(with: .failure(error))
                }
            }
        }
    }
    
    public func fetch<T>(_ type: T.Type, for key: PrimaryKey?) async throws -> T.ManagedObject? where T : Persistable {
        guard let ObjectType = type.ManagedObject as? NSManagedObject.Type else {
            throw DatabaseError.typeCasting(type.ManagedObject)
        }
        
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self = self else {
                continuation.resume(with: .failure(DatabaseError.dealocated(CoreDataDatabase.self)))
                return
            }
            
            self.perform { moc in
                do {
                    
                    var predicate: NSPredicate?
                    
                    if let key = key {
                        predicate = NSPredicate(format: "\(key.key) == %@", "\(key.value)")
                    }
                    
                    let result = try moc.fetch(ObjectType.createFetchRequest(predicate: predicate))
                    continuation.resume(with: .success(result.first as? T.ManagedObject))
                } catch {
                    continuation.resume(with: .failure(error))
                }
            }
        }
    }
    
    public func fetch<T>(_ type: T.Type) async throws -> [T.ManagedObject] where T : Persistable {
        guard let ObjectType = type.ManagedObject as? NSManagedObject.Type else {
            throw DatabaseError.typeCasting(type.ManagedObject)
        }
        
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self = self else {
                continuation.resume(with: .failure(DatabaseError.dealocated(CoreDataDatabase.self)))
                return
            }
            
            self.perform { moc in
                do {
                    let result = try moc.fetch(ObjectType.createFetchRequest())
                    continuation.resume(with: .success(result as! [T.ManagedObject]))
                } catch {
                    continuation.resume(with: .failure(error))
                }
            }
        }
    }
    
    public func fetchOrCreate<T>(_ type: T.Type, for key: PrimaryKey?) async throws -> T.ManagedObject where T : Persistable {
        guard let ObjectType = type.ManagedObject as? NSManagedObject.Type else {
            throw DatabaseError.typeCasting(type.ManagedObject)
        }
        
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self = self else {
                continuation.resume(with: .failure(DatabaseError.dealocated(CoreDataDatabase.self)))
                return
            }
            
            self.perform { moc in
                do {
                    
                    var predicate: NSPredicate?
                    
                    if let key = key {
                        predicate = NSPredicate(format: "\(key.key) == %@", "\(key.value)")
                    }
                    
                    let result = try moc.fetch(ObjectType.createFetchRequest(predicate: predicate))
                    if result.isEmpty {
                        let object = ObjectType.init(context: moc)
                        if let key = key {
                            object.setPrimaryKey(key)
                        }
                        moc.insert(object)
                        continuation.resume(with: .success(object as! T.ManagedObject))
                    } else {
                        continuation.resume(with: .success(result.first! as! T.ManagedObject))
                    }
                } catch {
                    continuation.resume(with: .failure(error))
                }
            }
        }
    }
}

public extension Persistable {
    func createOrUpdate(context: NSManagedObjectContext) throws -> ManagedObject
    where
    Context == NSManagedObjectContext,
    ManagedObject: NSManagedObject
    {
        var predicate: NSPredicate?
        
        if let key = primaryKey {
            predicate = NSPredicate(format: "\(key.key) == %@", "\(key.value)")
        }
        
        let request = ManagedObject.createFetchRequest(predicate: predicate)
        
        let result = try context.fetch(request)
        let object = result.first ?? ManagedObject.init(context: context)
        
        if let key = primaryKey {
            object.setPrimaryKey(key)
        }
        
        try update(object as! Self.ManagedObject, context: context)
        
        return object as! Self.ManagedObject
    }
}
