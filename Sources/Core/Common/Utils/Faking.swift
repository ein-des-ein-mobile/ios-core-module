//
//  Faking.swift
//

import Foundation

public protocol Faking {
    init()
    static func fakeItems(count: Int) -> [Self]
}

public extension Faking {
    static func fakeItems(count: Int = 10) -> [Self] {
        (0..<count).map { _ in Self.init()}
    }
    
    static func fakeItem() -> Self {
        fakeItems(count: 1).first!
    }
}

public extension Faking where Self: RawRepresentable & CaseIterable {
    init() {
        self = Self.allCases.randomElement()!
    }
}

public extension Faking {
    func delayed(_ seconds: Double = 0.3) async throws -> Self {
        try await Core.delayed(seconds) { self }
    }
}

public extension Array where Element: Faking {
    func delayed(_ seconds: Double = 0.3) async throws -> Self {
        try await Core.delayed(seconds) { self }
    }
}

public func fake() { }
public func fake<T>(_ with: T) { }
public func fake<T: Faking>() -> T { T.fakeItem() }
public func fake<T: Faking>() -> T? { T.fakeItem() }
public func fake<T: Faking>() -> [T] { T.fakeItems() }
public func fake<T: Faking, ID>(_ id: ID) -> T { T.fakeItem() }
public func fake<T: Faking>(_ count: Int) -> [T] { T.fakeItems(count: count) }
public func fakeIDs<T: Faking & Identifiable>(_ type: T.Type) -> [T.ID] { T.fakeItems().map(\.id) }
