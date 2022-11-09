//
//  Parameters.swift
//

import Foundation

@dynamicMemberLookup
public protocol ParametersSubscript {
    func parametersValue(for key: String) -> Parameters.Value
}

public extension ParametersSubscript {
    /**
     ```
     let parameters: Parameters = ...
     
     parameters.your.key.path <- value // value is some type T: ParametersEncodable
     ```
     */
    subscript(dynamicMember key: String) -> Parameters.Value {
        return parametersValue(for: key)
    }
    
    subscript<T: ParametersEncodable>(dynamicMember key: String) -> T? {
        return self[dynamicMember: key].getValue()
    }
}

// MARK: - Parameters

/**
 `Parameters` allows to create arbitary dictionaries with ease.
 ```
 let parameters = Parameters {
     $0.name.first <- "John"
     $0.name.last <- "Dou"
 }
 
 let dictionary = parameters.make() // ["name": ["first": "John", "last": "Dou"]]
 ```
 */
public struct Parameters: ParametersSubscript {
    // MARK: - Private
    private let storage: Storage
    
    private init(storage: Storage) {
        self.storage = storage
    }
    
    // MARK: - Public
    
    public init(builder: (inout Parameters) -> Void = { _ in }) {
        self.init(storage: Storage())
        builder(&self)
    }
    
    public func parametersValue(for key: String) -> Parameters.Value {
        return Parameters.Value(storage: storage, keys: [key])
    }
    
    public func make() -> [String: Any] {
        return storage.dictionary
    }
}

// MARK: - Parameters.Value

extension Parameters {
    fileprivate final class Storage {
        var dictionary: [String: Any] = [:]
    }
    
    public struct Value: ParametersSubscript {
        // MARK: - Private
        
        private let storage: Storage
        private let keys: [String]
        private var keyPath: String {
            return keys.joined(separator: ".")
        }
        
        fileprivate func getValue<T>() -> T? {
            return storage.dictionary[keyPath: keyPath] as? T
        }
        
        func setValue<T: ParametersEncodable>(_ value: T, includeNull: Bool = false) {
            if let encodedValue = value.encodedValue {
                storage.dictionary[keyPath: keyPath] = encodedValue
            } else if includeNull {
                storage.dictionary[keyPath: keyPath] = NSNull()
            } else {
                storage.dictionary[keyPath: keyPath] = nil
            }
        }
        
        fileprivate init(storage: Storage, keys: [String]) {
            self.storage = storage
            self.keys = keys
        }
        
        public func parametersValue(for key: String) -> Value {
            return Parameters.Value(storage: storage, keys: keys + [key])
        }
        
        var value: Any? {
            return storage.dictionary[keyPath: keyPath]
        }
    }
}

// MARK: - Operator `<-`

precedencegroup ParametersPrecedence {
    lowerThan: AdditionPrecedence
}

infix operator <-: ParametersPrecedence

extension Parameters.Value {
   public static func <- <T: ParametersEncodable>(lhs: Parameters.Value, rhs: T) {
        lhs.setValue(rhs)
    }
}

// MARK: - ParametersEncodable

public protocol ParametersEncodable {
    associatedtype EncodedValue = Self
    var encodedValue: EncodedValue? { get }
}
extension String: ParametersEncodable {
    public var encodedValue: String? { return self }
}
extension Bool: ParametersEncodable {
    public var encodedValue: Bool? { return self }
}
extension Numeric {
    public var encodedValue: Self? { return self }
}
extension Int: ParametersEncodable {}
extension Int8: ParametersEncodable {}
extension Int16: ParametersEncodable {}
extension Int32: ParametersEncodable {}
extension Int64: ParametersEncodable {}
extension Decimal: ParametersEncodable {}
extension Double: ParametersEncodable {}
extension Float: ParametersEncodable {}

extension Parameters: ParametersEncodable {
    public var encodedValue: [String: Any]? { return storage.dictionary }
}

extension Parameters.Value: ParametersEncodable {
    public var encodedValue: Any? { return storage.dictionary[keyPath: keyPath] }
}

extension Optional: ParametersEncodable where Wrapped: ParametersEncodable
{
    public typealias EncodedValue = Wrapped.EncodedValue
    
    public var encodedValue: Wrapped.EncodedValue? {
        return self?.encodedValue
    }
}

extension Array: ParametersEncodable
    where
    Element: ParametersEncodable
{
    public var encodedValue: Array<Element>? {
        return self
    }
}

extension Dictionary: ParametersEncodable where Key == String, Value: ParametersEncodable {
    public typealias EncodedValue = [Key: Value.EncodedValue]
    
    public var encodedValue: [Key: Value.EncodedValue]? {
        return reduce(into: Dictionary<Key, Value.EncodedValue>(), { (result, pair) in
            if let value = pair.value.encodedValue {
                result[pair.key] = value
            }
        })
    }
}
