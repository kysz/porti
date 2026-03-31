import Foundation
import PortiCore

@inline(__always)
func expect(_ condition: @autoclosure () -> Bool, _ message: String) {
    if !condition() {
        fputs("FAIL: \(message)\n", stderr)
        exit(1)
    }
}

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

    expect(profile.applications.count == 2, "Expected two application tiles")
    expect(profile.others.count == 1, "Expected one other tile")
    expect(profile.applications[0].kind == .app, "Expected first application tile to be an app")
    expect(profile.applications[0].path == "/Applications/Safari.app/", "Expected decoded Safari path")
    expect(profile.applications[1].kind == .spacer, "Expected spacer tile")
    expect(profile.others[0].kind == .folder, "Expected Downloads to be a folder tile")
}

func testProfileFingerprintIgnoresOpaquePayloadDifferences() throws {
    let tileA = try DockTile.spacer(section: .applications)
    let tileB = try DockTile.spacer(section: .applications)

    let profileA = DockProfile(name: "A", applications: [tileA], others: [])
    let profileB = DockProfile(name: "B", applications: [tileB], others: [])

    expect(profileA.fingerprint == profileB.fingerprint, "Expected fingerprint comparison to ignore payload bytes")
}

do {
    try testDecodesApplicationsAndSpacersFromDockDomain()
    try testProfileFingerprintIgnoresOpaquePayloadDifferences()
    print("PASS")
} catch {
    fputs("FAIL: \(error.localizedDescription)\n", stderr)
    exit(1)
}
