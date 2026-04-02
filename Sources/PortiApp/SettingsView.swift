import SwiftUI

struct SettingsView: View {
    @ObservedObject var appState: AppState
    @ObservedObject var appUpdater: AppUpdater

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SettingsSectionCard("Apply Behavior") {
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

                Toggle(
                    "Show notifications",
                    isOn: Binding(
                        get: { appState.showNotifications },
                        set: { appState.setShowNotifications($0) }
                    )
                )

                SettingsCaption("Porti will only ask apps that are not in the target Dock profile to quit normally. Apps can still keep running if you cancel their save prompts.")
            }

            Divider()

            SettingsSectionCard("Focus Mode") {
                Text("Assign Porti profiles from macOS Focus settings to switch Dock layouts automatically.")
                    .font(.body)

                SettingsCaption("Set this up in System Settings > Focus > a Focus mode > Focus Filters > Porti, then choose the Dock profile for that Focus.")

                if let activeFocusProfileName = appState.activeFocusProfileName {
                    SettingsCaption("Current Porti Focus profile: \(activeFocusProfileName)")
                } else {
                    SettingsCaption("No Porti Focus filter is active right now.")
                }

                SettingsCaption("Automatic Focus-driven switching only works while Porti is running. Enable Launch at login if you want it available after sign-in.")
            }

            Divider()

            SettingsSectionCard(
                "Updates",
                headerAccessory: {
                    Button("Check for Updates") {
                        appUpdater.checkForUpdates()
                    }
                    .buttonStyle(.bordered)
                    .disabled(!appUpdater.isConfigured || !appUpdater.canCheckForUpdates)
                }
            ) {
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

            }

            Divider()

            SettingsSectionCard("System") {
                Toggle(
                    "Launch at login",
                    isOn: Binding(
                        get: { appState.launchAtLogin },
                        set: { appState.updateLaunchAtLogin($0) }
                    )
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

private struct SettingsSectionCard<Content: View>: View {
    let title: String
    @ViewBuilder let headerAccessory: () -> AnyView
    @ViewBuilder let content: () -> Content

    init(
        _ title: String,
        @ViewBuilder headerAccessory: @escaping () -> some View = { EmptyView() },
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.headerAccessory = { AnyView(headerAccessory()) }
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 10) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)

                Spacer(minLength: 0)

                headerAccessory()
            }

            VStack(alignment: .leading, spacing: 12) {
                content()
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct SettingsCaption: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
    }
}
