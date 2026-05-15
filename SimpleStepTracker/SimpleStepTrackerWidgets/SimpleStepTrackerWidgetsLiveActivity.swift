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
            let stepValue = context.isStale ? "--" : "\(context.state.stepCount)"
            TrackingLiveActivityView(
                groupName: context.attributes.groupName,
                startedAt: context.attributes.startedAt,
                stepCount: stepValue
            )

        } dynamicIsland: { context in
            let stepValue = context.isStale ? "--" : "\(context.state.stepCount)"
            return DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    TrackingLiveActivityView(
                        groupName: context.attributes.groupName,
                        startedAt: context.attributes.startedAt,
                        stepCount: stepValue
                    )
                }
            } compactLeading: {
                HStack() {
                    WalkerIcon(size: 20, style: .circle)
                    GroupNameText(context.attributes.groupName)
                }
            } compactTrailing: {
                TrackingMetric(
                    type: .steps,
                    value: stepValue,
                    context: .liveActivity,
                    inlineHeader: true
                )
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
    let stepCount: String

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
                TrackingMetric(
                    type: .steps,
                    value: stepCount,
                    context: .liveActivity
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
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
        TrackingActivityAttributes.ContentState(elapsedSeconds: 300, stepCount: 1247)
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
