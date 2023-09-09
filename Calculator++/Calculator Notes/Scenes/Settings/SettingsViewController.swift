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
                self.backupStatus.text = self.backupIsActivated ? "Ativado" : "Desativado"
            }
        }
    }
    
    lazy var coordinator = SettingsCoordinator(viewController: self)
    
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
        
        guard FeatureFlags.iCloudEnabled,
              Defaults.getBool(.iCloudPurchased)  else {
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
        upgradeButton.layer.cornerRadius = 8
        ModeGroupView.layer.cornerRadius = 16
        ModeGroupView.layer.shadowOffset = CGSize(width: 0, height: 0)
        ModeGroupView.layer.shadowRadius = 4
        ModeGroupView.layer.shadowOpacity = 0.3
        noProtection.layer.cornerRadius = 8
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
        addShadow(to: ModeGroupView, offset: CGSize(width: 0, height: 0), radius: 4, opacity: 0.3)
    }
    
    private func addShadow(to view: UIView, offset: CGSize, radius: CGFloat, opacity: Float) {
        view.layer.shadowOffset = offset
        view.layer.shadowRadius = radius
        view.layer.shadowOpacity = opacity
    }
    
    private func loadData() {
        noProtectionImage.setImage(.diselectedIndicator)
    }
    
    private func showProtectionType(typeProtection: ProtectionMode) {
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

class SettingsCoordinator {
    weak var viewController: UIViewController?
    weak var tabBarController: UITabBarController? // Adicione essa linha se o tabBarController não for acessível de outra forma
    
    init(viewController: UIViewController) {
        self.viewController = viewController
        self.tabBarController = viewController.tabBarController // Adicione essa linha se necessário
    }
    
    func showBankMode() {
        let storyboard = UIStoryboard(name: "BankMode", bundle: nil)
        let changePasswordCalcMode = storyboard.instantiateViewController(withIdentifier: "ChangePasswordBankMode")
        viewController?.present(changePasswordCalcMode, animated: true)
    }
    
    func showCalculatorMode() {
        let storyboard = UIStoryboard(name: "CalculatorMode", bundle: nil)
        let changePasswordCalcMode = storyboard.instantiateViewController(withIdentifier: "ChangePasswordCalcMode")
        viewController?.present(changePasswordCalcMode, animated: true)
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

//
//  VideoCollectionCoordinator.swift
//  Calculator Notes
//
//  Created by Joao Victor Flores da Costa on 30/08/23.
//  Copyright © 2023 MakeSchool. All rights reserved.
//

import UIKit
import AVKit
import MobileCoreServices
import Photos
import CoreData
import os.log
import SnapKit

protocol VideoCollectionCoordinatorProtocol {
    func presentPurshes()
    func navigateToVideoCollectionViewController(
        for indexPath: IndexPath,
        folders: [Folder],
        basePath: String
    )
    func playVideo(
        videoPaths: [String],
        indexPath: IndexPath
    )
    func presentPickerController()
}

class VideoCollectionCoordinator: VideoCollectionCoordinatorProtocol {
    typealias Controller = UIViewController & UIImagePickerControllerDelegate & UINavigationControllerDelegate
    weak var viewController: Controller?
    
    init(viewController: Controller) {
        self.viewController = viewController
    }
    
    func presentPurshes() {
        let storyboard = UIStoryboard(name: "Purchase",bundle: nil)
        let changePasswordCalcMode = storyboard.instantiateViewController(withIdentifier: "Purchase")
        viewController?.present(changePasswordCalcMode, animated: true)
    }
    
    func navigateToVideoCollectionViewController(
        for indexPath: IndexPath,
        folders: [Folder],
        basePath: String
    ) {
        let storyboard = UIStoryboard(name: "VideoPlayer", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "VideoCollectionViewController") as? VideoCollectionViewController,
              indexPath.row < folders.count else { return }
        
        controller.basePath = basePath + folders[indexPath.row].name + Constants.deepSeparatorPath
        controller.navigationTitle = folders[indexPath.row].name.components(separatedBy: Constants.deepSeparatorPath).last
        viewController?.navigationController?.pushViewController(controller, animated: true)
    }
    
    func playVideo(
        videoPaths: [String],
                   indexPath: IndexPath
    ) {
        guard let viewController = viewController else {
            return
        }
        guard let videoURL = videoPaths[safe: indexPath.item],
              let path = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(videoURL) else {
            os_log("Failed to retrieve video URL", log: .default, type: .error)
            Alerts.showGenericError(controller: viewController)
            return
        }
        
        let player = AVPlayer(url: path)
        let playerController = AVPlayerViewController()
        playerController.player = player
        viewController.present(playerController, animated: true) {
            player.play()
        }
    }
    
    func presentPickerController() {
        guard let viewController = viewController else {
            return
        }
        guard UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) else {
            Alerts.showGenericError(controller: viewController)
            return
        }
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .savedPhotosAlbum
        imagePickerController.delegate = viewController
        imagePickerController.mediaTypes = [kUTTypeMovie as String]
        viewController.present(imagePickerController, animated: true, completion: nil)
    }
}
