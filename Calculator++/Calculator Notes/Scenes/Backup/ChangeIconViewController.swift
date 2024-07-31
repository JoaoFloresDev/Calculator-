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
    
    lazy var modalTitleView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        let titleLabel = UILabel()
        titleLabel.text = Text.backupSettings.localized()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 14)
        titleLabel.textColor = .black
        
        view.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        return view
    }()
    
    lazy var modalSubtitleView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        let titleLabel = UILabel()
        titleLabel.text = Text.backupNavigationSubtitle.localized()
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.textColor = .lightGray
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        
        view.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return view
    }()
    
    
    lazy var loginTitle: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        let titleLabel = UILabel()
        titleLabel.text = "Já possui uma conta?"
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.textColor = .darkGray
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        
        view.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return view
    }()
    
    lazy var loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Login With Google", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .systemGray6
        
        let googleLogo = UIImage(named: "google_logo")
        button.setImage(googleLogo, for: .normal)
        
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        
        button.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        
        button.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func loginTapped() {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
            guard let result = signInResult else {
                if (error as? NSError)?.code == -5 {
                    print("User cancelled")
                } else {
                    Alerts.showAlert(title: "Error", text: "\(error?.localizedDescription)\n\nSe você ainda não possui uma conta, selecione 'Sign up with google'" ?? "Something went wrong", controller: self)
                }
                return
            }
            
            if let googleID = result.user.userID, let email = result.user.profile?.email {
                self.manager.signInWithEmail(withEmail: email, password: googleID) { error in
                    if let error {
                        Alerts.showAlert(title: "Error", text: "\(error.localizedDescription)\n\nSe Você ainda não possui uma conta, selecione 'Sign up with google'", controller: self)
                    } else {
                        self.navigationController?.pushViewController(OnboardingAddPhotosViewController(), animated: true)
                    }
                }
            } else {
                Alerts.showAlert(title: "Error", text: "Something went wrong.", controller: self)
            }
        }
    }
    
    let manager = AuthManager()

    lazy var createAccountTitle: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        let titleLabel = UILabel()
        titleLabel.text = "Ainda não? Crie agora!"
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.textColor = .darkGray
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        
        view.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return view
    }()
    
    lazy var createAccountButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign Up With Google", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .systemGray6
        
        let googleLogo = UIImage(named: "google_logo")
        button.setImage(googleLogo, for: .normal)
        
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        
        button.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        
        button.addTarget(self, action: #selector(createAccountTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func createAccountTapped() {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
            guard let result = signInResult else {
                if (error as? NSError)?.code == -5 {
                    print("User cancelled")
                } else {
                    Alerts.showAlert(title: "Error", text: error?.localizedDescription ?? "Something went wrong", controller: self)
                }
                return
            }
            
            if let googleID = result.user.userID, let email = result.user.profile?.email {
                self.manager.createAccount(withEmail: email, password: googleID) { error in
                    if let error {
                        Alerts.showAlert(title: "Error", text: error.localizedDescription, controller: self)
                    } else {
                        self.navigationController?.pushViewController(OnboardingAddPhotosViewController(), animated: true)
                    }
                }
            } else {
                Alerts.showAlert(title: "Error", text: "Something went wrong.", controller: self)
            }
        }
    }
    
    lazy var switchControl: UISwitch = {
        let switchControl = UISwitch()
        switchControl.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        return switchControl
    }()
    
    lazy var backupStatus: UIView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        
        let leftLabel = UILabel()
        leftLabel.text = Text.backupStatus.localized()
        leftLabel.font = UIFont.systemFont(ofSize: 14)
        
        stackView.addArrangedSubview(leftLabel)
        stackView.addArrangedSubview(switchControl)
        
        let backupStatusView = UIView()
        backupStatusView.backgroundColor = .systemGray5
        backupStatusView.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview().inset(8)
            make.leading.equalToSuperview().inset(16)
        }
        
        backupStatusView.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        
        return backupStatusView
    }()

    lazy var restoreBackup: UIView = {
        let label = UILabel()
        label.text = "Restaurar backup"//Text.restoreBackup.localized()
        label.font = UIFont.systemFont(ofSize: 14)
        let restoreBackupView = UIView()
        restoreBackupView.backgroundColor = .systemGray5
        restoreBackupView.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview().inset(8)
            make.leading.equalToSuperview().inset(16)
        }
        
        restoreBackupView.snp.makeConstraints { make in
            make.height.equalTo(50) // Definindo a altura desejada
        }
        
        // Adicionar o gesture recognizer para tornar a view clicável
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
//        isConnectedToWiFi { isConnected in
            guard Defaults.getBool(.iCloudEnabled) else {
                Alerts.showBackupDisabled(controller: self)
                return
            }
            
//            if isConnected {
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
//            } else {
//                Alerts.showBackupErrorWifi(controller: self)
//            }
//        }
    }
    
    lazy var loadingAlert = LoadingAlert(in: self)
    
//    func isConnectedToWiFi(completion: @escaping (Bool) -> Void) {
//        let monitor = NWPathMonitor()
//        
//        monitor.pathUpdateHandler = { path in
//            if path.status == .satisfied && path.usesInterfaceType(.wifi) {
//                completion(true)
//            } else {
//                completion(false)
//            }
//        }
//        
//        let queue = DispatchQueue(label: "NetworkMonitor")
//        monitor.start(queue: queue)
//    }
    
    lazy var contentStackView: UIStackView = {
        let spacer = UIView()
        let stackView = UIStackView(arrangedSubviews: [backupStatus, restoreBackup, updateBackup, loginButton, createAccountButton, spacer])
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
    lazy var dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = maxDimmedAlpha
        return view
    }()
    
    // Constants
    let defaultHeight: CGFloat = 530
    var currentContainerHeight: CGFloat = 460
    
    // Dynamic container constraint
    var containerViewHeightConstraint: Constraint?
    var containerViewBottomConstraint: Constraint?
    
    init(backupIsActivated: Bool, delegate: BackupModalViewControllerDelegate) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
        switchControl.isOn = Defaults.getBool(.iCloudEnabled)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        
        // Adiciona um gesto de tap para fechar o modal
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleCloseAction))
        dimmedView.addGestureRecognizer(tapGesture)
        
        // Adiciona um gesto de swipe para baixo
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
        view.addSubview(dimmedView)
        view.addSubview(containerView)
        
        containerView.addSubview(modalTitleView)
        containerView.addSubview(modalSubtitleView)
        
        modalTitleView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().offset(8)
            make.height.equalTo(44)  // Altura da barra de título
        }
        
        modalSubtitleView.snp.makeConstraints { make in
            make.top.equalTo(modalTitleView.snp.bottom)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
        }
        
        dimmedView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            containerViewBottomConstraint = make.bottom.equalTo(view.snp.bottom).offset(defaultHeight).constraint
            containerViewHeightConstraint = make.height.equalTo(defaultHeight).constraint
        }
        
        containerView.addSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.top.equalTo(modalSubtitleView.snp.bottom).offset(24)
            make.bottom.equalTo(containerView.snp.bottom).offset(-20)
            make.leading.trailing.equalTo(containerView)
        }
        
        containerView.addSubview(loginTitle)
        containerView.addSubview(loginButton)
        containerView.addSubview(createAccountTitle)
        containerView.addSubview(createAccountButton)
        
        loginTitle.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalTo(loginButton.snp.top).inset(-12)
        }
        
        loginButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalTo(createAccountTitle.snp.top).inset(-24)
        }
        
        createAccountTitle.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalTo(createAccountButton.snp.top).inset(-12)
        }
        
        createAccountButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(24)
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
        dimmedView.alpha = maxDimmedAlpha
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = 0
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
