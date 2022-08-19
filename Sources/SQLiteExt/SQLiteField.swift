//
//  SQLiteField.swift
//  
//
//  Created by 翟泉 on 2022/8/18.
//

import Foundation
import SQLite

protocol SQLiteFieldProtocol {
    
    associatedtype Root
    
    var identifier: String { get }
    
    var partialKeyPath: PartialKeyPath<Root> { get }
        
    init<T>(identifier: String, keyPath: WritableKeyPath<Root, T>) where T: SQLiteFieldValue
}

class AnySQLiteField<Root>: SQLiteFieldProtocol {
    
    let identifier: String
    let partialKeyPath: PartialKeyPath<Root>
    
    private let create: (_ builder: TableBuilder) -> Void
    private let insert: (_ root: Root) -> Setter
    private let setValue: (_ row: Row, _ to: inout Root) -> Void
    
    required init<T>(identifier: String, keyPath: WritableKeyPath<Root, T>) where T: SQLiteFieldValue {
        self.partialKeyPath = keyPath
        self.identifier = identifier
        
        create = { builder in
            builder.column(T.expression(identifier), primaryKey: false)
        }
        setValue = { row, to in
            to[keyPath: keyPath] = row[T.expression(identifier)]
        }
        
        insert = { root in
            T.expression(identifier) <- root[keyPath: keyPath]
        }
    }
    
    func addColumn(to builder: TableBuilder) {
        create(builder)
    }
    
    func setter(from value: Root) -> Setter {
        insert(value)
    }
    
    func setRow(row: Row, to value: inout Root) {
        setValue(row, &value)
    }
}

class SQLiteFild<Root, Value: SQLiteFieldValue>: AnySQLiteField<Root> {
    
    let keyPath: KeyPath<Root, Value>
    
    init(identifier: String, keyPath: WritableKeyPath<Root, Value>) {
        self.keyPath = keyPath
        super.init(identifier: identifier, keyPath: keyPath)
    }
    
    required init<T>(identifier: String, keyPath: WritableKeyPath<Root, T>) where T : SQLiteFieldValue {
        fatalError("init(identifier:keyPath:) has not been implemented")
    }
    
    func expression() -> Expression<Value> {
        .init(identifier)
    }
}


//extension Never: Binding {
//}
//extension Never: SQLiteFieldValue {
//    public static func fromDatatypeValue(_ datatypeValue: Int) -> Int { 0 }
//
//    public var datatypeValue: Int { 0 }
//
//    public static var declaredDatatype: String { "" }
//}
//extension __SQLiteTab where PrimaryType == Never {
//}
//struct EmptySQLiteField {
//}
