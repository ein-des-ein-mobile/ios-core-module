//
//  Command.swift
//
//  Created by Anton Bal` on 11.11.2022.
//

import Foundation

public typealias Command = () -> Void
public typealias CommandWith<T> = (T) -> Void
