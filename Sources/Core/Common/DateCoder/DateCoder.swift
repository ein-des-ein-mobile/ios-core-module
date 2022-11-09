//
//  DateCoder.swift
//  Core
//
//  Created by Anton Bal` on 02.10.2022.
//

import Foundation

open class DateCoder: DateCodable {
    open class var formatter: CustomDateFormatter? { nil }

    public let value: Date

    public init(date: Date) {
        value = date
    }

    public func toString() -> String {
        if let formatter = type(of: self).formatter {
            return formatter.string(from: value)
        } else {
            return value.description
        }
    }

    public required init(from decoder: Decoder) throws {
        let string = try String(from: decoder)

        if let formatter = type(of: self).formatter {
            if let date = formatter.date(from: string) {
                value = date
            } else {
                let context = DecodingError.Context(codingPath: decoder.codingPath,
                                                    debugDescription: """
                    Invalid date format, expected \(String(describing: formatter.dateFormat)), actual \(string)
                    """)
                throw DecodingError.dataCorrupted(context)
            }
        } else {
            value = try Date(from: decoder)
        }
    }

    public func encode(to encoder: Encoder) throws {
        if let formatter = type(of: self).formatter {
            try formatter.string(from: value).encode(to: encoder)
        } else {
            try value.encode(to: encoder)
        }
    }
}
