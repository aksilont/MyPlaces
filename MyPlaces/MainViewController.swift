//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Aksilont on 05.05.2021.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    @IBOutlet weak var segmentedConrol: UISegmentedControl!
    @IBOutlet weak var reversedSortingButton: UIBarButtonItem!
    
    var places: Results<Place>!
    var ascendingSorting = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        places = realm.objects(Place.self)
        sorting(reloadTableView: false)
    }

    // MARK: - TableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.isEmpty ? 0 : places.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    func tableView(_ tableView: UITableView,
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
            guard let indexPath = tableView.indexPathForSelectedRow,
                  let newPlaceVC = segue.destination as? NewPlaceViewController
            else { return }
            let place = places[indexPath.row]
            newPlaceVC.currentPlace = place
        }
    }

    private func sorting(reloadTableView: Bool = true) {
        switch segmentedConrol.selectedSegmentIndex {
        case 0:
            places = places.sorted(byKeyPath: "date", ascending: ascendingSorting)
        case 1:
            places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
        default:
            break
        }
        if reloadTableView { tableView.reloadData() }
    }
    
    @IBAction func sortSelectection(_ sender: UISegmentedControl) {
        sorting()
    }
    
    @IBAction func reversedSorting(_ sender: Any) {
        ascendingSorting.toggle()
        if ascendingSorting {
            reversedSortingButton.image = UIImage(systemName: "arrowtriangle.up")
        } else {
            reversedSortingButton.image = UIImage(systemName: "arrowtriangle.down")
        }
        
        sorting()
    }
}
