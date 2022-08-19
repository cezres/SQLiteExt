# SQLiteExt

A description of this package.


### Examples


```swift
let db = try Connection(.inMemory)
let user1 = User(id: "1", name: "aaa", age: 12)
let user2 = User(id: "2", name: "bbb", age: 24)

// Create Table
try db.create(User.self)

// Insert
try db.insert(user1)
try db.insert(user2)

// Query
XCTAssertEqual(user1, try db.find(primary: user1.id))
XCTAssertEqual(user1, try db.find(keyPath: \.name, value: user1.name))
XCTAssertEqual([user1, user2], try db.query(User.expression(\.age) >= 12))
XCTAssertEqual([user2], try db.query(User.expression(\.age) >= 18))

// Delete
try db.delete(user1)
XCTAssertEqual(try db.find(type: User.self, keyPath: \.id, value: user1.id), nil)
```

```swift
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
```
