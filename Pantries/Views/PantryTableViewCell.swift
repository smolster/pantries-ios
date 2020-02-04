//
//  PantryTableViewCell.swift
//  Pantries
//
//  Created by Josh Johnson on 6/9/18.
//  Copyright © 2018 End Hunger Durham. All rights reserved.
//

import UIKit
import MapKit

final class PantryTableViewCell: UITableViewCell {

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var availabilityLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        accessoryType = .disclosureIndicator
    }
    
    func configure(with pantry: Pantry) {
        nameLabel.text = pantry.organizations
        availabilityLabel.text = "\(pantry.days), \(pantry.hours)"
    }
}
