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
import UIKit
import SnapKit

class BackupLoginView: UIView {
    let manager = AuthManager()
    
    lazy var createAccountTitle: UILabel = {
        let label = UILabel()
        label.text = Text.notHasAccount.localized()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    lazy var createAccountButton: UIButton = {
        let button = UIButton()
        button.setTitle(Text.signUpWithGoogle.localized(), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .systemGray6
        
        let googleLogo = UIImage(named: "google_logo")
        button.setImage(googleLogo, for: .normal)
        
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        
        button.addTarget(self, action: #selector(createAccountTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var loginTitle: UILabel = {
        let label = UILabel()
        label.text = Text.hasAccount.localized()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    lazy var loginButton: UIButton = {
        let button = UIButton()
        button.setTitle(Text.loginWithGoogle.localized(), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .systemGray6
        
        let googleLogo = UIImage(named: "google_logo")
        button.setImage(googleLogo, for: .normal)
        
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        
        button.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        return button
    }()
    
    let controller: BackupModalViewController
    let delegate: BackupLoginEvent?
    
    init(controller: BackupModalViewController, delegate: BackupLoginEvent?) {
        self.controller = controller
        self.delegate = delegate
        super.init(frame: .zero)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(createAccountTitle)
        addSubview(createAccountButton)
        addSubview(loginTitle)
        addSubview(loginButton)
    }
    
    private func setupConstraints() {
        createAccountTitle.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        createAccountButton.snp.makeConstraints { make in
            make.top.equalTo(createAccountTitle.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(50)
        }
        
        loginTitle.snp.makeConstraints { make in
            make.top.equalTo(createAccountButton.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(loginTitle.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().inset(16)
        }
    }
    
    @objc func loginTapped() {
        NotificationCenter.default.post(name: NSNotification.Name("alertWillBePresented"), object: nil)
        GIDSignIn.sharedInstance.signIn(withPresenting: controller) { signInResult, error in
            guard let result = signInResult else {
                if (error as? NSError)?.code == -5 {
                    print("User cancelled")
                } else {
                    Alerts.showAlert(title: Text.createLoginErrorTitle.localized(), text: "\(error?.localizedDescription ?? "\(Text.genericLoginError.localized())")\n\n\(Text.createLoginError.localized())", controller: self.controller)
                }
                return
            }
            
            if let googleID = result.user.userID, let email = result.user.profile?.email {
                self.manager.signInWithEmail(withEmail: email, password: googleID) { error in
                    if let error = error {
                        Alerts.showAlert(title: Text.createLoginErrorTitle.localized(), text: "\(error.localizedDescription)\n\n\(Text.createLoginError.localized())", controller: self.controller)
                    } else {
                        Defaults.setBool(.recurrentBackupUpdate, true)
                        Alerts.showAlert(title: Text.successLogin.localized(), text: Text.successLoginDescription.localized(), controller: self.controller) {
                            self.delegate?.refreshBackupLoginStatus()
                        }
                    }
                }
            } else {
                Alerts.showAlert(title: Text.errorTitle.localized(), text: Text.genericLoginError.localized(), controller: self.controller)
            }
            NotificationCenter.default.post(name: NSNotification.Name("alertHasBeenDismissed"), object: nil)
        }
    }
    
    @objc func createAccountTapped() {
        NotificationCenter.default.post(name: NSNotification.Name("alertWillBePresented"), object: nil)
        GIDSignIn.sharedInstance.signIn(withPresenting: controller) { signInResult, error in
            guard let result = signInResult else {
                if (error as? NSError)?.code == -5 {
                    print("User cancelled")
                } else {
                    Alerts.showAlert(title: Text.errorTitle.localized(), text: error?.localizedDescription ?? Text.genericLoginError.localized(), controller: self.controller)
                }
                return
            }
            
            if let googleID = result.user.userID, let email = result.user.profile?.email {
                self.manager.createAccount(withEmail: email, password: googleID) { error in
                    if let error = error {
                        Alerts.showAlert(title: Text.errorTitle.localized(), text: error.localizedDescription, controller: self.controller)
                    } else {
                        Defaults.setBool(.recurrentBackupUpdate, true)
                        self.delegate?.refreshBackupLoginStatus()
                        Alerts.showAlert(title: Text.successLogin.localized(), text: Text.successLoginDescription.localized(), controller: self.controller)
                    }
                }
            } else {
                Alerts.showAlert(title: Text.errorTitle.localized(), text: Text.genericLoginError.localized(), controller: self.controller)
            }
            NotificationCenter.default.post(name: NSNotification.Name("alertHasBeenDismissed"), object: nil)
        }
    }
}
