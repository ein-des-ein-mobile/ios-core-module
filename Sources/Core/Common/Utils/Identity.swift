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
