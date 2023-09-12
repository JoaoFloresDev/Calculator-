//
//  WelcomeViewController.swift
//  Calculator Notes
//
//  Created by Joao Victor Flores da Costa on 09/09/23.
//  Copyright © 2023 MakeSchool. All rights reserved.
//

import Foundation

import UIKit
import Network

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

protocol WelcomeViewControllerDelegate {
    func backupDone()
}

class WelcomeViewController: UIViewController {
    var coordinator: CollectionViewCoordinatorProtocol?
    lazy var loadingAlert = LoadingAlert(in: self)
    var delegate: WelcomeViewControllerDelegate?
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFirstUse()
    }
    
    init(coordinator: CollectionViewCoordinatorProtocol?,
         delegate: WelcomeViewControllerDelegate) {
        self.coordinator = coordinator
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension WelcomeViewController {
    private func setupFirstUse() {
        showSetProtectionOrNavigateToSettings()
    }
    
    private func performFirstUseSetup() {
        loadingAlert.startLoading()
        CloudKitPasswordService.fetchAllPasswords { [weak self] password, error in
            guard let self = self, let password = password, error == nil else {
                self?.loadingAlert.stopLoading {
                    self?.showSetProtectionOrNavigateToSettings()
                }
                return
            }
            self.loadingAlert.stopLoading {
                self.handleFirstUseCompletion(with: password)
            }
        }
    }
    
    private func handleFirstUseCompletion(with password: [String]) {
        Alerts.askUserToRestoreBackup(on: self) { [weak self] restoreBackup in
            if restoreBackup {
                self?.handleRestoreBackup(password: password)
            } else {
                self?.showSetProtectionOrNavigateToSettings()
            }
        }
    }
    
    private func handleRestoreBackup(password: [String]) {
        Alerts.insertPassword(controller: self) { [weak self] insertedPassword in
            guard let self = self, let insertedPassword = insertedPassword else {
                return
            }
            if password.contains(insertedPassword) {
                self.loadingAlert.startLoading()
                BackupService.hasDataInCloudKit { [weak self] hasData, _, items in
                    self?.loadingAlert.stopLoading {
                        guard let self = self, let items = items, !items.isEmpty, hasData else {
                            self?.showSetProtectionOrNavigateToSettings()
                            return
                        }
                        self.restoreBackupAndReloadData(photos: items)
                    }
                }
            } else {
                Alerts.showPasswordError(controller: self)
            }
        }
    }
    
    private func showSetProtectionOrNavigateToSettings() {
        Alerts.showSetProtectionAsk(controller: self) { [weak self] createProtection in
            if createProtection {
                self?.coordinator?.presentChangePasswordCalcMode()
            } else {
                self?.dismiss(animated: false) {
                    self?.coordinator?.navigateToSettingsTab()
                }
            }
        }
    }
    
    private func restoreBackupAndReloadData(photos: [(String, UIImage)]) {
        loadingAlert.startLoading()
        BackupService.restoreBackup(photos: photos) { [weak self] success, _ in
                if success {
                    self?.delegate?.backupDone()
                    self?.loadingAlert.stopLoading {
                        self?.showSetProtectionOrNavigateToSettings()
                    }
                } else {
                    guard let strongSelf = self else {
                        return
                    }
                    Alerts.showBackupError(controller: strongSelf)
                }
        }
    }
    
    private func monitorWiFiAndPerformActions() {
        guard Defaults.getBool(.iCloudPurchased) else {
            return
        }
        
        isConnectedToWiFi { isConnected in
            if isConnected {
                BackupService.updateBackup(completion: {_ in })
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
}
