//
//  DiamondView.swift
//  Calculator Notes
//
//  Created by Joao Victor Flores da Costa on 20/09/23.
//  Copyright © 2023 MakeSchool. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class PurchaseHeaderView: UIView {
    
    // Elementos da UI
    private let diamondView = DiamondView()
    private let stackView = UIStackView()
    private let marketIcon = UIImageView()
    let title = UILabel()
    let subtitle = UILabel()
    let price = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        // Configuração do DiamondView
        diamondView.frame = CGRect(x: 50, y: 50, width: 100, height: 100)
        addSubview(diamondView)
        
        // Configuração do StackView
        stackView.axis = .vertical
        diamondView.addSubview(stackView)
        
        // Configuração do MarketIcon
        marketIcon.contentMode = .scaleAspectFit
        marketIcon.image = UIImage(named: Img.iconMrk.name())
        marketIcon.snp.makeConstraints { make in
            make.height.width.equalTo(60)
        }
        
        // Configuração do Title
        title.textAlignment = .center
        title.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        
        // Configuração do Subtitle
        subtitle.textAlignment = .center
        subtitle.font = UIFont.systemFont(ofSize: 16, weight: .regular)

        price.textAlignment = .center
        price.font = UIFont.systemFont(ofSize: 18, weight: .regular)

        title.text = "SG PRO"
        subtitle.text = Text.callToActionPurchase.localized()
        price.isHidden = true
        
        // Adicionar elementos ao StackView
        stackView.addArrangedSubview(createSpacer(height:  8))
        stackView.addArrangedSubview(marketIcon)
        stackView.addArrangedSubview(createSpacer(height:  20))
        stackView.addArrangedSubview(title)
        stackView.addArrangedSubview(createSpacer(height:  8))
        stackView.addArrangedSubview(subtitle)
        stackView.addArrangedSubview(createSpacer(height:  16))
        stackView.addArrangedSubview(price)
        stackView.addArrangedSubview(createSpacer(height:  30))
        
        // Constraints do StackView
        stackView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        // Constraints do DiamondView
        diamondView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
        }
    }
    
    private func createSpacer(height: CGFloat) -> UIView {
        let spacer = UIView()
        spacer.snp.makeConstraints { make in
            make.height.equalTo(height)
        }
        return spacer
    }
}

