//
//  Task.swift
//

import Foundation

public enum NetworkTask {
    /// A request with no additional data.
    case requestPlain

    /// A requests body set with data.
    case requestData(Data)

    /// A requests body set with encoded parameters.
    case requestParameters(parameters: NetworkParameters)
}

