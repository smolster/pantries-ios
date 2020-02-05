//
//  PantryListViewController.swift
//  Pantries
//
//  Created by Swain Molster on 11/24/19.
//  Copyright © 2018 End Hunger Durham. All rights reserved.
//

import UIKit
import MapKit

typealias PantryLoadingFunction = (_ completion: @escaping ([Pantry]?) -> Void) -> Void

final class PantryListViewController: UITableViewController {
    
    private let cellIdentifier = "PantryTableCell"
    private let locationManager = CLLocationManager()
    private let searchController = UISearchController(searchResultsController: nil)
    
    private let loadPantries: PantryLoadingFunction
    
    private let loadingOverlay = LoadingOverlay()
    
    private var pantries: [Pantry] = []
    // Used for search
    private var filteredPantries: [Pantry] = []
    
    init(pantryLoadingFunction: @escaping PantryLoadingFunction) {
        self.loadPantries = pantryLoadingFunction
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("list_screen_title", comment: "Navigation title for the list screen.")
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search pantries"
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(refreshControlPulled), for: .valueChanged)
        
        tableView.register(UINib(nibName: "PantryTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        
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
    
    @objc func refreshControlPulled(_ sender: UIRefreshControl) {
        self.refreshPantries()
    }
    
    func refreshPantries() {
        self.loadingOverlay.isHidden = false
        self.tableView.isUserInteractionEnabled = false
        self.searchController.searchBar.text = nil
        self.searchController.searchBar.resignFirstResponder()

        loadPantries { [weak self] pantries in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let pantries = pantries {
                    self.pantries = pantries
                    self.filteredPantries = pantries
                    self.tableView.reloadData()
                }
                self.refreshControl?.endRefreshing()
                UIView.animate(
                    withDuration: 0.5,
                    animations: {
                        self.loadingOverlay.alpha = 0.0
                    },
                    completion: { _ in
                        self.loadingOverlay.isHidden = true
                    }
                )
                self.tableView.isUserInteractionEnabled = true
            }
        }
    }
    
    // MARK: - UITableViewDataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPantries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PantryTableViewCell
        cell.configure(with: filteredPantries[indexPath.row])
        return cell
    }
    
    // MARK: - UITableViewDelegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigationController?.pushViewController(PantryDetailViewController(for: filteredPantries[indexPath.row]), animated: true)
    }
}

extension PantryListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            self.filteredPantries = pantries.filter { pantry in
                return pantry.address.lowercased().contains(searchText.lowercased())
                    || pantry.city.lowercased().contains(searchText.lowercased())
                    || pantry.organizations.lowercased().contains(searchText.lowercased())
            }
        } else {
            filteredPantries = pantries
        }
        tableView.reloadData()
    }
    
}
