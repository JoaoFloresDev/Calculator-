//
//  RoundedShadowView.swift
//  Calculator Notes
//
//  Created by Joao Victor Flores da Costa on 12/09/23.
//  Copyright © 2023 MakeSchool. All rights reserved.
//

import Foundation
import UIKit

class RoundedShadowView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0.2
        self.backgroundColor = UIColor(hex: "#383B3F", alpha: 1)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.width / 2
        self.layer.masksToBounds = false
    }
}

class ShadowRoundedView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0.2
        self.layer.cornerRadius = 12
        self.backgroundColor = UIColor(hex: "#383B3F", alpha: 1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.masksToBounds = false // Não corta a sombra
    }
}
