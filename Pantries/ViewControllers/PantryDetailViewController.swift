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
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet private weak var organizationLabel: UILabel!
    @IBOutlet private weak var phoneNumberLabel: UILabel!
    
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
        // Plug pantry into labels.
        self.title = pantry.organizations
        
        self.organizationLabel.lineBreakMode = .byWordWrapping
        self.organizationLabel.numberOfLines = 0
        self.organizationLabel.font = .preferredFont(forTextStyle: .title1)
        self.organizationLabel.adjustsFontForContentSizeCategory = true
        self.organizationLabel.text = pantry.organizations
        
        self.phoneNumberLabel.lineBreakMode = .byWordWrapping
        self.phoneNumberLabel.numberOfLines = 0
        self.phoneNumberLabel.font = .preferredFont(forTextStyle: .title2)
        self.phoneNumberLabel.adjustsFontForContentSizeCategory = true
        self.phoneNumberLabel.text = pantry.phone
        
        [
            (
                title: NSLocalizedString("item_detail_address", comment: "The address header in the detail view."),
                detail: pantry.address
            ),
            (
                title: NSLocalizedString("item_detail_available", comment: "The availability header in the detail view."),
                detail: "\(pantry.days)\n\(pantry.hours)"
            ),
            (
                title: NSLocalizedString("item_detail_prereqs", comment: "The qualifications header in the detail view."),
                detail: pantry.prereq
            ),
            (
                title: NSLocalizedString("item_detail_info", comment: "The additional info header in the detail view."),
                detail: pantry.info
            )
        ]
            .forEach { item in
                let titleDetailView = makeTitleDetailView(title: item.title, detail: item.detail)
                stackView.addArrangedSubview(titleDetailView)
            }
        
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let coordinate = CLLocationCoordinate2D(latitude: pantry.latitude, longitude: pantry.longitude)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = pantry.organizations
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault])
        mapView.deselectAnnotation(view.annotation, animated: true)
    }
}

func makeTitleDetailView(title: String, detail: String) -> UIView {
    let titleLabel = UILabel()
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.numberOfLines = 0
    titleLabel.lineBreakMode = .byWordWrapping
    titleLabel.font = .preferredFont(forTextStyle: .headline)
    titleLabel.adjustsFontForContentSizeCategory = true
    titleLabel.text = title
    
    let detailLabel = UILabel()
    detailLabel.translatesAutoresizingMaskIntoConstraints = false
    detailLabel.numberOfLines = 0
    detailLabel.lineBreakMode = .byWordWrapping
    detailLabel.font = .preferredFont(forTextStyle: .body)
    detailLabel.adjustsFontForContentSizeCategory = true
    detailLabel.text = detail
    
    let view = UIView()
    view.addSubview(titleLabel)
    view.addSubview(detailLabel)
    
    NSLayoutConstraint.activate([
        titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        titleLabel.topAnchor.constraint(equalTo: view.topAnchor),
        titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        titleLabel.bottomAnchor.constraint(equalTo: detailLabel.topAnchor, constant: -10),
        detailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        detailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        detailLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
    return view
}
