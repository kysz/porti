import Foundation
import ServiceManagement

@MainActor
final class LaunchAtLoginController {
    func currentStatus() -> Bool {
        if #available(macOS 13.0, *) {
            return SMAppService.mainApp.status == .enabled
        }

        return false
    }

    func setEnabled(_ enabled: Bool) throws {
        if #available(macOS 13.0, *) {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            return
        }

        throw PortiAppError("Launch at login requires macOS 13 or newer.")
    }
}
