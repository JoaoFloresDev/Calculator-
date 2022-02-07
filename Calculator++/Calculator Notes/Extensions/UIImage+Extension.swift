//
//  UIImage+Extension.swift
//  Calculator Notes
//
//  Created by Joao Victor Flores da Costa on 06/02/22.
//  Copyright © 2022 MakeSchool. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func setImage(_ image: Img) {
        self.image = UIImage(named: image.rawValue)
    }
}
