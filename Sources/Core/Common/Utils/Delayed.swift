//
//  Delayed.swift
//
//  Created by Anton Bal` on 19.11.2022.
//

import Foundation

public func delayed<T>(_ seconds: Double = 0.3, _ builder: () throws -> T) async throws -> T  {
    try await Task.sleep(nanoseconds: UInt64(seconds * Double(NSEC_PER_SEC)))
    return try builder()
}

