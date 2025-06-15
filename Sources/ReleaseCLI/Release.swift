//
//  Release.swift
//
//
//  Created by zwc on 2024/9/17.
//

import Foundation
import ArgumentParser
import ReleaseCore
import Extensions

/// A command-line interface for creating or updating a comment on a GitHub issue or pull request.
package struct Release: ParsableCommand {

    /// The GitHub repository owner.
    @Option(name: .shortAndLong, help: "The owner of the GitHub repository.")
    var owner: String = #"environment["OWNER"]"#

    /// The GitHub repository name.
    @Option(name: .shortAndLong, help: "The name of the GitHub repository.")
    var repo: String = #"environment["REPO"]"#

    @Option(name: .shortAndLong, help: "The value of major | minor | patch (default)")
    var type: String = #"environment["TYPE"]"#

    @Option(name: .shortAndLong, help: "Specifies the commitish value that determines where the Git tag is created from. Can be any branch or commit SHA. Unused if the Git tag already exists. Default: the repository's default branch.")
    var ref: String = #"environment["REF"]"#

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

                let type = BumpVersionType(rawValue: ProcessInfo.processInfo.environment["TYPE"] ?? type) ?? .patch
                print("inputs.type: \(type)")

                let ref = ProcessInfo.processInfo.environment["REF"] ?? ref
                print("inputs.ref: \(ref)")

                let token = ProcessInfo.processInfo.environment["TOKEN"] ?? token
                print("inputs.token: \(token)")

                let useCase = try ReposUseCase(
                    token: token,
                    owner: owner,
                    repo: repo
                )
                try await useCase.createRelease(
                    type: type,
                    gitRef: ref)
                print("Release successfully created!")
            } catch {
                Self.exit(withError: error)
            }
        }
    }
}
