# Porti Engineering Spike

Status: Initial
Last updated: 2026-03-31

## Scope

This spike validates the Dock profile engine before a full menu bar app target exists.

The code in this repository currently proves:

- Current Dock preferences can be exported and parsed into a structured profile model.
- Profiles can be serialized as JSON with human-readable metadata plus the original tile payload required for high-fidelity restore.
- The current Dock can be compared against a saved profile to determine whether the state is still the last applied profile or has drifted to `Custom`.
- A saved profile can be written back through `defaults import` and made visible by restarting the Dock.
- A minimal SwiftUI menu bar app shell can sit on top of the core for capture, apply, and profile management flows.

## Local Findings

### 1. Dock data shape is parseable

On this machine, `com.apple.dock` exposes the expected top-level arrays:

- `persistent-apps`
- `persistent-others`

Each tile entry includes a `tile-type` and, for file-backed entries, a `tile-data.file-data._CFURLString` value that resolves to a local file URL. Spacer entries appear as `spacer-tile` with minimal `tile-data`.

### 2. Fidelity matters more than normalization

The Dock plist contains opaque fields such as `book` and other metadata that should not be reverse engineered prematurely for MVP restore logic. Porti therefore stores:

- readable summary fields for UI and debugging
- the original tile payload for restore fidelity

This lets the app restore captured profiles without needing a full reimplementation of Apple’s private tile schema.

### 3. Drift detection should use normalized fingerprints

Comparing raw payload bytes is too strict because opaque metadata may change independently of visible Dock state. Porti instead compares:

- section
- tile type
- normalized path
- bundle identifier
- label

This is sufficient for the MVP `Active` vs `Custom` state.

### 4. App Store viability is doubtful

This is an inference from Apple’s published requirements, not a direct policy ruling on Porti.

Apple’s macOS sandbox documentation says Mac App Store apps must enable App Sandbox, and sandboxed apps are restricted primarily to their own container and user-granted file access. Apple’s App Review Guidelines also say macOS apps should use the appropriate APIs when modifying user data stored by other apps.

Porti’s current restore mechanism updates the `com.apple.dock` preferences domain directly and restarts Dock. That approach does not appear to map cleanly to a documented public Dock profile API, and a sandboxed Mac App Store build may not be allowed to modify that preference domain at all.

Working assumption for implementation:

- GitHub distribution is the primary viable v1 channel.
- App Store support should be treated as experimental until proven otherwise.

## Architecture Direction

### Current modules

- `PortiCore`
  - `DockPreferencesStore`: export/import/restart mechanics
  - `DockProfile` and `DockTile`: domain model
  - `ProfileStore`: JSON persistence
- `porti-spike`
  - capture, inspect, drift, and apply commands
- `PortiApp`
  - menu bar shell
  - profile management window
  - warning and error surfaces for apply operations
- `scripts`
  - fallback `swiftc` build and smoke-test paths if SwiftPM is unavailable

### Recommended next app layers

- `PortiApp`
  - menu bar scene and profile actions
- `PortiUI`
  - lightweight profile management window
- `PortiCore`
  - remains the source of truth for Dock capture, apply, profile storage, and drift detection

## Immediate Next Steps

1. Add launch-at-login support.
2. Improve the menu bar capture flow so users can name a profile before save without opening the management window.
3. Add richer missing-item reporting and post-apply notifications.
4. Decide the minimum macOS deployment target after validating the Dock mechanism on currently supported releases.
5. Convert the package-based app shell into a polished Xcode app project when packaging and signing become the priority.

## Sources

- [Configuring the macOS App Sandbox](https://developer.apple.com/documentation/xcode/configuring-the-macos-app-sandbox/)
- [App Sandbox](https://developer.apple.com/documentation/security/app-sandbox)
- [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
