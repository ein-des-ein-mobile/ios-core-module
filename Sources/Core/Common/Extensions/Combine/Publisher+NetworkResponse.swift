//
//  File.swift
//  
//
//  Created by Anton Bal` on 09.11.2022.
//

import Foundation
import Combine

public extension Publisher
    where
    Output == NetworkResponse
{
    func jsonDecode<T: Decodable>(_ type: T.Type,
                              decoder: JSONDecoder = JSONDecoder()) ->
    Publishers.Decode<Publishers.Map<Self, JSONDecoder.Input>, T, JSONDecoder> {
        self
            .map { $0.data }
            .decode(type: type, decoder: decoder)
    }
}



