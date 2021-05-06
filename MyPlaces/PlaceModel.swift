//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Aksilont on 06.05.2021.
//

import Foundation

struct Place {
    let name: String
    let location: String
    let type: String
    let image: String
    
    static let restaurantNames = [
        "Burger Heroes", "Kitchen", "Bonsai", "Дастархан",
        "Индокитай", "X.O", "Балкан Гриль", "Sherlock Holmes",
        "Speak Easy", "Morris Pub", "Вкусные истории",
        "Классик", "Love&Life", "Шок", "Бочка"
    ]
    
    static func getPlaces() -> [Place] {
        return restaurantNames.map { Place(name: $0, location: "Москва", type: "Ресторан", image: $0) }
    }
}
