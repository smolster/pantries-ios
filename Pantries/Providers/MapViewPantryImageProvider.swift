//
//  MapViewPantryImageProvider.swift
//  Pantries
//
//  Created by Swain Molster on 11/24/19.
//  Copyright © 2019 End Hunger Durham. All rights reserved.
//

import Foundation
import MapKit

final class MapViewPantryImageProvider: PantryImageProvider {
    
    private let imageSize: CGSize
    
    private var snapshotters: [UUID: MKMapSnapshotter] = [:]
    
    init(size: CGSize) {
        self.imageSize = size
    }
    
    func loadImage(for pantry: Pantry, then completion: @escaping (UIImage?) -> Void) {
        // Get image snapshot.
        let options = MKMapSnapshotter.Options()
        let location = CLLocationCoordinate2DMake(pantry.latitude, pantry.longitude)
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 1000, longitudinalMeters: 1000)
        options.region = region
        options.size = imageSize
        options.showsBuildings = true
        options.showsPointsOfInterest = true

        let snapshotter = MKMapSnapshotter(options: options)
        let uuid = UUID()
        snapshotters[uuid] = snapshotter

        snapshotter.start { [weak self] snapshot, error in
            completion(snapshot?.image)
            self?.snapshotters.removeValue(forKey: uuid)
        }
        
    }
}
