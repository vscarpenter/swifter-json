swifter-json
============

Swift library for parsing JSON

It is a type safe and succinct way to decode JSON

# Example

First you can just look at a quick example of how SwifterJSON is intended
to be used. There is more in-depth information below the example on how to
use it and how it works.

## Make Type JSON decondable and encodable

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
```

## Use Nested Class

```swift
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

## Perform decoding

```swift
let user: User? = User.decode([
    "id": 10,
    "name": [
        "first": "Sarah",
        "last": "Doe",
    ],
    "email": "sarah@example.com",
])
```
# How To

## Decoding JSON

### Single Level Deep

To use this library on a type, you will have to create a
[curried](http://drewag.me/posts/practical-use-for-curried-functions-in-swift)
factory method with each of the parameters you want to parse out of the JSON.

For example, with a Name struct that has both a first and last name, you
can write a factory method:

```swift
static func create(first: String)(last: String) {
    return Name(first: first, last: last)
}
```

This allows always dealing with methods that take a single parameter, even
if sometimes they return additional methods that must take another parameter.

You will also need to take advantage of the JSONSpec and conversion functions.
The JSONSpec function is pretty straightforward. It takes a dictionary, a key
for the value within the dictionary you would like to convert, and a conversion
function for the type of the value. It also optionally takes specification for
whether this property is optional. The only difference it actually makes is
whether or not an error is logged to the console when the key is missing or
cannot be converted.

Then, using the 2 functions provided by this library, you can write a decoding
like so:

```swift
let user = Name.create <^>
    JSONSpec(dict, "first", JSONString)
    <*> JSONSpec(dict, "last", JSONString)
```
Let's break down the order of operations here to give you a better understanding
of how it works. Similar to how `4 + 5 + 6`, is done first by adding `4 + 5`,
the first function call is:

    Name.create <^> JSONSpec(dict, "first", JSONString

We have the function `<^>` that takes a parameter on each side of it. Name.create is
already simplified because it is just a method. The other parameter just first be
calculated. JSONSpec will attempt to access the value in the dict using the key provided
and return the value converted using the conversion function. In this case, it will attempt
to extract a string. If the value is not there or if it cannot be properly converted, the
function will log an error to the console and return nil.

Once simplified, we now call the `<^>` method. All it does is call the function on the
left, with the parameter from the right. The reason we use this special function is that
it also handles the case that the right parameter is `nil`. In that case, it just returns
`nil` itself. This, along with the `<*>` function, allows us to chain together multiple
parameters and handle the case that any of them may return nil, ending the execution of
the chain.

The only difference between `<^>` and `<*>` is that `<*>` allows the function parameter on
the left, to be optional. This is used after the first `<^>` because from then on, the previous
operation could always return `nil` instead of the next function to be called.

That function will now return either `nil` or the next part of the create function with the
previous parameter already filled in. Now the `<*>` function is the next to be executed. Again,
first, it must simplify the JSONSpec. With the `<*>` function, if either of the parameters are
`nil`, it simply returns `nil`, however, if the left is a function and the right is the same type
as the parameter to that function, the chain can continue. This repeats until all of the
parameters have been satisfied. If at any point, there was a `nil` for a required attributes, the
whole chain will start returning `nil`s and the end result will be `nil`. In that case, you can
check your console for the failing property.

There is a JSONDecoble protocol that you can use, but is not required. It simply defines a `decode` method
that returns a newly decoded object from a dictionary:

```swift
static func decode(dict: JSONDictionary) -> Name? {
    return Name.create <^>
        JSONSpec(dict, "first", JSONString)
        <*> JSONSpec(dict, "last", JSONString)
}
```
### Multiple Levels Deep

If you have a nested custom type in your object, you can parse them by passing
the result of decoding the type in place of a JSONSpec.

```swift
static func decode(dict: JSONDictionary) -> User? {
    return User.create <^>
        JSONSpec(dict, "id", JSONInt)
        <*> (Name.decode <^> dict["name"])
        <*> JSONSpec(dict, "email", JSONString, optional: true)
}
```

Notice two things about this code. First, the nested decoding is placed in
parameters to ensure that `Name.decode` is not used as a parameter to the
previous `<*>` function. Second, I used a second `<^>` function to perform
the decoding. This is because Name.decode is not optional, but it is possible
for `dict["name"]` to return nil.

## Encoding JSON

Encoding JSON is much more straight forward. There is a JSONEncodable protocol the defines a
method "encode" that returns a JSON dictionary. For example:

```swift
func encode() -> JSONDictionary {
    return [
        "first": self.first,
        "last": self.last,
    ]
}
```

All you have to do in that method is return a dictionary using it's properties. If you have
an optional parameter, you can use the coalescing operator with NSNull:

```swift
func encode() -> JSONDictionary {
    return [
        "first": self.first,
        "last": self.last ?? NSNull(),
    ]
}
```

Credits
============

The implementation of this library were largely inspired by a [blog entry written by Tony DisPasquale](http://robots.thoughtbot.com/efficient-json-in-swift-with-functional-concepts-and-generics).

Contribution
=============

I encourage anybody with ideas or bug fixes to make changes and submit pull requests. If you do, please follow the [CAAG Commit Style](http://drewag.me/posts/changes-at-a-glance?source=github).
