//
//  ViewController.swift
//  Pantries
//
//  Created by Josh Johnson on 6/9/18.
//  Copyright © 2018 End Hunger Durham. All rights reserved.
//

import UIKit
import MapKit

typealias PantryLoadingFunction = (_ completion: @escaping ([Pantry]?) -> Void) -> Void

final class PantryListViewController: UITableViewController {
    
    enum SortingMode {
        case alphabetical
        case nearby
    }
    
    private let cellIdentifier = "PantryTableCell"
    private let locationManager = CLLocationManager()
    
    private let loadPantries: PantryLoadingFunction
    private let pantryImageProvider: PantryImageProvider
    
    private let loadingOverlay = LoadingOverlay()
    
    private var sortingMode: SortingMode = .alphabetical
    
    private var alphabeticalPantries: [Pantry] = []
    private var nearbyPantries: [Pantry] = []
    
    init(pantryLoadingFunction: @escaping PantryLoadingFunction, pantryImageProvider: PantryImageProvider) {
        self.loadPantries = pantryLoadingFunction
        self.pantryImageProvider = pantryImageProvider
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        
        title = NSLocalizedString("list_screen_title", comment: "Navigation title for the list screen.")
        
        tableView.register(UINib(nibName: "PantryTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: #imageLiteral(resourceName: "icon_nearby"), style: .plain, target: self, action: #selector(scanButtonTapped)),
            UIBarButtonItem(title: "A-Z", style: .plain, target: self, action: #selector(alphabeticalButtonTapped))
        ]
        
        self.navigationController?.view.addSubview(loadingOverlay)
        loadingOverlay.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingOverlay.centerXAnchor.constraint(equalTo: navigationController!.view.centerXAnchor),
            loadingOverlay.centerYAnchor.constraint(equalTo: navigationController!.view.centerYAnchor)
        ])
        loadingOverlay.isHidden = true
        loadingOverlay.set(to: .spinningWithText("Loading..."))
        
        refreshPantries()
    }
    
    @objc private func alphabeticalButtonTapped() {
        self.sortingMode = .alphabetical
        tableView.reloadData()
    }
    
    @objc private func scanButtonTapped() {
        self.sortingMode = .nearby
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 100.0
        locationManager.requestLocation()
        tableView.reloadData()
    }
    
    func refreshPantries() {
        self.loadingOverlay.isHidden = false
        self.tableView.isUserInteractionEnabled = false
        loadPantries { [weak self] pantries in
            DispatchQueue.main.async {
                if let pantries = pantries {
                    self?.alphabeticalPantries = pantries
                    self?.tableView.reloadData()
                }
                UIView.animate(
                    withDuration: 0.5,
                    animations: {
                        self?.loadingOverlay.alpha = 0.0
                    },
                    completion: { _ in
                        self?.loadingOverlay.isHidden = true
                    }
                )
                self?.tableView.isUserInteractionEnabled = true
            }
        }
    }
    
    // MARK: - UITableViewDataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sortingMode {
        case .alphabetical: return alphabeticalPantries.count
        case .nearby: return nearbyPantries.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PantryTableViewCell
        let pantry: Pantry
        switch sortingMode {
        case .alphabetical: pantry = alphabeticalPantries[indexPath.row]
        case .nearby: pantry = nearbyPantries[indexPath.row]
        }
        cell.configure(with: pantry)
        return cell
    }
    
    // MARK: - UITableViewDelegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pantry: Pantry
        switch sortingMode {
        case .alphabetical: pantry = alphabeticalPantries[indexPath.row]
        case .nearby: pantry = nearbyPantries[indexPath.row]
        }
        
        self.navigationController?.pushViewController(PantryDetailViewController(for: pantry), animated: true)
    }
    
    // MARK: - Private Methods
}

extension PantryListViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied:
            navigationItem.rightBarButtonItem?.isEnabled = false
        case .authorizedWhenInUse:
            navigationItem.rightBarButtonItem?.isEnabled = true
        case .notDetermined, .authorizedAlways:
            break
        @unknown default:
            fatalError()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last,
            location.horizontalAccuracy <= kCLLocationAccuracyHundredMeters,
            sortingMode == .nearby
        else { return }
        
        self.nearbyPantries = self.alphabeticalPantries.sorted(by: nearest(to: location))
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed obtaining location: \(error.localizedDescription)")
    }
    
}

func nearest(to location: CLLocation) -> (Pantry, Pantry) -> Bool {
    return { lhs, rhs in
        let lhsLocation = CLLocation(latitude: lhs.latitude, longitude: rhs.longitude)
        let rhsLocation = CLLocation(latitude: rhs.latitude, longitude: rhs.longitude)
        return lhsLocation.distance(from: location) < rhsLocation.distance(from: location)
    }
}
