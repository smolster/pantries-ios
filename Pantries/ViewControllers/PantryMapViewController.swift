//
//  PantryMapViewController.swift
//  Pantries
//
//  Created by Josh Johnson on 7/10/18.
//  Copyright © 2018 End Hunger Durham. All rights reserved.
//

import UIKit
import MapKit

final class PantryMapViewController: UIViewController {

    private let mapView = MKMapView(frame: .zero)
    
    private let locationManager = CLLocationManager()
    private let loadPantries: PantryLoadingFunction
    
    private var isInitialLoad: Bool = true
    private var userLocation: CLLocationCoordinate2D?
    private var pantries: [Pantry] = []
    
    private var selectedPantry: Pantry?
    
    init(pantryLoadingFunction: @escaping PantryLoadingFunction) {
        self.loadPantries = pantryLoadingFunction
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("map_screen_title", comment: "Navigation title for the map screen.")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_nearby"), style: .plain, target: self, action: #selector(scanButtonTapped))
        navigationItem.rightBarButtonItem?.isEnabled = CLLocationManager.authorizationStatus() == .authorizedWhenInUse
        
        locationManager.delegate = self
        
        self.view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        refreshPantries()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 100.0
        if CLLocationManager.authorizationStatus() == .notDetermined {
            self.locationManager.requestWhenInUseAuthorization()
        } else if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    @objc private func scanButtonTapped(_ sender: UIBarButtonItem) {
        if let location = self.userLocation {
            self.mapView.setCenter(location, animated: true)
        }
    }
    
    private func refreshPantries() {
        loadPantries { [weak self] pantries in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let pantries = pantries {
                    self.pantries = pantries
                    self.pantries.forEach { pantry in
                        self.mapView.addAnnotation(PantryAnnotation(pantry: pantry))
                    }
                    self.mapView.camera.centerCoordinate = CLLocationCoordinate2D(latitude: 35.996543666002445, longitude: -78.90108037808307)
                    self.mapView.camera.altitude = 10000
                }
            }
        }
    }

}

extension PantryMapViewController: MKMapViewDelegate {
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? PantryAnnotation else { return nil }
        let reuseIdentifier = "Placemark"
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) {
            dequeuedView.annotation = annotation
            return dequeuedView
        } else {
            let marker = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            marker.animatesDrop = true
            marker.canShowCallout = true
            let button = UIButton(type: .detailDisclosure)
            button.addTarget(self, action: #selector(calloutButtonTapped(_:)), for: .touchUpInside)
            marker.rightCalloutAccessoryView = button
            return marker
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let pantryAnnotation = view.annotation as? PantryAnnotation {
            self.selectedPantry = pantryAnnotation.pantry
        }
    }
    
    @objc private func calloutButtonTapped(_ sender: UIButton) {
        guard let pantry = self.selectedPantry else { return }
        self.navigationController?.pushViewController(PantryDetailViewController(for: pantry), animated: true)
    }
}

extension PantryMapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last,
            location.horizontalAccuracy <= kCLLocationAccuracyHundredMeters else { return }
        self.userLocation = location.coordinate
        // On the initial load, we want to center the map on the user.
        if self.isInitialLoad {
            self.isInitialLoad = false
            DispatchQueue.main.async {
                self.mapView.setCenter(location.coordinate, animated: true)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed obtaining location: \(error.localizedDescription)")
    }
}

final class PantryAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let pantry: Pantry
    
    var title: String? {
        return pantry.organizations
    }
    
    var subtitle: String? {
        return "\(pantry.days), \(pantry.hours)"
    }
    
    init(pantry: Pantry) {
        self.pantry = pantry
        self.coordinate = CLLocationCoordinate2D(latitude: pantry.latitude, longitude: pantry.longitude)
        super.init()
    }
}
