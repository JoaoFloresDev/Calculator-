import UIKit
import SnapKit

class CustomLabelButtonView: UIView {
    
    private let leftLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .gray
        label.textAlignment = .right
        return label
    }()
    
    init(leftText: String, rightText: String = "", backgroundColor: UIColor) {
        super.init(frame: .zero)
        self.leftLabel.text = leftText
        self.label.text = rightText
        self.backgroundColor = backgroundColor
        self.setupView()
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.addSubview(leftLabel)
        self.addSubview(label)
    }
    
    private func setupConstraints() {
        leftLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.leading.equalToSuperview().inset(16)
        }
        
        label.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview().inset(8)
            make.leading.equalTo(leftLabel.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(16)
        }
        
        self.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
    }
    
    func setTapAction(target: Any?, action: Selector) {
        let tapGesture = UITapGestureRecognizer(target: target, action: action)
        self.addGestureRecognizer(tapGesture)
    }
}
