//
//  SQLiteTable.swift
//  
//
//  Created by 翟泉 on 2022/8/18.
//

import Foundation
import SQLite

protocol SQLiteTable {
    
    associatedtype PrimaryValue: SQLiteFieldValue where PrimaryValue.Datatype: Equatable
    
    static var tableName: String { get }
    
    static var primary: SQLiteFild<Self, PrimaryValue> { get }
    
    static var fields: [AnySQLiteField<Self>] { get }
        
    init()
}

extension SQLiteTable {
    static func expression<Value>(_ keyPath: KeyPath<Self, Value>) throws -> Expression<Value> {
        guard let field = allFields.first(where: { $0.partialKeyPath == keyPath }) else {
            throw NSError(domain: "", code: -1)
        }
        return .init(field.identifier)
    }
    
    static var allFields: [AnySQLiteField<Self>] {
        [primary] + fields
    }
    
    static var tableName: String {
        String(describing: Self.self)
    }
}

// MARK: - Set Values

extension SQLiteTable {
    
    mutating func setValues(_ row: Row) {
        setValues(row, for: Self.primary)
        Self.fields.forEach { field in
            setValues(row, for: field)
        }
    }
    
    mutating func setValues(_ row: Row, for field: AnySQLiteField<Self>) {
        field.setRow(row: row, to: &self)
    }
    
    func values() {
        Self.fields.forEach { field in
            print("\(field.identifier):", self[keyPath: field.partialKeyPath])
        }
    }
    
    mutating func setValue<V>(_ value: V, for keyPath: WritableKeyPath<Self, V>) throws {
        self[keyPath: keyPath] = value
    }
    
    mutating func setValues(_ values: [String: Any]) {
        var valueIndex = 0
        var fieldIndex = 0
        while valueIndex < values.count && fieldIndex < Self.fields.count {
            let field = Self.fields[fieldIndex]
            fieldIndex += 1
            guard let value = values[field.identifier] else {
                return
            }
            valueIndex += 1
            
            if let value = value as? any SQLiteFieldValue {
                value.setValue(to: &self, keyPath: field.partialKeyPath)
            }
        }
    }
}
