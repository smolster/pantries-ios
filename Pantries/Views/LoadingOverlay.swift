//
//  LoadingOverlay.swift
//  Pantries
//
//  Created by Swain Molster on 11/24/19.
//  Copyright © 2019 End Hunger Durham. All rights reserved.
//

import UIKit

final class LoadingOverlay: UIView {
    
    enum State {
        case spinningWithText(String)
        
        case spinning
    }
    
    private let activityIndicator = UIActivityIndicatorView(style: .white)
    private let label = UILabel(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        self.layer.cornerRadius = 5.0
        self.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        
        self.activityIndicator.startAnimating()
        self.label.font = UIFont.preferredFont(forTextStyle: .headline)
        self.label.textColor = .white
        
        let stackView = UIStackView(arrangedSubviews: [activityIndicator, label])
        stackView.axis = .horizontal
        stackView.spacing = 10.0
        stackView.alignment = .center

        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 15),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -15)
        ])
    }
    
    func set(to state: State) {
        switch state {
        case .spinning:
            label.isHidden = true
        case .spinningWithText(let text):
            label.isHidden = false
            label.text = text
        }
    }
    
    func hideSlowly() {
        UIView.animate(withDuration: 1.0) {
            self.isHidden = true
        }
    }
}

