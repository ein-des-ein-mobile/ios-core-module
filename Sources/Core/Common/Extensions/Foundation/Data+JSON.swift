//
//  File.swift
//  
//
//  Created by Anton Bal’ on 15.08.2023.
//

import Foundation

/// NSString gives us a nice sanitized debugDescription
public extension Data {
    var prettyPrintedJSONString: NSString? {
        guard
            let object = try? JSONSerialization.jsonObject(with: self, options: []),
            let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted])
        else {
            return NSString(data: self, encoding: String.Encoding.utf8.rawValue)
        }

        return NSString(data: data, encoding: String.Encoding.utf8.rawValue)
    }
}
