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
    @IBOutlet weak var changeIcon: UIView!
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
    @objc func changeIconPressed(_ sender: UITapGestureRecognizer? = nil) {
        let vc = ChangeIconViewController()
        vc.modalPresentationStyle = .overCurrentContext
        if let tabBarController = self.tabBarController {
            tabBarController.present(vc, animated: false, completion: nil)
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
        let changeIconPressed = UITapGestureRecognizer(target: self, action: #selector(changeIconPressed(_:)))
        changeIcon.addGestureRecognizer(changeIconPressed)
    }
    
    private func setupViewStyles() {
        upgradeButton.layer.cornerRadius = 8
        noProtection.layer.cornerRadius = 8
        vaultMode.layer.cornerRadius = 8
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
