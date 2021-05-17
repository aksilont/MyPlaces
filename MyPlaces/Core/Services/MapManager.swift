//
//  MapManager.swift
//  MyPlaces
//
//  Created by Aksilont on 16.05.2021.
//

import UIKit
import MapKit

class MapManager {
    
    let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        return manager
    }()
    
    weak var locationManagerDelegate: CLLocationManagerDelegate? {
        didSet {
            locationManager.delegate = locationManagerDelegate
        }
    }
    
    private let regionInMeters = 1000.0
    private var placeCoordinate: CLLocationCoordinate2D?
    
    func setupPlacemark(place: Place, mapView: MKMapView) {
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
            annotation.title = place.name
            annotation.subtitle = place.type
            annotation.coordinate = placemarkLocation.coordinate
            
            self.placeCoordinate = placemarkLocation.coordinate
            
            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() == false {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert("Службы геолокации",
                               with: """
                                     Службы геолокации выключены на устройстве.
                                     Для включения: Настройки → Конфиденциальность → Службы геолокации → Включить
                                     """)
            }
        }
    }
    
    func showUserLocation(mapView: MKMapView) {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func getDirections(for mapView: MKMapView, previousLocation: (CLLocation) -> Void) {
        guard let location = locationManager.location?.coordinate else {
            showAlert("Ошибка", with: "Не удалось определить текущее местопложение")
            return
        }
        
        locationManager.startUpdatingLocation()
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        
        guard let request = createDirectionsRequest(from: location) else {
            showAlert("Ошибка", with: "Не удалось получить координаты места назначения")
            return
        }
        
        let directions = MKDirections.init(request: request)
        resetMapView(for: mapView, with: directions)
        
        directions.calculate { response, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let response = response else {
                self.showAlert("Ошибка", with: "Маршрут не доступен")
                return
            }
            
            response.routes.forEach { route in
                mapView.addOverlay(route.polyline)
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval = route.expectedTravelTime
                
                print("Расстояние до места: \(distance) км.")
                print("Время в пути: \(timeInterval) сек.")
            }
            
        }
    }
    
    private func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
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
    
    func startTrackingUserLocation(for mapView: MKMapView,
                                   location: CLLocation?,
                                   closure: (CLLocation) -> Void) {
        guard let location = location else { return }
        let center = getCenterLocation(for: mapView)
        guard center.distance(from: location) > 50 else { return }
        closure(center)
    }
    
    private func resetMapView(for mapView: MKMapView, with directions: MKDirections) {
        mapView.removeOverlays(mapView.overlays)
        directions.cancel()
    }
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    private func showAlert(_ title: String, with: String) {
        
    }
    
}
