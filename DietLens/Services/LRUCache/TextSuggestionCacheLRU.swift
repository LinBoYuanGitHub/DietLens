//
//  SharedPreferenceCacheLRU.swift
//  DietLens
//
//  Created by linby on 2018/9/16.
//  Copyright © 2018 NExT++. All rights reserved.
//

import Foundation

class TextSuggestionCacheLRU {

    let capacity: Int
    var list = [Int]()
    var dict = [Int: TextSearchSuggestionEntity]()

    init(capacity: Int) {
        self.capacity = max(0, capacity)
        getFromSharedPreference()
    }

    func setValue(_ value: TextSearchSuggestionEntity, for key: Int) {
        if dict.keys.contains(where: { (eachKey) -> Bool in
            return eachKey == key
        }) {
            //move key to first
            guard let index = list.index(of: key) else {
                //handle the previous wrong cache issue
                dict.removeValue(forKey: key)
                return
            }
            list.remove(at: index)
            list.insert(key, at: 0)
        } else {
            //judege whether excess the capacity
            if list.count + 1 > capacity {
                let id = list.removeLast()
                dict.removeValue(forKey: id)
            }
            list.insert(key, at: 0)
            dict[key] = value
        }
        //persist the value each time when we save the LRU value
        save()
    }

    func getAllValue() -> [TextSearchSuggestionEntity] {
        var values = [TextSearchSuggestionEntity]()
        for key in list {
            let value = dict[key]
            values.append(value!)
        }
        return values
    }

    func save() {
        saveToSharedPreference()
    }

    func saveToSharedPreference() {
        let sharedPreference = UserDefaults.standard
        for (index, key) in list.enumerated() {
            let value = dict[key]
            if let encoded = try? JSONEncoder().encode(value) {
                 sharedPreference.set(encoded, forKey: "SearchLRU_" + String(index))
            }
        }
    }

    func getFromSharedPreference() {
        let sharedPreference = UserDefaults.standard
        for index in 0...(capacity - 1) {
            if let decodedData = sharedPreference.data(forKey: "SearchLRU_" + String(index)) {
                if let entity = try? JSONDecoder().decode(TextSearchSuggestionEntity.self, from: decodedData) {
                    dict[entity.id] = entity
                    list.append(entity.id)
                }

            }
        }
    }

}
