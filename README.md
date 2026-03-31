# Porti

Porti is a macOS utility for saving Dock profiles and switching between them quickly.

This repository currently contains the technical spike and core engine:

- `PortiCore`: Dock profile models, capture/apply logic, persistence, and drift detection.
- `porti-spike`: a command-line tool for validating Dock capture, JSON profile storage, and restore mechanics before a full app bundle exists.
- `PortiApp`: a minimal macOS menu bar app shell built on top of `PortiCore`.

## Requirements

- macOS
- Swift 6+
- Full Xcode is not required for the spike, but it will be required to build the eventual menu bar app target.

## Build

```bash
swift build
```

## Test

```bash
swift test
```

## Run The Menu Bar App

```bash
swift run PortiApp
```

Current app shell features:

- inline profile naming and capture from the menu bar
- profile apply, rename, duplicate, delete, and overwrite flows
- active profile tracking with `Custom` drift state
- optional apply confirmation
- optional notifications for saves, applies, warnings, and errors
- launch-at-login toggle, with graceful failure for development-style runs that cannot register themselves

## Spike Commands

Inspect the current Dock as JSON:

```bash
swift run porti-spike inspect-current
```

Capture the current Dock to a profile JSON file:

```bash
swift run porti-spike capture --name Work --output ./artifacts/work.json
```

Check whether the current Dock still matches a saved profile:

```bash
swift run porti-spike drift --input ./artifacts/work.json
```

Apply a saved profile back to the Dock:

```bash
swift run porti-spike apply --input ./artifacts/work.json --force
```

`apply` writes the Dock preferences and restarts the Dock. The command requires `--force` to avoid accidental changes during the spike phase.

## Fallback Scripts

If SwiftPM is unavailable in a local environment, the legacy scripts still exist:

```bash
./scripts/build-spike.sh
./scripts/test-spike.sh
```
