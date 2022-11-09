//
//  DateCoderFormatter.swift
//  Core
//
//  Created by Anton Bal` on 02.10.2022.
//

import Foundation

final class ISO8601DateCoder: DateCoder {
    override class var formatter: CustomDateFormatter? {
        DateFormatter.iso8601
    }
}


final class ISO8601LocalCoder: DateCoder {
    override class var formatter: CustomDateFormatter? {
        DateFormatter.iso8601Local
    }
}

