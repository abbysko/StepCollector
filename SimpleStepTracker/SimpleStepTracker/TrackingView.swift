//
//  TrackingView.swift
//  SimpleStepTracker
//
//  Created by Abigail Skofield on 4/13/26.
//

import SwiftUI
import CoreMotion

struct TrackingView: View {
    
    @Binding var startTime: Date?
    @Binding var isPaused: Bool
    @Binding var selectedGroup: WalkGroup?
    
    @State private var showingClearConfirmation = false
    @State private var pausedDate: Date? = nil
    @State private var currentStepCount = 0
    @State private var pedometer = CMPedometer()
    @State private var isPedometerRunning = false
    
    var body: some View {
        VStack(spacing: 24) {
            HStack(spacing: 12) {
                startButton
                stopButton
            }
            .padding(.top)
            
            Spacer()
            
            liveTrackingDisplay
            
            if isPaused {
                saveProgressGroup
            }
            
            Spacer()
        }
        .padding()
    }
    
    private var startButton: some View {
        Button("Start Tracking") {
            if startTime == nil {
                let startedAt = Date()
                startTime = startedAt
                pausedDate = nil
                currentStepCount = 0
                startPedometerUpdates(from: startedAt)
            }
            isPaused = false
        }
        .buttonStyle(.borderedProminent)
        .tint(.green)
        .disabled(startTime != nil)
    }
    
    private var stopButton: some View {
        Button("Stop Tracking") {
            isPaused = true
            pausedDate = Date()
            stopPedometerUpdates()
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
                            value: current.timeIntervalSince(startTime).stopwatchFormatted,
                            tint: .green
                        )

                        metricBlock(
                            title: "Steps",
                            value: "\(currentStepCount)",
                            tint: .cyan
                        )
                    }
                    .padding(.top, 8)
                }
            }
        }
    }
    
    private var saveProgressGroup: some View {
        HStack(spacing: 12) {
            Button("Save Progress") {
                guard let start = startTime,
                      let selectedGroup else { return }
                
                let endTime = isPaused ? (pausedDate ?? Date()) : Date()
                let elapsed = endTime.timeIntervalSince(start)
                let steps = max(0, currentStepCount)
                
                let session = WalkSession(start: start, duration: elapsed, stepCount: steps)
                selectedGroup.sessions.append(session)
                
                startTime = nil
                isPaused = false
                pausedDate = nil
                currentStepCount = 0
                stopPedometerUpdates()
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
                    pausedDate = nil
                    currentStepCount = 0
                    stopPedometerUpdates()
                }
                
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will remove your current tracking session.")
            }
        }
    }
    
    private func startPedometerUpdates(from start: Date) {
        guard CMPedometer.isStepCountingAvailable() else { return }

        isPedometerRunning = true
        pedometer.startUpdates(from: start) { data, error in
            DispatchQueue.main.async {
                if error != nil {
                    isPedometerRunning = false
                    return
                }

                if let steps = data?.numberOfSteps.intValue {
                    currentStepCount = steps
                }
            }
        }
    }

    private func stopPedometerUpdates() {
        guard isPedometerRunning else { return }
        pedometer.stopUpdates()
        isPedometerRunning = false
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

#Preview("Default"){
    TrackingView(
        startTime: .constant(nil),
        isPaused: .constant(false),
        selectedGroup: .constant(WalkGroup(name: "Training Runs (woods)"))
    )
}

#Preview("Active tracking"){
    TrackingView(
        startTime: .constant(Date().addingTimeInterval(-256)),
        isPaused: .constant(false),
        selectedGroup: .constant(WalkGroup(name: "Walks with kids"))
    )
}

