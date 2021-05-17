//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Aksilont on 13.05.2021.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewControllerDelegate: AnyObject {
    func getAddress(_ address: String?)
}

class MapViewController: UIViewController {
    
    let mapManager = MapManager()
    weak var mapViewControllerDelegate: MapViewControllerDelegate?
    var place = Place()
    
    let annotationIdentifier = "AnnotationIdentifier"
    var incomeSegueIdentifier = ""
    
    var previousLocation: CLLocation? {
        didSet {
            mapManager.startTrackingUserLocation(for: mapView, location: previousLocation) { currentLocation in
                self.previousLocation = currentLocation
                DispatchQueue.main.async {
                    self.mapManager.showUserLocation(mapView: self.mapView)
                }
            }
        }
    }
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.delegate = self
        }
    }
    @IBOutlet weak var mapPinImage: UIImageView!
    @IBOutlet weak var addressLabel: UILabel! {
        didSet {
            addressLabel.text = ""
        }
    }
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var goButton: UIButton! {
        didSet {
            goButton.isHidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
    }
    
    private func setupMapView() {
        mapManager.locationManagerDelegate = self
        mapManager.checkLocationServices()
        
        if incomeSegueIdentifier == "ShowPlace" {
            mapManager.setupPlacemark(place: place, mapView: mapView)
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden = false
        }
    }
    
    private func showAlert(_ title: String, with message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let actionOk = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(actionOk)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func myLocationTapped(_ sender: UIButton) {
        mapManager.showUserLocation(mapView: mapView)
    }
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        mapViewControllerDelegate?.getAddress(addressLabel.text)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func goButtonTapped(_ sender: UIButton) {
        mapManager.getDirections(for: mapView) { location in
            self.previousLocation = location
        }
    }
    
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        
        var annotationView =
            mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true
        }
        
        if let imageData = place.imageData {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            annotationView?.rightCalloutAccessoryView = imageView
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        if incomeSegueIdentifier == "ShowPlace" && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.mapManager.showUserLocation(mapView: mapView)
            }
        }
        
        if incomeSegueIdentifier == "GetAddress" {
            let centerLocation = mapManager.getCenterLocation(for: mapView)
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(centerLocation) { placemarks, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                guard let placemarks = placemarks else { return }
                let placemark = placemarks.first
                
                let streetName = placemark?.thoroughfare
                let buildNumber = placemark?.subThoroughfare
                
                DispatchQueue.main.async {
                    if streetName != nil && buildNumber != nil {
                        self.addressLabel.text = "\(streetName!), \(buildNumber!)"
                    } else if streetName != nil {
                        self.addressLabel.text = "\(streetName!)"
                    } else {
                        self.addressLabel.text = ""
                    }
                }
            }
        }
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .systemBlue
        renderer.lineWidth = 2.0
        return renderer
    }
    
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus as CLAuthorizationStatus {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if incomeSegueIdentifier == "GetAddress" { mapManager.showUserLocation(mapView: self.mapView) }
        case .denied:
            showAlert("Службы геолокации", with: "Нет доступа к местоположению")
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted:
            showAlert("Службы геолокации", with: "Приложение не авторизовано для использования служб геолокации")
        case .authorizedAlways:
            break
        @unknown default:
            break
        }
    }
    
}
