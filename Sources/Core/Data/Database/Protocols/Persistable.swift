//
//  Persistable.swift
//

import Foundation

public protocol Persistable {
    associatedtype ManagedObject
    associatedtype Context
    var primaryKey: Any { get }
    func update(_ object: ManagedObject, context: Context) throws
}

public extension Persistable
    where
    Self: Identifiable
{
    var primaryKey: Any { return id }
}

public extension Persistable where Context == Void {
    func update(_ object: ManagedObject) throws {
        try update(object, context: ())
    }
}

public protocol PersistableCollection {
    associatedtype Item: Persistable
    var items: [Item] { get }
}

extension Array: PersistableCollection where Element: Persistable {
    public typealias Item = Element
    public var items: [Item] { return self }
}
