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
import FirebaseAuth

extension SettingsViewController: ChangeNewCalcViewController2Delegate {
    func fakePassChanged() {
        Alerts.showSuccesFakePass(controller: self)
    }
    
    func changed() {
        Alerts.showSuccesChangePass(controller: self)
    }
}
extension SettingsViewController: PurchaseViewControllerDelegate {
    func purchased() {
        backupIsActivated = isUserLoggedIn() && isPremium()
    }
}

class SettingsViewController: UIViewController, UINavigationControllerDelegate {

    // MARK: - IBOutlet
    @IBOutlet weak var stackview: UIStackView!
    @IBOutlet weak var switchButton: UISwitch!
    @IBOutlet weak var recoverLabel: UILabel!
    @IBOutlet weak var upgradeButton: UIButton!
    @IBOutlet weak var customTabBar: UITabBarItem!
    @IBOutlet weak var faceIDView: UIView!
    
    @IBOutlet weak var browser: UIView!
    @IBOutlet weak var browserLabel: UILabel!
    
    @IBOutlet weak var backupOptions: UIView!
    @IBOutlet weak var backupStatus: UILabel!
    @IBOutlet weak var backupLabel: UILabel!
    
    @IBOutlet weak var changePassword: UIView!
    @IBOutlet weak var changePassworldLabel: UILabel!
    
    @IBOutlet weak var fakepasswordLabel: UILabel!
    @IBOutlet weak var fakePassword: UIView!
    
    @IBOutlet weak var shareWithOtherCalc: UIView!
    @IBOutlet weak var shareWithOtherCalcLabel: UILabel!
    
    @IBOutlet weak var sugestionsView: UIView!
    @IBOutlet weak var sugestionsLabel: UILabel!
    
    // MARK: - IBAction
    @IBAction func switchButtonAction(_ sender: UISwitch) {
        Defaults.setBool(.recoveryStatus, !sender.isOn)
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
    
    var backupIsActivated = false {
        didSet {
            DispatchQueue.main.async {
                self.backupStatus.text = self.backupIsActivated ? Text.backupEnabled.localized() : Text.backupDisabled.localized()
            }
        }
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
        backupIsActivated = isUserLoggedIn() && isPremium()
    }
    
    // MARK: - UI
    private func setupTexts() {
        self.title = Text.settings.localized()
        upgradeButton.setText(.premiumVersion)
        backupLabel.setText(.backupStatus)
        browserLabel.setText(.browser)
    }
    
    lazy var contentStackView = IconContentView()
    
    // MARK: - Actions
    @objc
    func privacyPolicePressed(_ sender: UITapGestureRecognizer? = nil) {
        let navigation = UINavigationController(rootViewController: ScrollableTextViewController())
        self.present(navigation, animated: true)
    }
    
    @objc
    func browserPressed(_ sender: UITapGestureRecognizer? = nil) {
        let controller = SafariWrapperViewController()
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true)
    }
    
    @objc
    func changePasswordPressed(_ sender: UITapGestureRecognizer? = nil) {
        let vaultViewController = viewControllerFor(storyboard: "NewCalc2", withIdentifier: "NewCalcChange")
        vaultViewController.modalPresentationStyle = .fullScreen
        
        guard let controller = vaultViewController as? ChangeNewCalcViewController2 else {
            return
        }
        controller.vaultMode = .create
        controller.faceIDButton.isHidden = true
        controller.delegate = self
        self.present(controller, animated: true)
    }
    
    private func viewControllerFor(storyboard storyboardName: String, withIdentifier viewControllerID: String) -> UIViewController {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: viewControllerID)
    }
    
    @objc
    func shareWithOtherCalcPressed(_ sender: UITapGestureRecognizer? = nil) {
        let controller = SharedFolderSettings()
        let navigationController = UINavigationController(rootViewController: controller)
        self.present(navigationController, animated: true)
    }
    
    @objc
    func fakePasswordPressed(_ sender: UITapGestureRecognizer? = nil) {
        let vaultViewController = viewControllerFor(storyboard: "NewCalc2", withIdentifier: "NewCalcChange")
        vaultViewController.modalPresentationStyle = .fullScreen
        
        guard let controller = vaultViewController as? ChangeNewCalcViewController2 else {
            return
        }
        controller.vaultMode = .createFakePass
        controller.faceIDButton.isHidden = true
        controller.delegate = self
        self.present(controller, animated: true)
    }
    
    @objc
    func backupPressed(_ sender: UITapGestureRecognizer? = nil) {
        if RazeFaceProducts.store.isProductPurchased("Calc.noads.mensal") ||
            RazeFaceProducts.store.isProductPurchased("calcanual") ||
            RazeFaceProducts.store.isProductPurchased("NoAds.Calc") {
            coordinator.showBackupOptions(backupIsActivated: self.backupIsActivated, delegate: self)
        } else {
            Alerts.showBePremiumToUseBackup(controller: self) { action in
                let storyboard = UIStoryboard(name: "Purchase",bundle: nil)
                let changePasswordCalcMode = storyboard.instantiateViewController(withIdentifier: "Purchase")
                if let changePasswordCalcMode = changePasswordCalcMode as? PurchaseViewController {
                    changePasswordCalcMode.delegate = self
                }
                self.present(changePasswordCalcMode, animated: true)
            }
        }
    }
    
    private func setupUI() {
        self.navigationController?.setup()
        switchButton.isOn = !Defaults.getBool(.recoveryStatus)
        setupTexts()
        setupViewStyles()
        setupNewTag()
        
        recoverLabel.text = Text.hideRecoverButton.localized()
        changePassworldLabel.text = Text.changePassword.localized()
        fakepasswordLabel.text = Text.addFakePassword.localized()
        shareWithOtherCalcLabel.text = Text.secretSharing.localized()
        sugestionsLabel.text = Text.improvementSuggestions.localized()
        
        fakePassword.isHidden = FeatureFlags.simpleMode()
        changePassword.isHidden = FeatureFlags.simpleMode()
    }
    
    private func setupNewTag() {
        let newTagLabel = UILabel()
        newTagLabel.text = Text.newTag.localized()
        newTagLabel.textColor = .white
        newTagLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        newTagLabel.textAlignment = .center
        newTagLabel.clipsToBounds = true

        let backgroundView = UIView()
        backgroundView.backgroundColor = .systemBlue
        backgroundView.layer.cornerRadius = 10
        backgroundView.clipsToBounds = true
        
        backgroundView.addSubview(newTagLabel)
        shareWithOtherCalc.addSubview(backgroundView)
        
        // Constraints para a newTagLabel dentro do backgroundView
        newTagLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(6)
        }
        
        // Constraints para o backgroundView em relação ao shareWithOtherCalcLabel
        backgroundView.snp.makeConstraints { make in
            make.leading.equalTo(shareWithOtherCalcLabel.snp.trailing).offset(8)
            make.centerY.equalTo(shareWithOtherCalcLabel)
        }
    }
    
    private func setupGestures() {
        let browserPressed = UITapGestureRecognizer(target: self, action: #selector(browserPressed(_:)))
        browser.addGestureRecognizer(browserPressed)
        
        let backupPressed = UITapGestureRecognizer(target: self, action: #selector(backupPressed(_:)))
        backupOptions.addGestureRecognizer(backupPressed)
        
        let changePasswordPressed = UITapGestureRecognizer(target: self, action: #selector(changePasswordPressed(_:)))
        changePassword.addGestureRecognizer(changePasswordPressed)
        
        let shareWithOtherCalcPressed = UITapGestureRecognizer(target: self, action: #selector(shareWithOtherCalcPressed(_:)))
        shareWithOtherCalc.addGestureRecognizer(shareWithOtherCalcPressed)
        
        let fakePasswordPressed = UITapGestureRecognizer(target: self, action: #selector(fakePasswordPressed(_:)))
        fakePassword.addGestureRecognizer(fakePasswordPressed)
        
        let sugestionsPressed = UITapGestureRecognizer(target: self, action: #selector(sugestionsPressed(_:)))
        sugestionsView.addGestureRecognizer(sugestionsPressed)
    }
    
    @objc func sugestionsPressed(_ sender: UITapGestureRecognizer? = nil) {
        let controller = SuggestionsViewController()
        let navigation = UINavigationController(rootViewController: controller)
        self.present(navigation, animated: true)
    }
    
    private func setupViewStyles() {
        upgradeButton.layer.cornerRadius = 8
        upgradeButton.clipsToBounds = true

        view.addSubview(self.contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.top.equalTo(self.stackview.snp.bottom).offset(12)
        }
    }
    
    private func addShadow(to view: UIView, offset: CGSize, radius: CGFloat, opacity: Float) {
        view.layer.shadowOffset = offset
        view.layer.shadowRadius = radius
        view.layer.shadowOpacity = opacity
    }
}

extension  SettingsViewController: BackupModalViewControllerDelegate {
    func backupExecuted() {
        
    }
    
    func enableBackupToggled(status: Bool) {
        backupIsActivated = status
    }
}
