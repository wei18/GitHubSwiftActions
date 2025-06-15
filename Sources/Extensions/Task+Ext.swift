//
//  Task+Ext.swift
//  
//
//  Created by zwc on 2024/9/6.
//

import Foundation

package extension Task where Failure == Error {
    /// Performs an async task in a sync context and returns the result.
    ///
    /// - Warning: This blocks the current thread. Avoid calling this on the main thread.
    @discardableResult
    static func synchronous(priority: TaskPriority? = nil, operation: @escaping @Sendable () async throws -> Success) throws -> Success {
        let semaphore = DispatchSemaphore(value: 0)
        var result: Result<Success, Error>!

        Task<Void, Never>(priority: priority) {
            defer { semaphore.signal() }
            do {
                let value = try await operation()
                result = .success(value)
            } catch {
                result = .failure(error)
            }
        }

        semaphore.wait()
        return try result.get()
    }
}
