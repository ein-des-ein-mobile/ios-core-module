//
//  With.swift
//  Domain
//

import Foundation

@discardableResult
public func with<T>(_ value: T,
                    _ builder: (inout T) throws -> Void) rethrows -> T {
    var mutableValue = value
    try builder(&mutableValue)
    return mutableValue
}

public func weakBox<V: AnyObject>(_ value: V,
                _ builder: @escaping (V) -> Void) -> (() -> Void)? {
    return { [weak value] in
        guard let value = value else { return }
        return builder(value)
    }
}

@discardableResult
public func withNonNil<T: OptionalProtocol>(_ value: T,
                                            _ builder: (inout T.Wrapped) throws -> Void) rethrows -> T {
    if var mutableValue = value.optional {
        try builder(&mutableValue)
        return T(reconstructing: mutableValue)
    } else {
        return value
    }
}

