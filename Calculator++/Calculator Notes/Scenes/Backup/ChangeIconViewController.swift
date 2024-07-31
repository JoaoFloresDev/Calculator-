import UIKit
import SnapKit
import Network
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
import GoogleSignIn

protocol BackupModalViewControllerDelegate {
    func enableBackupToggled(status: Bool)
}

class BackupModalViewController: UIViewController {
    var delegate: BackupModalViewControllerDelegate?
    
    lazy var backupHeaderView = BackupHeaderView()
    lazy var loginView = BackupLoginView(controller: self)
    
    lazy var backupStatusView = BackupStatusView(delegate: delegate)

    lazy var restoreBackup: UIView = {
        let label = UILabel()
        label.text = "Restaurar backup"
        label.font = UIFont.systemFont(ofSize: 14)
        let restoreBackupView = UIView()
        restoreBackupView.backgroundColor = .systemGray5
        restoreBackupView.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview().inset(8)
            make.leading.equalToSuperview().inset(16)
        }
        
        restoreBackupView.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.restoreBackupTapped))
        restoreBackupView.addGestureRecognizer(tapGesture)
        
        return restoreBackupView
    }()
    
    lazy var updateBackup: UIView = {
        let label = UILabel()
        label.text = "Atualizar backup"
        label.font = UIFont.systemFont(ofSize: 14)
        let restoreBackupView = UIView()
        restoreBackupView.backgroundColor = .systemGray5
        restoreBackupView.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview().inset(8)
            make.leading.equalToSuperview().inset(16)
        }
        
        restoreBackupView.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.updateBackupTapped))
        restoreBackupView.addGestureRecognizer(tapGesture)
        
        return restoreBackupView
    }()
    
    @objc func updateBackupTapped() {
            guard Defaults.getBool(.iCloudEnabled) else {
                Alerts.showBackupDisabled(controller: self)
                return
            }
            
                self.loadingAlert.startLoading {
                    FirebaseBackupService.updateBackup(completion: { _ in
                        DispatchQueue.main.async {
                            self.loadingAlert.stopLoading {
                                Alerts.showBackupSuccess(controller: self)
                            }
                        }
                    })

                    if Defaults.getBool(.needSavePasswordInCloud) {
                        CloudKitPasswordService.updatePassword(newPassword: Defaults.getString(.password)) { success, error in
                            if success && error == nil {
                                Defaults.setBool(.needSavePasswordInCloud, false)
                            }
                        }
                    }
                }
    }
    
    lazy var loadingAlert = LoadingAlert(in: self)
    
    lazy var contentStackView: UIStackView = {
        let spacer = UIView()
        let stackView = UIStackView(arrangedSubviews: [backupStatusView, restoreBackup, updateBackup, loginView])
        stackView.axis = .vertical
        stackView.spacing = 1
        return stackView
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    let maxDimmedAlpha: CGFloat = 0.6
    lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = maxDimmedAlpha
        return view
    }()
    
    let defaultHeight: CGFloat = 530
    var currentContainerHeight: CGFloat = 460
    
    var containerViewHeightConstraint: Constraint?
    var containerViewBottomConstraint: Constraint?
    
    init(backupIsActivated: Bool, delegate: BackupModalViewControllerDelegate) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
        backupStatusView.switchControl.isOn = Defaults.getBool(.iCloudEnabled)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleCloseAction))
        backgroundView.addGestureRecognizer(tapGesture)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipeDown))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
    }
    
    @objc func handleCloseAction() {
        animateDismissView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animatePresentContainer()
    }
    
    func setupView() {
        view.backgroundColor = .clear
    }
    
    func setupConstraints() {
        view.addSubview(backgroundView)
        view.addSubview(containerView)
        
        containerView.addSubview(backupHeaderView)
        
        backupHeaderView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().offset(8)
            make.height.equalTo(80)
        }
        
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            containerViewBottomConstraint = make.bottom.equalTo(view.snp.bottom).offset(defaultHeight).constraint
            containerViewHeightConstraint = make.height.equalTo(defaultHeight).constraint
        }
        
        containerView.addSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.top.equalTo(backupHeaderView.snp.bottom).offset(24)
            make.bottom.equalTo(containerView.snp.bottom).offset(-20)
            make.leading.trailing.equalTo(containerView)
        }
        
        containerViewHeightConstraint?.activate()
        containerViewBottomConstraint?.activate()
    }
    
    @objc func handleSwipeDown(_ gesture: UISwipeGestureRecognizer) {
        animateDismissView()
    }
    
    func animateContainerHeight(_ height: CGFloat) {
        UIView.animate(withDuration: 0.4) {
            self.containerViewHeightConstraint?.update(offset: height)
            self.view.layoutIfNeeded()
        }
        currentContainerHeight = height
    }
    
    // MARK: Present and dismiss animation
    func animatePresentContainer() {
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.update(offset: 0)
            self.view.layoutIfNeeded()
        }
    }
    
    func animateDismissView() {
        backgroundView.alpha = maxDimmedAlpha
        UIView.animate(withDuration: 0.4) {
            self.backgroundView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false)
        }
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.update(offset: self.defaultHeight)
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func switchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            Defaults.setBool(.iCloudEnabled, true)
            self.delegate?.enableBackupToggled(status: true)
        } else {
            Defaults.setBool(.iCloudEnabled, false)
            delegate?.enableBackupToggled(status: false)
        }
    }
}

extension BackupModalViewController {
    @objc func restoreBackupTapped() {
        
        guard Defaults.getBool(.iCloudEnabled) else {
            Alerts.showBackupDisabled(controller: self)
            return
        }
        
        self.checkBackupData()
    }
    
    private func checkBackupData() {
        loadingAlert.startLoading()
        FirebaseBackupService.hasDataInFirebase { hasData, _, items  in
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
        FirebaseBackupService.restoreBackup(items: backupItems) { success, _ in
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
