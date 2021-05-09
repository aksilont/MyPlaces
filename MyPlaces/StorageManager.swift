//
//  StorageManager.swift
//  MyPlaces
//
//  Created by Aksilont on 08.05.2021.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    
    static func saveObject(_ place: Place) {
        do {
            try realm.write {
                realm.add(place)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    static func deleteObject(_ place: Place) {
        do {
            try realm.write {
                realm.delete(place)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
}
