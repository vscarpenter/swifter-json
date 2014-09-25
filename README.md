swifter-json
============

Swift library for parsing JSON

Example:

```swift
struct Name: JSONDecodable, JSONEncodable {
    let first: String
    let last: String

    static func create(first: String)(last: String) -> Name {
        return Name(first: first, last: last)
    }

    static func decode(dict: JSONDictionary) -> Name? {
        return Name.create <^>
            JSONSpec(dict, "first", JSONString)
            <*> JSONSpec(dict, "last", JSONString)
    }

    func encode() -> JSONDictionary {
        return [
            "first": self.first,
            "last": self.last,
        ]
    }
}

struct User: JSONDecodable, JSONEncodable {
    let id: Int
    let name: Name
    let email: String?

    static func create(id: Int)(name: Name)(email: String?) -> User {
        return User(id: id, name: name, email: email)
    }

    static func decode(dict: JSONDictionary) -> User? {
        return User.create <^>
            JSONSpec(dict, "id", JSONInt)
            <*> (Name.decode <^> dict["name"])
            <*> JSONSpec(dict, "email", JSONString, optional: true)
    }

    func encode() -> JSONDictionary {
        return [
            "id": self.id,
            "name": [
                "first": self.name.first,
                "last": self.name.last,
            ],
            "email": self.email ?? NSNull(),
        ]
    }
}
```

Contribution
=============

I encourage anybody with ideas or bug fixes to make changes and submit pull requests. If you do, please follow the [CAAG Commit Style](http://drewag.me/posts/changes-at-a-glance?source=github).
