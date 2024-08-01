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
    
    lazy var loginTitle: UILabel = {
        let label = UILabel()
        label.text = "Já possui uma conta?"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.textAlignment = .center
        
        return label
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
        
        button.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        return button
    }()

    lazy var createAccountTitle: UILabel = {
        let label = UILabel()
        label.text = "Ainda não? Crie agora"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.textAlignment = .center
        
        return label
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
        
        button.addTarget(self, action: #selector(createAccountTapped), for: .touchUpInside)
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
        addSubview(loginTitle)
        addSubview(loginButton)
        addSubview(createAccountTitle)
        addSubview(createAccountButton)
    }
    
    private func setupConstraints() {
        loginTitle.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(loginTitle.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(50)
        }
        
        createAccountTitle.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        createAccountButton.snp.makeConstraints { make in
            make.top.equalTo(createAccountTitle.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().inset(16)
        }
    }
    
    @objc func loginTapped() {
        GIDSignIn.sharedInstance.signIn(withPresenting: controller) { signInResult, error in
            guard let result = signInResult else {
                if (error as? NSError)?.code == -5 {
                    print("User cancelled")
                } else {
                    Alerts.showAlert(title: "Error", text: "\(error?.localizedDescription ?? "Something went wrong")\n\nSe você ainda não possui uma conta, selecione 'Sign up with google'", controller: self.controller)
                }
                return
            }
            
            if let googleID = result.user.userID, let email = result.user.profile?.email {
                self.manager.signInWithEmail(withEmail: email, password: googleID) { error in
                    if let error = error {
                        Alerts.showAlert(title: "Error", text: "\(error.localizedDescription)\n\nSe Você ainda não possui uma conta, selecione 'Sign up with google'", controller: self.controller)
                    } else {
                        self.delegate?.refreshBackupLoginStatus()
                        Alerts.showAlert(title: "Login efetuado com sucesso!", text: "Suas fotos serão sincronizadas sempre que adicionar novas fotos ou clicar no botão 'atualizar backup'", controller: self.controller)
                    }
                }
            } else {
                Alerts.showAlert(title: "Error", text: "Something went wrong.", controller: self.controller)
            }
        }
    }
    
    @objc func createAccountTapped() {
        GIDSignIn.sharedInstance.signIn(withPresenting: controller) { signInResult, error in
            guard let result = signInResult else {
                if (error as? NSError)?.code == -5 {
                    print("User cancelled")
                } else {
                    Alerts.showAlert(title: "Error", text: error?.localizedDescription ?? "Something went wrong", controller: self.controller)
                }
                return
            }
            
            if let googleID = result.user.userID, let email = result.user.profile?.email {
                self.manager.createAccount(withEmail: email, password: googleID) { error in
                    if let error = error {
                        Alerts.showAlert(title: "Error", text: error.localizedDescription, controller: self.controller)
                    } else {
                        self.delegate?.refreshBackupLoginStatus()
                        Alerts.showAlert(title: "Login efetuado com sucesso!", text: "Suas fotos serão sincronizadas sempre que adicionar novas fotos ou clicar no botão 'atualizar backup'", controller: self.controller)
                    }
                }
            } else {
                Alerts.showAlert(title: "Error", text: "Something went wrong.", controller: self.controller)
            }
        }
    }
    
}
