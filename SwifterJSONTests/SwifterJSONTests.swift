//
//  SwifterJSONTests.swift
//  SwifterJSONTests
//
//  Created by Andrew J Wagner on 9/25/14.
//  Copyright (c) 2014 Drewag, LLC. All rights reserved.
//

import UIKit
import XCTest

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
            "email": self.email ?? NSNull()
        ]
    }
}

class JSONParserTests: XCTestCase {
    func testDecode() {
        if let user = User.decode([
            "id": 10,
            "name": [
                "first": "Andrew",
                "last": "Wagner",
            ],
            "email": "andrew@drewag.me",
        ]) {
            XCTAssertEqual(user.id, 10)
            XCTAssertEqual(user.name.first, "Andrew")
            XCTAssertEqual(user.name.last, "Wagner")
            XCTAssertEqual(user.email!, "andrew@drewag.me")
        }
        else {
            XCTAssert(false)
        }
    }

    func testDecodeWithNone() {
        if let user = User.decode([
            "id": 10,
            "name": [
                "first": "Andrew",
                "last": "Wagner",
            ],
            "email": NSNull(),
        ]) {
            XCTAssertEqual(user.id, 10)
            XCTAssertEqual(user.name.first, "Andrew")
            XCTAssertEqual(user.name.last, "Wagner")
            XCTAssertNil(user.email)
        }
        else {
            XCTAssert(false)
        }

    }

    func testDecodeWithMissingRequiredAttribute() {
        let user = User.decode([
            "id": 10,
            "email": "andrew@drewag.me",
        ])

        XCTAssertTrue(user == nil)
    }

    func testEncode() {
        let user = User(id: 10, name: Name(first: "Andrew", last: "Wagner"), email: "andrew@drewag.me")
        let userDict: JSONDictionary = user.encode()

        XCTAssertEqual(userDict["id"]! as Int, 10)

        let nameDict = userDict["name"]! as JSONDictionary
        XCTAssertEqual(nameDict["first"]! as String, "Andrew")
        XCTAssertEqual(nameDict["last"]! as String, "Wagner")

        XCTAssertEqual(userDict["email"]! as String, "andrew@drewag.me")
    }

    func testEncodeWithNone() {
        let user = User(id: 10, name: Name(first: "Andrew", last: "Wagner"), email: nil)
        let userDict: JSON = user.encode()

        XCTAssertEqual(userDict["id"] as Int, 10)

        let nameDict = userDict["name"]! as JSONDictionary
        XCTAssertEqual(nameDict["first"]! as String, "Andrew")
        XCTAssertEqual(nameDict["last"]! as String, "Wagner")

        XCTAssertEqual(userDict["email"] as NSObject, NSNull())
    }
}