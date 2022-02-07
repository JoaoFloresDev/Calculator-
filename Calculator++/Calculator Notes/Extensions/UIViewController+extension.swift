//
//  UIViewController+extension.swift
//  Calculator Notes
//
//  Created by Joao Victor Flores da Costa on 06/02/22.
//  Copyright © 2022 MakeSchool. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func setText(_ text: Text) {
        self.title = text.rawValue.localized()
    }
    
    func showGenericError() {
        let alert = UIAlertController(title: Text.errorTitle.rawValue.localized(),
                                      message: Text.errorMessage.rawValue.localized(),
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
