//
//  SimpleStepTrackerWidgetsLiveActivity.swift
//  SimpleStepTrackerWidgets
//
//  Created by Abigail Skofield on 5/14/26.
//

import ActivityKit
import WidgetKit
import SwiftUI
import StepTrackerShared

struct SimpleStepTrackerWidgetsLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TrackingActivityAttributes.self) { context in
            TrackingLiveActivityView(
                groupName: context.attributes.groupName,
                startedAt: context.attributes.startedAt,
                stepCount: context.state.stepCount,
                lastStepRefreshAt: context.state.lastStepRefreshAt
            )

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    TrackingLiveActivityView(
                        groupName: context.attributes.groupName,
                        startedAt: context.attributes.startedAt,
                        stepCount: context.state.stepCount,
                        lastStepRefreshAt: context.state.lastStepRefreshAt
                    )
                }
            } compactLeading: {
                HStack() {
                    WalkerIcon(size: 20, style: .circle)
                    GroupNameText(context.attributes.groupName)
                }
            } compactTrailing: {
                TimelineView(.explicit(staleDates(for: context.state.lastStepRefreshAt))) { _ in
                    TrackingMetric(
                        type: .steps,
                        value: formattedStepValue(stepCount: context.state.stepCount, lastStepRefreshAt: context.state.lastStepRefreshAt),
                        context: .liveActivity,
                        inlineHeader: true
                    )
                }
            } minimal: {
                WalkerIcon(size: 20, style: .circle)
            }
            .keylineTint(.green)
        }
    }
}

private struct TrackingLiveActivityView: View {
    let groupName: String
    let startedAt: Date
    let stepCount: Int
    let lastStepRefreshAt: Date?

    var body: some View {
        HStack(spacing: 16) {
            WalkerIcon(size: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text("Tracking")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                GroupNameText(groupName)
            }

            Spacer()

            HStack(alignment: .center, spacing: 20) {
                TrackingMetric(
                    type: .time,
                    value: "",
                    context: .liveActivity,
                    timerStartedAt: startedAt
                )
                TimelineView(.explicit(staleDates(for: lastStepRefreshAt))) { _ in
                    TrackingMetric(
                        type: .steps,
                        value: formattedStepValue(stepCount: stepCount, lastStepRefreshAt: lastStepRefreshAt),
                        context: .liveActivity
                    )
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

private let stepFreshnessWindow: TimeInterval = 10

private func staleDates(for lastStepRefreshAt: Date?) -> [Date] {
    guard let last = lastStepRefreshAt,
          Date().timeIntervalSince(last) <= stepFreshnessWindow else {
        return []
    }
    return [last.addingTimeInterval(stepFreshnessWindow)]
}

private func formattedStepValue(stepCount: Int, lastStepRefreshAt: Date?) -> String {
    guard let lastStepRefreshAt,
          Date().timeIntervalSince(lastStepRefreshAt) <= stepFreshnessWindow else {
        return "--"
    }

    return "\(stepCount)"
}

private struct GroupNameText: View {
    let groupName: String

    init(_ groupName: String) {
        self.groupName = groupName
    }

    var body: some View {
        Text(groupName)
            .font(.footnote.weight(.semibold))
            .lineLimit(1)
    }
}

extension TrackingActivityAttributes {
    fileprivate static var preview: TrackingActivityAttributes {
        TrackingActivityAttributes(groupName: "My Walks", startedAt: .now.addingTimeInterval(-300))
    }
}

extension TrackingActivityAttributes.ContentState {
    fileprivate static var preview: TrackingActivityAttributes.ContentState {
        TrackingActivityAttributes.ContentState(elapsedSeconds: 300, stepCount: 1247, lastStepRefreshAt: .now)
    }
}

#Preview("Lock Screen", as: .content, using: TrackingActivityAttributes.preview) {
   SimpleStepTrackerWidgetsLiveActivity()
} contentStates: {
    TrackingActivityAttributes.ContentState.preview
}

#Preview("DI Expanded", as: .dynamicIsland(.expanded), using: TrackingActivityAttributes.preview) {
   SimpleStepTrackerWidgetsLiveActivity()
} contentStates: {
    TrackingActivityAttributes.ContentState.preview
}

#Preview("DI Compact", as: .dynamicIsland(.compact), using: TrackingActivityAttributes.preview) {
   SimpleStepTrackerWidgetsLiveActivity()
} contentStates: {
    TrackingActivityAttributes.ContentState.preview
}

#Preview("DI Minimal", as: .dynamicIsland(.minimal), using: TrackingActivityAttributes.preview) {
   SimpleStepTrackerWidgetsLiveActivity()
} contentStates: {
    TrackingActivityAttributes.ContentState.preview
}
