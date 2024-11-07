import UIKit
import SnapKit

protocol SecretLinkCellDelegate: AnyObject {
    func removeCell(withTitle title: String)
    func showDetails(withTitle title: String)
}

class SecretLinkCell: UIView {
    
    weak var delegate: SecretLinkCellDelegate?
    
    private let titleLabel = UILabel()
    private let passwordLabel = UILabel()
    private let eyeButton = UIButton(type: .system)
    private let trashButton = UIButton(type: .system)
    private let copyButton = UIButton(type: .system)
    
    private var link: String
    private var key: String
    
    init(title: String) {
        self.link = title.components(separatedBy: "@@").first ?? "N/A"
        self.key = title.components(separatedBy: "@@").count > 1 ? title.components(separatedBy: "@@")[1] : "N/A"
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .white
        layer.cornerRadius = 10
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        
        // Configurar título com estilo
        let boldAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 16)]
        let normalAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 16)]
        
        let attributedText = NSMutableAttributedString(string: "link: ", attributes: boldAttributes)
        attributedText.append(NSAttributedString(string: link, attributes: normalAttributes))
        titleLabel.numberOfLines = 0
        titleLabel.attributedText = attributedText
        addSubview(titleLabel)
        
        // Configurar senha com estilo
        let passwordAttributedText = NSMutableAttributedString(string: "key: ", attributes: boldAttributes)
        passwordAttributedText.append(NSAttributedString(string: key, attributes: normalAttributes))
        passwordLabel.numberOfLines = 0
        passwordLabel.attributedText = passwordAttributedText
        addSubview(passwordLabel)
        
        // Configurar botões
        setupButtons()
        
        // Layout
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(10)
        }
        
        passwordLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        
        let buttonStackView = UIStackView(arrangedSubviews: [copyButton, eyeButton, trashButton])
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .equalSpacing
        buttonStackView.spacing = 16
        addSubview(buttonStackView)
        
        buttonStackView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(passwordLabel.snp.bottom)
            make.bottom.equalToSuperview().offset(-10)
            make.height.equalTo(60)
        }
    }
    
    private func setupButtons() {
        // Configuração do botão de olho
        eyeButton.setImage(UIImage(systemName: "eye"), for: .normal)
        eyeButton.tintColor = .systemBlue
        eyeButton.imageView?.contentMode = .scaleAspectFit
        eyeButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        // Configuração do botão de lixo
        trashButton.setImage(UIImage(systemName: "trash"), for: .normal)
        trashButton.tintColor = .systemBlue
        trashButton.imageView?.contentMode = .scaleAspectFit
        trashButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        // Configuração do botão de copiar
        copyButton.setImage(UIImage(systemName: "doc.on.doc"), for: .normal)
        copyButton.tintColor = .systemBlue
        copyButton.imageView?.contentMode = .scaleAspectFit
        copyButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        // Ações dos botões
        copyButton.addTarget(self, action: #selector(copyButtonTapped), for: .touchUpInside)
        eyeButton.addTarget(self, action: #selector(eyeButtonTapped), for: .touchUpInside)
        trashButton.addTarget(self, action: #selector(trashButtonTapped), for: .touchUpInside)
    }
    
    @objc private func copyButtonTapped() {
        UIPasteboard.general.string = "Link: \(link)\nSenha: \(key)"
    }
    
    @objc private func eyeButtonTapped() {
        delegate?.showDetails(withTitle: "\(link)@@\(key)")
    }
    
    @objc private func trashButtonTapped() {
        delegate?.removeCell(withTitle: "\(link)@@\(key)")
        removeFromSuperview()
    }
}
