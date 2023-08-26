//
//  UILabel+extensions.swift
//  Calculator Notes
//
//  Created by Joao Victor Flores da Costa on 06/02/22.
//  Copyright © 2022 MakeSchool. All rights reserved.
//

import UIKit

extension UILabel {
    func setText(_ text: Text) {
        self.text = text.localized()
    }
}
