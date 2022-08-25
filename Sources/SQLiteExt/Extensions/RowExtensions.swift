//
//  RowExtensions.swift
//  
//
//  Created by 翟泉 on 2022/8/18.
//

import Foundation
import SQLite

extension Row {
    func decode<T: Value>(_ identifier: String) -> T {
        self[Expression<T>(identifier)]
    }
    
    func decode<T, V: Value>(value: inout T, identifier: String, keyPath: WritableKeyPath<T, V>) {
        value[keyPath: keyPath] = decode(identifier)
    }
}
