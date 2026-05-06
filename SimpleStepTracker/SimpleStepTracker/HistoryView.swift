//
//  HistoryView.swift
//  SimpleStepTracker
//
//  Created by Abigail Skofield on 4/15/26.
//

import SwiftUI
import Charts
import SwiftData

struct DailyWalkTotal: Identifiable {
    let day: Date
    let totalDuration: TimeInterval
    let totalSteps: Int
    
    var id: Date { day }
}

struct CumulativeTotals: Identifiable {
    let time: Date
    let cumulativeSteps: Int
    let cumulativeDuration: TimeInterval
    
    var id: Date { time }
}

struct HistoryView: View {
    @State private var selectedMetric: Metric = .steps
    
    @Binding var selectedGroup: WalkGroup?
    
    private var sessions: [WalkSession] {
        (selectedGroup?.sessions ?? []).sorted { $0.start < $1.start }
    }
    
    enum Metric: String, CaseIterable {
        case steps = "Steps"
        case duration = "Duration"
        case allSessions = "List"
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            Text("Current group: \(selectedGroup?.name ?? "No Group Selected")").frame(maxWidth: .infinity, alignment: .center)
            
            Picker("Metric", selection: $selectedMetric) {
                ForEach(Metric.allCases, id: \.self) { metric in
                    Text(metric.rawValue)
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
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        } else if selectedMetric == .allSessions {
            sessionsSection
        } else {
            plotsSection
        }
    }
    
    
    private var plotsSection: some View{
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // Cumulative sum plot
                let cumulativePlotTitle = selectedMetric == .duration ? "Cumulative duration (min)" : "Cumulative steps"
                Text(cumulativePlotTitle)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .padding(.horizontal)
                cumulativePlot
                
                // Daily Totals Plot
                let plotTitle = selectedMetric == .duration ? "Duration by day" : "Steps by day"
                Text(plotTitle)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .padding(.horizontal)
                totalPlot
            }
        }
    }
    
    private var sessionsSection: some View{
        VStack(alignment: .leading, spacing: 12) {
            List(sessions.reversed()) { session in
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(session.start.formatted(date: .abbreviated, time: .shortened))")
                    
                    Text("\(String(session.stepCount)) steps; \(session.duration.durationFormatted)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .listStyle(.plain)
        }
    }
    
    private var cumulativePlot: some View{
        Chart(cumulativeTotals) { point in
            LineMark(
                x: .value("Time", point.time),
                y: .value(
                    selectedMetric == .duration ? "Cumulative Minutes" : "Cumulative Steps",
                    selectedMetric == .duration
                    ? point.cumulativeDuration / 60
                    : Double(point.cumulativeSteps)
                )
            )
            
            PointMark(
                x: .value("Time", point.time),
                y: .value(
                    selectedMetric == .duration ? "Cumulative Minutes" : "Cumulative Steps",
                    selectedMetric == .duration
                    ? point.cumulativeDuration / 60
                    : Double(point.cumulativeSteps)
                )
            )
        }
        .frame(height: 220)
        .padding(.horizontal)
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                AxisValueLabel(format: .dateTime.month().day())
            }
        }
    }
    
    private var totalPlot: some View{
        Chart(dailyTotals) { item in
            BarMark(
                x: .value("Day", item.day, unit: .day),
                y: .value(
                    selectedMetric == .duration ? "Minutes" : "Steps",
                    selectedMetric == .duration
                    ? item.totalDuration / 60
                    :  Double(item.totalSteps)
                )
            )
        }
        .frame(height: 220)
        .padding(.horizontal)
    }
    
    private var cumulativeTotals: [CumulativeTotals] {
        let sortedSessions = sessions.sorted { $0.start < $1.start }
        
        var runningTotalSteps = 0
        var runningTotalDuration: TimeInterval = 0
        
        return sortedSessions.map { session in
            runningTotalSteps += session.stepCount
            runningTotalDuration += session.duration
            return CumulativeTotals(
                time: session.start,
                cumulativeSteps: runningTotalSteps,
                cumulativeDuration: runningTotalDuration
            )
        }
    }
    
    private var dailyTotals: [DailyWalkTotal] {
        let calendar = Calendar.current
        
        let grouped = Dictionary(grouping: sessions) { session in
            calendar.startOfDay(for: session.start)
        }
        
        return grouped
            .map { day, sessionsForDay in
                DailyWalkTotal(
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
