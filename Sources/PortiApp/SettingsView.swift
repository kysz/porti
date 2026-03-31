import SwiftUI

struct SettingsView: View {
    @ObservedObject var appState: AppState

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
        .frame(minWidth: 520, minHeight: 397)
    }
}
