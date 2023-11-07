//
//  File.swift
//  
//
//  Created by Anton Bal’ on 07.11.2023.
//

import Foundation

public extension PrimaryKey {
    func toPredicate() -> NSPredicate {
        NSPredicate(format: "\(key) == %@", "\(value)")
    }
}
