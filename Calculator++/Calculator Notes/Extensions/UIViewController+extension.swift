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

    // Errors
    func showError(title: String, text: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: title,
                                      message: text,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in completion()
        }))
        
        self.present(alert, animated: true)
    }
    
    func showGenericError() {
        let alert = UIAlertController(title: Text.errorTitle.rawValue.localized(),
                                      message: Text.errorMessage.rawValue.localized(),
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // Folders
    func showInputDialog(title:String? = nil,
                         subtitle:String? = nil,
                         actionTitle:String?,
                         cancelTitle:String?,
                         inputPlaceholder:String? = nil,
                         inputKeyboardType:UIKeyboardType = UIKeyboardType.default,
                         cancelHandler: ((UIAlertAction) -> Swift.Void)? = nil,
                         actionHandler: ((_ text: String?) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        alert.addTextField { (textField:UITextField) in
            textField.placeholder = inputPlaceholder
            textField.keyboardType = inputKeyboardType
        }
        
        alert.addAction(UIAlertAction(title: cancelTitle, style: .default, handler: cancelHandler))
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { (action:UIAlertAction) in
            guard let textField =  alert.textFields?.first else {
                actionHandler?(nil)
                return
            }
            actionHandler?(textField.text)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // Edition
    func showConfirmationDelete(completion: @escaping () -> Void) {
        let alert = UIAlertController(title: Text.deleteConfirmationTitle.rawValue.localized(), message: nil, preferredStyle: .alert)
        
        alert.modalPresentationStyle = .popover
        
        alert.addAction(UIAlertAction(title: Text.cancel.localized(), style: .destructive, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion()
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    // Premium
    func showBePremiumToUse(completion: @escaping () -> Void) {
        let alert = UIAlertController(title: Text.premiumToolTitle.rawValue.localized(),
                                      message: Text.premiumToolMessage.rawValue.localized(),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Text.cancel.localized(), style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "See", style: .default, handler: { _ in
            completion()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // First use
    func showSetProtectionAsk(completion: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: Text.wouldLikeSetProtection.localized(), message: nil, preferredStyle: .alert)
        
        alert.modalPresentationStyle = .popover
        
        alert.addAction(UIAlertAction(title: Text.cancel.localized(), style: .default, handler: { _ in
            completion(false)
        }))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion(true)
        }))
        
        present(alert, animated: true, completion: nil)
    }
}
