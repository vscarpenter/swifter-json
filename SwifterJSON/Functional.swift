//
//  Functional.swift
//  JSONParser
//
//  Created by Andrew J Wagner on 9/19/14.
//  Copyright (c) 2014 Drewag, LLC. All rights reserved.
//

import Foundation

infix operator <^> { associativity left }

func <^><A, B>(f: A? -> B, a: A?) -> B? {
    return f(a)
}

func <^><A, B>(f: A -> B, a: A?) -> B? {
  if let x = a {
    return f(x)
  } else {
    return .None
  }
}

func <^><B>(f: JSONDictionary -> B?, a: JSON?) -> B? {
    if let x = a as? JSONDictionary {
        return f(x)
    }
    return nil
}

infix operator <*> { associativity left }

func <*><A, B>(f: (A -> B)?, a: A?) -> B? {
  if let x = a {
    if let fx = f {
      return fx(x)
    }
  }
  return .None
}

func <*><A, B>(f: (A? -> B)?, a: A?) -> B? {
    if let fx = f {
        return fx(a)
    }
    return .None
}

