//
//  BackgroundStepRefresh.swift
//  SimpleStepTracker
//
//  Created by Abigail Skofield on 5/14/26.
//

import Foundation
import ActivityKit
import BackgroundTasks
import StepTrackerShared

enum BackgroundStepRefresh {
    static let taskIdentifier = "com.abbysko.SimpleStepTracker.stepRefresh"

    static func schedule() {
        let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
        request.earliestBeginDate = Date().addingTimeInterval(20)

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Failed to schedule step refresh task: \(error.localizedDescription)")
        }
    }

    static func handleAppRefresh() async {
        // Always re-schedule; the system controls if/when this runs.
        schedule()

        guard let activity = Activity<TrackingActivityAttributes>.activities.first else {
            return
        }

        if Task.isCancelled {
            return
        }

        let now = Date()
        let startedAt = activity.attributes.startedAt
        let queriedSteps = await StepTracker.queryTotalSteps(from: startedAt, to: now)
        let stepCount = queriedSteps ?? activity.content.state.stepCount
        let elapsedSeconds = Int(now.timeIntervalSince(startedAt))

        if Task.isCancelled {
            return
        }

        let refreshedState = TrackingActivityAttributes.ContentState(
            elapsedSeconds: elapsedSeconds,
            stepCount: stepCount,
            lastStepRefreshAt: now
        )

        await activity.update(.init(state: refreshedState, staleDate: nil))
    }
}
