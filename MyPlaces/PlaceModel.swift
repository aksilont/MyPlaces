//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Aksilont on 06.05.2021.
//

import UIKit

struct Place {
    let name: String
    let location: String?
    let type: String?
    let image: UIImage?
    let restaurantImage: String?
    
    static let restaurantNames = [
        "Burger Heroes", "Kitchen", "Bonsai", "Дастархан",
        "Индокитай", "X.O", "Балкан Гриль", "Sherlock Holmes",
        "Speak Easy", "Morris Pub", "Вкусные истории",
        "Классик", "Love&Life", "Шок", "Бочка"
    ]
    
    static func getPlaces() -> [Place] {
        return restaurantNames.map {
            Place(name: $0, location: "Москва", type: "Ресторан", image: nil, restaurantImage: $0)
            
        }
    }
}
