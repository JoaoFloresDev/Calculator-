//
//  IconContentView.swift
//  Calculator Notes
//
//  Created by João Flores on 10/10/24.
//  Copyright © 2024 MakeSchool. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class IconContentView: UIView {
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    private func setupView() {
        let stackView = UIStackView(
            arrangedSubviews: [
                createIconImage(UIImage(named: "calculadora"), action: #selector(metodoExemplo)),
                createIconImage(UIImage(named: "foguetinho"), action: #selector(metodoExemplo2)),
                createIconImage(UIImage(named: "iPhotos"), action: #selector(metodoExemplo3)),
                createIconImage(UIImage(named: "iconeOriginal"), action: #selector(metodoExemplo4))
            ]
        )
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        
        let label = UILabel()
        label.setText(.changeIconTitle)
        label.font = UIFont.boldSystemFont(ofSize: 18)
        
        addSubview(stackView)
        addSubview(label)
        
        label.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        layer.cornerRadius = 10
        clipsToBounds = true
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 3
        layer.shadowOpacity = 0.2
        layer.masksToBounds = false
        
        backgroundColor = .white
    }
    
    private func createIconImage(_ image: UIImage?, action: Selector) -> UIView {
        let view = UIView()
        let imageView = UIImageView(image: image)
        
        view.addSubview(imageView)
        
        view.snp.makeConstraints { make in
            make.width.height.equalTo(80)
        }
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 1
        
        imageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: action)
        imageView.addGestureRecognizer(tapGesture)

        return view
    }
    
    @objc func metodoExemplo() {
        setIcon(name: "icon1")
    }
    
    @objc func metodoExemplo2() {
        setIcon(name: "Icon2")
    }
    
    @objc func metodoExemplo3() {
        setIcon(name: "icon3")
    }
    
    @objc func metodoExemplo4() {
        setIcon(name: "icon4")
    }
    
    func setIcon(name: String) {
        let app = UIApplication.shared
        if #available(iOS 10.3, *) {
            if app.supportsAlternateIcons {
                app.setAlternateIconName(name, completionHandler: { (error) in
                    if error != nil {
                        print("error => \(String(describing: error?.localizedDescription))")
                    } else {
                        print("Changed Icon Sucessfully.")
                    }
                })
            }
        }
    }
}
