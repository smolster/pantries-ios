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
    
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var organizationLabel: UILabel!
    
    private let pantry: Pantry
    
    init(for pantry: Pantry) {
        self.pantry = pantry
        super.init(nibName: "PantryDetailViewController", bundle: .main)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Plug pantry into labels.
        self.title = pantry.organizations
        
        self.organizationLabel.lineBreakMode = .byWordWrapping
        self.organizationLabel.numberOfLines = 0
        self.organizationLabel.font = .preferredFont(forTextStyle: .title1)
        self.organizationLabel.adjustsFontForContentSizeCategory = true
        self.organizationLabel.text = pantry.organizations
        
        [
            (
                title: NSLocalizedString("item_detail_address", comment: "The address header in the detail view."),
                detail: "\(pantry.address)\n\(pantry.city)",
                detailDataDetectorTypes: UIDataDetectorTypes.address
            ),
            (
                title: NSLocalizedString("item_detail_available", comment: "The availability header in the detail view."),
                detail: "\(pantry.days)\n\(pantry.hours)",
                detailDataDetectorTypes: nil
            ),
            (
                title: NSLocalizedString("item_detail_phone", comment: "The phone header in the detail view."),
                detail: pantry.phone,
                detailDataDetectorTypes: UIDataDetectorTypes.phoneNumber
            ),
            (
                title: NSLocalizedString("item_detail_prereqs", comment: "The qualifications header in the detail view."),
                detail: pantry.prereq,
                detailDataDetectorTypes: nil
            ),
            (
                title: NSLocalizedString("item_detail_info", comment: "The additional info header in the detail view."),
                detail: pantry.info,
                detailDataDetectorTypes: nil
            )
        ]
            .enumerated()
            .map { offset, item -> UIView in
                let titleLabel = UILabel()
                titleLabel.translatesAutoresizingMaskIntoConstraints = false
                titleLabel.numberOfLines = 0
                titleLabel.lineBreakMode = .byWordWrapping
                titleLabel.font = .preferredFont(forTextStyle: .headline)
                titleLabel.adjustsFontForContentSizeCategory = true
                titleLabel.text = item.title
                
                // We use a text view so that we can take advantage of dataDetectorTypes.
                let detailTextView = UITextView()
                detailTextView.translatesAutoresizingMaskIntoConstraints = false
                detailTextView.textContainerInset = .zero
                detailTextView.textContainer.lineFragmentPadding = 0.0
                detailTextView.isEditable = false
                detailTextView.isScrollEnabled = false
                detailTextView.textContainer.lineBreakMode = .byWordWrapping
                detailTextView.font = .preferredFont(forTextStyle: .body)
                detailTextView.adjustsFontForContentSizeCategory = true
                detailTextView.text = item.detail
                detailTextView.dataDetectorTypes = item.detailDataDetectorTypes ?? []
                
                let view = UIView()
                view.addSubview(titleLabel)
                view.addSubview(detailTextView)
                
                NSLayoutConstraint.activate([
                    titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    titleLabel.topAnchor.constraint(equalTo: view.topAnchor),
                    titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    titleLabel.bottomAnchor.constraint(equalTo: detailTextView.topAnchor, constant: -10),
                    detailTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    detailTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    detailTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                ])
                return view
            }
            .forEach(stackView.addArrangedSubview(_:))
        
        // Configure map view.
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let coordinate = CLLocationCoordinate2D(latitude: pantry.latitude, longitude: pantry.longitude)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = pantry.organizations
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault])
        mapView.deselectAnnotation(view.annotation, animated: true)
    }
}
