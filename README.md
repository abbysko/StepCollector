# Step Collector

Step Collector is an iOS app that lets you log and review your walks across named groups — useful for separating different walking contexts like commutes, hikes, family walks, or exercise. Track live step counts and elapsed time during a session, then browse cumulative and daily charts of your history. Built with SwiftUI and SwiftData, the app is fully local and requires no account.

## App UI Overview

The app has four tabs:
- **Home** — Manage up to 5 named walk groups (e.g. "Morning Walks", "Hikes"). Groups can be created, renamed, and deleted. A default "Demo Walks" group is created on first launch, prepopulated with sample data to allow users to see how their walks will be displayed in the History tab.
- **Track** — Start a walk session, stop when done, then save or reset. Shows a live step count and elapsed time during an active session.
- **History** — View saved sessions for the active group with three display modes:
  - **Steps** — Cumulative step line chart + daily steps bar chart
  - **Duration** — Cumulative duration line chart + daily duration bar chart
  - **List** — Scrollable list of all sessions with date, steps, and duration
- **About** — Displays the public project website inside the app, with an option to open the page in Safari. External links such as email and GitHub are opened outside the embedded web view.

## Architecture

| File | Responsibility |
|------|----------------|
| `SimpleStepTrackerApp.swift` | App entry point, SwiftData model container setup |
| `ContentView.swift` | Root `TabView` with Home / Track / History / About tabs |
| `BackgroundStepRefresh.swift` | Schedules and handles background refreshes to keep an active Live Activity updated |
| `HomeView.swift` | Management of walk groups (create, read, update, delete) |
| `TrackingView.swift` | Live session tracking, CoreMotion pedometer updates, save/reset flow |
| `HistoryView.swift` | Charts and session list for a selected group |
| `SafariView.swift` | Embedded `WKWebView` wrapper used by the About tab |
| `DataModels.swift` | SwiftData models (`WalkGroup`, `WalkSession`) and history aggregation structs |
| `StepTracker.swift` | Shared pedometer service for live step updates and background step queries |
| `TrackingActivityAttributes.swift` | Shared ActivityKit attributes and content state for the Live Activity |
| `SimpleStepTrackerWidgetsLiveActivity.swift` | Lock screen, Dynamic Island, and widget Live Activity presentation |
| `Formatters.swift` | Shared time interval formatting utilities |

## Requirements

- iOS 17+
- Motion & Fitness permission for live pedometer updates
- Xcode 16+

## Website, Support, and Privacy

- GitHub Pages site: https://abbysko.github.io/StepCollector/
- Includes the app overview, FAQ, privacy policy, support information, contact details, and source code link

## Repository

- Public source: http://github.com/abbysko/StepCollector
- Issues can be reported through GitHub issues or via the contact links on the website

## Release Process (App Store + GitHub)

Use this mapping for public releases:
- App Store version `1.0` -> Git tag `v1.0.0`

Checklist:
1. Update `MARKETING_VERSION` in Xcode (for example `1.0`).
2. Commit and push changes to `main`.
3. Create and push the release tag:
  - `git tag -a v1.0.0 -m "StepCollector 1.0"`
  - `git push origin main --follow-tags`
4. GitHub Actions runs `.github/workflows/release.yml` on tag push.
5. Workflow validates tag version against Xcode `MARKETING_VERSION` and publishes the GitHub Release.

If versions do not match, release publishing is blocked until they are aligned.