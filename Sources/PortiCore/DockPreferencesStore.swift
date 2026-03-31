import Foundation

public enum DockProfileState: Sendable {
    case active
    case custom
}

public struct DockSkippedItem: Sendable {
    public let section: DockSection
    public let label: String?
    public let path: String?
    public let reason: String

    public init(section: DockSection, label: String?, path: String?, reason: String) {
        self.section = section
        self.label = label
        self.path = path
        self.reason = reason
    }
}

public struct DockApplyReport: Sendable {
    public let skippedItems: [DockSkippedItem]

    public init(skippedItems: [DockSkippedItem]) {
        self.skippedItems = skippedItems
    }
}

public struct DockPreferencesStore: Sendable {
    private let runner = ProcessRunner()
    private let domain = "com.apple.dock"

    public init() {}

    public func captureCurrentProfile(named name: String, now: Date = Date()) throws -> DockProfile {
        let domainDictionary = try exportDockDomain()
        return try DockDomainCodec.decode(domain: domainDictionary, name: name, now: now)
    }

    public func inspectCurrentProfile(now: Date = Date()) throws -> DockProfile {
        try captureCurrentProfile(named: "Current Dock", now: now)
    }

    public func apply(profile: DockProfile) throws -> DockApplyReport {
        let domainDictionary = try exportDockDomain()
        let prepared = DockDomainCodec.prepareForApply(profile: profile)
        let updatedDomain = try DockDomainCodec.encode(profile: prepared.profile, onto: domainDictionary)
        try importDockDomain(updatedDomain)
        try restartDock()
        return DockApplyReport(skippedItems: prepared.skippedItems)
    }

    public func state(relativeTo profile: DockProfile) throws -> DockProfileState {
        let current = try inspectCurrentProfile()
        return current.fingerprint == profile.fingerprint ? .active : .custom
    }

    public func addSpacerToCurrentDock(in section: DockSection = .applications) throws {
        let domainDictionary = try exportDockDomain()
        let updatedDomain = try DockDomainCodec.appendingSpacer(to: section, in: domainDictionary)
        try importDockDomain(updatedDomain)
        try restartDock()
    }

    func exportDockDomain() throws -> [String: Any] {
        let data = try runner.run("/usr/bin/defaults", arguments: ["export", domain, "-"])
        let plist = try PropertyListSerialization.propertyList(from: data, format: nil)

        guard let dictionary = plist as? [String: Any] else {
            throw PortiError("Dock preferences export was not a dictionary plist.")
        }

        return dictionary
    }

    private func importDockDomain(_ dictionary: [String: Any]) throws {
        let plistData = try PropertyListSerialization.data(
            fromPropertyList: dictionary,
            format: .xml,
            options: 0
        )

        let tempDirectory = FileManager.default.temporaryDirectory
        let tempFile = tempDirectory.appendingPathComponent("porti-dock-import-\(UUID().uuidString).plist")
        try plistData.write(to: tempFile, options: .atomic)
        defer { try? FileManager.default.removeItem(at: tempFile) }

        _ = try runner.run("/usr/bin/defaults", arguments: ["import", domain, tempFile.path])
    }

    private func restartDock() throws {
        _ = try runner.run("/usr/bin/killall", arguments: ["Dock"])
    }
}

enum DockDomainCodec {
    struct PreparedApply {
        let profile: DockProfile
        let skippedItems: [DockSkippedItem]
    }

    static func decode(domain: [String: Any], name: String, now: Date) throws -> DockProfile {
        let applications = try decodeTiles(
            domain["persistent-apps"] as? [Any] ?? [],
            section: .applications
        )
        let others = try decodeTiles(
            domain["persistent-others"] as? [Any] ?? [],
            section: .others
        )

        return DockProfile(
            name: name,
            createdAt: now,
            updatedAt: now,
            applications: applications,
            others: others
        )
    }

    static func encode(profile: DockProfile, onto domain: [String: Any]) throws -> [String: Any] {
        var copy = domain
        copy["persistent-apps"] = try profile.applications.map { try $0.propertyListRepresentation() }
        copy["persistent-others"] = try profile.others.map { try $0.propertyListRepresentation() }
        return copy
    }

    static func prepareForApply(profile: DockProfile) -> PreparedApply {
        let applications = sanitizeTiles(profile.applications)
        let others = sanitizeTiles(profile.others)

        return PreparedApply(
            profile: DockProfile(
                id: profile.id,
                name: profile.name,
                createdAt: profile.createdAt,
                updatedAt: Date(),
                applications: applications.tiles,
                others: others.tiles
            ),
            skippedItems: applications.skippedItems + others.skippedItems
        )
    }

    static func appendingSpacer(to section: DockSection, in domain: [String: Any]) throws -> [String: Any] {
        var copy = domain
        let key = section == .applications ? "persistent-apps" : "persistent-others"
        let existingTiles = copy[key] as? [Any] ?? []
        let spacer = try DockTile.spacer(section: section).propertyListRepresentation()
        copy[key] = existingTiles + [spacer]
        return copy
    }

    private static func decodeTiles(_ rawTiles: [Any], section: DockSection) throws -> [DockTile] {
        try rawTiles.map { rawTile in
            guard let dictionary = rawTile as? [String: Any] else {
                throw PortiError("Dock tile entry is not a dictionary.")
            }

            let payload = try PropertyListSerialization.data(
                fromPropertyList: dictionary,
                format: .binary,
                options: 0
            )

            let tileType = dictionary["tile-type"] as? String ?? "unknown"
            let tileData = dictionary["tile-data"] as? [String: Any]
            let label = tileData?["file-label"] as? String
            let bundleIdentifier = tileData?["bundle-identifier"] as? String
            let isDockExtra = tileData?["dock-extra"] as? Bool
            let path = parseFilePath(tileData?["file-data"] as? [String: Any])
            let kind = classifyItemKind(section: section, tileType: tileType, path: path)

            return DockTile(
                section: section,
                tileType: tileType,
                kind: kind,
                label: label?.isEmpty == true ? nil : label,
                path: path,
                bundleIdentifier: bundleIdentifier,
                isDockExtra: isDockExtra,
                payload: payload
            )
        }
    }

    private static func parseFilePath(_ fileData: [String: Any]?) -> String? {
        guard let rawValue = fileData?["_CFURLString"] as? String,
              let url = URL(string: rawValue),
              url.isFileURL else {
            return nil
        }

        return url.path(percentEncoded: false)
    }

    private static func classifyItemKind(section: DockSection, tileType: String, path: String?) -> DockItemKind {
        if tileType == "spacer-tile" {
            return .spacer
        }

        guard let path else {
            return .unknown
        }

        let normalizedPath = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))

        if section == .applications || normalizedPath.lowercased().hasSuffix(".app") {
            return .app
        }

        var isDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        if exists {
            return isDirectory.boolValue ? .folder : .file
        }

        return .folder
    }

    private static func sanitizeTiles(_ tiles: [DockTile]) -> (tiles: [DockTile], skippedItems: [DockSkippedItem]) {
        var sanitized: [DockTile] = []
        var skipped: [DockSkippedItem] = []

        for tile in tiles {
            if shouldKeep(tile: tile) {
                sanitized.append(tile)
            } else {
                skipped.append(
                    DockSkippedItem(
                        section: tile.section,
                        label: tile.label,
                        path: tile.path,
                        reason: "Referenced item no longer exists at the saved path."
                    )
                )
            }
        }

        return (sanitized, skipped)
    }

    private static func shouldKeep(tile: DockTile) -> Bool {
        guard tile.kind != .spacer else {
            return true
        }

        guard let path = tile.path else {
            return true
        }

        return FileManager.default.fileExists(atPath: path)
    }
}

public enum PortiTestSupport {
    public static func decodeDockDomain(
        domain: [String: Any],
        name: String,
        now: Date
    ) throws -> DockProfile {
        try DockDomainCodec.decode(domain: domain, name: name, now: now)
    }

    public static func prepareProfileForApply(_ profile: DockProfile) -> DockApplyReport {
        DockApplyReport(skippedItems: DockDomainCodec.prepareForApply(profile: profile).skippedItems)
    }

    public static func appendingSpacer(
        to section: DockSection,
        in domain: [String: Any]
    ) throws -> [String: Any] {
        try DockDomainCodec.appendingSpacer(to: section, in: domain)
    }
}
