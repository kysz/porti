import Foundation
@preconcurrency import UserNotifications

@MainActor
final class NotificationController {
    func send(title: String, body: String) {
        guard canUseNotifications else {
            return
        }

        Task {
            let center = UNUserNotificationCenter.current()
            let granted = await ensureAuthorization()
            guard granted else {
                return
            }

            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = nil

            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: nil
            )

            try? await center.add(request)
        }
    }

    private func ensureAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined:
            return (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
        case .denied:
            return false
        @unknown default:
            return false
        }
    }

    private var canUseNotifications: Bool {
        Bundle.main.bundleURL.pathExtension == "app"
    }
}
