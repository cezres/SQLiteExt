//
//  File 2.swift
//  
//
//  Created by 翟泉 on 2022/8/18.
//

import Foundation
import SQLite

public protocol SQLiteFieldValue: SQLite.Value {
}

public extension SQLiteFieldValue {
    
    func setValue<Root>(to root: inout Root, keyPath: PartialKeyPath<Root>) {
        if let keyPath = keyPath as? WritableKeyPath<Root, Self> {
            root[keyPath: keyPath] = self
        }
    }
    
    static func getValue<Root>(from root: Root, keyPath: PartialKeyPath<Root>) -> Self? {
        if let keyPath = keyPath as? KeyPath<Root, Self> {
            return root[keyPath: keyPath]
        } else {
            return root[keyPath: keyPath] as? Self
        }
    }
    
    static func expression(_ identifier: String) -> Expression<Self> {
        .init(identifier)
    }
}

extension String: SQLiteFieldValue {}
extension Data: SQLiteFieldValue {}
extension Int: SQLiteFieldValue {}
extension Int64: SQLiteFieldValue {}
extension Double: SQLiteFieldValue {}
extension Blob: SQLiteFieldValue {}
extension Bool: SQLiteFieldValue {}
extension UUID: SQLiteFieldValue {}
