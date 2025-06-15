//
//  ReposUseCase.swift
//
//
//  Created by zwc on 2024/9/17.
//

import Foundation
import GitHubRestAPIRepos
import OpenAPIURLSession
import Middleware
import Extensions

package struct ReposUseCase {

    /// The client used to interact with GitHub's REST API for issues.
    private let client: GitHubRestAPIRepos.Client

    /// The owner of the repository.
    let owner: String

    /// The repository name.
    let repo: String

    /// Initializes a new `CommentUseCase` instance.
    ///
    /// - Parameters:
    ///   - token: The GitHub API token to authenticate requests.
    ///   - owner: The owner of the repository.
    ///   - repo: The name of the repository.
    package init(token: String, owner: String, repo: String) throws {
        self.client = Client(
            serverURL: try Servers.Server1.url(),
            transport: URLSessionTransport(),
            middlewares: [AuthenticationMiddleware(token: token)]
        )
        self.owner = owner
        self.repo = repo
    }

    package func createRelease(type: BumpVersionType, gitRef: String) async throws {
        let tag = try await client.reposListReleases(
            path: .init(owner: owner, repo: repo)
        ).ok.body.json.first?.tagName ?? "0.0.0"
        print("Get current tag(\(tag)) from reposListReleases")

        var version = try Version(tag)
        version.bump(type: type)

        print("Will create tag(\(version)).")
        _ = try await client.reposCreateRelease(
            path: .init(owner: owner, repo: repo),
            body: .json(
                .init(
                    tagName: version.string,
                    targetCommitish: gitRef,
                    generateReleaseNotes: true
                )
            )
        ).created
    }
}
