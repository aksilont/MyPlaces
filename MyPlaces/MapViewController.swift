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
    
    weak var mapViewControllerDelegate: MapViewControllerDelegate?
    var place = Place()
    var placeCoordinate: CLLocationCoordinate2D?
    let annotationIdentifier = "AnnotationIdentifier"
    let locationManager = CLLocationManager()
    let regionInMeters = 10_000.0
    var incomeSegueIdentifier = ""
    
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
        checkLocationServices()
    }
    
    private func setupMapView() {
        if incomeSegueIdentifier == "ShowPlace" {
            setupPlacemark()
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden = false
        }
    }
    
    private func setupPlacemark() {
        guard let location = place.location else { return }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { placemarks, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let placemarks = placemarks,
                  let placemark = placemarks.first,
                  let placemarkLocation = placemark.location
            else { return }
            
            let annotation = MKPointAnnotation()
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            annotation.coordinate = placemarkLocation.coordinate
            
            self.placeCoordinate = placemarkLocation.coordinate
            
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert("Службы геолокации",
                               with: """
                                     Службы геолокации выключены на устройстве.
                                     Для включения: Настройки → Конфиденциальность → Службы геолокации → Включить
                                     """)
            }
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func showAlert(_ title: String, with message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let actionOk = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(actionOk)
        present(alertController, animated: true, completion: nil)
    }
    
    private func showUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    private func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    private func getDirections() {
        guard let location = locationManager.location?.coordinate else {
            showAlert("Ошибка", with: "Не удалось определить текущее местопложение")
            return
        }
        
        guard let request = createDirectionRequest(from: location) else {
            showAlert("Ошибка", with: "Не удалось получить координаты места назначения")
            return
        }
        
        let direction = MKDirections.init(request: request)
        direction.calculate { response, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let response = response else {
                self.showAlert("Ошибка", with: "Маршрут не доступен")
                return
            }
            
            response.routes.forEach { route in
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval = route.expectedTravelTime
                
                print("Расстояние до места: \(distance) км.")
                print("Время в пути: \(timeInterval) сек.")
            }
            
        }
    }
    
    private func createDirectionRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        guard let destinationCoordinate = placeCoordinate else { return nil }
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        let source = MKPlacemark(coordinate: coordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: source)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        return request
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func myLocationTapped(_ sender: UIButton) {
        showUserLocation()
    }
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        mapViewControllerDelegate?.getAddress(addressLabel.text)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func goButtonTapped(_ sender: UIButton) {
        getDirections()
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
        let centerLocation = getCenterLocation(for: mapView)
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
            if incomeSegueIdentifier == "GetAddress" { showUserLocation() }
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
