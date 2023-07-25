//
//  PrimaryKey.swift
//  
//
//  Created by Anton Bal’ on 25.07.2023.
//

import Foundation

public protocol PrimaryKey {
    var key: String { get }
    var value: Any { get }
}

public struct IDPrimaryKey: PrimaryKey {
    public var key: String { "id" }
    public var value: Any { id.value }
    public let id: any Identity
    
    public init(id: any Identity) {
        self.id = id
    }
}
