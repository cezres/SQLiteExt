//
//  SQLiteField.swift
//  
//
//  Created by 翟泉 on 2022/8/18.
//

import Foundation
import SQLite

public protocol SQLiteFieldProtocol {
    
    associatedtype Root
    
    var identifier: String { get }
    
    var partialKeyPath: PartialKeyPath<Root> { get }
        
    init<T>(identifier: String, keyPath: WritableKeyPath<Root, T>) where T: SQLiteFieldValue
}

public class AnySQLiteField<Root>: SQLiteFieldProtocol {
    
    public let identifier: String
    public let partialKeyPath: PartialKeyPath<Root>
    
    private let create: (_ builder: TableBuilder, _ primaryKey: Bool) -> Void
    private let insert: (_ root: Root) -> Setter
    private let setValue: (_ row: Row, _ to: inout Root) -> Void
    
    public required init<T>(identifier: String, keyPath: WritableKeyPath<Root, T>) where T: SQLiteFieldValue {
        self.partialKeyPath = keyPath
        self.identifier = identifier
        
        create = { builder, primaryKey in
            builder.column(T.expression(identifier), primaryKey: primaryKey)
        }
        setValue = { row, to in
            to[keyPath: keyPath] = row[T.expression(identifier)]
        }
        
        insert = { root in
            T.expression(identifier) <- root[keyPath: keyPath]
        }
    }
    
    func addColumn(to builder: TableBuilder, primaryKey: Bool) {
        create(builder, primaryKey)
    }
    
    func setter(from value: Root) -> Setter {
        insert(value)
    }
    
    func setRow(row: Row, to value: inout Root) {
        setValue(row, &value)
    }
}

public class SQLiteFild<Root, Value: SQLiteFieldValue>: AnySQLiteField<Root> {
    
    let keyPath: KeyPath<Root, Value>
    
    public init(identifier: String, keyPath: WritableKeyPath<Root, Value>) {
        self.keyPath = keyPath
        super.init(identifier: identifier, keyPath: keyPath)
    }
    
    required init<T>(identifier: String, keyPath: WritableKeyPath<Root, T>) where T : SQLiteFieldValue {
        fatalError("init(identifier:keyPath:) has not been implemented")
    }
    
    public func expression() -> Expression<Value> {
        .init(identifier)
    }
}
