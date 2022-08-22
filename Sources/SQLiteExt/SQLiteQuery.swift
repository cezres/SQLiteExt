//
//  File.swift
//  
//
//  Created by 翟泉 on 2022/8/17.
//

import Foundation
import SQLite

public struct SQLiteQuery<T: SQLiteTable> {
    
    let expression: Expression<Bool>
    
    init(expression: Expression<Bool>) {
        self.expression = expression
    }
    
    static func equals<T, V>(_ keyPath: KeyPath<T, V>, _ value: V) throws -> SQLiteQuery<T> where T: SQLiteTable, V: SQLiteFieldValue, V.Datatype: Equatable {
        .init(expression: try T.expression(keyPath) == value)
    }
    
    static func notEquals<T, V>(_ keyPath: KeyPath<T, V>, _ value: V) throws -> SQLiteQuery<T> where T: SQLiteTable, V: SQLiteFieldValue, V.Datatype: Equatable {
        .init(expression: try T.expression(keyPath) != value)
    }
    
    static func lessThan<T, V>(_ keyPath: KeyPath<T, V>, _ value: V) throws -> SQLiteQuery<T> where T: SQLiteTable, V: SQLiteFieldValue, V.Datatype: Comparable {
        .init(expression: try T.expression(keyPath) < value)
    }
    
    static func lessThanOrEquals<T, V>(_ keyPath: KeyPath<T, V>, _ value: V) throws -> SQLiteQuery<T> where T: SQLiteTable, V: SQLiteFieldValue, V.Datatype: Comparable {
        .init(expression: try T.expression(keyPath) <= value)
    }
    
    static func greaterThan<T, V>(_ keyPath: KeyPath<T, V>, _ value: V) throws -> SQLiteQuery<T> where T: SQLiteTable, V: SQLiteFieldValue, V.Datatype: Comparable {
        .init(expression: try T.expression(keyPath) > value)
    }
    
    static func greaterThanOrEquals<T, V>(_ keyPath: KeyPath<T, V>, _ value: V) throws -> SQLiteQuery<T> where T: SQLiteTable, V: SQLiteFieldValue, V.Datatype: Comparable {
        .init(expression: try T.expression(keyPath) >= value)
    }
    
    static func && (_ lhs: Self, _ rhs: Self) -> Self {
        .init(expression: lhs.expression && rhs.expression)
    }
}

public extension Connection {
    
    func query<T>(query: SQLiteQuery<T>) throws -> [T] where T: SQLiteTable {
        try self.query(T.self, query: query)
    }
    
    func query<T>(_ type: T.Type, query: SQLiteQuery<T>) throws -> [T] where T: SQLiteTable {
        try self.query(type: type, predicate: query.expression)
    }
}
