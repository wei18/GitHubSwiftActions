//
//  CLIYamlBuilder.swift
//
//
//  Created by zwc on 2024/9/6.
//

import Foundation
import Yams
import ArgumentParser

/// A generic builder class for generating a GitHub Composite Action YAML file for any ParsableCommand.
struct CLIYamlBuilder {

    /// Generates the YAML content for the GitHub Composite Action based on a ParsableCommand.
    ///
    /// - Parameters:
    ///   - command: The ParsableCommand type to inspect.
    ///   - description: A short description of the action.
    /// - Returns: A string containing the generated YAML.
    func build<T: ParsableCommand>(command: T.Type, description: String) throws -> String {
        // Reflect on the command's properties
        let mirror = Mirror(reflecting: command.init())

        // Extract the properties and types to create input descriptions for the YAML
        var inputs: [String: Any] = [:]
        for child in mirror.children {
            guard let label = child.label?.replacingOccurrences(of: "_", with: "") else { continue }
            inputs[label] = [
                "description": "The \(label) for the command.",
                "required": true
            ]
        }

        let factory = SetUpActionFactory()
        inputs.merge(factory.buildInputs()) { _, new in new }

        var envDict = inputs.keys.reduce(into: [String: String]()) { partialResult, value in
            partialResult[value.uppercased()] = "${{ inputs.\(value) }}"
        }
        // mise queries the GitHub releases API to resolve the artifact bundle;
        // unauthenticated requests hit rate limits on shared runner IPs.
        envDict["GITHUB_TOKEN"] = "${{ inputs.token }}"
        // The mise spm backend is gated behind the experimental flag.
        envDict["MISE_EXPERIMENTAL"] = "1"

        let name = String(describing: command)
        let repo = SwiftPackageConfig.current.repo

        // Define the structure of the composite action
        let action: [String: Any] = [
            "name": name,
            "description": description,
            "inputs": inputs,
            "runs": [
                "using": "composite",
                "steps": factory.buildSteps() +
                [
                    [
                        "name": "Run \(name)",
                        "run": "mise x \"spm:\(repo)@${{ inputs.action_ref }}\" -- \(name)",
                        "env": envDict,
                        "shell": "bash",
                    ],
                ]
            ],
        ]

        // Convert the dictionary to a YAML string using Yams
        return try Yams.dump(object: action, width: -1, sortKeys: true)
    }
}

private struct SetUpActionFactory {

    /// Workaround: https://github.com/actions/runner/issues/2473#issuecomment-1776051383/
    func buildInputs() -> [String: Any] {
        return [
            "action_ref": [
                "default": "${{ github.action_ref }}"
            ]
        ]
    }

    func buildSteps() -> [[String: Any]] {
        // The spm backend only needs `swift -print-target-info` to match the
        // artifact bundle triple; GitHub-hosted runners ship with Swift, so no
        // toolchain install step is required.
        let action: [[String: Any]] = [
            [
                "name": "Setup Mise",
                "uses": "jdx/mise-action@v2",
            ],
        ]
        return action
    }

}
