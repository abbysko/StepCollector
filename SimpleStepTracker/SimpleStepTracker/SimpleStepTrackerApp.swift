//
//  SimpleStepTrackerApp.swift
//  SimpleStepTracker
//
//  Created by Abigail Skofield on 4/13/26.
//

import SwiftUI
import SwiftData

@main
struct SimpleStepTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [WalkGroup.self, WalkSession.self])
    }
}

