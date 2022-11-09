//
//  AsyncTask.swift
//  Bobbie
//
//  Created by Anton Bal` on 25.09.2022.
//

import Combine

public typealias AsyncTask<Value> = AnyPublisher<Value, Error>
public typealias AsyncValue<Value> = AnyPublisher<Value, Never>

