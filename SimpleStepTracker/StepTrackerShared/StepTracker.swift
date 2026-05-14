//
//  StepTracker.swift
//  StepTrackerShared
//
//  Created by Abigail Skofield on 5/14/26.
//

import Foundation
import CoreMotion
import Combine

public class StepTracker: NSObject, ObservableObject {
    @Published public var currentStepCount: Int = 0
    @Published public var isRunning: Bool = false
    @Published public var errorMessage: String? = nil
    
    private let pedometer = CMPedometer()
    private static let queryPedometer = CMPedometer()
    
    public override init() {
        super.init()
    }
    
    public func startUpdates(from startDate: Date) {
        guard CMPedometer.isStepCountingAvailable() else {
            errorMessage = "Step counting isn't available on this device."
            return
        }
        
        isRunning = true
        errorMessage = nil
        
        pedometer.startUpdates(from: startDate) { [weak self] data, error in
            DispatchQueue.main.async {
                if error != nil {
                    self?.isRunning = false
                    self?.errorMessage = "Unable to read step data from the pedometer. Check Motion & Fitness permissions in Settings."
                    return
                }
                
                if let steps = data?.numberOfSteps.intValue {
                    self?.currentStepCount = steps
                }
            }
        }
    }
    
    public func stopUpdates() {
        guard isRunning else { return }
        pedometer.stopUpdates()
        isRunning = false
    }

    public static func queryTotalSteps(from startDate: Date, to endDate: Date) async -> Int? {
        guard CMPedometer.isStepCountingAvailable() else {
            return nil
        }

        return await withCheckedContinuation { continuation in
            queryPedometer.queryPedometerData(from: startDate, to: endDate) { data, error in
                guard error == nil else {
                    continuation.resume(returning: nil)
                    return
                }

                continuation.resume(returning: data?.numberOfSteps.intValue)
            }
        }
    }
}
