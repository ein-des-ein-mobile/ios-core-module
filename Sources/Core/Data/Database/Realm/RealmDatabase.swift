//
//  RealmDatabase.swift
//
//  Created by Anton Bal` on 30.09.2022.
//

///
/// [WIP]
///
/// Realm data base example
/// not ready
///

/*
import Foundation
import RealmSwift
import Core

extension Realm: Database {
    
    public func fetchOrCreate<T, Key>(_ type: T.Type, forPrimaryKey key: Key?) throws -> T.ManagedObject where T : Persistable {
        guard let RealmObject = type.ManagedObject as? Object.Type else {
            throw DatabaseError.typeCasting(type)
        }
        
        guard let primaryKey = RealmObject.primaryKey(), let key = key else {
            return RealmObject.init() as! T.ManagedObject
        }
        
        return create(RealmObject, value: [primaryKey: key], update: .all) as! T.ManagedObject
    }
    
    public func createOrUpdate<T: Persistable>(from object: T, context: T.Context) throws -> T.ManagedObject
    {
        let managedObject = try fetchOrCreate(T.self, forPrimaryKey: object.primaryKey)
        try object.update(managedObject, context: context)
        return managedObject
    }
}


final class RealmDatabase: DatabaseProvider {
    
    typealias DB = Realm
    
    private let queue = DispatchQueue(label: "com.Custom.RealmDatabase.Queue",
                                      qos: .default)
    
    init() {
        Realm.Configuration.defaultConfiguration = Realm.Configuration(
            schemaVersion: 1,
            deleteRealmIfMigrationNeeded: true
        )
    }
    
    func perform<Output>(_ action: @escaping (RealmSwift.Realm) throws -> Output) async throws -> Output {
        try await withCheckedThrowingContinuation { [weak self]  continuation in
            self?.performWrite(action) {
                continuation.resume(with: $0)
            }
        }
    }
    
    func erase() async throws  {
        try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.performWrite({
                $0.deleteAll()
            }){
                continuation.resume(with: $0)
            }
            
        }
    }
    
    private func performWrite<Output>( _ action: @escaping (DB) throws -> Output,
                                       result: @escaping (Result<Output, Error>) -> Void) {
        queue.async {
            do {
                let realm = try Realm()
                let wasInWriteTransaction = realm.isInWriteTransaction
                if !wasInWriteTransaction {
                    realm.beginWrite()
                }
                let output = try action(realm)
                if !wasInWriteTransaction {
                    try realm.commitWrite()
                }
                result(.success(output))
            } catch {
                result(.failure(error))
            }
        }
    }
}

// MARK: - Realm Persistable Mappers

extension Persistable {
    func persist<D>(to database: D) async throws -> ManagedObject
    where D: DatabaseProvider,
          ManagedObject: RealmSwift.Object,
          Context == Void {
              try await database.persist(self)
          }
    
}

extension PersistableCollection {
    func persist<D>(to database: D) async throws -> [Item.ManagedObject]
    where D: DatabaseProvider,
          Item.ManagedObject: RealmSwift.Object,
          Item.Context == Void
    {
        try await database.persist(self)
    }
}

extension RealmSwift.Object {
    func tryMap<T, D>(to type: T.Type, database: D) async throws -> T?
    where D: DatabaseProvider,
          T: DatabaseRepresentable,
          T.ManagedObject: RealmSwift.Object,
          T.Context == Void
    {
        try await database.perform { [unowned self] _ -> T? in
            guard !self.isInvalidated else {
                return nil
            }
            return try T(self as! T.ManagedObject)
        }
    }
}

extension Array where Element: RealmSwift.Object {
    func tryMap<T, D>(to type: T.Type, database: D) async throws -> [T]
    where D: DatabaseProvider,
          T: DatabaseRepresentable,
          T.ManagedObject: RealmSwift.Object,
          T.Context == Void
    {
        try await database.perform { _ -> [T] in
            try self.compactMap {
                guard !$0.isInvalidated else {
                    return nil
                }
                return try T($0 as! T.ManagedObject)
            }
        }
    }
}
 */
