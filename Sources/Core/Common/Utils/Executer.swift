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
   let value = UnsafeTask {
       try await operation()
    }.get()
    
    callback?(value)
}

public func execute<Success>(
    operation: @escaping @Sendable () async throws -> Success
) throws -> Success {
    let result = UnsafeTask {
        try await operation()
     }.get()
    
    switch result {
    case .success(let success):
        return success
    case .failure(let failure):
        throw failure
    }
}

class UnsafeTask<T> {
    let semaphore = DispatchSemaphore(value: 0)
    private var result: Result<T, Error>?
    init(block: @escaping () async throws -> T) {
        Task {
            do {
                result = Result<T, Error>.success(try await block())
            } catch {
                result = Result.failure(error)
            }
            semaphore.signal()
        }
    }

    func get() -> Result<T, Error> {
        if let result = result { return result }
        semaphore.wait()
        return result!
    }
}
