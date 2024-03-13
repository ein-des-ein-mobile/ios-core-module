//
//  DateCoderFormatter.swift
//  Core
//
//  Created by Anton Bal` on 02.10.2022.
//

import Foundation

public final class ISO8601DateCoder: DateCoder {
    public override class var formatter: CustomDateFormatter? {
        DateFormatter.iso8601
    }
}


public final class ISO8601LocalCoder: DateCoder {
    public override class var formatter: CustomDateFormatter? {
        DateFormatter.iso8601Local
    }
}

