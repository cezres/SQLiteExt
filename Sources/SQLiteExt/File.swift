//
//  File.swift
//  
//
//  Created by 翟泉 on 2022/8/17.
//

import Foundation
import SQLite

struct SQLiteQuery {
    
    let query: Expression<Bool>
    
    init(query: Expression<Bool>) {
        self.query = query
    }
    
    init<R, V>(keyPath: KeyPath<R, V>, value: V, from table: R) where R: SQLiteTable, V: SQLite.Value, V.Datatype: Equatable {
        self.query = Expression<V>("xxxx") == value
    }
}

