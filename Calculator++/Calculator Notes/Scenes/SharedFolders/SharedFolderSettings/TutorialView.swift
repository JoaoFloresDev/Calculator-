import UIKit
import SnapKit

class TutorialView: UIView {
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        let titleLabel = UILabel()
        titleLabel.text = "Compartilhe fotos e vídeos com segurança"
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = """
        Agora você pode criar links compartilháveis com fotos e vídeos de maneira segura. Quem receber o link poderá importar as fotos diretamente no app.
        """
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        
        let howToLabel = UILabel()
        howToLabel.text = "Como usar?"
        howToLabel.font = UIFont.boldSystemFont(ofSize: 20)
        howToLabel.textAlignment = .center
        
        let stepsLabel = UILabel()
        stepsLabel.text = """
        1. Selecione as fotos na sua galeria.
        
        2. Toque em compartilhar e escolha 'Compartilhar com senha'.
        
        3. Envie o link e a senha para quem deseja compartilhar.
        """
        stepsLabel.font = UIFont.systemFont(ofSize: 18)
        stepsLabel.textAlignment = .left
        stepsLabel.numberOfLines = 0
        
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(howToLabel)
        addSubview(stepsLabel)
        
        // Constraints
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        howToLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        stepsLabel.snp.makeConstraints { make in
            make.top.equalTo(howToLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
}
