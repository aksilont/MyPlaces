//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Aksilont on 05.05.2021.
//

import UIKit

class MainViewController: UITableViewController {

    let restaurantNames = [
        "Burger Heroes", "Kitchen", "Bonsai", "Дастархан",
        "Индокитай", "X.O", "Балкан Гриль", "Sherlock Holmes",
        "Speak Easy", "Morris Pub", "Вкусные истории",
        "Классик", "Love&Life", "Шок", "Бочка"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - TableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurantNames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        var content = cell.defaultContentConfiguration()

        content.image = UIImage(named: restaurantNames[indexPath.row])
        content.imageProperties.cornerRadius = cell.frame.size.height / 2
        
        content.text = restaurantNames[indexPath.row]
        
        content.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 2, leading: 0, bottom: 2, trailing: 0)
        
        cell.contentConfiguration = content
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }

}
