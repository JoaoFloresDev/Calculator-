import Foundation
import UIKit

extension UIViewController {
    func setText(_ text: Text) {
        self.title = text.localized()
    }
}

struct Alerts {
    // Errors
    static func showError(title: String, text: String, controller: UIViewController, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: title,
                                      message: text,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in completion() }))
        
        controller.present(alert, animated: true)
    }
    
    static func showGenericError(controller: UIViewController) {
        showAlertWithTitle(Text.errorTitle.localized(),
                           message: Text.errorMessage.localized(),
                           controller: controller)
    }
    
    // Folders
    static func showInputDialog(title: String? = nil,
                                subtitle: String? = nil,
                                controller: UIViewController,
                                actionTitle: String?,
                                cancelTitle: String?,
                                inputPlaceholder: String? = nil,
                                inputKeyboardType: UIKeyboardType = .default,
                                cancelHandler: ((UIAlertAction) -> Void)? = nil,
                                actionHandler: ((_ text: String?) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = inputPlaceholder
            textField.keyboardType = inputKeyboardType
        }
        
        alert.addAction(UIAlertAction(title: cancelTitle, style: .default, handler: cancelHandler))
        alert.addAction(UIAlertAction(title: actionTitle, style: .default) { _ in
            actionHandler?(alert.textFields?.first?.text)
        })
        
        controller.present(alert, animated: true)
    }
    
    // Edition
    static func showConfirmationDelete(controller: UIViewController, completion: @escaping () -> Void) {
        showAlertWithTitle(Text.deleteConfirmationTitle.localized(),
                           controller: controller,
                           confirmAction: { _ in completion() })
    }
    
    // Premium
    static func showBePremiumToUse(controller: UIViewController, completion: @escaping () -> Void) {
        showAlertWithTitle(Text.premiumToolTitle.localized(),
                           message: Text.premiumToolMessage.localized(),
                           controller: controller,
                           confirmAction: { _ in completion() })
    }
    
    // First use
    static func showSetProtectionAsk(controller: UIViewController, completion: @escaping (Bool) -> Void) {
        showAlertWithTitle(Text.wouldLikeSetProtection.localized(),
                           controller: controller,
                           cancelTitle: Text.cancel.localized(),
                           confirmAction: { _ in completion(true) },
                           cancelAction: { _ in completion(false) })
    }
    
    // Backup
    static func askUserToRestoreBackup(on viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        showAlertWithTitle("Recuperar Backup",
                           message: "Você gostaria de recuperar seu último backup?",
                           controller: viewController,
                           confirmTitle: "Sim",
                           cancelTitle: "Não",
                           confirmAction: { _ in completion(true) },
                           cancelAction: { _ in completion(false) })
    }
    
    static func showBackupSuccess(controller: UIViewController) {
        showAlertWithTitle("Backup realizado",
                           message: "Seu backup foi recuperado com sucesso",
                           controller: controller)
    }
    
    static func showBackupError(controller: UIViewController) {
        showAlertWithTitle("Falha ao realizar backup",
                           message: "Não foram encontrados dados para backup",
                           controller: controller)
    }
    
    static func showPasswordError(controller: UIViewController) {
        showAlertWithTitle("Senha incorreta",
                           message: "A senha fornecida não é compativel, tente novamente",
                           controller: controller)
    }
    
    static func insertPassword(controller: UIViewController, completion: @escaping (String?) -> Void) {
        let alertController = UIAlertController(title: "Insira sua senha", message: "Insira a senha que era utilizada para abrir a calculadora", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Digite a senha da calculadora"
            textField.keyboardType = .numberPad
        }
        
        let addAction = UIAlertAction(title: "Confirmar", style: .default) { _ in
            completion(alertController.textFields?.first?.text)
        }
        
        let cancelAction = UIAlertAction(title: Text.cancel.localized(), style: .default) { _ in
            completion(nil)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        
        controller.present(alertController, animated: true)
    }
    
    // Helper function to show a basic alert
    private static func showAlertWithTitle(_ title: String,
                                           message: String? = nil,
                                           controller: UIViewController,
                                           confirmTitle: String = "OK",
                                           cancelTitle: String? = nil,
                                           confirmAction: ((UIAlertAction) -> Void)? = nil,
                                           cancelAction: ((UIAlertAction) -> Void)? = nil) {
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        if let cancelTitle = cancelTitle {
            alert.addAction(UIAlertAction(title: cancelTitle, style: .default, handler: cancelAction))
        }
        alert.addAction(UIAlertAction(title: confirmTitle, style: .default, handler: confirmAction))
        controller.present(alert, animated: true)
    }
}
