//
//  TrackingView.swift
//  SimpleStepTracker
//
//  Created by Abigail Skofield on 4/13/26.
//

import SwiftUI
import ActivityKit
import StepTrackerShared

struct TrackingView: View {
    
    @Binding var startTime: Date?
    @Binding var isPaused: Bool
    @Binding var selectedGroup: WalkGroup?
    
    @State private var showingClearConfirmation = false
    @State private var pausedDate: Date? = nil
    @StateObject private var stepTracker = StepTracker()
    @State private var currentActivity: Activity<TrackingActivityAttributes>?

    init(
        startTime: Binding<Date?>,
        isPaused: Binding<Bool>,
        selectedGroup: Binding<WalkGroup?>
    ) {
        _startTime = startTime
        _isPaused = isPaused
        _selectedGroup = selectedGroup
    }
    
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
        .onAppear {
            syncExistingLiveActivity()
        }
    }
    
    private var startButton: some View {
        Button("Start Tracking") {
            if startTime == nil {
                let startedAt = Date()
                startTime = startedAt
                initializeSessionState()
                startLiveActivity()
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
            endLiveActivity()
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

                VStack(spacing: 28) {
                    if isPaused {
                        let elapsed = Int((pausedDate ?? Date()).timeIntervalSince(startTime))
                        TrackingMetric(
                            type: .time,
                            value: TimeInterval(elapsed).stopwatchFormatted,
                            context: .app
                        )
                    } else {
                        TrackingMetric(
                            type: .time,
                            value: "",
                            context: .app,
                            timerStartedAt: startTime
                        )
                    }

                    TrackingMetric(
                        type: .steps,
                        value: "\(stepTracker.currentStepCount)",
                        context: .app
                    )

                    if let notice = trackingNotice() {
                        noticeBanner(notice)
                    }
                }
                .padding(.top, 8)
                .onChange(of: stepTracker.currentStepCount) { _, newSteps in
                    let elapsed = Int(Date().timeIntervalSince(startTime))
                    updateLiveActivity(elapsed: elapsed, steps: newSteps)
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
                let steps = max(0, stepTracker.currentStepCount)
                
                let session = WalkSession(start: start, duration: elapsed, stepCount: steps)
                selectedGroup.sessions.append(session)

                resetSession()
            }
            .buttonStyle(.borderedProminent)
            
            Button("Clear & Reset") {
                showingClearConfirmation = true
            }
            .buttonStyle(.bordered)
            .tint(.red)
            .confirmationDialog(
                "Clear & reset this session?",
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
        stepTracker.startUpdates(from: start)
    }

    private func stopPedometerUpdates() {
        stepTracker.stopUpdates()
    }

    private func startLiveActivity() {
        if let existing = Activity<TrackingActivityAttributes>.activities.first {
            currentActivity = existing
            return
        }

        guard let selectedGroup else { return }
        let attributes = TrackingActivityAttributes(
            groupName: selectedGroup.name,
            startedAt: startTime ?? Date()
        )
        let initialState = TrackingActivityAttributes.ContentState(
            elapsedSeconds: 0,
            stepCount: 0
        )

        do {
            currentActivity = try Activity<TrackingActivityAttributes>.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: nil),
                pushType: nil
            )
        } catch {
            print("Failed to start Live Activity: \(error.localizedDescription)")
        }
    }

    private func syncExistingLiveActivity() {
        currentActivity = Activity<TrackingActivityAttributes>.activities.first
    }

    private func updateLiveActivity(elapsed: Int, steps: Int) {
        guard currentActivity != nil else { return }
        let updatedState = TrackingActivityAttributes.ContentState(
            elapsedSeconds: elapsed,
            stepCount: steps
        )

        Task {
            await currentActivity?.update(.init(state: updatedState, staleDate: Date().addingTimeInterval(10)))
        }
    }

    private func endLiveActivity() {
        Task {
            if let currentActivity {
                await currentActivity.end(
                    .init(state: currentActivity.content.state, staleDate: nil),
                    dismissalPolicy: .immediate
                )
            }

            for activity in Activity<TrackingActivityAttributes>.activities {
                await activity.end(
                    .init(state: activity.content.state, staleDate: nil),
                    dismissalPolicy: .immediate
                )
            }

            self.currentActivity = nil
        }
    }

    private func resetSession() {
        startTime = nil
        isPaused = false
        initializeSessionState()
        stopPedometerUpdates()
        endLiveActivity()
    }

    private func initializeSessionState() {
        pausedDate = nil
        stepTracker.currentStepCount = 0
        stepTracker.errorMessage = nil
    }

    private func trackingNotice() -> TrackingNotice? {
        if let errorMessage = stepTracker.errorMessage {
            return TrackingNotice(
                systemImage: "exclamationmark.triangle.fill",
                message: errorMessage,
                tint: .orange
            )
        }

        return nil
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

#Preview("Paused save/reset"){
    TrackingView(
        startTime: .constant(Date().addingTimeInterval(-256)),
        isPaused: .constant(true),
        selectedGroup: .constant(WalkGroup(name: "Walks with kids"))
    )
}
