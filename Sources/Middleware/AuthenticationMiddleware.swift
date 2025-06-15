//
//  AuthenticationMiddleware.swift
//
//
//  Created by zwc on 2024/9/6.
//

import OpenAPIRuntime
import HTTPTypes
import Foundation

/// Injects an authorization header to every request.
package struct AuthenticationMiddleware: ClientMiddleware {

    private let token: String

    package init(token: String) {
        self.token = token
    }

    package func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var request = request
        request.headerFields.append(HTTPField(name: .authorization, value: "Bearer \(token)"))
        return try await next(request, body, baseURL)
    }

}
