import AppKit
import Combine
import Foundation
import Sparkle

@MainActor
final class AppUpdater: NSObject, ObservableObject, SPUUpdaterDelegate {
    @Published private(set) var isConfigured = false
    @Published private(set) var canCheckForUpdates = false
    @Published private(set) var automaticallyChecksForUpdates = false
    @Published private(set) var automaticallyDownloadsUpdates = false
    @Published private(set) var configurationIssue: String?

    private var updaterController: SPUStandardUpdaterController?

    override init() {
        super.init()

        let configuration = UpdaterBundleConfiguration(bundle: .main)
        guard configuration.isReady else {
            configurationIssue = configuration.missingKeysMessage
            return
        }

        let controller = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: self,
            userDriverDelegate: nil
        )
        updaterController = controller
        isConfigured = true
        canCheckForUpdates = true
        refreshPublishedState(from: controller.updater)
    }

    var updater: SPUUpdater? {
        updaterController?.updater
    }

    func checkForUpdates() {
        updaterController?.checkForUpdates(nil)
    }

    func setAutomaticallyChecksForUpdates(_ enabled: Bool) {
        guard let updater else {
            return
        }
        updater.automaticallyChecksForUpdates = enabled
        refreshPublishedState(from: updater)
    }

    func setAutomaticallyDownloadsUpdates(_ enabled: Bool) {
        guard let updater else {
            return
        }
        updater.automaticallyDownloadsUpdates = enabled
        refreshPublishedState(from: updater)
    }

    func feedURLString(for updater: SPUUpdater) -> String? {
        Bundle.main.object(forInfoDictionaryKey: UpdaterBundleConfiguration.feedURLKey) as? String
    }

    private func refreshPublishedState(from updater: SPUUpdater) {
        automaticallyChecksForUpdates = updater.automaticallyChecksForUpdates
        automaticallyDownloadsUpdates = updater.automaticallyDownloadsUpdates
    }
}

private struct UpdaterBundleConfiguration {
    static let feedURLKey = "SUFeedURL"
    static let publicEDKey = "SUPublicEDKey"

    let feedURL: String?
    let publicKey: String?

    init(bundle: Bundle) {
        feedURL = bundle.object(forInfoDictionaryKey: Self.feedURLKey) as? String
        publicKey = bundle.object(forInfoDictionaryKey: Self.publicEDKey) as? String
    }

    var isReady: Bool {
        [feedURL, publicKey].allSatisfy { value in
            !(value?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        }
    }

    var missingKeysMessage: String {
        var missing: [String] = []
        if feedURL?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true {
            missing.append(Self.feedURLKey)
        }
        if publicKey?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true {
            missing.append(Self.publicEDKey)
        }

        if missing.isEmpty {
            return "Sparkle updater configuration is missing."
        }

        return "Auto-update is unavailable in this build. Missing bundle keys: \(missing.joined(separator: ", "))."
    }
}
