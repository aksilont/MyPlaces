//
//  StorageManager.swift
//  MyPlaces
//
//  Created by Aksilont on 08.05.2021.
//

import RealmSwift

class StorageManager {
    
    static var realm: Realm {
        do {
            let realm = try Realm()
            return realm
        } catch {
            print("Could not access database: ", error)
        }
        return self.realm
    }
    
    static func getObjects<Element: Object>(_ type: Element.Type) -> Results<Element> {
        return realm.objects(type)
    }
    
    static func saveObject(_ place: Place, update: Bool = false) {
        do {
            try realm.write {
                if update {
                    realm.add(place, update: .modified)
                } else {
                    realm.add(place)
                }
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
