# SimpleStepTracker

A SwiftUI iOS app for tracking walks with live step updates. Built with SwiftData for local persistence.

## Features

- **Home** — Manage up to 5 named walk groups (e.g. "Morning Walks", "Hikes"). Groups can be created, renamed, and deleted. A default "My Walks" group is created on first launch.
- **Track** — Start, pause, save, or reset a walk session. Shows a live elapsed timer and live step count during an active session.
- **Step source behavior** — Uses CoreMotion pedometer updates for responsive live counts, with HealthKit query fallback when needed.
- **Save behavior** — Uses the same live session step count when saving to keep tracked and saved values aligned.
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
| `TrackingView.swift` | Live session tracking, CoreMotion pedometer updates, save/reset flow |
| `HistoryView.swift` | Charts and session list for a selected group |
| `HeaderView.swift` | Shared header component used across tabs |
| `HealthKitManager.swift` | HealthKit authorization and fallback step count queries |
| `DataModels.swift` | SwiftData models (`WalkGroup`, `WalkSession`) and history aggregation structs |
| `Formatters.swift` | Shared time interval formatting utilities |

## Requirements

- iOS 17+
- HealthKit entitlement (step count read permission)
- Motion & Fitness permission (`NSMotionUsageDescription`) for live pedometer updates
- Xcode 15+