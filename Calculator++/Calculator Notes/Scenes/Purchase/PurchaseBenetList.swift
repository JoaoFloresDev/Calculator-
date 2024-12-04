import Foundation
import UIKit
import SnapKit

class PurchaseBenetList: UIView {
    
    // Elementos da UI
    lazy var stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        // Configuração da stackView
        addSubview(stackView)
        
        // Configuração do StackView
        stackView.axis = .vertical
        
        // Adicionar elementos ao StackView na ordem de prioridade
        stackView.addArrangedSubview(createSpacer(height: 8))
        stackView.addArrangedSubview(
            PurchaseBenefitItem(
                text: Text.backupStatus.localized(),  // Primeiro benefício: backup em nuvem
                systemImageName: "icloud.and.arrow.down.fill")
        )
        
        stackView.addArrangedSubview(createSpacer(height: 8))
        stackView.addArrangedSubview(
            PurchaseBenefitItem(
                text: Text.noAds.localized(),  // Segundo benefício: remoção de anúncios
                imageName: Img.noads.name())
        )
        
        stackView.addArrangedSubview(createSpacer(height: 8))
        stackView.addArrangedSubview(
            PurchaseBenefitItem(
                text: Text.unlimitedStorage.localized(),  // Terceiro benefício: armazenamento ilimitado
                systemImageName: "tray.2.fill")
        )
        
        stackView.addArrangedSubview(createSpacer(height: 8))
        stackView.addArrangedSubview(
            PurchaseBenefitItem(
                text: Text.videoSuport.localized(),  // Quarto benefício: suporte para vídeo
                systemImageName: "video.fill")
        )
        stackView.addArrangedSubview(createSpacer(height: 8))
        
        stackView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    private func createSpacer(height: CGFloat) -> UIView {
        let spacer = UIView()
        spacer.snp.makeConstraints { make in
            make.height.equalTo(height).priority(750)
        }
        return spacer
    }
}

class PurchaseBenefitItem: UIView {
    // Elementos da UI
    private let imageView = UIImageView()
    private let label = UILabel()

    // Inicializador personalizado com dois parâmetros para alternar entre ícone customizado e do sistema
    init(text: String, imageName: String? = nil, systemImageName: String? = nil) {
        super.init(frame: .zero)
        setupView()
        label.text = text
        if let systemImageName = systemImageName {
            imageView.image = UIImage(systemName: systemImageName)
        } else if let imageName = imageName {
            imageView.image = UIImage(named: imageName)
        }
        imageView.tintColor = UIColor(red: 0/255.0, green: 175/255.0, blue: 232/255.0, alpha: 1.0)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        // Configuração da UIImageView
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        
        // Configuração da UILabel
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.numberOfLines = 0
        addSubview(label)
        
        // Configuração das constraints com SnapKit
        imageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        label.snp.makeConstraints { make in
            make.left.equalTo(imageView.snp.right).offset(16)
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        
        self.snp.makeConstraints { make in
            make.height.equalTo(60)
        }
    }
    
    // Métodos para configurar imagem e texto
    func setImage(_ image: UIImage) {
        imageView.image = image
    }
    
    func setText(_ text: String) {
        label.text = text
    }
}
