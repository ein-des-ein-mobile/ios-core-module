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

/*
import Foundation
import CoreData

final class CoreDataDatabase {
    
    private enum PersistentContainer {
        static let name = "CoreData"
    }
    // MARK: - Properties
    // concurrent queue for execution performAndWait on reading
    private let performQueue = DispatchQueue(label: "Database performQueue", qos: .userInitiated, attributes: .concurrent)
    
    private lazy var persistentContainer: NSPersistentContainer = NSPersistentContainer(name: PersistentContainer.name)
    
    private lazy var viewContext: NSManagedObjectContext = {
        let viewContext = persistentContainer.viewContext
        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        return viewContext
    }()
    
    private lazy var backgroundContext: NSManagedObjectContext = {
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.automaticallyMergesChangesFromParent = true
        backgroundContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        return backgroundContext
    }()
    
    // MARK: - Initialization
    
    init() {
        // loading is synchronius
        load { error in
            error.map { print("Database error: \($0)") }
        }
    }
    
    // MARK: - Functions
    
    func load(_ completion: @escaping (Error?) -> Void) {
        persistentContainer.loadPersistentStores { _, error in
            completion(error)
        }
    }
    
    // MARK: Perform
    
    func perform(_ block: @escaping (NSManagedObjectContext) throws -> Void) {
        performQueue.async { [unowned self] in
            self.backgroundContext.performAndWait {
                do {
                    try block(self.backgroundContext)
                } catch {
                    print("Database perform error: \(error)")
                }
            }
        }
    }
    
    private func performWrite(block: @escaping (NSManagedObjectContext) -> Void) {
        backgroundContext.performAndWait { [backgroundContext] in
            block(backgroundContext)
            
            if backgroundContext.hasChanges {
                do {
                    try backgroundContext.save()
                } catch {
                    print("Database performWrite error: \(error)")
                }
            }
        }
    }
}

extension CoreDataDatabase: DatabaseProvider {
    
    typealias DB = CoreDataDatabase
    
    func perform<Output>(_ action: @escaping (CoreDataDatabase) throws -> Output) async throws -> Output {
        try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self = self else {
                continuation.resume(with: .failure(DatabaseError.dealocated(CoreDataDatabase.self)))
                return
            }
            
            self.perform { moc in
                do {
                    try continuation.resume(with: .success(action(self)))
                } catch {
                    continuation.resume(with: .failure(error))
                }
            }
        }
    }
    
    func erase() async throws {
        
    }
}


extension CoreDataDatabase: Database {
    func fetchOrCreate<T, Key>(_ type: T.Type, forPrimaryKey key: Key?) async throws -> T.ManagedObject where T : Persistable {
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
                    let result = try moc.fetch(ObjectType.fetchRequest())
                    if result.isEmpty {
                        let object = ObjectType.init()
                        moc.insert(object)
                        try moc.save()
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
*/
