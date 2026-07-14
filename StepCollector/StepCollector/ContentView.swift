//
//  ContentView.swift
//  Step Collector
//
//  Created by Abigail Skofield on 4/13/26.
//

import SwiftUI
import SwiftData
import StepTrackerShared

struct ContentView: View {
    @Environment(\.openURL) private var openURL

    @State private var isPaused = false
    @State private var startTime: Date? = nil
    @State private var selectedGroup: WalkGroup? = nil
    @State private var selectedTab: Tab = .home

    private let aboutURL = URL(string: "https://abbysko.github.io/StepCollector/")!

    init(previewGroup: WalkGroup? = nil) {
        _selectedGroup = State(initialValue: previewGroup)
    }

    enum Tab: Hashable {
        case home, track, history, about

        var title: String {
            switch self {
            case .home: return "Home"
            case .track: return "Track Steps"
            case .history: return "History"
            case .about: return "About"
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            if selectedTab != .about {
                appHeader
                Divider()
            }

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

                aboutTabView
                    .tag(Tab.about)
                    .tabItem { Label("About", systemImage: "info.circle") }
            }
        }
    }

    private var appHeader: some View {
        HStack(spacing: 12) {
            WalkerIcon(size: 40, cornerRadius: 10)

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
        HomeView(selectedGroup: $selectedGroup, isTrackingActive: startTime != nil)
    }

    private var trackTabView: some View {
        TrackingView(
            startTime: $startTime,
            isPaused: $isPaused,
            selectedGroup: $selectedGroup
        )
    }

    private var historyTabView: some View {
        HistoryView(selectedGroup: $selectedGroup)
    }

    private var aboutTabView: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button {
                    openURL(aboutURL)
                } label: {
                    Label("Open in Safari", systemImage: "safari")
                        .font(.subheadline.weight(.semibold))
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)

            Divider()

            WebView(url: aboutURL)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .ignoresSafeArea(edges: .bottom)
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
