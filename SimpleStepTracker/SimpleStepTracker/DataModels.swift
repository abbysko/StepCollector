//
//  DataModels.swift
//  SimpleStepTracker
//
//  Created by Abigail Skofield on 4/16/26.
//

import SwiftData
import Foundation

/* Individual walk session */
@Model
final class WalkSession {
    var start: Date
    var duration: TimeInterval
    var stepCount: Int

    init(start: Date, duration: TimeInterval, stepCount: Int) {
        self.start = start
        self.duration = duration
        self.stepCount = stepCount
    }
}

/* Named group of walk sessions */
@Model
final class WalkGroup {
    var name: String
    var sessions: [WalkSession] = []

    init(name: String) {
        self.name = name
    }
}


