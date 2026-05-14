//
//  Formatters.swift
//  StepTrackerShared
//
//  Created by Abigail Skofield on 5/6/26.
//

import Foundation

public extension TimeInterval {
    /// Formats the interval as a stopwatch string: `HH:MM:SS`.
    var stopwatchFormatted: String {
        let elapsed = max(0, Int(self))
        let hours = elapsed / 3600
        let minutes = (elapsed % 3600) / 60
        let seconds = elapsed % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    /// Formats the interval as a compact stopwatch: `MM:SS` until 1 hour, then `HH:MM:SS`.
    var compactStopwatchFormatted: String {
        let elapsed = max(0, Int(self))
        let hours = elapsed / 3600
        let minutes = (elapsed % 3600) / 60
        let seconds = elapsed % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }

    /// Formats the interval in a human-readable style: `"X hr Y min"`, `"X min Y sec"`, or `"X sec"`.
    var durationFormatted: String {
        let totalSeconds = Int(self)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return String(format: "%d hr %d min", hours, minutes)
        } else if minutes > 0 {
            return String(format: "%d min %d sec", minutes, seconds)
        } else {
            return String(format: "%d sec", seconds)
        }
    }
}
