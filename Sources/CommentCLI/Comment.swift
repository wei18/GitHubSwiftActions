//
//  Comment.swift
//
//
//  Created by zwc on 2024/9/6.
//

import Foundation
import ArgumentParser
import CommentCore
import Extensions

/// A command-line interface for creating or updating a comment on a GitHub issue or pull request.
package struct Comment: ParsableCommand {

    /// The GitHub repository owner.
    @Option(name: .shortAndLong, help: "The owner of the GitHub repository.")
    var owner: String = #"environment["OWNER"]"#

    /// The GitHub repository name.
    @Option(name: .shortAndLong, help: "The name of the GitHub repository.")
    var repo: String = #"environment["REPO"]"#

    /// The issue or pull request number.
    @Option(name: .shortAndLong, help: "The issue or pull request number.")
    var number: String = #"environment["NUMBER"]"#

    /// The unique anchor to identify the comment.
    @Option(name: .shortAndLong, help: "A unique anchor to identify the comment.")
    var anchor: String = #"environment["ANCHOR"]"#

    /// The body content of the comment.
    @Option(name: .shortAndLong, help: "The body content of the comment.")
    var body: String = #"environment["BODY"]"#

    /// The GitHub API token for authentication.
    @Option(name: .shortAndLong, help: "The GitHub API token to authenticate requests.")
    var token: String = #"environment["TOKEN"]"#

    package init() {}
    /// Runs the command, creating or updating the comment on the GitHub issue or pull request.
    package func run() throws {
        try Task.synchronous {
            do {
                let owner = ProcessInfo.processInfo.environment["OWNER"] ?? owner
                print("inputs.owner: \(owner)")
                let repo = ProcessInfo.processInfo.environment["REPO"] ?? repo
                print("inputs.repo: \(repo)")
                let number = try Int(string: ProcessInfo.processInfo.environment["NUMBER"] ?? number)
                print("inputs.number: \(number)")
                let anchor = ProcessInfo.processInfo.environment["ANCHOR"] ?? anchor
                print("inputs.anchor: \(anchor)")
                let body = ProcessInfo.processInfo.environment["BODY"] ?? body
                print("inputs.body: \(body)")
                let token = ProcessInfo.processInfo.environment["TOKEN"] ?? token
                print("inputs.token: \(token)")

                let useCase = try CommentUseCase(
                    token: token,
                    owner: owner,
                    repo: repo,
                    number: number,
                    anchor: anchor,
                    body: body
                )
                try await useCase.run()
                print("Comment successfully created/updated!")
            } catch {
                Self.exit(withError: error)
            }
        }
    }
}
