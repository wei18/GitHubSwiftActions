//
//  Test.swift
//  GitHubSwiftActions
//
//  Created by zwc on 2025/6/15.
//

import Foundation
import Testing
import ReleaseCore

@Suite struct Test {

    let owner = "wei18"
    let repo = "GitHubSwiftActions"
    let type: BumpVersionType = .patch
    let ref = "main"

    @Test func runReleaseCore() async throws {
        let token = try #require(ProcessInfo.processInfo.environment["GITHUB_TOKEN"])
        let useCase = try ReposUseCase(
            token: token,
            owner: owner,
            repo: repo
        )
        try await useCase.createRelease(
            type: type,
            gitRef: ref)
        print("Release successfully created!")
    }

}
