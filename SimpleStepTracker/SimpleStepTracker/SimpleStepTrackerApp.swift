//
//  SimpleStepTrackerApp.swift
//  SimpleStepTracker
//
//  Created by Abigail Skofield on 4/13/26.
//

import SwiftUI
import SwiftData
import BackgroundTasks

@main
struct SimpleStepTrackerApp: App {
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [WalkGroup.self, WalkSession.self])
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                BackgroundStepRefresh.schedule()
            }
        }
        .backgroundTask(.appRefresh(BackgroundStepRefresh.taskIdentifier)) {
            await BackgroundStepRefresh.handleAppRefresh()
        }
    }
}

