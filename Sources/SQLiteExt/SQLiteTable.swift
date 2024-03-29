//
//  SQLiteTable.swift
//  
//
//  Created by 翟泉 on 2022/8/18.
//

import Foundation
import SQLite

public protocol SQLiteTable {
    
    static var tableName: String { get }
    
    static var fields: [AnySQLiteField<Self>] { get }
        
    init()
}

public extension SQLiteTable {
    static func expression<Value>(_ keyPath: KeyPath<Self, Value>) throws -> Expression<Value> {
        if let field = fields.first(where: { $0.partialKeyPath == keyPath }) {
            return .init(field.identifier)
        } else {
            throw SQLiteTableError.fieldNotFound
        }
    }
    
    static func expression<Value>(_ keyPath: KeyPath<Self, Value>) throws -> Expression<Value> where Self: SQLiteTablePrimaryKey {
        if keyPath == self.primary.keyPath {
            return .init(self.primary.identifier)
        } else if let field = fields.first(where: { $0.partialKeyPath == keyPath }) {
            return .init(field.identifier)
        } else {
            throw SQLiteTableError.fieldNotFound
        }
    }
    
    static var tableName: String {
        String(describing: Self.self)
    }
}

struct SQLiteExpression<T: SQLiteTable> {
    let keyPath: PartialKeyPath<T>
    
    init<V>(keyPath: WritableKeyPath<T, V>) where V: Value {
        self.keyPath = keyPath
    }
    
    func expression<V>() throws -> Expression<V> {
        if let keyPath = keyPath as? KeyPath<T, V> {
            return try T.expression(keyPath)
        } else {
            throw SQLiteTableError.fieldNotFound
        }
    }
}

enum SQLiteTableError: Error {
    case fieldNotFound
}

// MARK: - Set Values

extension SQLiteTable {
    
    mutating func setValues(_ row: Row) {
        Self.fields.forEach { field in
            setValues(row, for: field)
        }
    }
    
    mutating func setValues(_ row: Row) where Self: SQLiteTablePrimaryKey {
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
            
            if let value = value as? any Value {
                value.setValue(to: &self, keyPath: field.partialKeyPath)
            }
        }
    }
}
