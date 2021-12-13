//
//  NavigationController+Extensions.swift
//  Calculator Notes
//
//  Created by Joao Victor Flores da Costa on 13/12/21.
//  Copyright © 2021 MakeSchool. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController {
    func setup() {
        navigationBar.tintColor = UIColor.white
        navigationBar.isTranslucent = true

        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.backgroundColor = UIColor(named: "navigationBar")
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
            navigationBar.compactAppearance = appearance
        }

        navigationBar.layer.masksToBounds = false
        navigationBar.layer.shadowColor = UIColor.black.cgColor
        navigationBar.layer.shadowOffset = CGSize(width: 0, height: 2)
        navigationBar.layer.shadowRadius = 15
        navigationBar.layer.shadowOpacity = 0.1
    }
}
