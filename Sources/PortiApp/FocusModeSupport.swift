import AppIntents
import Foundation
import PortiCore

struct PortiDockProfileEntity: AppEntity {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Dock Profile"
    static let defaultQuery = PortiDockProfileEntityQuery()

    let id: String
    let name: String

    var displayRepresentation: DisplayRepresentation {
        .init(title: LocalizedStringResource(stringLiteral: name))
    }
}

struct PortiDockProfileEntityQuery: EntityStringQuery {
    func entities(for identifiers: [String]) async throws -> [PortiDockProfileEntity] {
        let identifiersByPriority = Dictionary(uniqueKeysWithValues: identifiers.enumerated().map { ($1, $0) })

        return try loadProfiles()
            .filter { identifiersByPriority[$0.id] != nil }
            .sorted { lhs, rhs in
                identifiersByPriority[lhs.id, default: .max] < identifiersByPriority[rhs.id, default: .max]
            }
    }

    func entities(matching string: String) async throws -> [PortiDockProfileEntity] {
        let query = string.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            return try loadProfiles()
        }

        return try loadProfiles().filter { entity in
            entity.name.localizedCaseInsensitiveContains(query)
        }
    }

    func suggestedEntities() async throws -> [PortiDockProfileEntity] {
        try loadProfiles()
    }

    private func loadProfiles() throws -> [PortiDockProfileEntity] {
        let store = ProfileStore()
        return try store.listProfiles()
            .map { url in
                let profile = try store.load(from: url)
                return PortiDockProfileEntity(id: profile.id.uuidString, name: profile.name)
            }
            .sorted { lhs, rhs in
                lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
            }
    }
}

struct PortiFocusFilterIntent: SetFocusFilterIntent {
    static let title: LocalizedStringResource = "Porti Dock Profile"
    static let description = IntentDescription("Apply a Porti Dock profile while this Focus mode is active.")

    @Parameter(title: "Dock Profile")
    var profile: PortiDockProfileEntity?

    init() {}

    init(profile: PortiDockProfileEntity) {
        self.profile = profile
    }

    var displayRepresentation: DisplayRepresentation {
        .init(title: LocalizedStringResource(stringLiteral: profile?.name ?? "None"))
    }

    static func suggestedFocusFilters(for context: FocusFilterSuggestionContext) async -> [PortiFocusFilterIntent] {
        let query = PortiDockProfileEntityQuery()
        guard let profiles = try? await query.suggestedEntities() else {
            return []
        }

        return profiles.map(PortiFocusFilterIntent.init(profile:))
    }

    func perform() async throws -> some IntentResult {
        .result()
    }
}

struct PortiFocusSelection: Equatable {
    let profileID: String
    let profileName: String
}

enum PortiFocusSelectionResolver {
    static func currentSelection() async -> PortiFocusSelection? {
        do {
            let current = try await PortiFocusFilterIntent.current
            guard let profile = current.profile else {
                return nil
            }

            return PortiFocusSelection(profileID: profile.id, profileName: profile.name)
        } catch {
            return nil
        }
    }
}
