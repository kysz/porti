import Foundation

public struct ProfileStore: Sendable {
    public let baseDirectory: URL

    public init(baseDirectory: URL? = nil) {
        if let baseDirectory {
            self.baseDirectory = baseDirectory
        } else {
            let applicationSupport = FileManager.default.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            ).first ?? FileManager.default.homeDirectoryForCurrentUser
            self.baseDirectory = applicationSupport
                .appendingPathComponent("Porti", isDirectory: true)
                .appendingPathComponent("Profiles", isDirectory: true)
        }
    }

    public func save(_ profile: DockProfile) throws -> URL {
        try FileManager.default.createDirectory(
            at: baseDirectory,
            withIntermediateDirectories: true
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        let url = fileURL(for: profile)

        let data = try encoder.encode(profile)
        try data.write(to: url, options: .atomic)
        return url
    }

    public func load(from url: URL) throws -> DockProfile {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(DockProfile.self, from: data)
    }

    public func listProfiles() throws -> [URL] {
        guard FileManager.default.fileExists(atPath: baseDirectory.path) else {
            return []
        }

        return try FileManager.default.contentsOfDirectory(
            at: baseDirectory,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: [.skipsHiddenFiles]
        )
        .filter { $0.pathExtension == "json" }
        .sorted { $0.lastPathComponent < $1.lastPathComponent }
    }

    public func deleteProfile(at url: URL) throws {
        try FileManager.default.removeItem(at: url)
    }

    public func renameProfile(at url: URL, to newName: String) throws -> URL {
        var profile = try load(from: url)
        profile = DockProfile(
            id: profile.id,
            name: newName,
            createdAt: profile.createdAt,
            updatedAt: Date(),
            applications: profile.applications,
            others: profile.others
        )

        let newURL = fileURL(for: profile)
        let data = try encoded(profile)
        try data.write(to: newURL, options: .atomic)

        if newURL != url {
            try deleteProfile(at: url)
        }

        return newURL
    }

    public func duplicateProfile(at url: URL) throws -> URL {
        let profile = try load(from: url)
        let duplicated = DockProfile(
            name: "\(profile.name) Copy",
            applications: profile.applications,
            others: profile.others
        )
        return try save(duplicated)
    }

    public func overwriteProfile(at url: URL, with profile: DockProfile) throws -> URL {
        let existing = try load(from: url)
        let updated = DockProfile(
            id: existing.id,
            name: existing.name,
            createdAt: existing.createdAt,
            updatedAt: Date(),
            applications: profile.applications,
            others: profile.others
        )

        let data = try encoded(updated)
        try data.write(to: url, options: .atomic)
        return url
    }

    public func fileURL(for profile: DockProfile) -> URL {
        let slug = profile.name
            .lowercased()
            .replacingOccurrences(of: "[^a-z0-9]+", with: "-", options: .regularExpression)
            .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
        let filename = slug.isEmpty ? profile.id.uuidString : "\(slug)-\(profile.id.uuidString)"
        return baseDirectory.appendingPathComponent(filename).appendingPathExtension("json")
    }

    private func encoded(_ profile: DockProfile) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(profile)
    }
}
