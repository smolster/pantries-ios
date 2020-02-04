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
    
    private var pantries: [Pantry] = []
    
    init(pantryLoadingFunction: @escaping PantryLoadingFunction) {
        self.loadPantries = pantryLoadingFunction
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("map_screen_title", comment: "Navigation title for the map screen.")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_nearby"), style: .plain, target: self, action: #selector(scanButtonTapped))
        
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
    }
    
    @objc private func scanButtonTapped(_ sender: UIBarButtonItem) {
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 100.0
        locationManager.requestLocation()
    }
    
    func refreshPantries() {
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

        let marker = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
        marker.animatesDrop = true
        
        return marker
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation as? PantryAnnotation else { return }
        self.navigationController?.pushViewController(PantryDetailViewController(for: annotation.pantry), animated: true)
    }
    
}

extension PantryMapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last,
            location.horizontalAccuracy <= kCLLocationAccuracyHundredMeters else { return }
        DispatchQueue.main.async {
            self.mapView.setCenter(location.coordinate, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed obtaining location: \(error.localizedDescription)")
    }
}

final class PantryAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    
    let pantry: Pantry
    
    init(pantry: Pantry) {
        self.pantry = pantry
        self.coordinate = CLLocationCoordinate2D(latitude: pantry.latitude, longitude: pantry.longitude)
        
        super.init()
    }
    
}


