# SimpleStepTracker

A SwiftUI iOS app for tracking walks with live step updates. Built with SwiftData for local persistence.

## Features

- **Home** — Manage up to 5 named walk groups (e.g. "Morning Walks", "Hikes"). Groups can be created, renamed, and deleted. A default "My Walks" group is created on first launch.
- **Track** — Start, pause, save, or reset a walk session. Shows a live step count and elapsed time during an active session.
- **History** — View saved sessions for the active group with three display modes:
  - **Steps** — Cumulative step line chart + daily steps bar chart
  - **Duration** — Cumulative duration line chart + daily duration bar chart
  - **List** — Scrollable list of all sessions with date, steps, and duration

## Architecture

| File | Responsibility |
|------|----------------|
| `SimpleStepTrackerApp.swift` | App entry point, SwiftData model container setup |
| `ContentView.swift` | Root `TabView` with Home / Track / History tabs |
| `HomeView.swift` | Management of walk groups (create, read, update, delete) |
| `TrackingView.swift` | Live session tracking, CoreMotion pedometer updates, save/reset flow |
| `HistoryView.swift` | Charts and session list for a selected group |
| `DataModels.swift` | SwiftData models (`WalkGroup`, `WalkSession`) and history aggregation structs |
| `Formatters.swift` | Shared time interval formatting utilities |

## Requirements

- iOS 17+
- Motion & Fitness permission for live pedometer updates
- Xcode 15+