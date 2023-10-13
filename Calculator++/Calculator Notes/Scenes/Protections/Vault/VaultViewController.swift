//
//  VaultViewController.swift
//  Calculator Notes
//
//  Created by Joao Victor Flores da Costa on 09/09/23.
//  Copyright © 2023 MakeSchool. All rights reserved.
//

import Foundation
import LocalAuthentication
import UIKit
import SnapKit
import FirebaseFirestore

enum VaultMode {
    case verify
    case create
    case confirmation
}

class VaultViewController: UIViewController {

    private var displayLabel = UILabel()
    private var displayContainer = UIView()
    private var displayShadow = ShadowRoundedView()
    private var titleLabel = UILabel()
    private var subtitleLabel = UILabel()
    private var recoverEmail = UILabel()
    private var numberButtons: [UIView] = []
    private var faceidImageView = UILabel()
    private var vaultMode: VaultMode
    private var inputSequenceConfirmation: String = ""
    
    private var inputSequence: String = "" {
        didSet {
            let attributedString = NSMutableAttributedString(string: inputSequence)
            attributedString.addAttribute(NSAttributedString.Key.kern, value: CGFloat(15.0), range: NSRange(location: 0, length: attributedString.length))
            DispatchQueue.main.async {
                self.displayLabel.attributedText = attributedString
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    init(mode: VaultMode) {
        self.vaultMode = mode
        if vaultMode != .verify {
            subtitleLabel.text = Text.createPassword.localized()
            faceidImageView.text = Text.cancel.localized()
        } else {
            subtitleLabel.text = Text.insertPassword.localized()
            faceidImageView.text = Text.recover.localized()
            if Defaults.getBool(.recoveryStatus) {
                faceidImageView.isHidden = true
            }
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        
        self.view.backgroundColor = UIColor(hex: "#23272C")

        // Título
        titleLabel.text = "SG"
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        
        // Subtítulo
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textColor = .white
        subtitleLabel.textAlignment = .center
        subtitleLabel.font = UIFont.boldSystemFont(ofSize: 16)

        recoverEmail.text = "Esqueceu sua senha?"
        recoverEmail.font = UIFont.boldSystemFont(ofSize: 24)
        recoverEmail.textColor = .white
        
        // Agrupar título e subtítulo
        let titleStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        titleStack.axis = .vertical
        titleStack.spacing = 8
        self.view.addSubview(titleStack)
        
        self.view.addSubview(displayContainer)

        // Adicionar a displayLabel à displayContainer
        displayContainer.addSubview(displayShadow)
        displayShadow.addSubview(displayLabel)
        
        // Configurar displayLabel
        displayLabel.textAlignment = .left
        displayLabel.font = UIFont.systemFont(ofSize: 32)
        displayLabel.text = ""
        displayLabel.textColor = .white
        
        // Constraints para displayContainer
        displayContainer.snp.makeConstraints { make in
            make.top.equalTo(titleStack.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(32)
            make.right.equalToSuperview().offset(-32)
        }
        
        displayShadow.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(110)
        }
        
        // Constraints para displayLabel
        displayLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
        }

        // Botão Clear
        let clearButton = createButton(title: Text.AC.localized())
        let clearRoundedView = RoundedShadowView()
        clearRoundedView.addSubview(clearButton)
        setupButtonConstraints(button: clearButton, in: clearRoundedView)
        
        // Botão 9
        let nineButton = createButton(title: "0")
        let nineRoundedView = RoundedShadowView()
        nineRoundedView.addSubview(nineButton)
        setupButtonConstraints(button: nineButton, in: nineRoundedView)
        
        // Botão Enter
        let enterButton = createButton(title: Text.Enter.localized())
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
        allNumberStack.spacing = 24

        self.view.addSubview(allNumberStack)

        // Constraints
        titleStack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
            make.left.equalToSuperview().offset(36)
            make.right.equalToSuperview().offset(-36)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.height.equalTo(40)
        }

        allNumberStack.snp.makeConstraints { make in
            make.top.equalTo(displayContainer.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(36)
            make.right.equalToSuperview().offset(-36)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-42)
        }
        
        self.view.addSubview(faceidImageView)
        faceidImageView.alpha = 0.8
        faceidImageView.textColor = .systemBlue
        faceidImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
        }
        
        // Tornar faceidImageView "tapável"
        faceidImageView.isUserInteractionEnabled = true

        // Criar e adicionar UITapGestureRecognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(faceIDTapped))
        faceidImageView.addGestureRecognizer(tapGesture)

        self.view.addSubview(recoverEmail)
        recoverEmail.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-4)
            make.left.equalToSuperview().offset(36)
        }
        recoverEmail.isUserInteractionEnabled = true
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(recoverEmailTapped))
        recoverEmail.addGestureRecognizer(tapGesture2)
    }
    
    @objc private func recoverEmailTapped() {
        self.dismissable = true
        self.secondDismissable = true
        showAlert2()
    }
    
    @objc private func faceIDTapped() {
        if vaultMode == .verify {
            let faceIDManager = FaceIDManager()

            if faceIDManager.isFaceIDAvailable() {
                faceIDManager.requestFaceIDAuthentication { success, error in
                    DispatchQueue.main.async {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let homeViewController = storyboard.instantiateViewController(withIdentifier: "Home")
                        self.present(homeViewController, animated: true)
                    }
                }
            }
        }
    }

    private func createButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.tintColor = .white
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        return button
    }
    
    @objc private func numberButtonPressed(_ sender: UIButton) {
        guard let number = sender.titleLabel?.text else { return }

        if number == Text.AC.localized() {
            inputSequence.removeAll()
        } else if number == Text.Enter.localized() {
            traitOpenGallery()
        } else {
            if inputSequence.count > 6 {
                inputSequence.removeAll()
            } else {
                inputSequence.append(number)
            }
        }
    }
    
    func traitOpenGallery() {
        if vaultMode == .create {
            subtitleLabel.text = "\(Text.insertCreatedPasswordAgain.localized()):\n\(inputSequence)"
            inputSequenceConfirmation = inputSequence
            inputSequence.removeAll()
            vaultMode = .confirmation
        } else if vaultMode ==  .confirmation {
            if inputSequence == inputSequenceConfirmation {
                showAlert()
                Defaults.setString(.password, inputSequence)
                UserDefaultService().setTypeProtection(protectionMode: ProtectionMode.vault)
                Defaults.setBool(.needSavePasswordInCloud, true)
            } else {
                let alert = UIAlertController(title: Text.incorrectPassword.localized(),
                                              message: Text.tryAgain.localized(),
                                              preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: Text.ok.localized(), style: .default))
                self.dismissable = true
                self.present(alert, animated: true, completion: {
                    self.inputSequence.removeAll()
                })
            }
        } else {
            if inputSequence == Defaults.getString(.password) || inputSequence == Constants.recoverPassword {
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let homeViewController = storyboard.instantiateViewController(withIdentifier: "Home")
                    self.present(homeViewController, animated: true)
                }
            } else {
                let alert = UIAlertController(title: Text.incorrectPassword.localized(),
                                              message: Text.tryAgain.localized(),
                                              preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: Text.ok.localized(), style: .default))
                self.dismissable = true
                self.present(alert, animated: true) {
                    self.inputSequence.removeAll()
                }
            }
        }
    }
    
    func showAlert() {
        let refreshAlert = UIAlertController(title: Text.done.localized(), message: Text.calcModeHasBeenActivated.localized(), preferredStyle: UIAlertControllerStyle.alert)

        refreshAlert.addAction(UIAlertAction(title: Text.ok.localized(), style: .default))
        self.dismissable = true
        self.secondDismissable = true
        present(refreshAlert, animated: true, completion: nil)
    }
    
    func showAlert2() {
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        
        // Crie um UIAlertController
        let alertController = UIAlertController(title: Text.emailPopupTitle.localized(), message: Text.emailmessage.localized(), preferredStyle: .alert)

        // Adicione um botão de ação "Cancelar" com um completion
        let cancelAction = UIAlertAction(title: Text.emailCancelButtonTitle.localized(), style: .cancel) { _ in
            vc.dismiss(animated: false)
        }

        // Adicione um botão de ação "OK" com um completion
        let okAction = UIAlertAction(title: Text.emailOkButtonTitle.localized(), style: .default) { _ in
            let email = Defaults.getString(.recoverEmail)
            guard !email.isEmpty else {
                let alertController = UIAlertController(title: Text.emailNotRegisteredTitle.localized(), message: Text.emailNotRegisteredMessage.localized(), preferredStyle: .alert)

                // Adicione um botão de ação "Cancelar" com um completion
                let cancelAction = UIAlertAction(title: Text.ok.localized(), style: .cancel) { _ in
                    vc.dismiss(animated: false)
                }
                
                alertController.addAction(cancelAction)
                vc.present(alertController, animated: true, completion: nil)
                return
            }
            // Referência ao Firebase Realtime Database
            let db = Firestore.firestore()
            
            // Crie uma referência à coleção "Textos"
            let textosCollection = db.collection("Email")
            
            // Crie um documento com um ID automático
            let novoDocumento = textosCollection.document()
            
            // Defina os dados do documento
            novoDocumento.setData(["conteudo": email]) { error in
                if error != nil {
                    let alertController = UIAlertController(title: Text.errorEmailTitle.localized(), message: Text.errorEmailMessage.localized(), preferredStyle: .alert)

                    // Adicione um botão de ação "Cancelar" com um completion
                    let cancelAction = UIAlertAction(title: Text.ok.localized(), style: .cancel) { _ in
                        vc.dismiss(animated: false)
                    }
                    alertController.addAction(cancelAction)
                    vc.present(alertController, animated: true, completion: nil)
                } else {
                    let alertController = UIAlertController(title: Text.successEmailTitle.localized(), message: Text.successEmailMessage.localized(), preferredStyle: .alert)

                    // Adicione um botão de ação "Cancelar" com um completion
                    let cancelAction = UIAlertAction(title: Text.ok.localized(), style: .cancel) { _ in
                        vc.dismiss(animated: false)
                    }
                    alertController.addAction(cancelAction)
                    vc.present(alertController, animated: true, completion: nil)
                }
            }
        }

        // Adicione os botões ao alerta
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        present(vc, animated: false)
        vc.present(alertController, animated: true, completion: nil)
    }

    var dismissable = false
    var secondDismissable = false
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        if dismissable {
            super.dismiss(animated: true) {
                if self.secondDismissable {
                    super.dismiss(animated: true) {
                        self.secondDismissable = false
                    }
                }
                self.dismissable = false
            }
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
