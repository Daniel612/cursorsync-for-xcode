//
//  CodableStorage.swift
//  CursorSync
//
//  Created by Daniel612 on 5/22/25.
//

import Foundation
import SwiftUI

@propertyWrapper
public struct CodableStorage<Value: Codable>: DynamicProperty {
    @AppStorage
    private var value: Data
    
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    public init(wrappedValue: Value, _ key: String, store: UserDefaults? = nil) {
        _value = .init(wrappedValue: try! encoder.encode(wrappedValue), key, store: store)
    }
    
    public var wrappedValue: Value {
        get { try! decoder.decode(Value.self, from: value) }
        nonmutating set { value = try! encoder.encode(newValue) }
    }
    
    public var projectedValue: Binding<Value> {
        Binding(
            get: { wrappedValue },
            set: { wrappedValue = $0 }
        )
    }
}

extension Optional: @retroactive RawRepresentable where Wrapped == String {
    public var rawValue: String {
        return ""
    }

    public init?(rawValue: String) {
        self = rawValue
    }
}
