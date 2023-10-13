import UIKit
import SnapKit

class InsertRecoverEmailViewController: UIViewController {

    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "background")
        return imageView
    }()
    
    // Declare o campo de texto
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = Text.insertEmailDescription.localized()
        textField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .systemGray6 // Defina a cor de fundo como cinza
        textField.layer.cornerRadius = 10 // Arredonde as bordas
        textField.layer.masksToBounds = false // Permite sombra
        textField.layer.shadowColor = UIColor.black.cgColor // Cor da sombra
        textField.layer.shadowOpacity = 0.5
        textField.layer.shadowOffset = CGSize(width: 0, height: 2)
        textField.layer.shadowRadius = 2
        return textField
    }()
    
    // Declare o rótulo explicativo
    let emailExplanationLabel: UILabel = {
        let label = UILabel()
        label.text = Text.createCodeOnboarding_skipButtonTitle.localized()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private let startButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button.setTitle(Text.insertEmailButtonText.localized(), for: .normal)
        return button
    }()
    
    private let skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.numberOfLines = 0
        button.tintColor = .white
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.setTitle(Text.createCodeOnboarding_skipButtonTitle.localized(), for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .lightGray

        view.addSubview(backgroundImageView)
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        // Adicione o rótulo explicativo à vista
        view.addSubview(emailExplanationLabel)
        
        // Configure as restrições do rótulo
        emailExplanationLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.top.equalToSuperview().offset(120) // Ajuste a posição vertical conforme necessário
        }
        
        // Adicione o campo de texto à vista
        view.addSubview(emailTextField)
        
        // Configure as restrições do campo de texto usando o SnapKit
        emailTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.top.equalTo(emailExplanationLabel.snp.bottom).offset(48)
            make.height.equalTo(60) // Ajuste a altura conforme necessário
        }

        // Adicione os botões à vista
        view.addSubview(startButton)
        view.addSubview(skipButton)
        
        // Configure as restrições dos botões
        startButton.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(48)
            make.leading.trailing.equalToSuperview().inset(48)
            make.height.equalTo(56) // Ajuste a altura conforme necessário
        }
        
        skipButton.snp.makeConstraints { make in
            make.top.equalTo(startButton.snp.bottom).offset(16) // Espaçamento entre os botões
            make.leading.trailing.equalToSuperview().inset(48)
            make.height.equalTo(56) // Ajuste a altura conforme necessário
        }
        
        startButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        skipButton.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
        
        emailTextField.becomeFirstResponder()
        // Configurar reconhecimento de toque para ocultar o teclado
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // Função para ocultar o teclado quando o usuário tocar fora do campo de texto
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func confirmButtonTapped() {
        guard let text = emailTextField.text,
              isValidEmail(text) else {
            Alerts.showEmailError(controller: self)
            return
        }
        
        Defaults.setString(.recoverEmail, text)
        self.navigationController?.pushViewController(OnboardingAddPhotosViewController(), animated: true)
    }

    // Função chamada quando o botão "Pular Etapa" é pressionado
    @objc func skipButtonTapped() {
        self.navigationController?.pushViewController(OnboardingAddPhotosViewController(), animated: true)
    }
    
    func isValidEmail(_ email: String) -> Bool {
        // Expressão regular para validar um email
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        // Crie um NSPredicate com a expressão regular
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        // Avalie o email usando o NSPredicate
        return emailPredicate.evaluate(with: email)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Remova a camada anterior (se existir) para evitar sobreposição de múltiplas camadas
        startButton.layer.sublayers?.removeAll { $0 is CAGradientLayer }
        
        // Agora adicione a camada de gradiente
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = startButton.bounds
        gradientLayer.colors = [UIColor(hex: "4EACE3").cgColor, UIColor(hex: "1E84C0").cgColor]
        gradientLayer.cornerRadius = 10
        startButton.layer.insertSublayer(gradientLayer, at: 0)
        
        skipButton.layer.sublayers?.removeAll { $0 is CAGradientLayer }
    }
}
