//
//  DateCodable.swift
//  
//
//  Created by Anton Bal` on 09.11.2022.
//

import Foundation

public protocol DateCodable: Codable {
    var value: Date { get }
    static var formatter: CustomDateFormatter? { get }
    func toString() -> String
}
