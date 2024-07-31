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

class BackupHeaderView: UIView {
    lazy var modalTitleView: UIView = {
        let label = UILabel()
        label.text = Text.backupSettings.localized()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.textAlignment = .center
        
        return label
    }()
    
    lazy var modalSubtitleView: UILabel = {
        let label = UILabel()
        label.text = Text.backupNavigationSubtitle.localized()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.numberOfLines = 0
        label.textAlignment = .center
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        addSubview(modalTitleView)
        addSubview(modalSubtitleView)
    }
    
    private func setupConstraints() {
        modalTitleView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        modalSubtitleView.snp.makeConstraints { make in
            make.top.equalTo(modalTitleView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(24)
        }
    }
}

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
                        Alerts.showAlert(title: "Login efetuado com sucesso!", text: "Suas fotos serão sincronizadas sempre que adicionar novas fotos ou clicar no botão 'atualizar backup'", controller: self.controller)
                    }
                }
            } else {
                Alerts.showAlert(title: "Error", text: "Something went wrong.", controller: self.controller)
            }
        }
    }

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
                        Alerts.showAlert(title: "Login efetuado com sucesso!", text: "Suas fotos serão sincronizadas sempre que adicionar novas fotos ou clicar no botão 'atualizar backup'", controller: self.controller)
                    }
                }
            } else {
                Alerts.showAlert(title: "Error", text: "Something went wrong.", controller: self.controller)
            }
        }
    }
    
    let controller: UIViewController
    
    init(controller: UIViewController) {
        self.controller = controller
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
            make.bottom.equalToSuperview()
        }
    }
}

class BackupStatusView: UIView {
    var delegate: BackupModalViewControllerDelegate?
    
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
    
    @objc func switchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            Defaults.setBool(.iCloudEnabled, true)
            self.delegate?.enableBackupToggled(status: true)
        } else {
            Defaults.setBool(.iCloudEnabled, false)
            delegate?.enableBackupToggled(status: false)
        }
    }
    
    init(delegate: BackupModalViewControllerDelegate?) {
        self.delegate = delegate
        super.init(frame: .zero)
        self.addSubview(backupStatus)
        backupStatus.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CustomLabelButtonView: UIView {
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    init(text: String, backgroundColor: UIColor) {
        super.init(frame: .zero)
        self.label.text = text
        self.backgroundColor = backgroundColor
        self.layer.cornerRadius = 8
        self.setupView()
        self.setupConstraints()
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buttonTapped)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.addSubview(label)
    }
    
    private func setupConstraints() {
        label.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview().inset(8)
            make.leading.equalToSuperview().inset(16)
        }
        
        self.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
    }
    
    @objc private func buttonTapped() {
        print("Button tapped")
    }
    
    func setTapAction(target: Any?, action: Selector) {
        let tapGesture = UITapGestureRecognizer(target: target, action: action)
        self.addGestureRecognizer(tapGesture)
    }
}

// Exemplo de uso dentro de outra view
class ExampleView: UIView {
    
    lazy var updateBackup: CustomLabelButtonView = {
        let view = CustomLabelButtonView(text: "Atualizar backup", backgroundColor: .systemGray5)
        view.setTapAction(target: self, action: #selector(updateBackupTapped))
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(updateBackup)
    }
    
    private func setupConstraints() {
        updateBackup.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(50)
        }
    }
    
    @objc private func updateBackupTapped() {
        print("Atualizar backup tapped")
    }
}
