//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Aksilont on 05.05.2021.
//

import UIKit
import RealmSwift

class MainViewController: UITableViewController {

    var places: Results<Place>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        places = realm.objects(Place.self)
    }

    // MARK: - TableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.isEmpty ? 0 : places.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? CustomTableViewCell
        else { return UITableViewCell() }

        let place = places[indexPath.row]

        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.imageOfPlace.image = UIImage(data: place.imageData!)
        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2
        cell.imageOfPlace.clipsToBounds = true

        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt
                                indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let place = places[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _,_,_ in
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        let configAction = UISwipeActionsConfiguration(actions: [deleteAction])
        return configAction
    }
    
    // MARK: - Unwind Segue
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let newPlaceVC = segue.source as? NewPlaceViewController else { return }
        newPlaceVC.savePlace()
        tableView.reloadData()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let place = places[indexPath.row]
            let newPlaceVC = segue.destination as! NewPlaceViewController
            newPlaceVC.currentPlace = place
        }
    }

}
