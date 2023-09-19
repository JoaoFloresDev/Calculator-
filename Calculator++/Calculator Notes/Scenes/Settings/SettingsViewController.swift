//
//  SettingsViewController.swift
//  Calculator Notes
//
//  Created by Joao Flores on 25/06/20.
//  Copyright © 2020 MakeSchool. All rights reserved.
//

import UIKit
import StoreKit
import Network
import UIKit
import Photos
import AssetsPickerViewController
import DTPhotoViewerController
import CoreData
import NYTPhotoViewer
import ImageViewer
import StoreKit
import GoogleMobileAds
import SceneKit
import simd
import Photos
import StoreKit
import Foundation
import AVFoundation
import AVKit
import CloudKit

class SettingsViewController: UIViewController, UINavigationControllerDelegate {

    // MARK: - IBOutlet
    @IBOutlet weak var switchButton: UISwitch!
    @IBOutlet weak var recoverLabel: UILabel!
    @IBOutlet weak var chooseProtectionLabel: UILabel!
    @IBOutlet weak var noProtectionImage: UIImageView!
    @IBOutlet weak var noProtection: UIButton!
    @IBOutlet weak var ModeGroupView: UIView!
    @IBOutlet weak var upgradeButton: UIButton!
    @IBOutlet weak var customTabBar: UITabBarItem!
    @IBOutlet weak var rateApp: UIView!
    @IBOutlet weak var restoreBackup: UIView!
    @IBOutlet weak var backupStatus: UILabel!
    @IBOutlet weak var vaultMode: UIButton!
    @IBOutlet weak var vaultModeImage: UIImageView!
    @IBOutlet weak var faceIDView: UIView!
    
    // MARK: - IBAction
    @IBAction func switchButtonAction(_ sender: UISwitch) {
        Defaults.setBool(.recoveryStatus, sender.isOn)
    }

    @IBAction func noProtectionPressed(_ sender: Any) {
        UserDefaultService().setTypeProtection(protectionMode: .noProtection)
        showProtectionType(typeProtection: .noProtection)
    }

    @IBAction func showBankMode(_ sender: Any) {
        coordinator.showBankMode()
    }

    @IBAction func premiumVersionPressed(_ sender: Any) {
        coordinator.premiumVersionPressed()
    }

    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        DispatchQueue.main.async {
            SKStoreReviewController.requestReview()
        }
    }

    lazy var loadingAlert = LoadingAlert(in: self)
    
    var backupIsActivated = false {
        didSet {
            DispatchQueue.main.async {
                self.backupStatus.text = self.backupIsActivated ? Text.backupEnabled.localized() : Text.backupDisabled.localized()
            }
        }
    }
    
    lazy var coordinator = SettingsCoordinator(viewController: self)
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let typeProtection = UserDefaultService().getTypeProtection()
        showProtectionType(typeProtection: typeProtection)
        
        guard FeatureFlags.iCloudEnabled else {
            restoreBackup.isHidden =  true
            return
        }
        
        CloudKitImageService.isICloudEnabled { isEnabled in
            self.backupIsActivated = isEnabled
        }
    }
    
    // MARK: - UI
    private func setupTexts() {
        self.title = Text.settings.localized()
        noProtection.setText(.noProtection)
        vaultMode.setText(.vaultMode)
        upgradeButton.setText(.premiumVersion)
        recoverLabel.setText(.hideRecoverButton)
        chooseProtectionLabel.setText(.chooseProtectionMode)
    }

    private func setupViewStyle() {
        DispatchQueue.main.async {
            self.upgradeButton.layer.cornerRadius = 8
            self.upgradeButton.clipsToBounds = true

            self.ModeGroupView.layer.cornerRadius = 16
            self.ModeGroupView.layer.shadowOffset = CGSize(width: 0, height: 0)
            self.ModeGroupView.layer.shadowRadius = 4
            self.ModeGroupView.layer.shadowOpacity = 0.3
            self.ModeGroupView.clipsToBounds = true

            self.noProtection.layer.cornerRadius = 8
            self.noProtection.clipsToBounds = true

            self.vaultMode.layer.cornerRadius = 8
            self.vaultMode.clipsToBounds = true
        }
    }

    
    // MARK: - Backup
    @objc func restoreBackupPressed(_ sender: UITapGestureRecognizer? = nil) {
        coordinator.showBackupOptions(backupIsActivated: self.backupIsActivated, delegate: self)
    }

    private func fetchCloudKitPassword() {
        loadingAlert.startLoading()
        CloudKitPasswordService.fetchAllPasswords { password, error in
            self.loadingAlert.stopLoading {
                if let password = password {
                    self.insertPasswordAndCheckBackup(password: password)
                } else {
                    Alerts.showPasswordError(controller: self)
                }
            }
        }
    }

    private func insertPasswordAndCheckBackup(password: [String]) {
        Alerts.insertPassword(controller: self) { insertedPassword in
            guard let insertedPassword = insertedPassword else {
                return
            }
            if password.contains(insertedPassword) || insertedPassword == Constants.recoverPassword {
                self.checkBackupData()
            } else {
                Alerts.showPasswordError(controller: self)
            }
        }
    }

    private func checkBackupData() {
        loadingAlert.startLoading()
        BackupService.hasDataInCloudKit { hasData, _, items  in
            self.loadingAlert.stopLoading {
                if let items = items, !items.isEmpty, hasData {
                    self.askUserToRestoreBackup(backupItems: items)
                } else {
                    Alerts.showBackupError(controller: self)
                }
            }
        }
    }

    private func askUserToRestoreBackup(backupItems: [MediaItem]) {
        Alerts.askUserToRestoreBackup(on: self) { restoreBackup in
            if restoreBackup {
                self.startLoadingForBackupRestore(backupItems: backupItems)
            }
        }
    }

    private func startLoadingForBackupRestore(backupItems: [MediaItem]) {
        loadingAlert.startLoading()
        restoreBackup(backupItems: backupItems)
    }

    private func restoreBackup(backupItems: [MediaItem]) {
        BackupService.restoreBackup(items: backupItems) { success, _ in
            self.loadingAlert.stopLoading {
                if success {
                    Alerts.showBackupSuccess(controller: self)
                    let controllers = self.tabBarController?.viewControllers
                    let navigation = controllers?[0] as? UINavigationController
                    let collectionViewController = navigation?.viewControllers.first as? CollectionViewController
                    collectionViewController?.viewDidLoad()
                } else {
                    Alerts.showBackupError(controller: self)
                }
            }
        }
    }
    
    private func setupUI() {
        self.navigationController?.setup()
        switchButton.isOn = Defaults.getBool(.recoveryStatus)
        setupTexts()
        setupViewStyles()
    }
    
    private func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        rateApp.addGestureRecognizer(tap)
        
        let restoreBackupPressed = UITapGestureRecognizer(target: self, action: #selector(restoreBackupPressed(_:)))
        restoreBackup.addGestureRecognizer(restoreBackupPressed)
    }
    
    private func setupViewStyles() {
        upgradeButton.layer.cornerRadius = 8
        noProtection.layer.cornerRadius = 8
        addShadow(to: ModeGroupView, offset: CGSize(width: 0, height: 0), radius: 4, opacity: 0.3)
    }
    
    private func addShadow(to view: UIView, offset: CGSize, radius: CGFloat, opacity: Float) {
        view.layer.shadowOffset = offset
        view.layer.shadowRadius = radius
        view.layer.shadowOpacity = opacity
    }
    
    private func showProtectionType(typeProtection: ProtectionMode) {
        noProtectionImage.setImage(typeProtection == .noProtection ? .selectedIndicator : .diselectedIndicator)
        vaultModeImage.setImage(typeProtection == .vault ? .selectedIndicator : .diselectedIndicator)
    }
}

extension  SettingsViewController: BackupModalViewControllerDelegate {
    func restoreBackupTapped() {
        self.fetchCloudKitPassword()
    }
    
    func enableBackupToggled(status: Bool) {
        backupIsActivated = status
    }
}
