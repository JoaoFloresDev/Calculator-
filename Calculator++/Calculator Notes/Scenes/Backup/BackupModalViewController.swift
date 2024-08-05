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
import FirebaseAuth

protocol BackupModalViewControllerDelegate: AnyObject {
    func enableBackupToggled(status: Bool)
}

extension BackupModalViewController: BackupLoginEvent {
    func refreshBackupLoginStatus() {
        backupStatusView.switchControl.setOn(Defaults.getBool(.iCloudEnabled), animated: true)
        self.delegate?.enableBackupToggled(status: isUserLoggedIn())
        setBackupLoginStatus()
        if !isUserLoggedIn() {
            Defaults.setString(.lastBackupUpdate, "")
            updateBackup.label.text = "Pendente"
        } else {
            loadingAlert.startLoading()
            FirebaseBackupService.hasDataInFirebase { hasData, _, items  in
                self.loadingAlert.stopLoading {
                    if let items = items, !items.isEmpty, hasData {
                        self.askUserToRestoreBackup(backupItems: items)
                    } else {
                        self.updateBackupTapped()
                    }
                }
            }
        }
    }
}
                                        
class BackupModalViewController: UIViewController {
    
    // MARK: - Constants
    let defaultHeight: CGFloat = 530
    var currentContainerHeight: CGFloat = 460
    let maxDimmedAlpha: CGFloat = 0.6
    
    // MARK: - Variables
    var containerViewHeightConstraint: Constraint?
    var containerViewBottomConstraint: Constraint?
    var rootController: CollectionViewController?
    weak var delegate: BackupModalViewControllerDelegate?
    
    // MARK: - Views
    lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = maxDimmedAlpha
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleCloseAction))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    lazy var contentStackView: UIStackView = {
        let spacer = UIView()
        let stackView = UIStackView(arrangedSubviews: [backupHeaderView, backupStatusView, restoreBackup, updateBackup, loginView, profileView])
        stackView.axis = .vertical
        stackView.spacing = 1
        return stackView
    }()
    
    lazy var loadingAlert = LoadingAlert(in: self)
    
    lazy var backupHeaderView = BackupHeaderView()
    
    lazy var backupStatusView = BackupStatusView(controller: self)
    
    lazy var restoreBackup: UIView = {
        let view = CustomLabelButtonView(leftText: "Baixar backup", backgroundColor: .systemGray5)
        view.setTapAction(target: self, action: #selector(restoreBackupTapped))
        return view
    }()
    
    lazy var updateBackup: CustomLabelButtonView = {
        var date = Defaults.getString(.lastBackupUpdate)
        if date.isEmpty {
            date = "Pendente"
        }
        let view = CustomLabelButtonView(leftText: "Atualizar backup", rightText: date, backgroundColor: .systemGray5)
        view.setTapAction(target: self, action: #selector(updateBackupTapped))
        return view
    }()
    
    lazy var loginView: BackupLoginView = {
        let view = BackupLoginView(controller: self, delegate: self)
        view.isHidden = true
        return view
    }()
    
    lazy var profileView: BackupProfileView = {
        let view = BackupProfileView(delegate: self)
        view.isHidden = true
        return view
    }()
    
    // MARK: - Life Cycle
    init(delegate: BackupModalViewControllerDelegate?, rootController: CollectionViewController?) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
        self.rootController = rootController
        backupStatusView.switchControl.isOn = Defaults.getBool(.iCloudEnabled)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.handleCloseAction))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animatePresentContainer()
    }
    
    // MARK: - Layout
    func setupConstraints() {
        view.addSubview(backgroundView)
        view.addSubview(containerView)
        
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
            make.top.equalToSuperview().offset(8)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
            make.leading.trailing.equalTo(containerView)
        }
        
        containerViewHeightConstraint?.activate()
        containerViewBottomConstraint?.activate()
        
        setBackupLoginStatus()
    }
    
    func setBackupLoginStatus() {
        let isLoggedIn = isUserLoggedIn()
        
        UIView.animate(withDuration: 0.3) {
            if isLoggedIn {
                self.profileView.alpha = 1.0
                self.loginView.alpha = 0.0
            } else {
                self.profileView.alpha = 0.0
                self.loginView.alpha = 1.0
            }
        } completion: { _ in
            self.profileView.isHidden = !isLoggedIn
            self.loginView.isHidden = isLoggedIn
            if isLoggedIn {
                self.profileView.configure(name: Auth.auth().currentUser?.email)
            }
        }
    }
    
    //MARK: - Animation
    func animateContainerHeight(_ height: CGFloat) {
        UIView.animate(withDuration: 0.4) {
            self.containerViewHeightConstraint?.update(offset: height)
            self.view.layoutIfNeeded()
        }
        currentContainerHeight = height
    }
    
    func animatePresentContainer() {
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.update(offset: 0)
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Actions
    @objc func handleCloseAction() {
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
    
    func isUserLoggedIn() -> Bool {
        return Auth.auth().currentUser != nil && Auth.auth().currentUser?.email != nil
    }
    
    @objc func restoreBackupTapped() {
        if !isUserLoggedIn() {
            Alerts.showBackupDisabled(controller: self)
        }
        
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
    
    @objc func updateBackupTapped() {
        if !isUserLoggedIn() {
            Alerts.showBackupDisabled(controller: self)
        }
        
        self.loadingAlert.startLoading {
            FirebaseBackupService.updateBackup(completion: { _ in
                DispatchQueue.main.async {
                    self.loadingAlert.stopLoading {
                        Alerts.showBackupSuccess(controller: self)
                        Defaults.setString(.lastBackupUpdate, self.getCurrentDateTimeFormatted())
                        self.updateBackup.label.text = Defaults.getString(.lastBackupUpdate)
                    }
                }
            })
        }
    }
    
    func getCurrentDateTimeFormatted() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        let currentDate = Date()
        return dateFormatter.string(from: currentDate)
    }

    
    // MARK: - Private Functions
    private func askUserToRestoreBackup(backupItems: [MediaItem]) {
        Alerts.askUserToRestoreBackup(on: self) { restoreBackup in
            if restoreBackup {
                self.loadingAlert.startLoading() {
                    self.restoreBackup(backupItems: backupItems)
                }
            }
        }
    }
    
    private func restoreBackup(backupItems: [MediaItem]) {
            FirebaseBackupService.restoreBackup(items: backupItems) { success, _ in
                self.loadingAlert.stopLoading {
                    if success {
                        Alerts.showBackupSuccess(controller: self)
                        self.rootController?.viewDidLoad()
                    } else {
                        Alerts.showBackupError(controller: self)
                    }
                }
            }
    }
}

