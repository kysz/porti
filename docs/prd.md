# Porti PRD

Status: Draft v0.3
Last updated: 2026-03-31
Product: Porti
Platform: macOS menu bar app

## 0. Product Decisions

- Target OS support: all currently Apple-supported macOS versions, unless the Dock integration mechanism differs enough to justify narrowing support during the engineering spike.
- Distribution targets: Mac App Store and GitHub releases.
- Distribution fallback: if Mac App Store policies or sandboxing prevent the required Dock modification approach, Porti v1 will ship via GitHub only.
- Missing items on apply: skip missing items and warn the user without blocking the switch.
- Active profile state: a profile is considered active immediately after apply; if the user manually changes the Dock afterward, Porti should show the state as `Custom`.
- Profile editing scope for MVP: profile-level management only. No manual per-item editing UI in v1.
- Import and export: out of scope for MVP.

## 1. Summary

Porti is a macOS menu bar app that lets users save named Dock profiles and switch between them in a couple of clicks. A Dock profile is a saved arrangement of pinned apps and folders, including their order, so users can move quickly between work contexts such as coding, writing, meetings, design, or personal use.

The MVP should make three things easy:

1. Save the current Dock as a named profile.
2. See available profiles from the menu bar.
3. Apply a profile reliably and quickly.

## 2. Problem

Power users often change the contents and order of their macOS Dock depending on what they are doing. macOS does not provide a simple built-in way to save multiple Dock setups and switch between them. Rebuilding a Dock manually is tedious, easy to get wrong, and interrupts flow.

The result is a repeated low-grade friction problem:

- Users avoid customizing their Dock because it is annoying to maintain.
- Users keep a cluttered "one size fits all" Dock that is suboptimal for specific workflows.
- Users lose time dragging apps and folders around whenever their context changes.

## 3. Goal

Help users move between saved Dock setups in less than 10 seconds with minimal cognitive load.

## 4. Target User

Primary user:

- A Mac power user who actively changes tools based on context and wants a fast, reversible way to switch Dock setups.

Examples:

- A developer with separate coding, debugging, and meeting setups.
- A creator with writing, editing, and publishing setups.
- A freelancer who wants clean client-specific workspaces.

## 5. Jobs To Be Done

- When I am switching from one kind of work to another, I want to apply the right Dock layout instantly so my most relevant tools are always one click away.
- When I have tuned my Dock for a specific workflow, I want to save that arrangement so I can restore it later without rebuilding it manually.
- When something changes on my Mac, I want Porti to tell me if a saved Dock item is missing instead of failing silently.

## 6. Product Principles

- Fast from the menu bar: no heavy main window required for the core loop.
- Safe by default: profile switching should be intentional and recoverable.
- Native feel: the app should behave like a focused macOS utility, not a general-purpose dashboard.
- Honest about constraints: if macOS limitations exist, the product should expose them clearly instead of hiding them.

## 7. MVP Scope

Included in MVP:

- Save the current Dock as a named profile.
- List saved profiles in the menu bar.
- Switch to a saved profile from the menu bar.
- Rename and delete profiles.
- Update an existing profile from the current Dock.
- The ability to add a spacer between dock items.
- Basic settings such as launch at login and confirmation behavior.

Explicitly out of scope for MVP:

- Syncing profiles across Macs.
- Window layouts, Spaces, Stage Manager, or desktop icon layouts.
- Scheduled or automatic switching based on location, time, focus mode, or connected displays.
- Sharing profile templates with other users.
- Advanced profile version history.
- Full Dock editing UI inside the app.

## 8. Core User Flows

### A. Save Current Dock

1. User opens the menu bar app.
2. User chooses `Save Current Dock`.
3. User enters a profile name.
4. App captures the current Dock configuration and saves it.
5. New profile appears in the menu list immediately.

Success criteria:

- Completed in under 30 seconds.
- No manual file selection required.

### B. Switch Profiles

1. User opens the menu bar app.
2. User selects a profile.
3. App applies the saved Dock configuration.
4. Dock refreshes.
5. App shows a lightweight success or warning state, including skipped items if any were missing.

Success criteria:

- User can switch in two clicks or fewer after opening the menu.
- App communicates if any saved items cannot be restored.

### C. Manage Profiles

1. User opens `Manage Profiles`.
2. User can rename, delete, duplicate, or update a profile from the current Dock.
3. Changes persist immediately.

Success criteria:

- Profile management is simple enough that a separate preferences-heavy app is unnecessary.

## 9. Functional Requirements

### FR1. Profile Capture

Porti must be able to capture the current Dock state, including:

- Pinned application items.
- Pinned folder or file stack items.
- Item ordering.
- Separation between app items and folder/file items.
- Spacer tiles.

If technically feasible during implementation, Porti should also preserve:

- Folder display and sort settings.

### FR2. Profile Storage

Porti must persist profiles locally on the Mac.

Each profile should include at minimum:

- Profile id.
- Profile name.
- Creation timestamp.
- Updated timestamp.
- Dock items with enough metadata to restore them reliably.

Preferred data captured per item:

- Item type.
- Absolute path.
- Bundle identifier when available.
- Display name.
- Original section and position.

### FR3. Profile Switching

When a profile is applied, Porti must:

- Validate the profile data before applying it.
- Replace the current Dock arrangement with the saved one.
- Refresh the Dock so the change becomes visible immediately.
- Report completion, partial success, or failure.

### FR4. Missing Item Handling

If a saved app, file, or folder no longer exists:

- Porti must not fail silently.
- Porti should show which items are missing.
- Porti should continue switching the rest of the profile automatically.
- Porti should not require confirmation or block the switch for missing items.

### FR5. Profile Management

Users must be able to:

- Create a profile from the current Dock.
- Rename a profile.
- Delete a profile.
- Duplicate a profile.
- Overwrite a profile with the current Dock state.

### FR6. Menu Bar UX

The menu bar dropdown must expose:

- Current profile if known.
- A list of saved profiles.
- `Save Current Dock`.
- `Manage Profiles`.
- `Settings`.
- `Quit`.

The default interaction should optimize for profile switching over management.

### FR7. Settings

MVP settings should include:

- Launch at login.
- Confirmation before applying a profile.
- Whether warnings are shown inline or as notifications.

### FR8. Active Profile State

Porti must track and display profile state as follows:

- Immediately after a successful apply, the selected profile is the active profile.
- If the Dock no longer matches the last applied profile, Porti should show the current state as `Custom`.
- Porti does not need to infer which saved profile is "closest" to the current Dock.

## 10. Non-Functional Requirements

- App launch should feel instant for a small utility.
- Profile switching should complete quickly enough to feel deliberate rather than disruptive.
- Profile data should be stored in a format that is easy to inspect and back up.
- Failures should be diagnosable through user-facing messaging and internal logs.
- The app should work offline and require no account.
- The app should degrade gracefully if one distribution target imposes restrictions that another does not.

## 11. UX Notes

Recommended IA for MVP:

- Menu bar is the primary control surface.
- A small profile management window is acceptable for rename/delete/update flows.
- The app should avoid a large multipane settings experience unless complexity proves necessary.

Recommended menu structure:

- Active Profile: `<name or Unknown>`
- Profiles
- `Work`
- `Meetings`
- `Home`
- Divider
- `Save Current Dock`
- `Manage Profiles`
- `Settings`
- Divider
- `Quit Porti`

Potential UX enhancements after MVP:

- Recent profiles.
- Keyboard shortcuts for specific profiles.
- Temporary preview or undo after switch.

## 12. Success Metrics

For MVP, success means:

- A first-time user can create their first profile without documentation.
- A saved profile can be applied reliably in normal use.
- Switching requires at most two clicks from the menu after opening it.
- Most switches complete without manual recovery.

## 13. Risks And Open Questions

These are the main product and technical unknowns that should be validated early:

1. How stable is the Dock configuration format across current macOS versions?
2. What is the most reliable way to identify and restore items: path only, bundle id first, or a hybrid strategy?
3. Will switching require restarting the Dock process, and if so, what is the acceptable UX around that visible refresh?
4. Can the same Dock-modification approach satisfy both Mac App Store and GitHub distribution requirements, especially around sandboxing and store policy?
5. How should Porti behave when users have apps installed in nonstandard locations or on external volumes?
6. Should Porti capture only persistent Dock items, or also special tiles if present?
7. What is the cleanest way to detect that the Dock has drifted and should be marked `Custom` after a manual edit?

## 14. Assumptions

These assumptions shape the MVP and should be challenged in the first engineering spike:

- Porti can read the current Dock state programmatically.
- Porti can write a saved Dock state programmatically.
- Applying a profile will be acceptable even if the Dock visibly refreshes.
- Users care more about speed and reliability than about editing every Dock detail inside Porti.
- GitHub distribution is a viable fallback even if App Store distribution proves constrained.

## 15. Recommended Engineering Spike

Before UI implementation, run a short feasibility spike to answer:

1. How to read the current Dock configuration into a structured model.
2. How to write a profile back safely.
3. What fields are required to restore apps, folders, and ordering reliably.
4. What happens when an item is missing or moved.
5. What user-visible effect occurs when the Dock refreshes.
6. Whether the implementation can ship in the Mac App Store, or whether App Store and GitHub builds need different capabilities or distribution strategy.
7. How to detect Dock drift after apply so the UI can switch from a named profile to `Custom`.

Deliverables for the spike:

- A tiny command-line prototype or internal test harness.
- Sample captured Dock profile JSON.
- A decision on whether MVP is technically viable with acceptable UX.
- A decision memo on App Store viability versus GitHub-only fallback for v1.

## 16. Post-MVP Ideas

- Import/export profiles.
- Cloud sync between Macs.
- Smart profile switching based on context.
- Profile hotkeys.
- Backup and restore history.
- Cross-device profile templates.
- Pair Dock profiles with app launch sets.

## 17. Implementation Readiness

Product direction is now concrete enough to begin the engineering spike.

The first implementation milestone should validate:

1. Dock capture and restore mechanics across supported macOS versions.
2. Profile persistence format and missing-item handling.
3. Drift detection for `Custom` state.
4. Whether App Store distribution is viable, with GitHub-only release as the approved fallback.
