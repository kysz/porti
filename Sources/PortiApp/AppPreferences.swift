import Foundation

struct AppPreferences {
    var confirmBeforeApply: Bool
    var quitOtherApplicationsOnApply: Bool
    var showNotifications: Bool
    var launchAtLogin: Bool

    static let `default` = AppPreferences(
        confirmBeforeApply: false,
        quitOtherApplicationsOnApply: false,
        showNotifications: true,
        launchAtLogin: false
    )
}
