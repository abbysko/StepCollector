//
//  TrackingActivityAttributes.swift
//  StepTrackerShared
//
//  Created by Abigail Skofield on 5/14/26.
//

import ActivityKit

public struct TrackingActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var elapsedSeconds: Int
        public var stepCount: Int

        public init(elapsedSeconds: Int, stepCount: Int) {
            self.elapsedSeconds = elapsedSeconds
            self.stepCount = stepCount
        }
    }

    public var groupName: String

    public init(groupName: String) {
        self.groupName = groupName
    }
}
