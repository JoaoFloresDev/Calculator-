import UIKit
import FirebaseStorage
import SnapKit

protocol SecretLinkCellDelegate: AnyObject {
    func removeCell(withTitle title: String)
    func showDetails(withTitle title: String)
    func copyLink()
    func updatedCell()
}

class SecretLinkCell: UIView {
    
    weak var delegate: SecretLinkCellDelegate?
    
    private let titleLabel = UILabel()
    private let passwordLabel = UILabel()
    private let eyeButton = UIButton(type: .system)
    private let trashButton = UIButton(type: .system)
    private let copyButton = UIButton(type: .system)
    private let statusLabel = UILabel()  // Label para mostrar o status do link
    private let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .medium)
    
    private var link: String
    private var key: String
    
    init(title: String) {
        self.link = title.components(separatedBy: "@@").first ?? "N/A"
        self.key = title.components(separatedBy: "@@").count > 1 ? title.components(separatedBy: "@@")[1] : "N/A"
        super.init(frame: .zero)
        setupView()
        
        // Exibir o loading
        loadingIndicator.startAnimating()
        self.alpha = 0.5
        let folderId = title
            .replacingOccurrences(of: "secrets://shared_photos/", with: "")
            .replacingOccurrences(of: "@@", with: "")
        let folderRef = Storage.storage().reference().child("shared_photos/\(folderId)")
        
        // Verifica a disponibilidade do link
        folderRef.listAll { result, error in
            self.alpha = 1
            self.loadingIndicator.stopAnimating()
            if let error = error {
                let nsError = error as NSError
                if nsError.domain == NSURLErrorDomain {
                    self.statusLabel.text = Text.networkError.localized()
                    self.statusLabel.isHidden = false
                } else {
                    // Remover do Defaults e animar remoção da célula
                    self.removeLinkFromDefaults(title: title)
                    self.animateRemoval()
                    self.delegate?.updatedCell()
                }
                return
            }
            
            if result?.items.isEmpty == true {
                self.removeLinkFromDefaults(title: title)
                self.animateRemoval()
                self.delegate?.updatedCell()
            }
        }
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
        
        let attributedText = NSMutableAttributedString(string: Text.linkPrefix.localized(), attributes: boldAttributes)
        attributedText.append(NSAttributedString(string: link, attributes: normalAttributes))
        titleLabel.numberOfLines = 0
        titleLabel.attributedText = attributedText
        addSubview(titleLabel)
        let passwordAttributedText = NSMutableAttributedString(string: Text.keyPrefix.localized(), attributes: boldAttributes)
        passwordAttributedText.append(NSAttributedString(string: key, attributes: normalAttributes))
        passwordLabel.numberOfLines = 0
        passwordLabel.attributedText = passwordAttributedText
        addSubview(passwordLabel)
        
        // Configurar label de status
        statusLabel.isHidden = true
        statusLabel.textColor = .black
        statusLabel.font = UIFont.systemFont(ofSize: 20)
        statusLabel.textAlignment = .center
        addSubview(statusLabel)
        
        // Configurar indicador de loading
        addSubview(loadingIndicator)
        
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
            make.top.equalTo(passwordLabel.snp.bottom).offset(8)
            make.height.equalTo(50)
        }
        
        statusLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(buttonStackView.snp.bottom).offset(8)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
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
        let appPath = "https://apps.apple.com/sa/app/sg-secret-gallery-vault/id1479873340"
        UIPasteboard.general.string = """
        \(Text.sharedContentIntro.localized())
        \(Text.sharedContentStep1.localized())\(appPath)
        \(Text.sharedContentStep2.localized())\(link)
        \(Text.sharedContentStep3.localized())\(key)
        """
        delegate?.copyLink()
    }
    
    @objc private func eyeButtonTapped() {
        delegate?.showDetails(withTitle: "\(link)@@\(key)")
    }
    
    @objc private func trashButtonTapped() {
        delegate?.removeCell(withTitle: "\(link)@@\(key)")
    }
    
    // Função para remover o link do Defaults
    private func removeLinkFromDefaults(title: String) {
        var updatedCellTitles = Defaults.getStringArray(.secretLinks) ?? []
        if let index = updatedCellTitles.firstIndex(of: title) {
            updatedCellTitles.remove(at: index)
            Defaults.setStringArray(.secretLinks, updatedCellTitles)
        }
    }
    
    // Função para animar a remoção da célula
    private func animateRemoval() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
        }
    }
}
