//
//  File.swift
//  
//
//  Created by Anton Bal` on 09.11.2022.
//

import Foundation
import Combine

public extension Publisher {
    func eraseError() -> Publishers.MapError<Self, Error> {
        mapError { $0 as Error }
    }
}

public extension Publisher {
    func mapToVoid() -> Publishers.Map<Self, Void> {
        map { _ in () }
    }
}
