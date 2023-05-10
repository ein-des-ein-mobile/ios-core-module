//
//  LoggerPlugin.swift
//  
//
//  Created by Anton Bal’ on 09.05.2023.
//

import Foundation
import OSLog

public struct LoggerPlugin {
    private static let os_logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "EDE")
    let isEnabled: Bool
    
    public init(isEnabled: Bool) {
        self.isEnabled = isEnabled
    }
}

extension LoggerPlugin: NetworkPlugin {
    public func didReceive(_ result: Result<NetworkResponse, Error>,
                           data: Data?,
                           request: URLRequest,
                           target: RequestConvertible
    ) {
        guard isEnabled else { return }

        let message = request.url?.absoluteString ?? "Invalid URL"
        
        LoggerPlugin.os_logger.debug("\(message)")
        
        switch result {
            
        case .success(let response):
            let value = String(data: response.data, encoding: .utf8) ?? ""
            LoggerPlugin.os_logger.debug("\(value)")
            
        case .failure(let error):
            LoggerPlugin.os_logger.debug("\(error.localizedDescription)")
            
            if let data = data {
                let value = String(data: data, encoding: .utf8) ?? ""
                LoggerPlugin.os_logger.debug("\(value)")
            }
        }
    }
}
