//
//  JSONSpec.swift
//  JSONParser
//
//  Created by Andrew J Wagner on 9/20/14.
//  Copyright (c) 2014 Drewag, LLC. All rights reserved.
//

import Foundation

func JSONSpec<B>(dict: JSONDictionary, key: String, conversion: JSON -> B?, optional: Bool = false) -> B? {
    if let x: JSON = dict[key] {
        if let value = conversion(x) {
            return value
        }
        else {
            if !optional {
                JSONParsingErrorFailedConversion(dict, key)
            }
            return nil
        }
    }
    if !optional {
        JSONParsingErrorMissingKey(dict, key)
    }
    return nil
}