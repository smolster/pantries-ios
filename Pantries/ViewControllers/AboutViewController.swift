//
//  AboutViewController.swift
//  Pantries
//
//  Created by Swain Molster on 2/18/20.
//  Copyright © 2020 End Hunger Durham. All rights reserved.
//

import UIKit

final class AboutViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "About"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closeTapped(_:)))
        
        view.backgroundColor = .groupTableViewBackground

        let blurbLabel = UILabel()
        blurbLabel.numberOfLines = 0
        blurbLabel.translatesAutoresizingMaskIntoConstraints = false
        blurbLabel.adjustsFontForContentSizeCategory = true
        blurbLabel.font = .preferredFont(forTextStyle: .body)
        blurbLabel.textAlignment = .center
        blurbLabel.text = NSLocalizedString("ehd_blurb", comment: "The blurb on the About page.")
        
        let versionLabel = UILabel()
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        versionLabel.adjustsFontForContentSizeCategory = true
        versionLabel.font = .preferredFont(forTextStyle: .caption1)
        blurbLabel.textAlignment = .center
        versionLabel.text = "Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)"
        
        self.view.addSubview(blurbLabel)
        self.view.addSubview(versionLabel)
        
        NSLayoutConstraint.activate([
            blurbLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            blurbLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            blurbLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            blurbLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            
            versionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            versionLabel.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor)
        ])
    }
    
    @objc private func closeTapped(_ sender: UIBarButtonItem) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }

}
