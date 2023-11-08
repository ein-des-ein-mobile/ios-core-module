//
//  Identity.swift
//
//  Created by Anton Bal` on 11.11.2022.
//

import Foundation

/**
 Use this protocol to give your Model typesafe identifier
 
 Example:

     struct User: Identifiable {
 
        struct ID: Identity {
            let value: String
        }
 
        let id: ID
        let name: String
     }
 
 - Tag: Identity
 */

public protocol Identity: Hashable, Codable {
    associatedtype Value: Hashable, Codable
    
    var value: Value { get }
    
    init(value: Value)
}

// MARK: - Basic Typed Identity

public struct String_ID<T>: Equatable, Identity {
    public let value: String
    public init(value: String) {
        self.value = value
    }
}

public struct Int_ID<T>: Equatable, Identity {
    public let value: Int
    public init(value: Int) {
        self.value = value
    }
}

public struct Int64_ID<T>: Equatable, Identity {
    public let value: Int64
    public init(value: Int64) {
        self.value = value
    }
}

public struct UUID_ID<T>: Equatable, Identity {
    public let value: UUID
    public init(value: UUID) {
        self.value = value
    }
}
