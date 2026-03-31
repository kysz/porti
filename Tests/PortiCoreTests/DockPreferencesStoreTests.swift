import XCTest
@testable import PortiCore

final class DockPreferencesStoreTests: XCTestCase {
    func testDecodesApplicationsAndSpacersFromDockDomain() throws {
        let domain: [String: Any] = [
            "persistent-apps": [
                [
                    "tile-type": "file-tile",
                    "tile-data": [
                        "file-label": "Safari",
                        "bundle-identifier": "com.apple.Safari",
                        "file-data": [
                            "_CFURLString": "file:///Applications/Safari.app/",
                            "_CFURLStringType": 15,
                        ],
                    ],
                ],
                [
                    "tile-type": "spacer-tile",
                    "tile-data": [
                        "file-label": "",
                    ],
                ],
            ],
            "persistent-others": [
                [
                    "tile-type": "directory-tile",
                    "tile-data": [
                        "file-label": "Downloads",
                        "file-data": [
                            "_CFURLString": "file:///Users/test/Downloads/",
                            "_CFURLStringType": 15,
                        ],
                    ],
                ],
            ],
        ]

        let profile = try PortiTestSupport.decodeDockDomain(
            domain: domain,
            name: "Work",
            now: Date(timeIntervalSince1970: 0)
        )

        XCTAssertEqual(profile.applications.count, 2)
        XCTAssertEqual(profile.others.count, 1)
        XCTAssertEqual(profile.applications[0].kind, .app)
        XCTAssertEqual(profile.applications[0].path, "/Applications/Safari.app/")
        XCTAssertEqual(profile.applications[1].kind, .spacer)
        XCTAssertEqual(profile.others[0].kind, .folder)
    }

    func testProfileFingerprintIgnoresOpaquePayloadDifferences() throws {
        let tileA = try DockTile.spacer(section: .applications)
        let tileB = try DockTile.spacer(section: .applications)

        let profileA = DockProfile(name: "A", applications: [tileA], others: [])
        let profileB = DockProfile(name: "B", applications: [tileB], others: [])

        XCTAssertEqual(profileA.fingerprint, profileB.fingerprint)
    }

    func testPrepareProfileForApplySkipsMissingPaths() throws {
        let existingApp = DockTile(
            section: .applications,
            tileType: "file-tile",
            kind: .app,
            label: "Safari",
            path: "/Applications/Safari.app/",
            bundleIdentifier: "com.apple.Safari",
            isDockExtra: false,
            payload: try PropertyListSerialization.data(
                fromPropertyList: [
                    "tile-type": "file-tile",
                    "tile-data": [
                        "file-label": "Safari",
                    ],
                ],
                format: .binary,
                options: 0
            )
        )

        let missingFolder = DockTile(
            section: .others,
            tileType: "directory-tile",
            kind: .folder,
            label: "Missing",
            path: "/tmp/porti-does-not-exist",
            bundleIdentifier: nil,
            isDockExtra: nil,
            payload: try PropertyListSerialization.data(
                fromPropertyList: [
                    "tile-type": "directory-tile",
                    "tile-data": [
                        "file-label": "Missing",
                    ],
                ],
                format: .binary,
                options: 0
            )
        )

        let report = PortiTestSupport.prepareProfileForApply(
            DockProfile(name: "Work", applications: [existingApp], others: [missingFolder])
        )

        XCTAssertEqual(report.skippedItems.count, 1)
        XCTAssertEqual(report.skippedItems[0].label, "Missing")
    }

    func testAppendingSpacerAddsSpacerTileToApplicationsSection() throws {
        let domain: [String: Any] = [
            "persistent-apps": [],
            "persistent-others": [],
        ]

        let updated = try PortiTestSupport.appendingSpacer(to: .applications, in: domain)
        let applications = try XCTUnwrap(updated["persistent-apps"] as? [[String: Any]])
        XCTAssertEqual(applications.count, 1)
        XCTAssertEqual(applications[0]["tile-type"] as? String, "spacer-tile")
    }
}
