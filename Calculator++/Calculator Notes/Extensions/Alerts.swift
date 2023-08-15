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
}

struct Alerts {
    // Errors
    static func showError(title: String, text: String, controller: UIViewController, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: title,
                                      message: text,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in completion()
        }))
        
        controller.present(alert, animated: true)
    }
    
    static func showGenericError(controller: UIViewController) {
        let alert = UIAlertController(title: Text.errorTitle.rawValue.localized(),
                                      message: Text.errorMessage.rawValue.localized(),
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        controller.present(alert, animated: true, completion: nil)
    }
    
    // Folders
    static func showInputDialog(title:String? = nil,
                                subtitle:String? = nil,
                                controller: UIViewController,
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
        
        controller.present(alert, animated: true, completion: nil)
    }
    
    // Edition
    static func showConfirmationDelete(controller: UIViewController, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: Text.deleteConfirmationTitle.rawValue.localized(), message: nil, preferredStyle: .alert)
        
        alert.modalPresentationStyle = .popover
        
        alert.addAction(UIAlertAction(title: Text.cancel.localized(), style: .destructive, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion()
        }))
        
        controller.present(alert, animated: true, completion: nil)
    }
    
    // Premium
    static func showBePremiumToUse(controller: UIViewController, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: Text.premiumToolTitle.rawValue.localized(),
                                      message: Text.premiumToolMessage.rawValue.localized(),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Text.cancel.localized(), style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: Text.see.localized(), style: .default, handler: { _ in
            completion()
        }))
        controller.present(alert, animated: true, completion: nil)
    }
    
    // First use
    static func showSetProtectionAsk(controller: UIViewController, completion: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: Text.wouldLikeSetProtection.localized(), message: nil, preferredStyle: .alert)
        
        alert.modalPresentationStyle = .popover
        
        alert.addAction(UIAlertAction(title: Text.cancel.localized(), style: .default, handler: { _ in
            completion(false)
        }))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion(true)
        }))
        
        controller.present(alert, animated: true, completion: nil)
    }
    
    // Backup
    static func askUserToRestoreBackup(on viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: "Recuperar Backup",
                                      message: "Você gostaria de recuperar seu último backup?",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Não", style: .default) { _ in
            completion(false)
        })
        
        alert.addAction(UIAlertAction(title: "Sim", style: .default) { _ in
            completion(true)
        })
        
        viewController.present(alert, animated: true)
    }
    
    static func showBackupSuccess(controller: UIViewController) {
        let alert = UIAlertController(title: "Backup realizado",
                                      message: "Seu backup foi recuperado com sucesso",
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        controller.present(alert, animated: true, completion: nil)
    }
    
    static func showBackupError(controller: UIViewController) {
        let alert = UIAlertController(title: "Falha ao realizar backup",
                                      message: "Não foram encontrados dados no seu backup",
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        controller.present(alert, animated: true, completion: nil)
    }
    
    static func showPasswordError(controller: UIViewController) {
        let alert = UIAlertController(title: "Senha incorreta",
                                      message: "A senha fornecida não é compativel, tente novamente",
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        controller.present(alert, animated: true, completion: nil)
    }
    
    static func insertPassword(controller: UIViewController, completion: @escaping (String?) -> Void) {
        let alertController = UIAlertController(title: "Insira sua senha", message: "Insira a senha que era utilizada para abrir a calculadora", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Digite a senha numérica"
        }
        
        let addAction = UIAlertAction(title: "Confirmar", style: .default) { _ in
            if let password = alertController.textFields?.first?.text {
                completion(password)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel) { _ in
            completion(nil)
        }
        
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        
        controller.present(alertController, animated: true)
    }

}
