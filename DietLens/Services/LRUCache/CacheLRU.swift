//
//  CacheLRU.swift
//  DietLens
//
//  Created by linby on 2018/9/16.
//  Copyright © 2018 NExT++. All rights reserved.
//

import Foundation

final class CacheLRU<Key: Hashable, Value> {

    struct CachePayload {
        let key: Key
        let value: Value
    }

    let capacity: Int
    let list = DoublyLinkedList<CachePayload>()
    var nodesDict = [Key: DoublyLinkedListNode<CachePayload>]()

    init(capacity: Int) {
        self.capacity = max(0, capacity)
    }

    func setValue(_ value: Value, for key: Key) {
        let payload = CachePayload(key: key, value: value)

        if let node = nodesDict[key] {
            node.payload = payload
            list.moveToHead(node)
        } else {
            let node = list.addHead(payload)
            nodesDict[key] = node
        }

        if list.count > capacity {
            let nodeRemoved = list.removeLast()
            if let key = nodeRemoved?.payload.key {
                nodesDict[key] = nil
            }
        }
    }

    func getValue(for key: Key) -> Value? {
        guard let node = nodesDict[key] else { return nil }

        list.moveToHead(node)

        return node.payload.value
    }

}
