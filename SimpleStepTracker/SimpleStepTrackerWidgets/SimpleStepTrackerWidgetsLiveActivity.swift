//
//  SimpleStepTrackerWidgetsLiveActivity.swift
//  SimpleStepTrackerWidgets
//
//  Created by Abigail Skofield on 5/14/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct TrackingActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var elapsedSeconds: Int
        var stepCount: Int
    }

    var groupName: String
}

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
                DynamicIslandExpandedRegion(.leading) {
                    Text("Tracking")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.state.stepCount) steps")
                        .font(.caption)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    TrackingLiveActivityView(
                        groupName: context.attributes.groupName,
                        elapsedSeconds: context.state.elapsedSeconds,
                        stepCount: context.state.stepCount
                    )
                }
            } compactLeading: {
                Image(systemName: "figure.walk")
            } compactTrailing: {
                Text(TimeInterval(context.state.elapsedSeconds).stopwatchFormatted)
                    .monospacedDigit()
            } minimal: {
                Image(systemName: "figure.walk")
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
            LiveWalkerIcon(size: 28, cornerRadius: 8)

            VStack(alignment: .leading, spacing: 2) {
                Text("Tracking")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(groupName)
                    .font(.footnote.weight(.semibold))
                    .lineLimit(1)
            }

            Spacer()

            HStack(alignment: .center, spacing: 20) {
                LiveMetric(title: "Time", value: TimeInterval(elapsedSeconds).stopwatchFormatted, tint: .green)
                LiveMetric(title: "Steps", value: "\(stepCount)", tint: .cyan)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

private struct LiveWalkerIcon: View {
    let size: CGFloat
    let cornerRadius: CGFloat

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.75, green: 0.25, blue: 0.65), Color(red: 0.15, green: 0.15, blue: 0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Image(systemName: "figure.walk")
                .foregroundStyle(.white)
                .font(.system(size: size * 0.45, weight: .semibold))
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

private struct LiveMetric: View {
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(tint)
        }
    }
}

private extension TimeInterval {
    var stopwatchFormatted: String {
        let elapsed = max(0, Int(self))
        let hours = elapsed / 3600
        let minutes = (elapsed % 3600) / 60
        let seconds = elapsed % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
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

#Preview("Notification", as: .content, using: TrackingActivityAttributes.preview) {
   SimpleStepTrackerWidgetsLiveActivity()
} contentStates: {
    TrackingActivityAttributes.ContentState.preview
}
