import UIKit
import SnapKit

class PlaceholderView: UIView {
    
    // Elementos da view
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor(red: 74/255.0, green: 74/255.0, blue: 74/255.0, alpha: 1.0)
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor(red: 126/255.0, green: 126/255.0, blue: 126/255.0, alpha: 1.0)
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0/255.0, green: 175/255.0, blue: 232/255.0, alpha: 1.0)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.clipsToBounds = true
        return button
    }()

    
    // Stack View para organizar os elementos
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.setCustomSpacing(24, after: imageView)
        stackView.setCustomSpacing(8, after: titleLabel)
        stackView.alignment = .center
        return stackView
    }()
    
    // Inicializadores
    init(title: String, subtitle: String, image: UIImage?, buttonText: String? = nil, buttonAction: (() -> Void)? = nil) {
        super.init(frame: .zero)
        titleLabel.text = title
        subtitleLabel.text = subtitle
        imageView.image = image
        if let buttonText = buttonText, let buttonAction = buttonAction {
            actionButton.setTitle(buttonText, for: .normal)
            actionButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
            self.buttonAction = buttonAction
        }
        
        setupView()
    }
    
    func update(title: String, subtitle: String, image: UIImage?, buttonText: String? = nil, buttonAction: (() -> Void)? = nil) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        imageView.image = image
        if let buttonText = buttonText, let buttonAction = buttonAction {
            actionButton.setTitle(buttonText, for: .normal)
            actionButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
            self.buttonAction = buttonAction
        } else {
            actionButton.isHidden = true
        }
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // Closure para armazenar o completionHandler
    private var buttonAction: (() -> Void)?
    
    // Método chamado quando o botão é pressionado
    @objc private func buttonPressed() {
        buttonAction?()
    }
    
    private func setupView() {
        // Adiciona a stackView como subview
        addSubview(stackView)
        
        // Configura as constraints da stackView
        let width = 200.0
        let rate = 0.6
        stackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-30)
            make.width.equalTo(300)
        }
        
        // Configura as constraints da imageView
        imageView.snp.makeConstraints { make in
            make.width.equalTo(width)
            make.height.equalTo(width*rate)
        }

        // Se a ação do botão estiver configurada, adicionamos o botão à view
        if buttonAction != nil {
            addSubview(actionButton)
            actionButton.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(16)
                make.right.equalToSuperview().inset(16)
                make.height.equalTo(44)
                make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).inset(16)
            }
        }
    }
}
