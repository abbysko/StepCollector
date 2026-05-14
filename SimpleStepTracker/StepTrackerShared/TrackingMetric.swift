//
//  TrackingMetric.swift
//  StepTrackerShared
//
//  Created by Abigail Skofield on 5/14/26.
//

import SwiftUI
import Foundation

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
    public let inlineHeader: Bool
    public let elapsed: TimeInterval?
    public let timerStartedAt: Date?
    public let startedAt: Date?

    public init(type: MetricType, value: String, context: MetricContext) {
        self.type = type
        self.value = value
        self.context = context
        self.inlineHeader = false
        self.elapsed = nil
        self.timerStartedAt = nil
        self.startedAt = nil
    }

    public init(type: MetricType, value: String, context: MetricContext, inlineHeader: Bool = false) {
        self.type = type
        self.value = value
        self.context = context
        self.inlineHeader = inlineHeader
        self.elapsed = nil
        self.timerStartedAt = nil
        self.startedAt = nil
    }

    public init(type: MetricType, value: String, context: MetricContext, inlineHeader: Bool = false, elapsed: TimeInterval? = nil, timerStartedAt: Date? = nil, startedAt: Date? = nil) {
        self.type = type
        self.value = value
        self.context = context
        self.inlineHeader = inlineHeader
        self.elapsed = elapsed
        self.timerStartedAt = timerStartedAt
        self.startedAt = startedAt
    }
    
    public var body: some View {
        if inlineHeader {
            HStack(alignment: .center, spacing: 6) {
                titleText
                valueText
            }
        } else {
            VStack(alignment: .leading, spacing: context.spacing) {
                titleText
                valueText
            }
        }
    }

    private var titleText: some View {
        Text(type.title)
            .font(.caption)
            .foregroundStyle(.secondary)
    }

    @ViewBuilder
    private var valueText: some View {
        if type == .time {
            if let timerStartedAt {
                Text(timerInterval: timerStartedAt...Date.distantFuture, countsDown: false, showsHours: true)
                    .font(.system(size: context.fontSize, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(type.tint)
            } else if let elapsed {
                Text(elapsed.compactStopwatchFormatted)
                    .font(.system(size: context.fontSize, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(type.tint)
            } else {
                Text(displayValue)
                    .font(.system(size: context.fontSize, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(type.tint)
            }
        } else {
            Text(displayValue)
                .font(.system(size: context.fontSize, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(type.tint)
        }
    }

    private var displayValue: String {
        guard type == .time else { return value }

        let components = value.split(separator: ":")
        guard components.count == 3 else { return value }

        // Collapse 00:MM:SS to MM:SS for cleaner sub-hour display.
        if components[0] == "00" {
            return "\(components[1]):\(components[2])"
        }

        return value
    }
}
