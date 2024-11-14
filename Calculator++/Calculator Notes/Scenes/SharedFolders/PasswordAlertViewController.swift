import UIKit
import FirebaseStorage
import SnapKit

class PasswordAlertViewController: UIViewController {

    private let alertContainer = UIView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let passwordTextField = UITextField()
    private let confirmButton = UIButton(type: .system)
    private let closeButton = UIButton(type: .system)
    private let errorLabel = UILabel()
    private let url: URL
    private var loadingAlert: LoadingAlert?
    private let confirmAction: ([URL]) -> Void

    init(title: String, message: String, url: URL, confirmAction: @escaping ([URL]) -> Void) {
        self.url = url
        self.confirmAction = confirmAction
        super.init(nibName: nil, bundle: nil)
        
        titleLabel.text = title
        messageLabel.text = message
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        setupUI()
        setupConstraints()
        
        passwordTextField.becomeFirstResponder() // Exibe o teclado automaticamente
    }
    
    private func setupUI() {
        alertContainer.backgroundColor = .white
        alertContainer.layer.cornerRadius = 12
        alertContainer.layer.shadowColor = UIColor.black.cgColor
        alertContainer.layer.shadowOpacity = 0.3
        alertContainer.layer.shadowOffset = CGSize(width: 0, height: 4)
        alertContainer.layer.shadowRadius = 8
        view.addSubview(alertContainer)
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center
        alertContainer.addSubview(titleLabel)
        
        messageLabel.font = UIFont.systemFont(ofSize: 14)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        alertContainer.addSubview(messageLabel)
        
        passwordTextField.placeholder = "Digite a senha"
        passwordTextField.isSecureTextEntry = true
        passwordTextField.borderStyle = .roundedRect
        alertContainer.addSubview(passwordTextField)
        
        errorLabel.font = UIFont.systemFont(ofSize: 12)
        errorLabel.textAlignment = .center
        errorLabel.textColor = .red
        errorLabel.isHidden = true
        alertContainer.addSubview(errorLabel)
        
        confirmButton.setTitle("OK", for: .normal)
        confirmButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        confirmButton.backgroundColor = .systemBlue
        confirmButton.layer.cornerRadius = 8
        confirmButton.tintColor = .white
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        alertContainer.addSubview(confirmButton)
        
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .darkGray
        closeButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        alertContainer.addSubview(closeButton)
    }
    
    private func setupConstraints() {
        alertContainer.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-50) // Posiciona o alertContainer mais para cima
            make.width.equalTo(320)
            make.height.equalTo(260)
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(alertContainer).offset(12)
            make.left.equalTo(alertContainer).offset(12)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(alertContainer).offset(16)
            make.left.right.equalTo(alertContainer).inset(16)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.right.equalTo(titleLabel)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(18)
            make.left.right.equalTo(alertContainer).inset(16)
        }
        
        errorLabel.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(12)
            make.height.equalTo(14)
            make.left.right.equalTo(alertContainer).inset(16)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(errorLabel.snp.bottom).offset(16)
            make.left.right.equalTo(alertContainer).inset(16)
            make.height.equalTo(48)
            make.bottom.equalTo(alertContainer).offset(-16)
        }
    }
    
    @objc private func confirmTapped() {
        guard let password = passwordTextField.text, !password.isEmpty else {
            errorLabel.text = Text.invalidLinkOrPasswordMessage.localized()
            errorLabel.isHidden = false
            return
        }
        
        errorLabel.isHidden = true
        let folderId = url.lastPathComponent + password
        loadPhotos(folderId: folderId)
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }

    private func loadPhotos(folderId: String) {
        let folderRef = Storage.storage().reference().child("shared_photos/\(folderId)")
        
        if let rootViewController = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            
            loadingAlert = LoadingAlert(in: self)
            
            loadingAlert?.startLoading {
                folderRef.listAll { result, error in
                    if let error = error {
                        print("Erro ao listar fotos: \(error.localizedDescription)")
                        self.loadingAlert?.stopLoading {
                            self.errorLabel.text = Text.invalidLinkOrPasswordMessage.localized()
                            self.errorLabel.isHidden = false
                        }
                        return
                    }
                    
                    var photoURLs: [URL] = []
                    let dispatchGroup = DispatchGroup()
                    
                    result?.items.forEach { item in
                        dispatchGroup.enter()
                        item.downloadURL { url, error in
                            if let url = url {
                                photoURLs.append(url)
                            }
                            dispatchGroup.leave()
                        }
                    }
                    
                    dispatchGroup.notify(queue: .main) {
                        guard !photoURLs.isEmpty else {
                            self.loadingAlert?.stopLoading {
                                self.errorLabel.text = Text.invalidLinkOrPasswordMessage.localized()
                                self.errorLabel.isHidden = false
                            }
                            return
                        }
                        self.loadingAlert?.stopLoading {
                            self.dismiss(animated: true) {
                                self.confirmAction(photoURLs)
                            }
                        }
                    }
                }
            }
        }
    }
}
