//
//  FooterView.swift
//  Calculator Notes
//
//  Created by Joao Victor Flores da Costa on 24/06/23.
//  Copyright © 2023 MakeSchool. All rights reserved.
//

import UIKit

protocol HeaderViewDelegate: AnyObject {
    func headerTapped(header: HeaderView)
}

class HeaderView: UICollectionReusableView {
    
    weak var delegate: HeaderViewDelegate?
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .systemGray2
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .medium)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.isHidden = true
        return activityIndicatorView
    }()
    
    var gradientView: GradientView?
    
    // Example: Configure the UI elements and layout
    private func setupUI() {
        gradientView = GradientView(frame: bounds)
        if let gradientView = gradientView {
            addSubview(gradientView)
        }
        addSubview(messageLabel)
        
        addSubview(activityIndicatorView)
        NSLayoutConstraint.activate([
            activityIndicatorView.leadingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 16),
            activityIndicatorView.topAnchor.constraint(equalTo: topAnchor),
            activityIndicatorView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Add constraints to position the message label
        // Customize the constraints based on your layout requirements
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            messageLabel.topAnchor.constraint(equalTo: topAnchor),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Add tap gesture recognizer
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    // Called when the view is about to be reused for a new section
    override func prepareForReuse() {
        super.prepareForReuse()
        // Reset any content or state of the footer view here
    }
    
    // Called when initializing the view from code
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    // Called when initializing the view from a storyboard or nib (not applicable in this case)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    // Handle tap gesture
    @objc private func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        DispatchQueue.main.async {
            self.activityIndicatorView.isHidden = false
            self.activityIndicatorView.startAnimating()
        }
        delegate?.headerTapped(header: self)
    }
}

class FooterView: UICollectionReusableView { }

class GradientView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        setupGradient()
    }
    
    func setupGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        
        // Defina as cores do gradiente
        let startColor = UIColor.systemGray6.cgColor
        let endColor = UIColor.white.cgColor
        gradientLayer.colors = [startColor, endColor]
        
        // Defina a direção do gradiente (opcional)
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0) // Início no topo
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1) // Fim na parte inferior
        
        // Adicione o gradiente à view
        layer.insertSublayer(gradientLayer, at: 0)
    }
}
