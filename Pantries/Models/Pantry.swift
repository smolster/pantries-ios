//
//  Pantry.swift
//  Pantries
//
//  Created by Swain Molster on 11/24/19.
//  Copyright © 2019 End Hunger Durham. All rights reserved.
//

import Foundation
import MapKit

struct Pantry: Decodable {
    var address: String
    var city: String
    var days: String
    var hours: String
    var info: String
    var organizations: String
    var phone: String
    var prereq: String
    var latitude: Double
    var longitude: Double
}

class PantryOld {
    
    var address: String?
    var city: String?
    var days: String?
    var hours: String?
    var info: String?
    var organization: String?
    var phone: String?
    var prereq: String?
    var latitude: Double?
    var longitude: Double?
    
    var image: UIImage?
    var snapshotter: MKMapSnapshotter?
    
    // todo cheating a distance for demo
    var distance = Double.greatestFiniteMagnitude
    
}
