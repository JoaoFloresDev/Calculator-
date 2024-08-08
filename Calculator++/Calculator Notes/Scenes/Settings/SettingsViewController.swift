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
    @IBOutlet weak var rateApp: UIView!
    @IBOutlet weak var faceIDView: UIView!
    
    @IBOutlet weak var useTerms: UIView!
    @IBOutlet weak var useTermsLabel: UILabel!
    
    @IBOutlet weak var augmentedReality: UIView!
    @IBOutlet weak var augmentedRealityLabel: UILabel!
    
    @IBOutlet weak var browser: UIView!
    @IBOutlet weak var browserLabel: UILabel!
    
    @IBOutlet weak var backupOptions: UIView!
    @IBOutlet weak var backupStatus: UILabel!
    @IBOutlet weak var backupLabel: UILabel!
    
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
        recoverLabel.setText(.hideRecoverButton)
        useTermsLabel.setText(.termsOfUse)
        augmentedRealityLabel.setText(.augmentedReality)
        augmentedReality.isHidden = true
        backupLabel.setText(.backupStatus)
        browserLabel.setText(.browser)
    }
    
    lazy var contentStackView: UIView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                createIconImage(UIImage(named: "calculadora"), action: #selector(metodoExemplo)),
                createIconImage(UIImage(named: "foguetinho"), action: #selector(metodoExemplo2)),
                createIconImage(UIImage(named: "iPhotos"), action: #selector(metodoExemplo3)),
                createIconImage(UIImage(named: "iconeOriginal"), action: #selector(metodoExemplo4))
            ]
        )
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        
        let label = UILabel()
        label.setText(.changeIconTitle)
        label.font = UIFont.boldSystemFont(ofSize: 18)
        
        let view = UIView()
        view.addSubview(stackView)
        view.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 3
        view.layer.shadowOpacity = 0.2
        view.layer.masksToBounds = false
        
        view.backgroundColor = .white
        return view
    }()

    
    func createIconImage(_ image: UIImage?, action: Selector) -> UIView {
        let view = UIView()
        let imageView = UIImageView(image: image)
        
        view.addSubview(imageView)
        
        view.snp.makeConstraints { make in
            make.width.height.equalTo(80)
        }
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 1
        
        // Adiciona interatividade
        imageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: action)
        imageView.addGestureRecognizer(tapGesture)

        return view
    }
    
    func setIcon(name: String) {
        let app = UIApplication.shared
        if #available(iOS 10.3, *) {
            if app.supportsAlternateIcons {
                app.setAlternateIconName(name, completionHandler: { (error) in
                    if error != nil {
                        print("error => \(String(describing: error?.localizedDescription))")
                    } else {
                        print("Changed Icon Sucessfully.")
                    }
                })
            }
        }
    }
    
    @objc func metodoExemplo() {
        setIcon(name: "icon1")
    }
    
    @objc func metodoExemplo2() {
        setIcon(name: "Icon2")
    }
    
    @objc func metodoExemplo3() {
        setIcon(name: "icon3")
    }
    
    @objc func metodoExemplo4() {
        setIcon(name: "icon4")
    }
    
    // MARK: - Backup
    @objc
    func useTermsPressed(_ sender: UITapGestureRecognizer? = nil) {
        let navigation = UINavigationController(rootViewController: UseTermsViewController())
        self.present(navigation, animated: true)
    }
    
    @objc
    func privacyPolicePressed(_ sender: UITapGestureRecognizer? = nil) {
        let navigation = UINavigationController(rootViewController: ScrollableTextViewController())
        self.present(navigation, animated: true)
    }
    
    @objc
    func augmentedRealityPressed(_ sender: UITapGestureRecognizer? = nil) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ViewController")
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true)
    }
    
    @objc
    func browserPressed(_ sender: UITapGestureRecognizer? = nil) {
        let controller = SafariWrapperViewController()
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
    }
    
    private func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        rateApp.addGestureRecognizer(tap)
        
        let useTermsPressed = UITapGestureRecognizer(target: self, action: #selector(useTermsPressed(_:)))
        useTerms.addGestureRecognizer(useTermsPressed)
        
        let augmentedRealityPressed = UITapGestureRecognizer(target: self, action: #selector(augmentedRealityPressed(_:)))
        augmentedReality.addGestureRecognizer(augmentedRealityPressed)
        
        let browserPressed = UITapGestureRecognizer(target: self, action: #selector(browserPressed(_:)))
        browser.addGestureRecognizer(browserPressed)
        
        let backupPressed = UITapGestureRecognizer(target: self, action: #selector(backupPressed(_:)))
        backupOptions.addGestureRecognizer(backupPressed)
    }
    
    private func setupViewStyles() {
        upgradeButton.layer.cornerRadius = 8
        upgradeButton.clipsToBounds = true

        view.addSubview(self.contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.top.equalTo(self.stackview.snp.bottom).offset(24)
        }
    }
    
    private func addShadow(to view: UIView, offset: CGSize, radius: CGFloat, opacity: Float) {
        view.layer.shadowOffset = offset
        view.layer.shadowRadius = radius
        view.layer.shadowOpacity = opacity
    }
}

import UIKit
import SafariServices

class SafariWrapperViewController: UIViewController, SFSafariViewControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let googleURL = URL(string: "https://www.google.com") else { return }
        let safariVC = SFSafariViewController(url: googleURL)
        
        addChildViewController(safariVC)
        view.addSubview(safariVC.view)
        
        safariVC.view.translatesAutoresizingMaskIntoConstraints = false
        safariVC.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        safariVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        safariVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        safariVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        safariVC.delegate = self
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        print("oi2")
    }
    
    func safariViewController(_ controller: SFSafariViewController, activityItemsFor URL: URL, title: String?) -> [UIActivity] {
        []
    }
}


extension  SettingsViewController: BackupModalViewControllerDelegate {
    func enableBackupToggled(status: Bool) {
        backupIsActivated = status
    }
}
