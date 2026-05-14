//
//  TrackingMetric.swift
//  SimpleStepTracker
//
//  Created by Abigail Skofield on 5/14/26.
//

import SwiftUI

enum MetricType {
    case time
    case steps
    
    var title: String {
        switch self {
        case .time: "Time"
        case .steps: "Steps"
        }
    }
    
    var tint: Color {
        switch self {
        case .time: .green
        case .steps: .cyan
        }
    }
}

enum MetricContext {
    case app
    case liveActivity
    
    var fontSize: CGFloat {
        switch self {
        case .app: 42
        case .liveActivity: 18
        }
    }
    
    var spacing: CGFloat {
        switch self {
        case .app: 4
        case .liveActivity: 2
        }
    }

    var horizontalAlignment: HorizontalAlignment {
        switch self {
        case .app: .center
        case .liveActivity: .leading
        }
    }
}

struct TrackingMetric: View {
    let type: MetricType
    let value: String
    let context: MetricContext

    var body: some View {
        VStack(alignment: context.horizontalAlignment, spacing: context.spacing) {
            Text(type.title)
                .font(.title3)
                .foregroundStyle(.primary)

            Text(value)
                .font(.system(size: context.fontSize, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(type.tint)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        TrackingMetric(type: .time, value: "15:42", context: .app)
        TrackingMetric(type: .steps, value: "1,234", context: .app)
        TrackingMetric(type: .time, value: "3:21", context: .liveActivity)
        TrackingMetric(type: .steps, value: "842", context: .liveActivity)
    }
    .padding()
}
