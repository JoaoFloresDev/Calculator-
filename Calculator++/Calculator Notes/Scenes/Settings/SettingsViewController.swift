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
    @IBOutlet weak var faceIDView: UIView!
    
    @IBOutlet weak var useTerms: UIView!
    @IBOutlet weak var useTermsLabel: UILabel!
    
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
    
    @IBOutlet weak var changePassword: UIView!
    
    @IBOutlet weak var shareWithOtherCalc: UIView!
    
    @IBOutlet weak var fakePassword: UIView!
    
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
//        recoverLabel.setText(.hideRecoverButton)
        useTermsLabel.setText(.termsOfUse)
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
        controller.modalPresentationStyle = .fullScreen
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
        
        let useTermsPressed = UITapGestureRecognizer(target: self, action: #selector(useTermsPressed(_:)))
        useTerms.addGestureRecognizer(useTermsPressed)
        
        let augmentedRealityPressed = UITapGestureRecognizer(target: self, action: #selector(augmentedRealityPressed(_:)))
        
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

//import UIKit
//import SafariServices
//
//class SafariWrapperViewController: UIViewController, SFSafariViewControllerDelegate {
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        guard let googleURL = URL(string: "https://www.google.com") else { return }
//        let safariVC = SFSafariViewController(url: googleURL)
//        
//        addChildViewController(safariVC)
//        view.addSubview(safariVC.view)
//        
//        safariVC.view.translatesAutoresizingMaskIntoConstraints = false
//        safariVC.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
//        safariVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
//        safariVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//        safariVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
//        safariVC.delegate = self
//    }
//    
//    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
//        print("oi2")
//    }
//    
//    func safariViewController(_ controller: SFSafariViewController, activityItemsFor URL: URL, title: String?) -> [UIActivity] {
//        []
//    }
//}


extension  SettingsViewController: BackupModalViewControllerDelegate {
    func backupExecuted() {
        
    }
    
    func enableBackupToggled(status: Bool) {
        backupIsActivated = status
    }
}

//
//import UIKit
//import SnapKit
//
//class SettingsViewController2: UIViewController {
//
//    // MARK: - Views
//    
//    private let stackView = UIStackView()
//    private let premiumButton = UIButton(type: .system)
//    private let backupOptionsView = UIView()
//    private let augmentedRealityView = UIView()
//    private let browserView = UIView()
//    private let appReviewView = UIView()
//    private let termsView = UIView()
//
//    private let backupLabel = UILabel()
//    private let backupStatusLabel = UILabel()
//    
//    private let augmentedRealityLabel = UILabel()
//    private let browserLabel = UILabel()
//    private let appReviewLabel = UILabel()
//    private let termsLabel = UILabel()
//    
//    private let switchButton = UISwitch()
//    
//    // MARK: - Lifecycle
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupViews()
//        setupConstraints()
//    }
//    
//    // MARK: - Setup Views
//    
//    private func setupViews() {
//        view.backgroundColor = .systemBackground
//        
//        // Setup StackView
//        stackView.axis = .vertical
//        stackView.spacing = 1
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(stackView)
//        
//        // Setup Premium Button
//        premiumButton.setTitle("Premium Version", for: .normal)
//        premiumButton.backgroundColor = UIColor(red: 0.0, green: 0.686, blue: 0.91, alpha: 1)
//        premiumButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
//        premiumButton.addTarget(self, action: #selector(premiumVersionPressed), for: .touchUpInside)
//        stackView.addArrangedSubview(premiumButton)
//        
//        // Setup Backup Options View
//        backupOptionsView.backgroundColor = .systemGray5
//        stackView.addArrangedSubview(backupOptionsView)
//        
//        backupLabel.text = "Backup Criptografado"
//        backupLabel.font = UIFont.systemFont(ofSize: 17)
//        backupOptionsView.addSubview(backupLabel)
//        
//        backupStatusLabel.text = "Disabled"
//        backupStatusLabel.font = UIFont.systemFont(ofSize: 17)
//        backupStatusLabel.textColor = .systemGray
//        backupOptionsView.addSubview(backupStatusLabel)
//        
//        // Setup Augmented Reality View
//        augmentedRealityLabel.text = "Augmented Reality"
//        augmentedRealityLabel.font = UIFont.systemFont(ofSize: 17)
//        augmentedRealityView.backgroundColor = .systemGray5
//        augmentedRealityView.addSubview(augmentedRealityLabel)
//        stackView.addArrangedSubview(augmentedRealityView)
//        
//        // Setup Browser View
//        browserLabel.text = "Browser"
//        browserLabel.font = UIFont.systemFont(ofSize: 17)
//        browserView.backgroundColor = .systemGray5
//        browserView.addSubview(browserLabel)
//        stackView.addArrangedSubview(browserView)
//        
//        // Setup App Review View
//        appReviewLabel.text = "App review"
//        appReviewLabel.font = UIFont.systemFont(ofSize: 17)
//        appReviewView.backgroundColor = .systemGray5
//        appReviewView.addSubview(appReviewLabel)
//        stackView.addArrangedSubview(appReviewView)
//        
//        // Setup Terms View
//        termsLabel.text = "Termos de uso"
//        termsLabel.font = UIFont.systemFont(ofSize: 17)
//        termsView.backgroundColor = .systemGray5
//        termsView.addSubview(termsLabel)
//        stackView.addArrangedSubview(termsView)
//        
//        // Setup Switch
//        backupOptionsView.addSubview(switchButton)
//        switchButton.isOn = true
//        switchButton.addTarget(self, action: #selector(switchButtonAction), for: .valueChanged)
//    }
//    
//    // MARK: - Setup Constraints
//    
//    private func setupConstraints() {
//        stackView.snp.makeConstraints { make in
//            make.edges.equalTo(view.safeAreaLayoutGuide)
//        }
//        
//        premiumButton.snp.makeConstraints { make in
//            make.height.equalTo(44)
//        }
//        
//        backupOptionsView.snp.makeConstraints { make in
//            make.height.equalTo(48)
//        }
//        
//        backupLabel.snp.makeConstraints { make in
//            make.leading.equalTo(backupOptionsView).offset(16)
//            make.centerY.equalTo(backupOptionsView)
//        }
//        
//        backupStatusLabel.snp.makeConstraints { make in
//            make.trailing.equalTo(backupOptionsView).offset(-16)
//            make.centerY.equalTo(backupOptionsView)
//        }
//        
//        augmentedRealityView.snp.makeConstraints { make in
//            make.height.equalTo(48)
//        }
//        
//        augmentedRealityLabel.snp.makeConstraints { make in
//            make.leading.equalTo(augmentedRealityView).offset(16)
//            make.centerY.equalTo(augmentedRealityView)
//        }
//        
//        browserView.snp.makeConstraints { make in
//            make.height.equalTo(48)
//        }
//        
//        browserLabel.snp.makeConstraints { make in
//            make.leading.equalTo(browserView).offset(16)
//            make.centerY.equalTo(browserView)
//        }
//        
//        appReviewView.snp.makeConstraints { make in
//            make.height.equalTo(48)
//        }
//        
//        appReviewLabel.snp.makeConstraints { make in
//            make.leading.equalTo(appReviewView).offset(16)
//            make.centerY.equalTo(appReviewView)
//        }
//        
//        termsView.snp.makeConstraints { make in
//            make.height.equalTo(48)
//        }
//        
//        termsLabel.snp.makeConstraints { make in
//            make.leading.equalTo(termsView).offset(16)
//            make.centerY.equalTo(termsView)
//        }
//        
//        switchButton.snp.makeConstraints { make in
//            make.trailing.equalTo(backupOptionsView).offset(-16)
//            make.centerY.equalTo(backupOptionsView)
//        }
//    }
//    
//    // MARK: - Actions
//    
//    @objc private func premiumVersionPressed() {
//        // Handle premium version button press
//    }
//    
//    @objc private func switchButtonAction() {
//        // Handle switch value change
//    }
//}
