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
    
    private enum C {
        enum PersistentContainer {
            static let name = "iOS-Module-CoreData"
        }
    }
    
    // MARK: - Properties
    // concurrent queue for execution performAndWait on reading
    private let performQueue = DispatchQueue(label: "Database performQueue", qos: .userInitiated, attributes: .concurrent)
    
    private lazy var persistentContainer = NSPersistentContainer(name: C.PersistentContainer.name)
    
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
    
    // MARK: - Initialization
    
    public init() {
        // loading is synchronius
        load { error in
            error.map { print("Database error: \($0)") }
        }
    }
    
    // MARK: - Functions
    
    public func load(_ completion: @escaping (Error?) -> Void) {
        persistentContainer.loadPersistentStores { _, error in
            completion(error)
        }
    }
    
    // MARK: Perform
    
    public func perform(_ block: @escaping (NSManagedObjectContext) throws -> Void) {
        performQueue.async { [backgroundContext] in
            backgroundContext.performAndWait {
                do {
                    try block(backgroundContext)
                    
                    if backgroundContext.hasChanges {
                        try backgroundContext.save()
                    }
                } catch {
                    print("Database perform error: \(error)")
                }
            }
        }
    }
}

extension CoreDataDatabase: DatabaseProvider {
    
    public typealias DB = CoreDataDatabase
    
    private func performWrite<Output>( _ action: @escaping (DB) async throws -> Output,
                                       result: @escaping (Result<Output, Error>) -> Void) {
        perform { moc in
            let semaphore = DispatchSemaphore(value: 0)
            
            Task { [weak self] in
                defer { semaphore.signal() }
                
                guard let self = self else {
                    result(.failure(DatabaseError.dealocated(CoreDataDatabase.self)))
                    return
                }
                
                do {
                    result(.success(try await action(self)))
                } catch {
                    result(.failure(DatabaseError.underlying(error)))
                }
            }
            
            semaphore.wait()
        }
    }
    
    public func perform<Output>(_ action: @escaping (DB) async throws -> Output) async throws -> Output {
        try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self = self else {
                continuation.resume(with: .failure(DatabaseError.dealocated(CoreDataDatabase.self)))
                return
            }
            
            self.performWrite(action) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    public func erase() async throws {
        
    }
}

extension CoreDataDatabase: Database {
    public func fetchOrCreate<T, Key>(_ type: T.Type, forPrimaryKey key: Key?) async throws -> T.ManagedObject where T : Persistable {
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
                        object.setCustomValue(key, for: "id")
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
