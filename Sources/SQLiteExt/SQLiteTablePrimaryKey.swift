//
//  SQLiteTablePrimaryKey.swift
//  
//
//  Created by 翟泉 on 2022/8/22.
//

import Foundation
import SQLite

public protocol SQLiteTablePrimaryKey {

    associatedtype PrimaryValue: Value where PrimaryValue.Datatype: Equatable

    static var primary: SQLiteFild<Self, PrimaryValue> { get }
}
