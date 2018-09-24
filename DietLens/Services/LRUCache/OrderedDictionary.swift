//
//  OrderedDictionary.swift
//  DietLens
//
//  Created by linby on 2018/9/21.
//  Copyright © 2018 NExT++. All rights reserved.
//

import Foundation

public struct OrderedDictionary<KeyType: Hashable, ValueType> {
    fileprivate var _dictionary: Dictionary<KeyType, ValueType>
    fileprivate var _keys: Array<KeyType>

    public init() {
        _dictionary = [:]
        _keys = []
    }

    public init(minimumCapacity: Int) {
        _dictionary = Dictionary<KeyType, ValueType>(minimumCapacity: minimumCapacity)
        _keys = Array<KeyType>()
    }

    public init(_ dictionary: Dictionary<KeyType, ValueType>) {
        _dictionary = dictionary
        _keys = [KeyType](dictionary.keys)
    }

    public init(_ orderedDictionary: OrderedDictionary<KeyType, ValueType>) {
        _dictionary = orderedDictionary._dictionary
        _keys = orderedDictionary._keys
    }

    public subscript(key: KeyType) -> ValueType? {
        get {
            return _dictionary[key]
        }
        set {
            if newValue == nil {
                self.removeValueForKey(key: key)
            } else {
                self.updateValue(value: newValue!, forKey: key)
            }
        }
    }

    public mutating func updateValue(value: ValueType, forKey key: KeyType) -> ValueType? {
        let oldValue = _dictionary.updateValue(value, forKey: key)
        if oldValue == nil {
            _keys.append(key)
        }
        return oldValue
    }

    public mutating func removeValueForKey(key: KeyType) {
        _keys = _keys.filter { $0 != key }
        _dictionary.removeValue(forKey: key)
    }

    public mutating func removeAll(keepCapacity: Int) {
        _keys = []
        _dictionary = Dictionary<KeyType, ValueType>(minimumCapacity: keepCapacity)
    }

    public mutating func sortKeys( isOrderedBefore: (KeyType, KeyType) -> Bool) {
        _keys.sort(by: isOrderedBefore)
    }

    public var count: Int { get { return _dictionary.count } }

    // keys isn't lazy evaluated because it's just an array anyway
    public var keys: [KeyType] { get { return _keys } }

    // values is lazy evaluated because of the dictionary lookup and creating a new array
    public var values: AnyIterator<ValueType> {
        get {
            var index = 0
            return AnyIterator({ () -> ValueType? in
                if index >= self._keys.count {
                    return nil
                } else {
                    let key = self._keys[index]
                    index += 1
                    return self._dictionary[key]
                }
            })
        }
    }
}

extension OrderedDictionary: Sequence {
    public func makeIterator() -> AnyIterator<(KeyType, ValueType)> {
        var index = 0
        return AnyIterator({ () -> (KeyType, ValueType)? in
            if index >= self._keys.count {
                return nil
            } else {
                let key = self._keys[index]
                index += 1
                return (key, self._dictionary[key]!)
            }
        })
    }
}

public func ==<Key: Equatable, Value: Equatable>(lhs: OrderedDictionary<Key, Value>, rhs: OrderedDictionary<Key, Value>) -> Bool {
    return lhs._keys == rhs._keys && lhs._dictionary == rhs._dictionary
}

public func !=<Key: Equatable, Value: Equatable>(lhs: OrderedDictionary<Key, Value>, rhs: OrderedDictionary<Key, Value>) -> Bool {
    return lhs._keys != rhs._keys || lhs._dictionary != rhs._dictionary
}
