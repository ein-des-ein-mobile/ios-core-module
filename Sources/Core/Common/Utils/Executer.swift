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

public func execute<Success>(
    operation: @escaping @Sendable () async throws -> Success
) throws -> Success {
    UnsafeTask {
        try await operation()
    }.get()
}

class UnsafeTask<T> {
    let semaphore = DispatchSemaphore(value: 0)
    private var result: T?
    init(block: @escaping () async throws -> T) {
        Task {
            result = try await block()
            semaphore.signal()
        }
    }

    func get() -> T {
        if let result = result { return result }
        semaphore.wait()
        return result!
    }
}
