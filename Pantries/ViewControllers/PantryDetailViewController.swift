//
//  PantryDetailViewController.swift
//  Pantries
//
//  Created by Swain Molster on 2/3/20.
//  Copyright © 2020 End Hunger Durham. All rights reserved.
//

import UIKit
import MapKit

final class PantryDetailViewController: UIViewController {
    
    @IBOutlet private weak var mapView: MKMapView!
    
    @IBOutlet private weak var organizationLabel: UILabel!
    @IBOutlet private weak var phoneNumberLabel: UILabel!
    @IBOutlet private weak var addressTitleLabel: UILabel!
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var availabilityTitleLabel: UILabel!
    @IBOutlet private weak var availabilityLabel: UILabel!
    @IBOutlet private weak var qualificationsTitleLabel: UILabel!
    @IBOutlet private weak var qualificationsLabel: UILabel!
    @IBOutlet private weak var additionalInfoTitleLabel: UILabel!
    @IBOutlet private weak var additionalInfoLabel: UILabel!
    
    private let pantry: Pantry
    
    init(for pantry: Pantry) {
        self.pantry = pantry
        super.init(nibName: "PantryDetailViewController", bundle: .main)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func tappedPhoneNumber(_ sender: UITapGestureRecognizer) {
        if let callURL = URL(string: "tel://\(pantry.phone)"),
            UIApplication.shared.canOpenURL(callURL) {
            UIApplication.shared.open(callURL, options: [:], completionHandler: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Plug pnztry into labels.
        self.title = pantry.organizations
        self.organizationLabel.text = pantry.organizations
        self.phoneNumberLabel.text = pantry.phone
        self.addressTitleLabel.text = NSLocalizedString("item_detail_address", comment: "The address header in the detail view.")
        self.addressLabel.text = pantry.address
        self.availabilityTitleLabel.text = NSLocalizedString("item_detail_available", comment: "The availability header in the detail view.")
        self.availabilityLabel.text = "\(pantry.days)\n\(pantry.hours)"
        self.qualificationsTitleLabel.text = NSLocalizedString("item_detail_prereqs", comment: "The qualifications header in the detail view.")
        self.qualificationsLabel.text = pantry.prereq
        self.additionalInfoTitleLabel.text = NSLocalizedString("item_detail_info", comment: "The additional info header in the detail view.")
        self.additionalInfoLabel.text = pantry.info
        
        // Configure map view.
        self.mapView.delegate = self
        self.mapView.addAnnotation(PantryAnnotation(pantry: self.pantry))
        self.mapView.camera.centerCoordinate = CLLocationCoordinate2D(latitude: self.pantry.latitude, longitude: self.pantry.longitude)
        self.mapView.camera.altitude = 1000
    }
}

extension PantryDetailViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let marker = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
        marker.animatesDrop = true
        return marker
    }
}
