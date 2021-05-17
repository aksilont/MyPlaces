//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Aksilont on 05.05.2021.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    @IBOutlet weak var segmentedConrol: UISegmentedControl!
    @IBOutlet weak var reversedSortingButton: UIBarButtonItem!
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var places: Results<Place>!
    private var filteredPlaces: Results<Place>!
    private var ascendingSorting = true
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return true }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        places = StorageManager.getObjects(Place.self)
        sorting(reloadTableView: false)
        
        // Setup the search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        definesPresentationContext = true
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow,
                  let newPlaceVC = segue.destination as? NewPlaceViewController
            else { return }
            
            let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
            newPlaceVC.currentPlace = place
        }
    }
    
    // MARK: - Sorting
    
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
    
    // MARK: - Unwind Segue
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let newPlaceVC = segue.source as? NewPlaceViewController else { return }
        newPlaceVC.savePlace()
        tableView.reloadData()
    }
    
    // MARK: - IBActions
    
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

// MARK: - UITableViewDataSource, UITableViewDelegate

extension MainViewController: UITableViewDataSource, UITableViewDelegate {

    // MARK: - Table view Data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFiltering ? filteredPlaces.count : places.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? CustomTableViewCell
        else { return UITableViewCell() }

        let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
        
        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.imageOfPlace.image = UIImage(data: place.imageData!)
        cell.ratingView.rating = Int(place.rating)

        return cell
    }
    
    // MARK: - Table view Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt
                    indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _,_,_ in
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        let configAction = UISwipeActionsConfiguration(actions: [deleteAction])
        return configAction
    }
    
}

// MARK: - UISearchResultsUpdating

extension MainViewController: UISearchResultsUpdating {
    
    private func filterContentForSearchText(_ searchText: String) {
        filteredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
}
