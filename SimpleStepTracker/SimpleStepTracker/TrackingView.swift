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
    @State private var trackingIssueMessage: String? = nil
    @State private var pedometer = CMPedometer()
    @State private var isPedometerRunning = false

    private let zeroStepTimeoutThreshold: TimeInterval = 180
    
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
                initializeSessionState()
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
                    let notice = trackingNotice(for: current)

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

                        if let notice {
                            noticeBanner(notice)
                        }
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

                resetSession()
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
                    resetSession()
                }
                
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will remove your current tracking session.")
            }
        }
    }
    
    private func startPedometerUpdates(from start: Date) {
        guard CMPedometer.isStepCountingAvailable() else {
            trackingIssueMessage = "Step counting isn't available on this device."
            return
        }

        isPedometerRunning = true
        pedometer.startUpdates(from: start) { data, error in
            DispatchQueue.main.async {
                if error != nil {
                    isPedometerRunning = false
                    trackingIssueMessage = "Unable to read step data from the pedometer. Check Motion & Fitness permissions in Settings."
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

    private func resetSession() {
        startTime = nil
        isPaused = false
        initializeSessionState()
        stopPedometerUpdates()
    }

    private func initializeSessionState() {
        pausedDate = nil
        currentStepCount = 0
        trackingIssueMessage = nil
    }

    private func trackingNotice(for current: Date) -> TrackingNotice? {
        if let trackingIssueMessage {
            return TrackingNotice(
                systemImage: "exclamationmark.triangle.fill",
                message: trackingIssueMessage,
                tint: .orange
            )
        }

        guard let startTime, !isPaused else { return nil }

        let elapsed = current.timeIntervalSince(startTime)
        guard currentStepCount == 0, elapsed >= zeroStepTimeoutThreshold else { return nil }

        return TrackingNotice(
            systemImage: "figure.walk.motion",
            message: "No steps have been detected yet. If you're walking, keep your iPhone on you and make sure Motion & Fitness is enabled.",
            tint: .orange
        )
    }

    private func noticeBanner(_ notice: TrackingNotice) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: notice.systemImage)
                .foregroundStyle(notice.tint)
                .font(.headline)

            Text(notice.message)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(notice.tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(notice.tint.opacity(0.22), lineWidth: 1)
        )
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

    private struct TrackingNotice {
        let systemImage: String
        let message: String
        let tint: Color
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

#Preview("No steps detected (warning)"){
    TrackingView(
        startTime: .constant(Date().addingTimeInterval(-240)),
        isPaused: .constant(false),
        selectedGroup: .constant(WalkGroup(name: "Morning Walk"))
    )
}

