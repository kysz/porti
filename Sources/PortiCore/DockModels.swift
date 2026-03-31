import Foundation

public enum DockSection: String, Codable, Sendable {
    case applications
    case others
}

public enum DockItemKind: String, Codable, Sendable {
    case app
    case folder
    case file
    case spacer
    case unknown
}

public struct DockTile: Codable, Sendable, Identifiable {
    public let id: UUID
    public let section: DockSection
    public let tileType: String
    public let kind: DockItemKind
    public let label: String?
    public let path: String?
    public let bundleIdentifier: String?
    public let isDockExtra: Bool?
    public let payload: Data

    public init(
        id: UUID = UUID(),
        section: DockSection,
        tileType: String,
        kind: DockItemKind,
        label: String?,
        path: String?,
        bundleIdentifier: String?,
        isDockExtra: Bool?,
        payload: Data
    ) {
        self.id = id
        self.section = section
        self.tileType = tileType
        self.kind = kind
        self.label = label
        self.path = path
        self.bundleIdentifier = bundleIdentifier
        self.isDockExtra = isDockExtra
        self.payload = payload
    }

    public static func spacer(section: DockSection) throws -> DockTile {
        let rawTile: [String: Any] = [
            "tile-type": "spacer-tile",
            "tile-data": [
                "file-label": "",
            ],
        ]

        return DockTile(
            section: section,
            tileType: "spacer-tile",
            kind: .spacer,
            label: nil,
            path: nil,
            bundleIdentifier: nil,
            isDockExtra: nil,
            payload: try PropertyListSerialization.data(
                fromPropertyList: rawTile,
                format: .binary,
                options: 0
            )
        )
    }

    public var fingerprint: DockTileFingerprint {
        let normalizedPath = path.map {
            URL(fileURLWithPath: $0).resolvingSymlinksInPath().path.lowercased()
        }

        return DockTileFingerprint(
            section: section,
            tileType: tileType,
            kind: kind,
            normalizedPath: normalizedPath,
            bundleIdentifier: bundleIdentifier?.lowercased(),
            label: label?.lowercased()
        )
    }

    public func propertyListRepresentation() throws -> [String: Any] {
        let plist = try PropertyListSerialization.propertyList(from: payload, format: nil)

        guard let dictionary = plist as? [String: Any] else {
            throw PortiError("Dock tile payload is not a dictionary plist.")
        }

        return dictionary
    }
}

public struct DockTileFingerprint: Equatable, Sendable {
    public let section: DockSection
    public let tileType: String
    public let kind: DockItemKind
    public let normalizedPath: String?
    public let bundleIdentifier: String?
    public let label: String?
}

public struct DockProfile: Codable, Sendable, Identifiable {
    public let id: UUID
    public let name: String
    public let createdAt: Date
    public let updatedAt: Date
    public let applications: [DockTile]
    public let others: [DockTile]

    public init(
        id: UUID = UUID(),
        name: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        applications: [DockTile],
        others: [DockTile]
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.applications = applications
        self.others = others
    }

    public var fingerprint: DockProfileFingerprint {
        DockProfileFingerprint(
            applications: applications.map(\.fingerprint),
            others: others.map(\.fingerprint)
        )
    }
}

public struct DockProfileFingerprint: Equatable, Sendable {
    public let applications: [DockTileFingerprint]
    public let others: [DockTileFingerprint]
}
