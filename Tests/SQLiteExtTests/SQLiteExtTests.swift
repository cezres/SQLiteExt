import XCTest
@testable import SQLiteExt
import SQLite

final class SQLiteExtTests: XCTestCase {
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(SQLiteExt().text, "Hello, World!")
                
        let db = try Connection(.inMemory)
        let user1 = User(id: "1", name: "aaa", age: 12)
        var user2 = User(id: "2", name: "bbb", age: 24)
        
        // Insert
        try db.insert(user1)
        try db.insert(user2)
        XCTAssertEqual(try db.count(User.self), 2)
        
        // Query
        XCTAssertEqual(user1, try db.find(primary: user1.id))
        XCTAssertEqual([user1], try db.query(keyPath: \.name, value: user1.name))
        XCTAssertEqual([user1, user2], try db.query(User.expression(\.age) >= 12))
        XCTAssertEqual([user2], try db.query(User.expression(\.age) >= 18))
        XCTAssertEqual([user2], try db.query(query: .greaterThan(\.age, 18) && .lessThan(\.age, 28)))
        
        // Delete
        try db.delete(user1)
        XCTAssertEqual(try db.find(type: User.self, primary: user1.id), nil)
        XCTAssertEqual(try db.count(User.self), 1)
        
        // Update
        user2.age = 44
        try db.insert(user2)
        XCTAssertEqual(user2, try db.find(primary: user2.id))
        
        //
        let table = Table(User.tableName)
        let query = table.filter(try User.expression(\.id) == user2.id)
        let update = query.update(try User.expression(\.age) += 1)
        try db.run(update)
        XCTAssertEqual(try db.find(type: User.self, primary: user2.id)?.age, user2.age + 1)
        
        print(try db.query(User.self))
    }
    
    func testInsert() throws {
        let db = try Connection(.inMemory)
        var user1 = User(id: "1", name: "aaa", age: 12)
        
        try db.insert(user1)
        XCTAssertEqual(try db.count(User.self), 1)
        
        user1.age = 16
        try db.insert(user1)
        XCTAssertEqual(try db.count(User.self), 1)
        XCTAssertEqual(user1, try db.find(primary: user1.id))
    }
}

struct User: SQLiteTable, Equatable {
    
    static var primary: SQLiteFild<User, String> = .init(identifier: "id", keyPath: \.id)
        
    static var fields: [AnySQLiteField<User>] = [
        .init(identifier: "name", keyPath: \.name),
        .init(identifier: "age", keyPath: \.age),
    ]
    
    var id: String
    var name: String
    var age: Int
    
    init(id: String, name: String, age: Int) {
        self.id = id
        self.name = name
        self.age = age
    }
    
    init() {
        id = ""
        name = ""
        age = 0
    }
}
