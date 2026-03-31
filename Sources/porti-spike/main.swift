import Foundation
import PortiCore

enum SpikeCommand: String {
    case inspectCurrent = "inspect-current"
    case capture
    case apply
    case drift
    case help
}

struct SpikeCLI {
    private let dockStore = DockPreferencesStore()
    private let profileStore = ProfileStore()

    func run() throws {
        let args = Array(CommandLine.arguments.dropFirst())
        let command = SpikeCommand(rawValue: args.first ?? "help") ?? .help

        switch command {
        case .inspectCurrent:
            let profile = try dockStore.inspectCurrentProfile()
            try printJSON(profile)
        case .capture:
            let name = try optionValue("--name", in: args) ?? timestampedName()
            let profile = try dockStore.captureCurrentProfile(named: name)
            if let output = try optionValue("--output", in: args) {
                try write(profile: profile, to: output)
                print("Captured current Dock profile to \(output)")
            } else {
                let savedURL = try profileStore.save(profile)
                print("Captured current Dock profile to \(savedURL.path)")
            }
        case .apply:
            let input = try requiredOptionValue("--input", in: args)
            guard args.contains("--force") else {
                throw PortiError("Refusing to modify the Dock without --force.")
            }
            let profile = try loadProfile(from: input)
            let report = try dockStore.apply(profile: profile)
            print("Applied profile \(profile.name)")
            if !report.skippedItems.isEmpty {
                let names = report.skippedItems.map { $0.label ?? $0.path ?? "Unnamed item" }
                print("Skipped missing items: \(names.joined(separator: ", "))")
            }
        case .drift:
            let input = try requiredOptionValue("--input", in: args)
            let profile = try loadProfile(from: input)
            let state = try dockStore.state(relativeTo: profile)
            switch state {
            case .active:
                print("active")
            case .custom:
                print("custom")
            }
        case .help:
            printUsage()
        }
    }

    private func loadProfile(from path: String) throws -> DockProfile {
        try profileStore.load(from: resolvePath(path))
    }

    private func write(profile: DockProfile, to path: String) throws {
        let url = resolvePath(path)
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(profile)
        try data.write(to: url, options: .atomic)
    }

    private func resolvePath(_ path: String) -> URL {
        let expandedPath = (path as NSString).expandingTildeInPath
        if expandedPath.hasPrefix("/") {
            return URL(fileURLWithPath: expandedPath)
        }

        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent(expandedPath)
    }

    private func printJSON(_ profile: DockProfile) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(profile)

        guard let json = String(data: data, encoding: .utf8) else {
            throw PortiError("Unable to encode JSON output.")
        }

        print(json)
    }

    private func optionValue(_ name: String, in args: [String]) throws -> String? {
        guard let index = args.firstIndex(of: name) else {
            return nil
        }
        let next = args.index(after: index)
        guard args.indices.contains(next) else {
            throw PortiError("Missing value for \(name)")
        }
        return args[next]
    }

    private func requiredOptionValue(_ name: String, in args: [String]) throws -> String {
        guard let value = try optionValue(name, in: args) else {
            throw PortiError("Missing required option \(name)")
        }
        return value
    }

    private func timestampedName() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]
        return "Dock \(formatter.string(from: Date()))"
    }

    private func printUsage() {
        let usage = """
        Usage:
          swift run porti-spike inspect-current
          swift run porti-spike capture --name <profile-name> [--output <path>]
          swift run porti-spike drift --input <profile.json>
          swift run porti-spike apply --input <profile.json> --force
        """
        print(usage)
    }
}

do {
    try SpikeCLI().run()
} catch {
    fputs("error: \(error.localizedDescription)\n", stderr)
    exit(1)
}
