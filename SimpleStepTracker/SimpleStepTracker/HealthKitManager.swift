//
//  HealthKitManager.swift
//  SimpleStepTracker
//
//  Created by Abigail Skofield on 4/15/26.
//

import Foundation
import HealthKit

final class HealthKitManager {
    let healthStore = HKHealthStore()

    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            return
        }

        try await healthStore.requestAuthorization(toShare: [], read: [stepType])
    }

    func fetchStepCount(from start: Date, to end: Date) async throws -> Int {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            return 0
        }

        let predicate = HKQuery.predicateForSamples(
            withStart: start,
            end: end,
            options: .strictStartDate
        )

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let count = result?
                    .sumQuantity()?
                    .doubleValue(for: HKUnit.count()) ?? 0

                continuation.resume(returning: Int(count))
            }

            healthStore.execute(query)
        }
    }
}
