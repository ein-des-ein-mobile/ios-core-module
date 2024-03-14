//
//  DateFormatter.swift
//  Core
//
//  Created by Anton Bal` on 02.10.2022.
//

import Foundation

extension DateFormatter {
    public static var iso8601: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }

    public static var iso8601Local: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.formatOptions = [.withYear, .withMonth, .withDay, .withTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
        return formatter
    }
}

extension DateFormatter: CustomDateFormatter { }
extension ISO8601DateFormatter: CustomDateFormatter {
    public var dateFormat: String! {
        "ISO8601DateFormatter"
    }
}
