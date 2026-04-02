import AppKit
import SwiftUI

struct MenuBarContentView: View {
    @ObservedObject var appState: AppState
    @ObservedObject var appUpdater: AppUpdater
    @ObservedObject var preferencesSelection: PreferencesSelection

    var body: some View {
        Group {
            Text("Active: \(appState.activeProfileLabel)")

            if appState.profiles.isEmpty {
                Text("No saved profiles")
            } else {
                ForEach(appState.profiles) { storedProfile in
                    Button {
                        appState.apply(storedProfile)
                    } label: {
                        Label(
                            storedProfile.profile.name,
                            systemImage: storedProfile.profile.name == appState.activeProfileLabel ? "checkmark" : "dock.rectangle"
                        )
                    }

                    if appState.activeProfileLabel == "Custom",
                       appState.lastAppliedProfileName == storedProfile.profile.name {
                        Button {
                            appState.updateLastAppliedProfileFromCurrentDock()
                        } label: {
                            Text("Update \(storedProfile.profile.name)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            .padding(.leading, 14)
                        }
                    }
                }
            }

            Divider()

            Button {
                appState.promptAndSaveCurrentDock()
            } label: {
                Text("Save Current Dock")
            }
            .keyboardShortcut(.defaultAction)

            Button {
                appState.addSpacerToCurrentDock()
            } label: {
                Text("Add Spacer to Dock")
            }

            Button {
                openSettings(tab: .profiles)
            } label: {
                Text("Manage Profiles")
            }

            Divider()

            Button {
                openSettings(tab: .settings)
            } label: {
                Text("Settings")
            }

            Button {
                appUpdater.checkForUpdates()
            } label: {
                Text("Check for Updates")
            }
            .disabled(!appUpdater.isConfigured || !appUpdater.canCheckForUpdates)

            Button {
                openSettings(tab: .about)
            } label: {
                Text("About Porti")
            }

            if let warningMessage = appState.warningMessage {
                Divider()
                Text(warningMessage)
            }

            if let errorMessage = appState.errorMessage {
                Divider()
                Text(errorMessage)
            }

            if appState.warningMessage != nil || appState.errorMessage != nil {
                Button {
                    appState.clearMessages()
                } label: {
                    Text("Clear Messages")
                }
            }

            Divider()

            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Text("Quit Porti")
            }
            .keyboardShortcut("q")
        }
        .onAppear {
            appState.refreshAll()
        }
    }

    private func openSettings(tab: PortiWindowTab) {
        preferencesSelection.tab = tab
        PortiSettingsPresenter.request(tab: tab)
    }
}
