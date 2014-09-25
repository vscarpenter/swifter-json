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
                "first": "Sarah",
                "last": "Doe",
            ],
            "email": "sarah@example.com",
        ]) {
            XCTAssertEqual(user.id, 10)
            XCTAssertEqual(user.name.first, "Sarah")
            XCTAssertEqual(user.name.last, "Doe")
            XCTAssertEqual(user.email!, "sarah@example.com")
        }
        else {
            XCTAssert(false)
        }
    }

    func testDecodeWithNone() {
        if let user = User.decode([
            "id": 10,
            "name": [
                "first": "Sarah",
                "last": "Doe",
            ],
            "email": NSNull(),
        ]) {
            XCTAssertEqual(user.id, 10)
            XCTAssertEqual(user.name.first, "Sarah")
            XCTAssertEqual(user.name.last, "Doe")
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
        let user = User(id: 10, name: Name(first: "Sarah", last: "Doe"), email: "sarah@example.com")
        let userDict: JSONDictionary = user.encode()

        XCTAssertEqual(userDict["id"]! as Int, 10)

        let nameDict = userDict["name"]! as JSONDictionary
        XCTAssertEqual(nameDict["first"]! as String, "Sarah")
        XCTAssertEqual(nameDict["last"]! as String, "Doe")

        XCTAssertEqual(userDict["email"]! as String, "sarah@example.com")
    }

    func testEncodeWithNone() {
        let user = User(id: 10, name: Name(first: "Sarah", last: "Doe"), email: nil)
        let userDict: JSON = user.encode()

        XCTAssertEqual(userDict["id"] as Int, 10)

        let nameDict = userDict["name"]! as JSONDictionary
        XCTAssertEqual(nameDict["first"]! as String, "Sarah")
        XCTAssertEqual(nameDict["last"]! as String, "Doe")

        XCTAssertEqual(userDict["email"] as NSObject, NSNull())
    }
}