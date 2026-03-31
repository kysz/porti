import AppKit
import SwiftUI

@main
struct PortiAppMain: App {
    @StateObject private var appState = AppState()
    @StateObject private var appUpdater = AppUpdater()
    @StateObject private var windowCoordinator = WindowCoordinator()

    var body: some Scene {
        MenuBarExtra("Porti", systemImage: "dock.rectangle") {
            MenuBarContentView(
                appState: appState,
                appUpdater: appUpdater,
                windowCoordinator: windowCoordinator
            )
        }
        .menuBarExtraStyle(.menu)
    }
}
