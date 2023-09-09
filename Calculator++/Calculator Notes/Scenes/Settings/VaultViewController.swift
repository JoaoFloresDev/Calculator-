//
//  VaultViewController.swift
//  Calculator Notes
//
//  Created by Joao Victor Flores da Costa on 09/09/23.
//  Copyright © 2023 MakeSchool. All rights reserved.
//

import Foundation

import UIKit
import SnapKit

class RoundedShadowView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0.2
        self.backgroundColor = UIColor(hex: "#383B3F", alpha: 1)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.width / 2
        self.layer.masksToBounds = false // Não corta a sombra
    }
}

class ShadowRoundedView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0.2
        self.layer.cornerRadius = 12
        self.backgroundColor = UIColor(hex: "#383B3F", alpha: 1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.masksToBounds = false // Não corta a sombra
    }
}

enum VaultMode {
    case verify
    case create
}

class VaultViewController: UIViewController {

    private var displayLabel = UILabel()
    private var displayContainer = ShadowRoundedView()
    private var titleLabel = UILabel()
    private var subtitleLabel = UILabel()
    private var numberButtons: [UIView] = []
    private var faceidImageView = UIImageView()
    private var vaultMode: VaultMode
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    init(mode: VaultMode) {
        self.vaultMode = mode
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        
        self.view.backgroundColor = UIColor(hex: "#23272C")

        // Título
        titleLabel.text = "Calc+"
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 32)
        
        // Subtítulo
        subtitleLabel.text = "Digite sua senha e confirme com enter"
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textColor = .white
        subtitleLabel.textAlignment = .center
        subtitleLabel.font = UIFont.systemFont(ofSize: 20)

        // Agrupar título e subtítulo
        let titleStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        titleStack.axis = .vertical
        titleStack.spacing = 16
        self.view.addSubview(titleStack)
        
        self.view.addSubview(displayContainer)

        // Adicionar a displayLabel à displayContainer
        displayContainer.addSubview(displayLabel)
        
        // Configurar displayLabel
        displayLabel.textAlignment = .left
        displayLabel.font = UIFont.systemFont(ofSize: 36)
        displayLabel.text = "0"
        displayLabel.textColor = .white

        // Adicionando espaçamento entre as letras
        let attributedString = NSMutableAttributedString(string: "0")
        attributedString.addAttribute(NSAttributedString.Key.kern, value: CGFloat(5.0), range: NSRange(location: 0, length: attributedString.length - 1))
        displayLabel.attributedText = attributedString
        
        // Constraints para displayContainer
        displayContainer.snp.makeConstraints { make in
            make.top.equalTo(titleStack.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(32)
            make.right.equalToSuperview().offset(-32)
        }
        
        // Constraints para displayLabel
        displayLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
        }

        // Botão Clear
        let clearButton = createButton(title: "Clear")
        let clearRoundedView = RoundedShadowView()
        clearRoundedView.addSubview(clearButton)
        setupButtonConstraints(button: clearButton, in: clearRoundedView)
        
        // Botão 9
        let nineButton = createButton(title: "0")
        let nineRoundedView = RoundedShadowView()
        nineRoundedView.addSubview(nineButton)
        setupButtonConstraints(button: nineButton, in: nineRoundedView)
        
        // Botão Enter
        let enterButton = createButton(title: "Enter")
        let enterRoundedView = RoundedShadowView()
        enterRoundedView.addSubview(enterButton)
        setupButtonConstraints(button: enterButton, in: enterRoundedView)
        
        // Nova StackView com botões Clear, 9, e Enter
        let additionalStack = UIStackView(arrangedSubviews: [clearRoundedView, nineRoundedView, enterRoundedView])
        additionalStack.axis = .horizontal
        additionalStack.distribution = .fillEqually
        additionalStack.spacing = 40
        
        for i in 1..<10 {
            let button = createButton(title: "\(i)")
            let roundedView = RoundedShadowView()
            roundedView.addSubview(button)
            roundedView.clipsToBounds = true // Isso vai cortar o botão para ajustar à view circular
            
            roundedView.snp.makeConstraints { make in
                make.width.equalTo(roundedView.snp.height)
            }

            button.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(8)
            }
            button.addTarget(self, action: #selector(numberButtonPressed(_:)), for: .touchUpInside)
            numberButtons.append(roundedView)
        }

        let numberStacks = stride(from: 0, to: numberButtons.count, by: 3).map { index -> UIStackView in
            let stack = UIStackView(arrangedSubviews: Array(numberButtons[index..<min(index+3, numberButtons.count)]))
            stack.axis = .horizontal
            stack.distribution = .fillEqually
            stack.spacing = 40
            return stack
        }

        let allNumberStack = UIStackView(arrangedSubviews: numberStacks +  [additionalStack])
        allNumberStack.axis = .vertical
        allNumberStack.distribution = .fillEqually
        allNumberStack.spacing = 40

        self.view.addSubview(allNumberStack)

        // Constraints
        titleStack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
            make.left.equalToSuperview().offset(36)
            make.right.equalToSuperview().offset(-36)
        }

        allNumberStack.snp.makeConstraints { make in
            make.top.equalTo(displayContainer.snp.bottom).offset(32)
            make.left.equalToSuperview().offset(36)
            make.right.equalToSuperview().offset(-36)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-64)
        }
        
        self.view.addSubview(faceidImageView)
        faceidImageView.image = UIImage(named: "faceid")
        faceidImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.height.width.equalTo(48)
        }
        
        // Tornar faceidImageView "tapável"
        faceidImageView.isUserInteractionEnabled = true

        // Criar e adicionar UITapGestureRecognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(faceIDTapped))
        faceidImageView.addGestureRecognizer(tapGesture)

    }
    
    @objc private func faceIDTapped() {
        // Coloque aqui o código para autenticação FaceID
        print("FaceID ícone tocado!")
    }


    private func createButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.tintColor = .white
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        return button
    }

    private var inputSequence = ""
    
    @objc private func numberButtonPressed(_ sender: UIButton) {
        guard let number = sender.titleLabel?.text else { return }

        if number == "Clear" {
            inputSequence.removeAll()
            displayLabel.text = inputSequence
        } else {
            inputSequence.append(number)
            
            // Atualizar displayLabel com espaçamento entre as letras
            let attributedString = NSMutableAttributedString(string: inputSequence)
            attributedString.addAttribute(NSAttributedString.Key.kern, value: CGFloat(5.0), range: NSRange(location: 0, length: attributedString.length - 1))
            displayLabel.attributedText = attributedString
        }
    }
    
    private func setupButtonConstraints(button: UIButton, in roundedView: RoundedShadowView) {
        roundedView.snp.makeConstraints { make in
            make.width.equalTo(roundedView.snp.height)
        }
        
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        
        button.addTarget(self, action: #selector(numberButtonPressed(_:)), for: .touchUpInside)
    }
}
