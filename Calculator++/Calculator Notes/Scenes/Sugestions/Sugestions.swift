import UIKit
import SnapKit

class SuggestionsViewController: UIViewController {

    // MARK: - UI Elements
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = Text.headerMessage.localized()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.textColor = .darkGray
        label.numberOfLines = 0
        return label
    }()

    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = Text.emailContact.localized()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .darkGray
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = Text.writeYourMessage.localized()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .darkGray
        return label
    }()

    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = Text.emailPlaceholder.localized()
        textField.borderStyle = .none
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.layer.cornerRadius = 8
        textField.backgroundColor = .white
        textField.setPadding(left: 10)
        return textField
    }()

    private let messageTextView: UITextView = {
        let textView = UITextView()
        textView.layer.borderWidth = 0
        textView.layer.cornerRadius = 8
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.text = Text.feedbackPlaceholder.localized()
        textView.textColor = .lightGray
        textView.isScrollEnabled = true
        textView.backgroundColor = .white
        textView.setPadding(left: 10)
        return textView
    }()

    private let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Text.submitButtonTitle.localized(), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.1
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.shadowRadius = 5
        button.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        return button
    }()

    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        setupTextViewPlaceholder()
        setupNavigationBar()
        
        // Configura o reconhecimento de toque para ocultar o teclado
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        // Observadores para ajustar o layout conforme o teclado aparece e desaparece
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        view.addSubview(headerLabel)
        view.addSubview(emailLabel)
        view.addSubview(emailTextField)
        view.addSubview(messageLabel)
        view.addSubview(messageTextView)
        view.addSubview(submitButton)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: Text.close.localized(),
            style: .plain,
            target: self,
            action: #selector(closePressed)
        )
        title = Text.suggestionsFeedbackTitle.localized()
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closePressed)
        )
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemGray6
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        navigationController?.navigationBar.tintColor = .systemBlue
        
        title = Text.suggestionsFeedbackTitle.localized()
    }
    
    private func setupConstraints() {
        headerLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(headerLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(emailLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        messageTextView.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(submitButton.snp.top).offset(-16)
        }
        
        submitButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(50)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(20)
        }
    }
    
    private func setupTextViewPlaceholder() {
        messageTextView.delegate = self
    }

    // MARK: - Actions
    @objc private func closePressed() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }

    @objc private func submitButtonTapped() {
        guard let message = messageTextView.text, !message.isEmpty,
              message != Text.feedbackPlaceholder.localized() else {
            let alert = UIAlertController(
                title: Text.emptyMessageAlertTitle.localized(),
                message: Text.emptyMessageAlertMessage.localized(),
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: Text.ok.localized(), style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        let loading = LoadingAlert(in: self)
        loading.startLoading {
            FirebasePhotoSharingService.uploadTextFile(mail: self.emailTextField.text, message: message) { response, error in
                loading.stopLoading {
                    if let error = error {
                        let confirmationAlert = UIAlertController(
                            title: Text.errorAlertTitle.localized(),
                            message: Text.errorAlertMessage.localized(),
                            preferredStyle: .alert
                        )
                        confirmationAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                            self.dismiss(animated: true, completion: nil)
                        }))
                        self.present(confirmationAlert, animated: true, completion: nil)
                    } else {
                        let confirmationAlert = UIAlertController(
                            title: Text.thankYouAlertTitle.localized(),
                            message: Text.thankYouAlertMessage.localized(),
                            preferredStyle: .alert
                        )
                        confirmationAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                            self.dismiss(animated: true, completion: nil)
                        }))
                        self.present(confirmationAlert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    // MARK: - Keyboard Handlers
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            submitButton.snp.updateConstraints { make in
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(keyboardHeight + 10)
            }
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        submitButton.snp.updateConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(20)
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - UITextViewDelegate
extension SuggestionsViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == Text.feedbackPlaceholder.localized() {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = Text.feedbackPlaceholder.localized()
            textView.textColor = .lightGray
        }
    }
}

// MARK: - UITextField Padding Extension
extension UITextField {
    func setPadding(left: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: left, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}

extension UITextView {
    func setPadding(top: CGFloat = 0, left: CGFloat, bottom: CGFloat = 0, right: CGFloat = 0) {
        self.textContainerInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }
}
