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
                elapsedSeconds: context.state.elapsedSeconds,
                stepCount: context.state.stepCount
            )

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    TrackingLiveActivityView(
                        groupName: context.attributes.groupName,
                        elapsedSeconds: context.state.elapsedSeconds,
                        stepCount: context.state.stepCount
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
                    value: "\(context.state.stepCount)",
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
    let elapsedSeconds: Int
    let stepCount: Int

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
                    value: TimeInterval(elapsedSeconds).stopwatchFormatted,
                    context: .liveActivity
                )
                TrackingMetric(
                    type: .steps,
                    value: "\(stepCount)",
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
        TrackingActivityAttributes(groupName: "My Walks")
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
