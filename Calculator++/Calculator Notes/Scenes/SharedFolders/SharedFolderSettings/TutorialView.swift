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
        titleLabel.text = Text.tutorialTitle.localized()
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = Text.tutorialDescription.localized()
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        
        let howToLabel = UILabel()
        howToLabel.text = Text.tutorialHowTo.localized()
        howToLabel.font = UIFont.boldSystemFont(ofSize: 20)
        howToLabel.textAlignment = .center
        
        let stepsLabel = UILabel()
        stepsLabel.text = Text.tutorialSteps.localized()
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
