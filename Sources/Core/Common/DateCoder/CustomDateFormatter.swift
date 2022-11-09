//
//  CustomDateFormatter.swift
//  
//
//  Created by Anton Bal` on 09.11.2022.
//

import Foundation

public protocol CustomDateFormatter {
    func string(from: Date) -> String
    func date(from: String) -> Date?
    var dateFormat: String! { get }
}
