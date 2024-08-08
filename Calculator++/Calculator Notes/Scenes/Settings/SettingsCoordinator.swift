//
//  SettingsCoordinator.swift
//  Pods
//
//  Created by Joao Victor Flores da Costa on 09/09/23.
//

import UIKit
import Foundation

class SettingsCoordinator {
    weak var viewController: SettingsViewController?
    weak var tabBarController: UITabBarController?
    
    init(viewController: SettingsViewController) {
        self.viewController = viewController
        self.tabBarController = viewController.tabBarController
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
        if let changePasswordCalcMode = changePasswordCalcMode as? PurchaseViewController {
            changePasswordCalcMode.delegate = viewController
        }
        viewController?.present(changePasswordCalcMode, animated: true)
    }
    
    func showBackupOptions(backupIsActivated: Bool, delegate: BackupModalViewControllerDelegate) {
        let controllers = self.tabBarController?.viewControllers
        
        let navigation = controllers?[0] as? UINavigationController
        let collectionViewController = navigation?.viewControllers.first as? CollectionViewController
        
        let navigation1 = controllers?[1] as? UINavigationController
        let videosRootController = navigation1?.viewControllers.first as? VideoCollectionViewController
        
        let vc = BackupModalViewController(
            delegate: delegate,
            imagesRootController: collectionViewController,
            videosRootController: videosRootController
        )
        vc.modalPresentationStyle = .overCurrentContext
        if let tabBarController = self.tabBarController {
            tabBarController.present(vc, animated: false, completion: nil)
        }
    }
}
