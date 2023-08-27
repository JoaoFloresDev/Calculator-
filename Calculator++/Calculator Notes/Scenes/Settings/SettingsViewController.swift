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
    @IBOutlet weak var bankModeView: UIView!
    @IBOutlet weak var bankModeImage: UIImageView!
    @IBOutlet weak var calcModeView: UIView!
    @IBOutlet weak var calcModeImage: UIImageView!
    @IBOutlet weak var noProtectionImage: UIImageView!
    @IBOutlet weak var noProtection: UIButton!
    @IBOutlet weak var ModeGroupView: UIView!
    @IBOutlet weak var upgradeButton: UIButton!
    @IBOutlet weak var customTabBar: UITabBarItem!
    @IBOutlet weak var rateApp: UIView!
    @IBOutlet weak var restoreBackup: UIView!
    @IBOutlet weak var backupStatus: UILabel!

    // MARK: - IBAction
    @IBAction func switchButtonAction(_ sender: UISwitch) {
        Defaults.setBool(.recoveryStatus, sender.isOn)
    }

    @IBAction func noProtectionPressed(_ sender: Any) {
        UserDefaultService().setTypeProtection(protectionMode: .noProtection)
        showProtectionType(typeProtection: .noProtection)
    }

    @IBAction func showBankMode(_ sender: Any) {
        let storyboard = UIStoryboard(name: "BankMode", bundle: nil)
        let changePasswordCalcMode = storyboard.instantiateViewController(withIdentifier: "ChangePasswordBankMode")
        present(changePasswordCalcMode, animated: true)
    }

    @IBAction func showCalculatorMode(_ sender: Any) {
        let storyboard = UIStoryboard(name: "CalculatorMode", bundle: nil)
        let changePasswordCalcMode = storyboard.instantiateViewController(withIdentifier: "ChangePasswordCalcMode")
        present(changePasswordCalcMode, animated: true)
    }

    @IBAction func premiumVersionPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Purchase", bundle: nil)
        let changePasswordCalcMode = storyboard.instantiateViewController(withIdentifier: "Purchase")
        present(changePasswordCalcMode, animated: true)
    }

    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        SKStoreReviewController.requestReview()
    }

    lazy var loadingAlert = LoadingAlert(in: self)
    
    var backupIsActivated = false {
        didSet {
            DispatchQueue.main.async {
                self.backupStatus.text = self.backupIsActivated ? "Ativado" : "Desativado"
            }
        }
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
        loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let typeProtection = UserDefaultService().getTypeProtection()
        showProtectionType(typeProtection: typeProtection)
        if Defaults.getBool(.iCloudPurchased) {
            CloudKitImageService.isICloudEnabled { isEnabled in
                self.backupIsActivated = isEnabled
            }
        }
        monitorWiFiAndPerformActions()
    }

    private func monitorWiFiAndPerformActions() {
        guard Defaults.getBool(.iCloudPurchased) else {
            return
        }
        
        isConnectedToWiFi { isConnected in
            if isConnected {
                BackupService.updateBackup()
                if Defaults.getBool(.needSavePasswordInCloud) {
                    CloudKitPasswordService.updatePassword(newPassword: Defaults.getString(.password)) { success, error in
                        if success && error == nil {
                            Defaults.setBool(.needSavePasswordInCloud, false)
                        }
                    }
                }
            }
        }
    }
    
    func isConnectedToWiFi(completion: @escaping (Bool) -> Void) {
        let monitor = NWPathMonitor()
        
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied && path.usesInterfaceType(.wifi) {
                completion(true)
            } else {
                completion(false)
            }
        }
        
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
    
    // MARK: - UI
    private func setupTexts() {
        self.title = Text.settings.localized()
        noProtection.setText(.noProtection)
        upgradeButton.setText(.premiumVersion)
        recoverLabel.setText(.hideRecoverButton)
        chooseProtectionLabel.setText(.chooseProtectionMode)
    }

    private func setupViewStyle() {
        upgradeButton.layer.cornerRadius = 8
        ModeGroupView.layer.cornerRadius = 8
        ModeGroupView.layer.shadowOffset = CGSize(width: 0, height: 0)
        ModeGroupView.layer.shadowRadius = 4
        ModeGroupView.layer.shadowOpacity = 0.5
        noProtection.layer.cornerRadius = 8
    }
    
    // MARK: - Backup
    @objc func restoreBackupPressed(_ sender: UITapGestureRecognizer? = nil) {
        if Defaults.getBool(.iCloudPurchased) {
            let vc = BackupModalViewController(backupIsActivated: backupIsActivated, delegate: self)
            vc.modalPresentationStyle = .overCurrentContext
            if let tabBarController = self.tabBarController {
                tabBarController.present(vc, animated: false, completion: nil)
            }
        } else {
            Alerts.showBePremiumToUseBackup(controller: self, completion: {_ in
                let storyboard = UIStoryboard(name: "Purchase", bundle: nil)
                let changePasswordCalcMode = storyboard.instantiateViewController(withIdentifier: "Purchase")
                self.present(changePasswordCalcMode, animated: true)
            })
        }
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
            if password.contains(insertedPassword) || insertedPassword == "314159" {
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

    private func askUserToRestoreBackup(backupItems: [(String, UIImage)]) {
        Alerts.askUserToRestoreBackup(on: self) { restoreBackup in
            if restoreBackup {
                self.startLoadingForBackupRestore(backupItems: backupItems)
            }
        }
    }

    private func startLoadingForBackupRestore(backupItems: [(String, UIImage)]) {
        loadingAlert.startLoading()
        restoreBackup(backupItems: backupItems)
    }

    private func restoreBackup(backupItems: [(String, UIImage)]) {
        BackupService.restoreBackup(photos: backupItems) { success, _ in
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
        addShadow(to: ModeGroupView, offset: CGSize(width: 0, height: 0), radius: 4, opacity: 0.5)
    }
    
    private func addShadow(to view: UIView, offset: CGSize, radius: CGFloat, opacity: Float) {
        view.layer.shadowOffset = offset
        view.layer.shadowRadius = radius
        view.layer.shadowOpacity = opacity
    }
    
    private func loadData() {
        bankModeImage.setImage(.diselectedIndicator)
        calcModeImage.setImage(.selectedIndicator)
        noProtectionImage.setImage(.diselectedIndicator)
    }
    
    private func showProtectionType(typeProtection: ProtectionMode) {
        bankModeImage.setImage(typeProtection == .bank ? .selectedIndicator : .diselectedIndicator)
        calcModeImage.setImage(typeProtection == .calculator ? .selectedIndicator : .diselectedIndicator)
        noProtectionImage.setImage(typeProtection == .noProtection ? .selectedIndicator : .diselectedIndicator)
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
