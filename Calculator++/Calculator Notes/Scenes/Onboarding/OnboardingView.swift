//
//  OnboardingView.swift
//  Calculator Notes
//
//  Created by Joao Victor Flores da Costa on 25/09/23.
//  Copyright © 2023 MakeSchool. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

protocol OnboardingViewDelegate: AnyObject {
    func didTapPrimaryButton()
    func didTapSecondaryButton()
}

class OnboardingView: UIView {
    
    weak var delegate: OnboardingViewDelegate?
    
    // Elementos da tela
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()
    
    private let startButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    private let skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.numberOfLines = 0
        button.tintColor = .white
        return button
    }()
    
    // Inicializador personalizado
    init(
        title: String,
        subtitle: String,
        startButtonTitle: String,
        skipButtonTitle: String,
        delegate: OnboardingViewDelegate
    ) {
        super.init(frame: .zero)
        
        backgroundImageView.image = UIImage(named: "background")
        titleLabel.text = title
        subtitleLabel.text = subtitle
        startButton.setTitle(startButtonTitle, for: .normal)
        skipButton.setTitle(skipButtonTitle, for: .normal)
        
        // Adicionar elementos à view
        addSubview(backgroundImageView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(startButton)
        addSubview(skipButton)
        
        // Configurar layout com SnapKit
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().multipliedBy(0.8)
            make.leading.trailing.equalToSuperview()
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().inset(24)
        }
        
        startButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().inset(24)
            make.bottom.equalTo(skipButton.snp.top).offset(-32)
            make.height.equalTo(56)
        }
        
        skipButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalTo(safeAreaLayoutGuide).offset(-20)
        }
        
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        skipButton.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
        
        self.delegate = delegate
    }
    
    @objc private func startButtonTapped() {
        delegate?.didTapPrimaryButton()
    }
    
    @objc private func skipButtonTapped() {
        delegate?.didTapSecondaryButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Remova a camada anterior (se existir) para evitar sobreposição de múltiplas camadas
        startButton.layer.sublayers?.removeAll { $0 is CAGradientLayer }
        
        // Agora adicione a camada de gradiente
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = startButton.bounds
        gradientLayer.colors = [UIColor(hex: "4EACE3").cgColor, UIColor(hex: "1E84C0").cgColor]
        gradientLayer.cornerRadius = 10
        startButton.layer.insertSublayer(gradientLayer, at: 0)
    }
}
