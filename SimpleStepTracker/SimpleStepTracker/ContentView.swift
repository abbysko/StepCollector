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
    @State private var selectedGroup: WalkGroup? = nil
    @State private var selectedTab: Tab = .home

    init(previewGroup: WalkGroup? = nil) {
        _selectedGroup = State(initialValue: previewGroup)
    }

    enum Tab: Hashable {
        case home, track, history

        var title: String {
            switch self {
            case .home: return "Home"
            case .track: return "Track Steps"
            case .history: return "History"
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            appHeader
            Divider()
            TabView(selection: $selectedTab) {
                homeTabView
                    .tag(Tab.home)
                    .tabItem { Label("Home", systemImage: "house") }

                trackTabView
                    .tag(Tab.track)
                    .tabItem { Label("Track", systemImage: "figure.walk") }
                    .badge(startTime != nil ? "●" : nil)

                historyTabView
                    .tag(Tab.history)
                    .tabItem { Label("History", systemImage: "chart.line.uptrend.xyaxis") }
            }
        }
    }

    private var appHeader: some View {
        HStack(spacing: 12) {
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.75, green: 0.25, blue: 0.65), Color(red: 0.15, green: 0.15, blue: 0.85)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Image(systemName: "figure.walk")
                    .foregroundStyle(.white)
                    .font(.system(size: 18, weight: .semibold))
            }
            .frame(width: 40, height: 40)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(selectedTab.title)
                    .font(.headline)
                if let group = selectedGroup {
                    Text("Current group: \(group.name)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }

    private var homeTabView: some View {
        NavigationStack {
            HomeView(selectedGroup: $selectedGroup)
                .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var trackTabView: some View {
        NavigationStack {
            TrackingView(
                startTime: $startTime,
                isPaused: $isPaused,
                selectedGroup: $selectedGroup
            )
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var historyTabView: some View {
        NavigationStack {
            HistoryView(selectedGroup: $selectedGroup)
                .toolbar(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
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

    let group2 = WalkGroup(name: "Training runs")
    context.insert(group2)
    let group3 = WalkGroup(name: "Mountain climbs")
    context.insert(group3)

    context.insert(group)
    
    return ContentView(previewGroup: group)
        .modelContainer(container)
}
