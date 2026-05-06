# SimpleStepTracker

A SwiftUI iOS app for tracking walks using HealthKit. Built with SwiftData for local persistence.

## Features

- **Home** — Manage up to 5 named walk groups (e.g. "Morning Walks", "Hikes"). Groups can be created, renamed, and deleted. A default "My Walks" group is created on first launch.
- **Track** — Start, pause, save, or reset a walk session. Displays a live elapsed timer and step count (refreshed every 5 seconds from HealthKit) while a session is active. On stop, saves the session's duration and total steps to the selected group.
- **History** — View saved sessions for the active group with three display modes:
  - **Steps** — Cumulative step line chart + daily steps bar chart
  - **Duration** — Cumulative duration line chart + daily duration bar chart
  - **List** — Scrollable list of all sessions with date, steps, and duration

## Architecture

| File | Responsibility |
|------|----------------|
| `SimpleStepTrackerApp.swift` | App entry point, SwiftData model container setup |
| `ContentView.swift` | Root `TabView` with Home / Track / History tabs |
| `HomeView.swift` | Walk group CRUD (SwiftData + SwiftUI list) |
| `TrackingView.swift` | Live session tracking, HealthKit step polling |
| `HistoryView.swift` | Charts and session list for a selected group |
| `TabHeaderView.swift` | Shared header component used across tabs |
| `HealthKitManager.swift` | HealthKit authorization and step count queries |
| `DataModels.swift` | SwiftData models: `WalkGroup` and `WalkSession` |

## Requirements

- iOS 17+
- HealthKit entitlement (step count read permission)
- Xcode 15+