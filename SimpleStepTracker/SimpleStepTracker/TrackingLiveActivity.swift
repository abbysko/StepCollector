//
//  TrackingLiveActivity.swift
//  SimpleStepTracker
//
//  Created by Abigail Skofield on 5/14/26.
//

import ActivityKit

struct TrackingActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var elapsedSeconds: Int
        var stepCount: Int
    }

    var groupName: String
}
