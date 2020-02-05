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
    
    private let loadPantries: PantryLoadingFunction
    
    private let loadingOverlay = LoadingOverlay()
    
    private var pantries: [Pantry] = []
    
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
        loadPantries { [weak self] pantries in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let pantries = pantries {
                    self.pantries = pantries
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
        return pantries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PantryTableViewCell
        cell.configure(with: pantries[indexPath.row])
        return cell
    }
    
    // MARK: - UITableViewDelegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigationController?.pushViewController(PantryDetailViewController(for: pantries[indexPath.row]), animated: true)
    }
}
