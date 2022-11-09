//
//  File.swift
//  
//
//  Created by Anton Bal` on 09.11.2022.
//

import Foundation
import Combine

///
/// Future to Task
///
public extension Future where Failure == Error {
    convenience init(
        operation: @escaping () async throws -> Output) {
            self.init { promise in
                Task {
                    do {
                        let output = try await operation()
                        promise(.success(output))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
}
