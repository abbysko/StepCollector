//
//  TrackingActivityAttributes.swift
//  StepTrackerShared
//
//  Created by Abigail Skofield on 5/14/26.
//

import ActivityKit
import Foundation

public struct TrackingActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var elapsedSeconds: Int
        public var stepCount: Int
        public var lastStepRefreshAt: Date?

        public init(elapsedSeconds: Int, stepCount: Int, lastStepRefreshAt: Date? = nil) {
            self.elapsedSeconds = elapsedSeconds
            self.stepCount = stepCount
            self.lastStepRefreshAt = lastStepRefreshAt
        }
    }

    public var groupName: String
    public var startedAt: Date

    public init(groupName: String, startedAt: Date) {
        self.groupName = groupName
        self.startedAt = startedAt
    }
}
