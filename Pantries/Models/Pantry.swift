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
