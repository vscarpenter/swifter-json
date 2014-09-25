//
//  JSONParsingErrors.swift
//  JSONParser
//
//  Created by Andrew J Wagner on 9/20/14.
//  Copyright (c) 2014 Drewag, LLC. All rights reserved.
//

import Foundation

let JSONParsingErrorDomain = "JSONParsingErrorDomain"

enum JSONParsingErrorCode: Int {
    case MissingKey
    case FailedConversion
}

func JSONParsingErrorMissingKey(dict: JSONDictionary, key: String) {
    println("JSON Parsing Error: Dictionary (\(dict)) is missing key (\(key))")
}

func JSONParsingErrorFailedConversion(dict: JSONDictionary, key: String) {
    println("JSON Parsing Error: Failed to convert value (\(dict[key]!)) for key (\(key))")
}