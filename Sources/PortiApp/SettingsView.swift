import SwiftUI

struct SettingsView: View {
    @ObservedObject var appState: AppState
    @ObservedObject var appUpdater: AppUpdater

    var body: some View {
        Form {
            Section("Apply Behavior") {
                Toggle(
                    "Confirm before applying a profile",
                    isOn: Binding(
                        get: { appState.confirmBeforeApply },
                        set: { appState.setConfirmBeforeApply($0) }
                    )
                )
                Toggle(
                    "Quit other applications when switching docks",
                    isOn: Binding(
                        get: { appState.quitOtherApplicationsOnApply },
                        set: { appState.setQuitOtherApplicationsOnApply($0) }
                    )
                )
                Text("Porti will only ask apps that are not in the target Dock profile to quit normally. Apps can still keep running if you cancel their save prompts.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Toggle(
                    "Show notifications",
                    isOn: Binding(
                        get: { appState.showNotifications },
                        set: { appState.setShowNotifications($0) }
                    )
                )
            }

            Section("Updates") {
                Toggle(
                    "Automatically check for updates",
                    isOn: Binding(
                        get: { appUpdater.automaticallyChecksForUpdates },
                        set: { appUpdater.setAutomaticallyChecksForUpdates($0) }
                    )
                )
                .disabled(!appUpdater.isConfigured)

                Toggle(
                    "Automatically download updates",
                    isOn: Binding(
                        get: { appUpdater.automaticallyDownloadsUpdates },
                        set: { appUpdater.setAutomaticallyDownloadsUpdates($0) }
                    )
                )
                .disabled(!appUpdater.isConfigured || !appUpdater.automaticallyChecksForUpdates)

                if let configurationIssue = appUpdater.configurationIssue {
                    Text(configurationIssue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Sparkle stores these updater preferences in the app’s defaults. Install Porti from an app bundle in Applications for the smoothest update flow.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section("System") {
                Toggle(
                    "Launch at login",
                    isOn: Binding(
                        get: { appState.launchAtLogin },
                        set: { appState.updateLaunchAtLogin($0) }
                    )
                )

                Text("Launch at login may fail for ad hoc or development builds that are not installed as a normal app bundle.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .padding(16)
        .frame(minWidth: 520, minHeight: 470)
    }
}
