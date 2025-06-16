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
    static func synchronous(priority: TaskPriority? = nil, operation: @escaping @Sendable () async throws -> Success) throws {
        let semaphore = DispatchSemaphore(value: 0)
        var captured: Error?
        Task<Void, Never>(priority: priority) {
            defer { semaphore.signal() }
            do {
                _ = try await operation()
            } catch {
                captured = error
            }
        }
        semaphore.wait()
        if let captured {
            throw captured
        }
    }
}
