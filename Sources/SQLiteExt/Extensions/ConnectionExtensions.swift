//
//  ConnectionExtensions.swift
//  
//
//  Created by 翟泉 on 2022/8/18.
//

import Foundation
import SQLite

public extension Connection {
    
    @discardableResult private func __run<T, R>(type: T.Type, _ block: () throws -> R) throws -> R where T: SQLiteTable {
        do {
            return try block()
        } catch SQLite.Result.error(let message, let code, let statement) {
            if let statement = statement {
                debugPrint(message, code, statement)
            } else {
                debugPrint(message, code)
            }
            
            if message.contains("no such table") {
                try create(T.self)
                return try block()
            } else {
                throw SQLite.Result.error(message: message, code: code, statement: statement)
            }
        } catch {
            throw error
        }
    }
    @discardableResult private func __run<T, R>(type: T.Type, _ block: () throws -> R) throws -> R where T: SQLiteTable, T: SQLiteTablePrimaryKey {
        do {
            return try block()
        } catch SQLite.Result.error(let message, let code, let statement) {
            if let statement = statement {
                debugPrint(message, code, statement)
            } else {
                debugPrint(message, code)
            }
            
            if message.contains("no such table") {
                try create(T.self)
                return try block()
            } else {
                throw SQLite.Result.error(message: message, code: code, statement: statement)
            }
        } catch {
            throw error
        }
    }
    
    func create<T>(_ table: T.Type) throws where T: SQLiteTable, T: SQLiteTablePrimaryKey {
        try run(
            Table(T.tableName).create(ifNotExists: true) { builder in
                T.primary.addColumn(to: builder, primaryKey: true)
                T.fields.forEach {
                    $0.addColumn(to: builder, primaryKey: false)
                }
            }
        )
    }
    func create<T>(_ table: T.Type) throws where T: SQLiteTable {
        try run(
            Table(T.tableName).create(ifNotExists: true) { builder in
                T.fields.forEach {
                    $0.addColumn(to: builder, primaryKey: false)
                }
            }
        )
    }
        
    func insert<T>(_ value: T) throws where T: SQLiteTable {
        try __run(type: T.self) {
            try self.run(
                Table(T.tableName).insert(
                    or: .replace,
                    T.fields.map {
                        $0.setter(from: value)
                    }
                )
            )
        }
    }
    func insert<T>(_ value: T) throws where T: SQLiteTable, T: SQLiteTablePrimaryKey {
        try __run(type: T.self) {
            try self.run(
                Table(T.tableName).insert(
                    or: .replace,
                    ([T.primary] + T.fields).map {
                        $0.setter(from: value)
                    }
                )
            )
        }
    }
    
    func count(_ type: any SQLiteTable.Type) throws -> Int {
        try self.scalar(Table(type.tableName).count)
    }
}

// MARK: - Delete
extension Connection {
    
    func delete(_ type: any SQLiteTable.Type) throws{
        try run(Table(type.tableName).delete())
    }
    
    func delete<T>(_ value: T) throws where T: SQLiteTable, T: SQLiteTablePrimaryKey {
        try delete(T.self, predicate: T.primary.expression() == value[keyPath: T.primary.keyPath])
    }
    
    func delete<T, V>(_ type: T.Type, keyPath: KeyPath<T, V>, value: V) throws where T: SQLiteTable, V: Value, V.Datatype: Equatable {
        try delete(type, predicate: T.expression(keyPath) == value)
    }
    
    func delete<T>(_ type: T.Type, predicate: Expression<Bool>) throws where T: SQLiteTable {
        try run(Table(T.tableName).filter(predicate).delete())
    }
}

// MARK: - Query
public extension Connection {
    
    func find<T>(primary: T.PrimaryValue) throws -> T? where T: SQLiteTable, T: SQLiteTablePrimaryKey {
        try query(type: T.self, predicate: T.primary.expression() == primary).first
    }
    
    func find<T>(type: T.Type, primary: T.PrimaryValue) throws -> T? where T: SQLiteTable, T: SQLiteTablePrimaryKey {
        try query(type: T.self, predicate: T.primary.expression() == primary).first
    }
    
    func query<T, V>(keyPath: KeyPath<T, V>, value: V) throws -> [T] where T: SQLiteTable, V: Value, V.Datatype: Equatable {
        try query(type: T.self, predicate: T.expression(keyPath) == value)
    }
    func query<T, V>(keyPath: KeyPath<T, V>, value: V) throws -> [T] where T: SQLiteTable, T: SQLiteTablePrimaryKey, V: Value, V.Datatype: Equatable {
        try query(type: T.self, predicate: T.expression(keyPath) == value)
    }
    
    func query<T, V>(type: T.Type, keyPath: KeyPath<T, V>, value: V) throws -> [T] where T: SQLiteTable, V: Value, V.Datatype: Equatable {
        try query(type: type, predicate: T.expression(keyPath) == value)
    }
    func query<T, V>(type: T.Type, keyPath: KeyPath<T, V>, value: V) throws -> [T] where T: SQLiteTable, T: SQLiteTablePrimaryKey, V: Value, V.Datatype: Equatable {
        try query(type: type, predicate: T.expression(keyPath) == value)
    }
    
    func query<T>(_ type: T.Type) throws -> [T] where T: SQLiteTable {
        try query(type: type, predicate: nil)
    }
    func query<T>(_ type: T.Type) throws -> [T] where T: SQLiteTable, T: SQLiteTablePrimaryKey {
        try query(type: type, predicate: nil)
    }
    
    func query<T>() throws -> [T] where T: SQLiteTable {
        try query(type: T.self, predicate: nil)
    }
    func query<T>() throws -> [T] where T: SQLiteTable, T: SQLiteTablePrimaryKey {
        try query(type: T.self, predicate: nil)
    }
    
    func query<T>(_ predicate: Expression<Bool>?) throws -> [T] where T: SQLiteTable {
        try query(type: T.self, predicate: predicate)
    }
    func query<T>(_ predicate: Expression<Bool>?) throws -> [T] where T: SQLiteTable, T: SQLiteTablePrimaryKey {
        try query(type: T.self, predicate: predicate)
    }
    
    func query<T>(type: T.Type, predicate: Expression<Bool>?) throws -> [T] where T: SQLiteTable {
        let query: QueryType
        if let predicate = predicate {
            query = Table(T.tableName).filter(predicate)
        } else {
            query = Table(T.tableName)
        }
        return try __run(type: T.self) {
            try prepare(query).map {
                var value = T.init()
                value.setValues($0)
                return value
            }
        }
    }
    func query<T>(type: T.Type, predicate: Expression<Bool>?) throws -> [T] where T: SQLiteTable, T: SQLiteTablePrimaryKey {
        let query: QueryType
        if let predicate = predicate {
            query = Table(T.tableName).filter(predicate)
        } else {
            query = Table(T.tableName)
        }
        return try __run(type: T.self) {
            try prepare(query).map {
                var value = T.init()
                value.setValues($0)
                return value
            }
        }
    }
}
