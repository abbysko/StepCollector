//
//  HistoryView.swift
//  SimpleStepTracker
//
//  Created by Abigail Skofield on 4/15/26.
//

import SwiftUI
import Charts
import SwiftData

struct HistoryView: View {
    @State private var displayType: DisplayOption = .steps
    @State private var selectedChartDay: Date?
    @Environment(\.modelContext) private var modelContext
    
    @Binding var selectedGroup: WalkGroup?
    
    private var sessions: [WalkSession] {
        (selectedGroup?.sessions ?? []).sorted { $0.start < $1.start }
    }

    private var reversedSessions: [WalkSession] {
        Array(sessions.reversed())
    }
    
    enum DisplayOption: String, CaseIterable {
        case steps = "Steps"
        case duration = "Duration"
        case list = "List"
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            Picker("DisplayOption", selection: $displayType) {
                ForEach(DisplayOption.allCases, id: \.self) { option in
                    Text(option.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            historyContentView
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
    
    @ViewBuilder
    private var historyContentView: some View {
        if sessions.isEmpty {
            Text("No saved sessions")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding()
        } else if displayType == .list {
            listView
        } else {
            plotsView
        }
    }
    
    private var plotsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                let cumulativeTitle = displayType == .duration ? "Cumulative duration (min)" : "Cumulative steps"
                Text(cumulativeTitle)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .padding(.horizontal)
                cumulativePlot

                let dailyTitle = displayType == .duration ? "Duration by day (min)" : "Steps by day"
                Text(dailyTitle)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .padding(.horizontal)
                totalPlot
            }
        }
    }
    
    private var listView: some View {
        List {
            ForEach(reversedSessions) { session in
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.start.formatted(date: .abbreviated, time: .shortened))

                    Text("\(session.stepCount) steps; \(session.duration.durationFormatted)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .onDelete(perform: deleteSessions)
        }
        .listStyle(.plain)
    }

    private func deleteSessions(at offsets: IndexSet) {
        guard let selectedGroup else { return }

        let sessionsToDelete = offsets.map { reversedSessions[$0] }
        for session in sessionsToDelete {
            selectedGroup.sessions.removeAll { $0 === session }
            modelContext.delete(session)
        }
    }
    
    private var cumulativePlot: some View {
        Chart(cumulativeTotals) { point in
            let yLabel = displayType == .duration ? "Cumulative Minutes" : "Cumulative Steps"
            let yValue = displayType == .duration ? point.cumulativeDuration / 60 : Double(point.cumulativeSteps)

            LineMark(x: .value("Time", point.time), y: .value(yLabel, yValue))
            PointMark(x: .value("Time", point.time), y: .value(yLabel, yValue))
        }
        .frame(height: 220)
        .padding(.horizontal)
        .chartXAxis {
            AxisMarks(values: .automatic) { _ in
                AxisValueLabel(format: .dateTime.month().day())
            }
        }
    }
    
    private var totalPlot: some View{
        VStack(alignment: .leading, spacing: 10) {
            Chart(dailyTotals) { item in
                BarMark(
                    x: .value("Day", item.day, unit: .day),
                    y: .value(
                        displayType == .duration ? "Minutes" : "Steps",
                        displayType == .duration
                        ? item.totalDuration / 60
                        :  Double(item.totalSteps)
                    )
                )

                if let selectedDailyTotal {
                    RuleMark(x: .value("Selected Day", selectedDailyTotal.day, unit: .day))
                        .foregroundStyle(.secondary.opacity(0.35))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                }
            }
            .chartXSelection(value: $selectedChartDay)

            if let selectedDailyTotal {
                HStack(spacing: 8) {
                    Text(selectedDailyTotal.day.formatted(date: .abbreviated, time: .omitted))
                        .font(.footnote.weight(.semibold))

                    Text("•")
                        .foregroundStyle(.secondary)

                    Text(selectedDailyValueText(for: selectedDailyTotal))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 2)
            } else {
                Text("Tap a bar for details")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 2)
            }
        }
        .frame(height: 220)
        .padding(.horizontal)
    }

    private var selectedDailyTotal: HistoryDailyWalkTotal? {
        guard let selectedChartDay else { return nil }
        return dailyTotals.min {
            abs($0.day.timeIntervalSince(selectedChartDay)) < abs($1.day.timeIntervalSince(selectedChartDay))
        }
    }

    private func selectedDailyValueText(for total: HistoryDailyWalkTotal) -> String {
        if displayType == .duration {
            let minutes = Int((total.totalDuration / 60).rounded())
            return "\(minutes) min"
        }

        return "\(total.totalSteps) steps"
    }
    
    private var cumulativeTotals: [HistoryCumulativeTotals] {
        var runningSteps = 0
        var runningDuration: TimeInterval = 0

        return sessions.map { session in
            runningSteps += session.stepCount
            runningDuration += session.duration
            return HistoryCumulativeTotals(
                time: session.start,
                cumulativeSteps: runningSteps,
                cumulativeDuration: runningDuration
            )
        }
    }
    
    private var dailyTotals: [HistoryDailyWalkTotal] {
        let calendar = Calendar.current
        
        let grouped = Dictionary(grouping: sessions) { session in
            calendar.startOfDay(for: session.start)
        }
        
        return grouped
            .map { day, sessionsForDay in
                HistoryDailyWalkTotal(
                    day: day,
                    totalDuration: sessionsForDay.reduce(0) { $0 + $1.duration },
                    totalSteps: sessionsForDay.reduce(0) { $0 + $1.stepCount }
                )
            }
            .sorted { $0.day < $1.day }
    }
    
}

#Preview("Default"){
    let group = WalkGroup(name: "Walks with kids")
    group.sessions = [
        WalkSession(
            start: Date().addingTimeInterval(-203600),
            duration: 1200,
            stepCount: 200
        ),
        WalkSession(
            start: Date().addingTimeInterval(-100600),
            duration: 4500,
            stepCount: 100
        ),
        WalkSession(
            start: Date().addingTimeInterval(-300600),
            duration: 800,
            stepCount: 300
        )
    ]
    
    return HistoryView(
        selectedGroup: .constant(group)
    )
}

#Preview("Empty history"){
    HistoryView(
        selectedGroup: .constant(WalkGroup(name: "Walks with kids")))
}

