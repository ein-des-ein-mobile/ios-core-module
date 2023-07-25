//
//  File.swift
//  
//
//  Created by Anton Bal’ on 23.07.2023.
//

import OSLog
import UIKit

private let loggerCategory = "iOS-Core"

struct DeviceInfo: Codable {
    
    static func current() -> DeviceInfo {
        
#if targetEnvironment(simulator)
        let device = "Simulator"
#else
        let device = "Device"
#endif
        return .init(
            system: "\(UIDevice.current.systemName)\(UIDevice.current.systemVersion)",
            model: UIDevice.modelName,
            device: device
        )
    }

    private let system: String
    private let model: String
    private let device: String
}

public protocol CoreLogging {
    func log(_ str: String)
    func error(_ str: String, _ error: Error)
}

public struct CoreLogger: CoreLogging {
   
    private let logger: Logger
    
    public init(category: String? = nil) {
        self.logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: category ?? loggerCategory)
    }
    
    public func log(_ str: String) {
        logger.debug("\(str)")
    }
    
    public func error(_ str: String,_ error: Error) {
        logger.error("\(str) \(error.localizedDescription)")
    }
}
