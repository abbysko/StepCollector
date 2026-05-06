//
//  ContentView.swift
//  SimpleStepTracker
//
//  Created by Abigail Skofield on 4/13/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var isPaused = false
    @State private var startTime: Date? = nil
    @State private var healthKitManager = HealthKitManager()
    @State private var selectedGroup: WalkGroup? = nil
    
    var body: some View {
        allTabsView
            .task {
                
#if DEBUG
                if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                    return
                }
#endif
                do {
                    try await healthKitManager.requestAuthorization()
                } catch {
                    print("HealthKit auth failed: \(error)")
                }
            }
    }
    
    private var allTabsView: some View {
        TabView {
            homeTabView
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            trackTabView
                .tabItem {
                    Label("Track", systemImage: "figure.walk")
                }
                .badge(startTime != nil ? "●" : nil)
            
            historyTabView
                .tabItem {
                    Label("History", systemImage: "chart.line.uptrend.xyaxis")
                }
        }
    }
    
    private var homeTabView: some View {
        VStack {
            HeaderView(title: "Welcome!")
            Spacer()
            HomeView(selectedGroup: $selectedGroup)
                .frame(maxHeight: .infinity, alignment: .center)
                .padding()
            Spacer()
        }
        .frame(maxHeight: .infinity, alignment: .center)
    }
    
    private var trackTabView: some View{
        VStack {
            HeaderView(title: "Track Steps")
            Spacer()
            TrackingView(
                healthKitManager: healthKitManager,
                startTime: $startTime,
                isPaused: $isPaused,
                selectedGroup: $selectedGroup
            )
            Spacer()
        }
    }
    
    private var historyTabView: some View{
        VStack {
            HeaderView(title: "History")
            Spacer()
            HistoryView(selectedGroup: $selectedGroup)
            Spacer()
        }
    }
}

#Preview {
    ContentView()
}

#Preview("sample data") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: WalkGroup.self, WalkSession.self,
        configurations: config
    )

    let context = container.mainContext

    let group = WalkGroup(name: "Walks with kids")
    group.sessions = [
        WalkSession(
            start: Date().addingTimeInterval(-203600),
            duration: 1200,
            stepCount: 200
        ),
        WalkSession(
            start: Date().addingTimeInterval(-100600),
            duration: 4500,
            stepCount: 100
        ),
        WalkSession(
            start: Date().addingTimeInterval(-300600),
            duration: 800,
            stepCount: 300
        )
    ]

    context.insert(group)
    
    let group2 = WalkGroup(name: "Training runs")
    context.insert(group2)
    let group3 = WalkGroup(name: "Mountain climbs")
    context.insert(group3)
    
    return ContentView()
        .modelContainer(container)
}
