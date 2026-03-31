import AppKit
import SwiftUI

@MainActor
final class WindowCoordinator: NSObject, ObservableObject, NSWindowDelegate {
    private var manageProfilesWindow: NSWindow?
    private var settingsWindow: NSWindow?

    func showManageProfiles(appState: AppState) {
        let window = manageProfilesWindow ?? makeManageProfilesWindow(appState: appState)
        manageProfilesWindow = window
        present(window: window)
    }

    func showSettings(appState: AppState, appUpdater: AppUpdater) {
        let window = settingsWindow ?? makeSettingsWindow(appState: appState, appUpdater: appUpdater)
        settingsWindow = window
        present(window: window)
    }

    func windowWillClose(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else {
            return
        }

        if window == manageProfilesWindow {
            manageProfilesWindow = nil
        } else if window == settingsWindow {
            settingsWindow = nil
        }

        if manageProfilesWindow == nil && settingsWindow == nil {
            NSApplication.shared.setActivationPolicy(.accessory)
        }
    }

    private func makeManageProfilesWindow(appState: AppState) -> NSWindow {
        let window = makeWindow(
            title: "Manage Profiles",
            identifier: "manage-profiles",
            frame: NSRect(x: 0, y: 0, width: 720, height: 420),
            isResizable: true,
            rootView: ProfileManagerView(appState: appState)
        )
        manageProfilesWindow = window
        return window
    }

    private func makeSettingsWindow(appState: AppState, appUpdater: AppUpdater) -> NSWindow {
        let window = makeWindow(
            title: "Settings",
            identifier: "settings",
            frame: NSRect(x: 0, y: 0, width: 520, height: 470),
            isResizable: false,
            rootView: SettingsView(appState: appState, appUpdater: appUpdater)
        )
        window.contentMinSize = NSSize(width: 520, height: 470)
        settingsWindow = window
        return window
    }

    private func makeWindow<Content: View>(
        title: String,
        identifier: String,
        frame: NSRect,
        isResizable: Bool,
        rootView: Content
    ) -> NSWindow {
        var styleMask: NSWindow.StyleMask = [.titled, .closable, .miniaturizable]
        if isResizable {
            styleMask.insert(.resizable)
        }

        let window = NSWindow(
            contentRect: frame,
            styleMask: styleMask,
            backing: .buffered,
            defer: false
        )
        window.identifier = NSUserInterfaceItemIdentifier(identifier)
        window.title = title
        window.center()
        window.isReleasedWhenClosed = false
        window.tabbingMode = .disallowed
        window.delegate = self
        window.contentViewController = NSHostingController(rootView: rootView)
        return window
    }

    private func present(window: NSWindow) {
        NSApplication.shared.setActivationPolicy(.regular)
        NSApplication.shared.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()
    }
}
