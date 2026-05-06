//
//  TrackingView.swift
//  SimpleStepTracker
//
//  Created by Abigail Skofield on 4/13/26.
//

import SwiftUI
import Combine
import SwiftData

struct TrackingView: View {
    let healthKitManager: HealthKitManager
    
    @Binding var startTime: Date?
    @Binding var isPaused: Bool
    @Binding var selectedGroup: WalkGroup?
    
    @State private var showingClearConfirmation = false
    @State private var pausedDate: Date? = nil
    @State private var currentStepCount = 0
    @State private var lastStepRefresh: Date? = nil
    
    var body: some View {
        VStack(spacing: 24) {
            
            Text("Current group: \(selectedGroup?.name ?? "No Group Selected")")
            
            // Start & Stop control buttons
            HStack(spacing: 12) {
                startButton
                stopButton
            }
            .padding(.top)
            
            Spacer()
            
            // Show live tracking of steps and duration
            liveTrackingDisplay
            
            if isPaused {
                saveProgressGroup
            }
            
            Spacer()
        }
        .padding()
    }
    
    // derived state
    var isTracking: Bool {
        startTime != nil && !isPaused
    }
    
    // view elements
    private var startButton: some View {
        Button("Start Tracking") {
            print("start pressed")
            if startTime == nil {
                startTime = Date()
            }
            isPaused = false
        }
        .buttonStyle(.borderedProminent)
        .tint(.green)
        .disabled(startTime != nil)
    }
    
    private var stopButton: some View{
        Button("Stop Tracking") {
            print("stop pressed")
            isPaused = true
            pausedDate = Date()
        }
        .buttonStyle(.borderedProminent)
        .tint(.red)
        .disabled(startTime == nil || isPaused)
    }
    
    private var liveTrackingDisplay: some View {
        VStack(spacing: 20) {
            if let startTime {
                Text("Started at \(startTime.formatted(date: .omitted, time: .shortened))")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                TimelineView(.periodic(from: .now, by: 1)) { context in
                    let current = isPaused ? (pausedDate ?? context.date) : context.date

                    VStack(spacing: 28) {
                        metricBlock(
                            title: "Time",
                            value: formattedElapsedTime(from: startTime, to: current),
                            tint: .green
                        )

                        metricBlock(
                            title: "Steps",
                            value: "\(currentStepCount)",
                            tint: .cyan
                        )
                    }
                    .padding(.top, 8)
                    .task(id: stepRefreshTriggerDate(for: current)) {
                        await refreshLiveStepsIfNeeded(current: current, startTime: startTime)
                    }
                }
            }
        }
    }
    
    private var saveProgressGroup: some View {
        HStack(spacing: 12) {
            Button("Save Progress") {
                print("Save Progress tapped")
                Task {
                    guard let start = startTime,
                          let selectedGroup else { return }
                    
                    let endTime = isPaused ? (pausedDate ?? Date()) : Date()
                    let elapsed = endTime.timeIntervalSince(start)
                    
                    var steps = 0
                    do {
                        steps = try await healthKitManager.fetchStepCount(from: start, to: endTime)
                    } catch {
                        print("Failed to fetch steps: \(error)")
                        steps = -999
                    }
                    
                    let session = WalkSession(
                        start: start,
                        duration: elapsed,
                        stepCount: steps
                    )
                    selectedGroup.sessions.append(session)
                    
                    startTime = nil
                    isPaused = false
                    pausedDate = nil
                    
                }
            }
            .buttonStyle(.borderedProminent)
            
            Button("Reset") {
                showingClearConfirmation = true
            }
            .buttonStyle(.bordered)
            .tint(.red)
            .confirmationDialog(
                "Reset this session?",
                isPresented: $showingClearConfirmation,
                titleVisibility: .visible
            ) {
                Button("Yes, reset", role: .destructive) {
                    startTime = nil
                    isPaused = false
                }
                
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will remove your current tracking session.")
            }
        }
    }
    
    private func formattedElapsedTime(from start: Date, to end: Date) -> String {
        let elapsed = max(0, Int(end.timeIntervalSince(start)))
        let hours = elapsed / 3600
        let minutes = (elapsed % 3600) / 60
        let seconds = elapsed % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private func stepRefreshTriggerDate(for current: Date) -> Date {
        let interval: TimeInterval = 5
        let bucket = floor(current.timeIntervalSinceReferenceDate / interval)
        return Date(timeIntervalSinceReferenceDate: bucket * interval)
    }

    private func refreshLiveStepsIfNeeded(current: Date, startTime: Date) async {
        guard !isPaused else { return }

        let refreshInterval: TimeInterval = 5
        if let lastStepRefresh,
           current.timeIntervalSince(lastStepRefresh) < refreshInterval {
            return
        }

        do {
            currentStepCount = try await healthKitManager.fetchStepCount(from: startTime, to: current)
            lastStepRefresh = current
        } catch {
            print("Failed to fetch live steps: \(error)")
        }
    }
    
    private func metricBlock(title: String, value: String, tint: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.title3)
                .foregroundStyle(.primary)

            Text(value)
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(tint)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }
}

#Preview("Active tracking"){
    TrackingView(
        healthKitManager: HealthKitManager(),
        startTime: .constant(Date().addingTimeInterval(-256)),
        isPaused: .constant(false),
        selectedGroup: .constant(WalkGroup(name: "Walks with kids"))
    )
}

#Preview("Default"){
    TrackingView(
        healthKitManager: HealthKitManager(),
        startTime: .constant(nil),
        isPaused: .constant(false),
        selectedGroup: .constant(WalkGroup(name: "Training Runs (woods)"))
    )
}
