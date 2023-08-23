//
//  SettingsViewController.swift
//  Calculator Notes
//
//  Created by Joao Flores on 25/06/20.
//  Copyright © 2020 MakeSchool. All rights reserved.
//

import UIKit
import StoreKit

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
        Key.recoveryStatus.setBoolean(sender.isOn)
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

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setup()
        setupViewStyle()
        switchButton.isOn = Key.recoveryStatus.getBoolean()
        setupTexts()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        rateApp.addGestureRecognizer(tap)
        let restoreBackupPressed = UITapGestureRecognizer(target: self, action: #selector(self.restoreBackupPressed(_:)))
        restoreBackup.addGestureRecognizer(restoreBackupPressed)
    }

    override func viewWillAppear(_ animated: Bool) {
        let typeProtection = UserDefaultService().getTypeProtection()
        showProtectionType(typeProtection: typeProtection)
        backupStatus.text = "Ativado"
        
        CloudKitImageService.isICloudEnabled { isActive in
            print("---- isActive:", isActive)
        }
        if let settingsURL = URL(string: UIApplicationOpenSettingsURLString) {
             UIApplication.shared.open(settingsURL)
         }
    }

    // MARK: - Private Methods
    private func showProtectionType(typeProtection: ProtectionMode) {
        switch typeProtection {
        case .calculator:
            bankModeImage.setImage(.diselectedIndicator)
            calcModeImage.setImage(.selectedIndicator)
            noProtectionImage.setImage(.diselectedIndicator)

        case .noProtection:
            bankModeImage.setImage(.diselectedIndicator)
            calcModeImage.setImage(.diselectedIndicator)
            noProtectionImage.setImage(.selectedIndicator)

        case .bank:
            bankModeImage.setImage(.selectedIndicator)
            calcModeImage.setImage(.diselectedIndicator)
            noProtectionImage.setImage(.diselectedIndicator)
        }
    }

    // MARK: - UI
    private func setupTexts() {
        self.setText(.settings)
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
    var loadingAlert = LoadingAlert()

    @objc func restoreBackupPressed(_ sender: UITapGestureRecognizer? = nil) {
        let vc = CustomModalViewController {
            
        } deactiveBackupTappedHandler: {
            
        } restoreBackupTapped: {
            self.fetchCloudKitPassword()
        }

        vc.modalPresentationStyle = .overCurrentContext
        if let tabBarController = self.tabBarController {
            tabBarController.present(vc, animated: false, completion: nil)
        }
    }

    private func fetchCloudKitPassword() {
        loadingAlert.startLoading(in: self)
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
                self.startLoadingForBackupCheck()
            } else {
                Alerts.showPasswordError(controller: self)
            }
        }
    }

    private func startLoadingForBackupCheck() {
        loadingAlert.startLoading(in: self)
        checkBackupData()
    }

    private func checkBackupData() {
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
        loadingAlert.startLoading(in: self)
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
}
