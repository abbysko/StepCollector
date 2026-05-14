//
//  TrackingLiveActivity.swift
//  SimpleStepTracker
//
//  Created by Abigail Skofield on 5/14/26.
//

import ActivityKit
import SwiftUI

struct TrackingActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var elapsedSeconds: Int
        var stepCount: Int
    }

    var groupName: String
}

struct TrackingLiveActivityView: View {
    let groupName: String
    let elapsedSeconds: Int
    let stepCount: Int

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Tracking")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(groupName)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
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

#Preview("Live Activity") {
    TrackingLiveActivityView(
        groupName: "My Walks",
        elapsedSeconds: 300,
        stepCount: 1247
    )
}
