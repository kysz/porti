import AppKit
import Foundation

@MainActor
enum AppMetadata {
    static let fallbackShortVersion = "0.1.2"
    static let fallbackBuildVersion = "0001002"
    static let repositoryURL = URL(string: "https://github.com/krisphere/porti")!

    static var shortVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? fallbackShortVersion
    }

    static var buildVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? fallbackBuildVersion
    }

    static var bundledIconImage: NSImage? {
        guard let url = Bundle.module.url(forResource: "porti", withExtension: "png") else {
            return nil
        }
        return NSImage(contentsOf: url)
    }

    static var applicationIconImage: NSImage {
        if let appIcon = NSApp.applicationIconImage, appIcon.size.width > 0, appIcon.size.height > 0 {
            return appIcon
        }

        if let bundledIconImage {
            return bundledIconImage
        }

        return NSImage(size: NSSize(width: 128, height: 128))
    }
}
