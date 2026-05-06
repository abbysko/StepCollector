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

/* Aggregated totals for a single day, used in history charts */
struct DailyWalkTotal: Identifiable {
    let day: Date
    let totalDuration: TimeInterval
    let totalSteps: Int

    var id: Date { day }
}

/* Running cumulative totals across sessions, used in history charts */
struct CumulativeTotals: Identifiable {
    let time: Date
    let cumulativeSteps: Int
    let cumulativeDuration: TimeInterval

    var id: Date { time }
}

