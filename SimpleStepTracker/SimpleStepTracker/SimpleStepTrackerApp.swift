//
//  SimpleStepTrackerApp.swift
//  SimpleStepTracker
//
//  Created by Abigail Skofield on 4/13/26.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct SimpleStepTrackerApp: App {
    @State private var showNotificationExplanation = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    showNotificationExplanation = true
                }
                .alert("Enable Notifications?", isPresented: $showNotificationExplanation) {
                    Button("Allow", action: requestNotificationPermission)
                    Button("Not Now", role: .cancel) { }
                } message: {
                    Text("The only notification we'll send you is a reminder if you are tracking steps in the background for over an hour — nothing else.")
                }
        }
        .modelContainer(for: [WalkGroup.self, WalkSession.self])
    }
    
    private func requestNotificationPermission() {
        // Request permission to send a reminder if the user's walk session runs for over an hour
        // without being saved or reset—helps prevent accidental long-running sessions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
    }
}

