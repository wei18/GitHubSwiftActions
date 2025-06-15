//
//  CommentUseCase.swift
//
//
//  Created by zwc on 2024/9/6.
//

import Foundation
import GitHubRestAPIIssues
import OpenAPIURLSession
import Middleware

/// A struct representing a GitHub issue or pull request comment, which interacts with the GitHub REST API.
package struct CommentUseCase {

    /// The client used to interact with GitHub's REST API for issues.
    private let client: GitHubRestAPIIssues.Client

    /// The owner of the repository.
    let owner: String

    /// The repository name.
    let repo: String

    /// The issue or pull request number.
    /// This can refer to either an issue or a pull request, as GitHub treats them similarly in its API.
    let number: Int

    /// An anchor used within the comment to uniquely identify it.
    /// This anchor is hidden within the body of the comment to allow future updates to the same comment.
    let anchor: String

    /// The body content of the comment.
    let body: String

    /// Initializes a new `CommentUseCase` instance.
    ///
    /// - Parameters:
    ///   - token: The GitHub API token to authenticate requests.
    ///   - owner: The owner of the repository.
    ///   - repo: The name of the repository.
    ///   - number: The issue or pull request number.
    ///   - anchor: A unique anchor used to identify the comment in future interactions.
    ///   - body: The body content of the comment.
    package init(token: String, owner: String, repo: String, number: Int, anchor: String, body: String) throws {
        self.client = Client(
            serverURL: try Servers.Server1.url(),
            transport: URLSessionTransport(),
            middlewares: [AuthenticationMiddleware(token: token)]
        )
        self.owner = owner
        self.repo = repo
        self.number = number
        self.anchor = anchor
        self.body = body
    }

    /// Runs the process of adding or updating a comment in a GitHub issue or pull request.
    ///
    /// This method performs the following steps:
    /// 1. It creates a hidden anchor within the comment body to uniquely identify the comment.
    /// 2. It fetches all existing comments for the given issue or pull request.
    /// 3. If a comment with the same anchor is found, the comment is updated with the new body content.
    /// 4. If no comment with the anchor is found, a new comment is created.
    ///
    /// - Throws: An error if the GitHub API request fails.
    package func run() async throws {
        // Hidden content that allows us to identify the comment later by its anchor.
        let hidingContent = "<!-- Comment anchor: \(anchor) -->"

        // Combine the new body with the hidden anchor content.
        let newBody = "\(hidingContent)\(body)"

        // Fetch all comments for the issue or pull request.
        let comments = try await client.issuesListComments(
            path: .init(owner: owner, repo: repo, issueNumber: number)
        ).ok.body.json

        // Try to find an existing comment with the hidden anchor content.
        if let comment = comments.first(where: { $0.body?.contains(hidingContent) == true }) {
            _ = try await client.issuesUpdateComment(
                path: .init(owner: owner, repo: repo, commentId: Components.Parameters.CommentId(comment.id)),
                body: .json(.init(body: newBody))
            ).ok
            print("Update the existing comment with the new body content.")
        } else {
            _ = try await client.issuesCreateComment(
                path: .init(owner: owner, repo: repo, issueNumber: number),
                body: .json(.init(body: newBody))
            ).created
            print("Create a new comment which no existing comment with the anchor is found.")
        }
    }
}

