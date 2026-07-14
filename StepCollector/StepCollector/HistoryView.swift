//
//  HistoryView.swift
//  Step Collector
//
//  Created by Abigail Skofield on 4/15/26.
//

import SwiftUI
import Charts
import SwiftData
import StepTrackerShared

struct HistoryView: View {
    @State private var displayType: DisplayOption = .steps
    @State private var selectedChartDay: Date?
    @State private var visibleDaySpan: Double?
    @State private var gestureStartDaySpan: Double?
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
                HStack {
                    Text(cumulativeTitle)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    if isZoomedIn {
                        Button("Reset Zoom") {
                            resetZoom()
                        }
                        .font(.footnote.weight(.semibold))
                    }
                }
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
        Chart(displayedCumulativeTotals) { point in
            let yLabel = displayType == .duration ? "Cumulative Minutes" : "Cumulative Steps"
            let yValue = displayType == .duration ? point.cumulativeDuration / 60 : Double(point.cumulativeSteps)

            LineMark(x: .value("Time", point.time), y: .value(yLabel, yValue))
            PointMark(x: .value("Time", point.time), y: .value(yLabel, yValue))
        }
        .chartXScale(domain: visibleDateDomain)
        .chartOverlay { _ in
            VStack(alignment: .leading, spacing: 2) {
                Text(displayType == .duration ? "Total time" : "Total steps")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(totalCumulativeValueText)
                    .font(.headline)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(.top, 8)
            .padding(.leading, 8)
            .allowsHitTesting(false)
        }
        .frame(height: 220)
        .padding(.horizontal)
        .chartXAxis {
            AxisMarks(values: .automatic) { _ in
                AxisValueLabel(format: .dateTime.month().day())
            }
        }
        .simultaneousGesture(zoomGesture)
    }
    
    private var totalPlot: some View{
        Chart(displayedDailyTotals) { item in
            let yLabel = displayType == .duration ? "Minutes" : "Steps"
            let yValue = displayType == .duration
                ? item.totalDuration / 60
                : Double(item.totalSteps)
            let hasSelection = selectedDailyTotal != nil
            let isSelected = selectedDailyTotal?.day == item.day

            BarMark(
                x: .value("Day", item.day, unit: .day),
                y: .value(yLabel, yValue)
            )
            .foregroundStyle(hasSelection ? (isSelected ? .blue : .blue.opacity(0.55)) : .blue)
        }
        .chartXScale(domain: visibleDateDomain)
        .chartOverlay { chartProxy in
            GeometryReader { geometry in
                Rectangle()
                    .fill(.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        SpatialTapGesture()
                            .onEnded { value in
                                toggleDailySelection(at: value.location, chartProxy: chartProxy, geometry: geometry)
                            }
                    )
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 8)
                            .onChanged { value in
                                updateDailySelection(at: value.location, chartProxy: chartProxy, geometry: geometry)
                            }
                    )

                if let selectedDailyTotal {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(selectedDailyTotal.day.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text(selectedDailyValueText(for: selectedDailyTotal))
                            .font(.headline)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(.top, 8)
                    .padding(.leading, 8)
                    .allowsHitTesting(false)
                } else {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Daily average (\(displayedDailyTotals.count) days)")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text(averageDailyValueText)
                            .font(.headline)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(.top, 8)
                    .padding(.leading, 8)
                    .allowsHitTesting(false)
                }
            }
        }
        .frame(height: 220)
        .padding(.horizontal)
        .simultaneousGesture(zoomGesture)
    }

    private var zoomGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                let fullSpan = fullDaySpan
                let baseline = gestureStartDaySpan ?? visibleDaySpan ?? fullSpan
                if gestureStartDaySpan == nil {
                    gestureStartDaySpan = baseline
                }

                let proposed = baseline / value.magnification
                visibleDaySpan = min(max(proposed, 3), fullSpan)
            }
            .onEnded { _ in
                gestureStartDaySpan = nil
                guard let visibleDaySpan else { return }

                if visibleDaySpan >= fullDaySpan - 0.5 {
                    self.visibleDaySpan = nil
                }
            }
    }

    private var isZoomedIn: Bool {
        visibleDaySpan != nil
    }

    private func resetZoom() {
        visibleDaySpan = nil
        gestureStartDaySpan = nil
    }

    private var selectedDailyTotal: HistoryDailyWalkTotal? {
        guard let selectedChartDay else { return nil }
        return displayedDailyTotals.min {
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

    private var averageDailyValueText: String {
        guard !displayedDailyTotals.isEmpty else {
            return displayType == .duration ? "0 min" : "0 steps"
        }

        if displayType == .duration {
            let averageMinutes = displayedDailyTotals.reduce(0) { $0 + ($1.totalDuration / 60) } / Double(displayedDailyTotals.count)
            return "\(Int(averageMinutes.rounded())) min"
        }

        let averageSteps = Double(displayedDailyTotals.reduce(0) { $0 + $1.totalSteps }) / Double(displayedDailyTotals.count)
        return "\(Int(averageSteps.rounded())) steps"
    }

    private var totalCumulativeValueText: String {
        guard let latestTotal = cumulativeTotals.last else {
            return displayType == .duration ? "0 min" : "0 steps"
        }

        if displayType == .duration {
            return latestTotal.cumulativeDuration.durationFormatted
        }

        return "\(latestTotal.cumulativeSteps) steps"
    }

    private func updateDailySelection(
        at location: CGPoint,
        chartProxy: ChartProxy,
        geometry: GeometryProxy
    ) {
        selectedChartDay = nearestDailyDay(at: location, chartProxy: chartProxy, geometry: geometry)
    }

    private func toggleDailySelection(
        at location: CGPoint,
        chartProxy: ChartProxy,
        geometry: GeometryProxy
    ) {
        guard let nearestDay = nearestDailyDay(at: location, chartProxy: chartProxy, geometry: geometry) else {
            return
        }

        if let selectedChartDay,
           Calendar.current.isDate(nearestDay, inSameDayAs: selectedChartDay) {
            self.selectedChartDay = nil
        } else {
            selectedChartDay = nearestDay
        }
    }

    private func nearestDailyDay(
        at location: CGPoint,
        chartProxy: ChartProxy,
        geometry: GeometryProxy
    ) -> Date? {
        guard let plotFrame = chartProxy.plotFrame else { return nil }
        let plotAreaFrame = geometry[plotFrame]
        let xPosition = location.x - plotAreaFrame.origin.x

        guard xPosition >= 0, xPosition <= chartProxy.plotSize.width else { return nil }

        return displayedDailyTotals.min { lhs, rhs in
            let lhsX = chartProxy.position(forX: dayCenter(for: lhs.day)) ?? .greatestFiniteMagnitude
            let rhsX = chartProxy.position(forX: dayCenter(for: rhs.day)) ?? .greatestFiniteMagnitude
            return abs(lhsX - xPosition) < abs(rhsX - xPosition)
        }?.day
    }

    private func dayCenter(for day: Date) -> Date {
        Calendar.current.date(byAdding: .hour, value: 12, to: day) ?? day
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

    private var fullDateDomain: ClosedRange<Date> {
        guard let first = sessions.first?.start,
              let last = sessions.last?.start else {
            let now = Date()
            return now...now
        }

        let calendar = Calendar.current
        let start = calendar.startOfDay(for: first)
        let lastDay = calendar.startOfDay(for: last)
        let inclusiveEnd = calendar.date(byAdding: .day, value: 1, to: lastDay)?.addingTimeInterval(-1) ?? last
        return start...inclusiveEnd
    }

    private var fullDaySpan: Double {
        max(1, fullDateDomain.upperBound.timeIntervalSince(fullDateDomain.lowerBound) / 86_400)
    }

    private var visibleDateDomain: ClosedRange<Date> {
        guard let visibleDaySpan else { return fullDateDomain }

        let duration = visibleDaySpan * 86_400
        let startCandidate = fullDateDomain.upperBound.addingTimeInterval(-duration)
        let boundedStart = max(startCandidate, fullDateDomain.lowerBound)
        return boundedStart...fullDateDomain.upperBound
    }

    private var displayedCumulativeTotals: [HistoryCumulativeTotals] {
        cumulativeTotals.filter { visibleDateDomain.contains($0.time) }
    }

    private var displayedDailyTotals: [HistoryDailyWalkTotal] {
        dailyTotals.filter { visibleDateDomain.contains($0.day) }
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
            start: Date().addingTimeInterval(-1*60*60*24*1),
            duration: 1200,
            stepCount: 200
        ),
        WalkSession(
            start: Date().addingTimeInterval(-1*60*60*24*2),
            duration: 4500,
            stepCount: 100
        ),
        WalkSession(
            start: Date().addingTimeInterval(-1*60*60*24*3),
            duration: 800,
            stepCount: 300
        ),
        WalkSession(
            start: Date().addingTimeInterval(-1*60*60*24*4),
            duration: 1200,
            stepCount: 200
        ),
        WalkSession(
            start: Date().addingTimeInterval(-1*60*60*24*6),
            duration: 3000,
            stepCount: 350
        ),
        WalkSession(
            start: Date().addingTimeInterval(-1*60*60*24*8),
            duration: 1200,
            stepCount: 400
        )
    ]
    
    return HistoryView(
        selectedGroup: .constant(group)
    )
}

#Preview("Lots of sessions") {
    let group = WalkGroup(name: "Daily Walks")
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())

    group.sessions = stride(from: 0, through: 58, by: 1).map { dayOffset in
        let start = calendar.date(byAdding: .day, value: -dayOffset, to: today) ?? today
        let duration = TimeInterval(900 + ((dayOffset * 73) % 2400))
        let stepCount = 1800 + ((dayOffset * 131) % 5200)
        return WalkSession(start: start, duration: duration, stepCount: stepCount)
    }

    return HistoryView(
        selectedGroup: .constant(group)
    )
}

#Preview("Empty history"){
    HistoryView(
        selectedGroup: .constant(WalkGroup(name: "Walks with kids")))
}

