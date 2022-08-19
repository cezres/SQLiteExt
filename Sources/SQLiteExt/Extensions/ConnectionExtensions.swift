//
//  ConnectionExtensions.swift
//  
//
//  Created by 翟泉 on 2022/8/18.
//

import Foundation
import SQLite

extension Connection {
    func create<T>(_ table: T.Type) throws where T: SQLiteTable {
        try run(
            Table(T.tableName).create(ifNotExists: true) { builder in
                T.allFields.forEach {
                    $0.addColumn(to: builder)
                }
            }
        )
    }
    
    func insert<T>(_ value: T) throws where T: SQLiteTable {
        let insert = Table(T.tableName).insert(
            T.allFields.map {
                $0.setter(from: value)
            }
        )
        print(insert.asSQL())
        try run(
            insert
        )
    }
    
    func delete<T>(_ value: T) throws where T: SQLiteTable {
        try run(
            Table(T.tableName).filter(
                T.primary.expression() == value[keyPath: T.primary.keyPath]
            ).delete()
        )
    }
    
    func values<T>(_ type: T.Type) throws -> [T] where T: SQLiteTable {
        try query(nil)
    }
    
    func find<T>(primary: T.PrimaryValue) throws -> T? where T: SQLiteTable {
        try query(T.primary.expression() == primary).first
    }
    
    func find<T>(type: T.Type, primary: T.PrimaryValue) throws -> T? where T: SQLiteTable {
        try query(T.primary.expression() == primary).first
    }
    
    func find<T>(type: T.Type, keyPath: KeyPath<T, T.PrimaryValue>, value: T.PrimaryValue) throws -> T? where T: SQLiteTable {
        try query(T.expression(keyPath) == value).first
    }
    
    func find<T, Value>(keyPath: KeyPath<T, Value>, value: Value) throws -> T? where T: SQLiteTable, Value: SQLiteFieldValue, Value.Datatype: Equatable {
        try query(T.expression(keyPath) == value).first
    }
    
    func find<T, Value>(type: T.Type, keyPath: KeyPath<T, Value>, value: Value) throws -> T? where T: SQLiteTable, Value: SQLiteFieldValue, Value.Datatype: Equatable {
        try query(T.expression(keyPath) == value).first
    }
    
    func query<T>(_ predicate: Expression<Bool>?) throws -> [T] where T: SQLiteTable {
        try query(type: T.self, predicate: predicate)
    }
    
    func query<T>(type: T.Type, predicate: Expression<Bool>?) throws -> [T] where T: SQLiteTable {
        let query: QueryType
        if let predicate = predicate {
            query = Table(T.tableName).filter(predicate)
        } else {
            query = Table(T.tableName)
        }
        return try prepare(query).map {
            var value = T.init()
            value.setValues($0)
            return value
        }
    }
    
    func query<T>() throws -> [T] where T: SQLiteTable {
        
        
        
        return []
    }
}
