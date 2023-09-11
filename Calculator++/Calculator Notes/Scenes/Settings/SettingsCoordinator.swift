//
//  SettingsCoordinator.swift
//  Pods
//
//  Created by Joao Victor Flores da Costa on 09/09/23.
//

import UIKit
import Foundation

class SettingsCoordinator {
    weak var viewController: UIViewController?
    weak var tabBarController: UITabBarController? // Adicione essa linha se o tabBarController não for acessível de outra forma
    
    init(viewController: UIViewController) {
        self.viewController = viewController
        self.tabBarController = viewController.tabBarController // Adicione essa linha se necessário
    }
    
    func showBankMode() {
        let vaultViewController = VaultViewController(mode: .create)
        vaultViewController.modalPresentationStyle = .fullScreen
        viewController?.present(vaultViewController, animated: true)
    }
    
    func showCalculatorMode() {
        viewController?.present(VaultViewController(mode: .create), animated: true)
    }
    
    func premiumVersionPressed() {
        let storyboard = UIStoryboard(name: "Purchase", bundle: nil)
        let changePasswordCalcMode = storyboard.instantiateViewController(withIdentifier: "Purchase")
        viewController?.present(changePasswordCalcMode, animated: true)
    }
    
    func showBackupOptions(backupIsActivated: Bool, delegate: BackupModalViewControllerDelegate) {
        let vc = BackupModalViewController(
            backupIsActivated: backupIsActivated,
            delegate: delegate
        )
        vc.modalPresentationStyle = .overCurrentContext
        if let tabBarController = self.tabBarController {
            tabBarController.present(vc, animated: false, completion: nil)
        }
    }
}

struct FeatureFlags {
    static let iCloudEnabled  = false
}
