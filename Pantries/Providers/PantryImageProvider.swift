//
//  PantryImageProvider.swift
//  Pantries
//
//  Created by Swain Molster on 11/24/19.
//  Copyright © 2019 End Hunger Durham. All rights reserved.
//

import Foundation
import UIKit

protocol PantryImageProvider {
    func loadImage(for pantry: Pantry, then completion: @escaping (UIImage?) -> Void)
}
