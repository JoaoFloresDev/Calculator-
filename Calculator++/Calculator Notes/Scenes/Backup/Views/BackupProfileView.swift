import FirebaseAuth
import UIKit
import SnapKit

protocol BackupLoginEvent: AnyObject {
    func refreshBackupLoginStatus()
}

class BackupProfileView: UIView {
    weak var delegate: BackupLoginEvent?
    
    // Container view para os componentes
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    // View que agrupa a foto e o nome
    private let infoView: UIView = {
        let view = UIView()
        return view
    }()
    
    // Componentes da célula
    private let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 25 // Arredonda as bordas da imagem
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.numberOfLines = 1
        return label
    }()
    
    lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        let title = "Logout"
        let attributedTitle = NSAttributedString(string: title, attributes: [
            .foregroundColor: UIColor.systemBlue,
            .underlineStyle: NSUnderlineStyle.styleSingle.rawValue
        ])
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        return button
    }()
    
    init(delegate: BackupLoginEvent) {
        self.delegate = delegate
        super.init(frame: .zero)
        self.setupView()
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Método para configurar a view
    private func setupView() {
        addSubview(containerView)
        containerView.addSubview(infoView)
        infoView.addSubview(photoImageView)
        infoView.addSubview(nameLabel)
        containerView.addSubview(logoutButton)
    }
    
    // Método para configurar as constraints usando SnapKit
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview().inset(16)
        }
        
        infoView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.centerX.equalToSuperview()
        }
        
        photoImageView.snp.makeConstraints { make in
            make.leading.equalTo(infoView)
            make.width.height.equalTo(50)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(photoImageView.snp.trailing).offset(16)
            make.trailing.equalTo(infoView)
            make.centerY.equalTo(photoImageView)
        }
        
        logoutButton.snp.makeConstraints { make in
            make.top.equalTo(infoView.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(16)
        }
    }
    
    func configure(name: String?) {
        nameLabel.text = name
        photoImageView.image = UIImage(named: "profile")
    }
    
    @objc
    private func logoutButtonTapped() {
        do {
            try Auth.auth().signOut()
            Defaults.setBool(.iCloudEnabled, false)
            delegate?.refreshBackupLoginStatus()
        } catch {
            print("deu erro")
        }
    }
}
