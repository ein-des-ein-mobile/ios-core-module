//
//  DatabaseRepresentable.swift
//  Memodo
//
//  Created by Ihor Teltov on 10/1/18.
//  Copyright © 2018 Cleveroad Inc. All rights reserved.
//

import Foundation

public protocol DatabaseRepresentable {
    associatedtype ManagedObject
    associatedtype Context

    init(_ object: ManagedObject, context: Context) throws
}

public extension DatabaseRepresentable where Context == Void {
    init(_ object: ManagedObject) throws {
        try self.init(object, context: ())
    }
}
