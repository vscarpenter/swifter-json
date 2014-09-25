//
//  JSONObject.swift
//  JSONParser
//
//  Created by Andrew J Wagner on 9/19/14.
//  Copyright (c) 2014 Drewag, LLC. All rights reserved.
//

import Foundation

typealias JSON = AnyObject
typealias JSONDictionary = Dictionary<String, JSON>
typealias JSONArray = Array<JSON>

func JSONInt(object: JSON) -> Int? {
    return object as? Int
}

func JSONString(object: JSON) -> String? {
    return object as? String
}

func JSONDouble(object: JSON) -> Double? {
    return object as? Double
}

func JSONObject(object: JSON?) -> JSONDictionary? {
  return object as? JSONDictionary
}

protocol JSONEncodable {
    func encode() -> JSONDictionary
}

protocol JSONDecodable {
    class func decode(dict: JSONDictionary) -> Self?
}