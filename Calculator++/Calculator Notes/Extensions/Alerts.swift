import Foundation
import UIKit

struct Alerts {
    
    private static func createAlert(title: String, message: String?, actions: [UIAlertAction]) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for action in actions {
            alert.addAction(action)
        }
        return alert
    }
    
    private static func createAction(title: String?, style: UIAlertAction.Style = .default, handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction(title: title, style: style, handler: handler)
    }
    
    private static func presentAlert(_ alert: UIAlertController, on controller: UIViewController) {
        DispatchQueue.main.async {
            controller.present(alert, animated: true)
        }
    }
    
    // Errors
    static func showError(title: String, text: String, controller: UIViewController, completion: @escaping () -> Void) {
        let alert = createAlert(title: title, message: text, actions: [createAction(title: "OK", handler: { _ in completion() })])
        presentAlert(alert, on: controller)
    }
    
    static func showGenericError(controller: UIViewController) {
        let alert = createAlert(title: Text.errorTitle.localized(), message: Text.errorMessage.localized(), actions: [createAction(title: "OK")])
        presentAlert(alert, on: controller)
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
        
        let alert = UIAlertController(title: title ?? "", message: subtitle, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: cancelTitle, style: .default, handler: cancelHandler)
        alert.addAction(cancelAction)
        
        alert.addTextField { textField in
            textField.placeholder = inputPlaceholder
            textField.keyboardType = inputKeyboardType
        }
        
        let action = UIAlertAction(title: actionTitle, style: .default) { _ in
            actionHandler?(alert.textFields?.first?.text)
        }
        
        alert.addAction(action)
        
        controller.present(alert, animated: true)
    }
    
    // Edition
    static func showConfirmationDelete(controller: UIViewController, completion: @escaping () -> Void) {
        let alert = createAlert(title: Text.deleteConfirmationTitle.localized(), message: nil, actions: [createAction(title: "OK", handler: { _ in completion() })])
        presentAlert(alert, on: controller)
    }
    
    // Premium
    static func showBePremiumToUse(controller: UIViewController, completion: @escaping () -> Void) {
        let alert = createAlert(title: Text.premiumToolTitle.localized(), message: Text.premiumToolMessage.localized(), actions: [createAction(title: "OK", handler: { _ in completion() })])
        presentAlert(alert, on: controller)
    }
    
    // First use
    static func showSetProtectionAsk(controller: UIViewController, completion: @escaping (Bool) -> Void) {
        let alert = createAlert(title: Text.wouldLikeSetProtection.localized(), message: nil, actions: [createAction(title: "Cancelar", handler: { _ in completion(false) }), createAction(title: "OK", handler: { _ in completion(true) })])
        presentAlert(alert, on: controller)
    }
    
    // Backup
    static func askUserToRestoreBackup(on viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        let alert = createAlert(title: Text.askToRestoreBackupTitle.localized(), message: Text.askToRestoreBackupMessage.localized(), actions: [createAction(title: "Não", handler: { _ in completion(false) }), createAction(title: "Sim", handler: { _ in completion(true) })])
        presentAlert(alert, on: viewController)
    }
    
    static func showBackupSuccess(controller: UIViewController) {
        let alert = createAlert(title: Text.backupSuccessTitle.localized(), message: Text.backupSuccessMessage.localized(), actions: [createAction(title: "OK")])
        presentAlert(alert, on: controller)
    }
    
    static func showBackupError(controller: UIViewController) {
        let alert = createAlert(title: Text.backupErrorTitle.localized(), message: Text.backupErrorMessage.localized(), actions: [createAction(title: "OK")])
        presentAlert(alert, on: controller)
    }
    
    static func showPasswordError(controller: UIViewController) {
        let alert = createAlert(title: Text.incorrectPasswordTitle.localized(), message: Text.incorrectPasswordMessage.localized(), actions: [createAction(title: "OK")])
        presentAlert(alert, on: controller)
    }
    
    static func insertPassword(controller: UIViewController, completion: @escaping (String?) -> Void) {
        var alert: UIAlertController!
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .default) { _ in
            completion(nil)
        }
        
        alert = UIAlertController(title: Text.insertPasswordTitle.localized(),
                                  message: Text.insertPasswordMessage.localized(),
                                  preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Confirmar", style: .default) { _ in
            completion(alert.textFields?.first?.text)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        
        alert.addTextField { textField in
            textField.placeholder = Text.inputPlaceholder.localized()
            textField.keyboardType = .numberPad
        }
        presentAlert(alert, on: controller)
    }
    
    static func showBePremiumToUseBackup(controller: UIViewController, completion: ((UIAlertAction) -> Void)?) {
        let alert = createAlert(title: Text.premiumToolTitle.localized(), message: "O suporte para backup é um recurso premium. Apresentaremos os detalhes do produto", actions: [createAction(title: "OK", handler: completion)])
        presentAlert(alert, on: controller)
    }
    
    static func showGoToSettingsToEnbaleCloud(controller: UIViewController, completion: ((UIAlertAction) -> Void)?) {
        let alert = createAlert(title: "Ação Requerida", message: "\n1. Clique em iCloud\n\n2.Procure o app Calc+ na lista\n\n3. Habilite o iCloud", actions: [createAction(title: "Ir para configurações", handler: completion)])
        presentAlert(alert, on: controller)
    }
}
