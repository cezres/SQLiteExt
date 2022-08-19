//
//  KeyPathExtensions.swift
//  
//
//  Created by 翟泉 on 2022/8/18.
//

import Foundation
import SQLite

extension KeyPath {
    static func == <R,V>(_ keyPath: KeyPath<R,V>, _ value: V) -> (KeyPath<R, V>, V) {
        (keyPath, value)
    }
    
    func equal(_ value: Value) -> (KeyPath<Root, Value>, Value) {
        (self, value)
    }
    
    func asExpression() throws -> Expression<Value> where Root: SQLiteTable {
        guard let identifier = Root.fields.first(where: { $0.partialKeyPath == self })?.identifier else {
            throw NSError(domain: "", code: -1)
        }
        return asExpression(identifier)
    }
    
    func asExpression(_ identifier: String) -> Expression<Value> {
        Expression<Value>(identifier)
    }
}
