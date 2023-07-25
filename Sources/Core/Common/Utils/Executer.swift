//
//  File.swift
//  
//
//  Created by Anton Bal’ on 25.07.2023.
//

import Foundation

public func execute<Success>(
    operation: @escaping @Sendable () async throws -> Success,
    callback: ((Result<Success, Error>) -> Void)? = nil
) {
    
    let semaphore = DispatchSemaphore(value: 0)
    
    Task {
        defer { semaphore.signal() }
        
        do {
            callback?(.success(try await operation()))
        } catch {
            callback?(.failure(error))
        }
    }
    
    semaphore.wait()
}
