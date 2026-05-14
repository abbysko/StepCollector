//
//  TrackingMetric.swift
//  StepTrackerShared
//
//  Created by Abigail Skofield on 5/14/26.
//

import SwiftUI

public enum MetricType {
    case time
    case steps
    
    public var title: String {
        switch self {
        case .time: "Time"
        case .steps: "Steps"
        }
    }
    
    public var tint: Color {
        switch self {
        case .time: .green
        case .steps: .cyan
        }
    }
}

public enum MetricContext {
    case app
    case liveActivity
    
    public var fontSize: CGFloat {
        switch self {
        case .app: 42
        case .liveActivity: 18
        }
    }
    
    public var spacing: CGFloat {
        switch self {
        case .app: 8
        case .liveActivity: 2
        }
    }
}

public struct TrackingMetric: View {
    public let type: MetricType
    public let value: String
    public let context: MetricContext

    public init(type: MetricType, value: String, context: MetricContext) {
        self.type = type
        self.value = value
        self.context = context
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: context.spacing) {
            Text(type.title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: context.fontSize, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(type.tint)
        }
    }
}
