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
    case createFakePass
    case confirmationFakePass
}

import UIKit
import SnapKit

class SpacerView: UIView {
    
    init(height: CGFloat? = nil, width: CGFloat? = nil) {
        super.init(frame: .zero)
        
        if let height = height {
            self.snp.makeConstraints { make in
                make.height.equalTo(height)
            }
        }
        
        if let width = width {
            self.snp.makeConstraints { make in
                make.width.equalTo(width)
            }
        }
        
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class VaultViewController: UIViewController {

    private var displayLabel = UILabel()
    private var displayContainer = UIView()
    private var displayShadow = ShadowRoundedView()
    private var titleLabel = UILabel()
    private var subtitleLabel = UILabel()
    private var numberButtons: [UIView] = []
    private var faceidImageView = UILabel()
    private var vaultMode: VaultMode
    private var inputSequenceConfirmation: String = ""
    private var containerView = UIView()
    
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
    
    var viewHeight = 630
    
    init(mode: VaultMode) {
        self.vaultMode = mode
        if vaultMode != .verify {
            subtitleLabel.text = Text.createPassword.localized()
            faceidImageView.text = Text.cancel.localized()
            faceidImageView.isHidden = true
        } else {
            subtitleLabel.isHidden = true
            titleLabel.isHidden = true
            viewHeight = 600
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
        
        let titleStack = UIStackView(arrangedSubviews:[titleLabel, subtitleLabel])
        
        titleStack.axis = .vertical
        titleStack.spacing = 8
        
        self.view.addSubview(containerView)
        containerView.addSubview(titleStack)
        containerView.addSubview(displayContainer)
        displayContainer.addSubview(displayShadow)
        displayShadow.addSubview(displayLabel)
        
        displayLabel.textAlignment = .left
        displayLabel.font = UIFont.systemFont(ofSize: 32)
        displayLabel.text = ""
        displayLabel.textColor = .white
        
        containerView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(350)
            make.height.equalTo(viewHeight)
        }
        
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
        
        displayLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
        }

        let clearButton = createButton(title: Text.AC.localized())
        let clearRoundedView = RoundedShadowView()
        clearRoundedView.addSubview(clearButton)
        setupButtonConstraints(button: clearButton, in: clearRoundedView)
        
        let nineButton = createButton(title: "0")
        let nineRoundedView = RoundedShadowView()
        nineRoundedView.addSubview(nineButton)
        setupButtonConstraints(button: nineButton, in: nineRoundedView)
        
        let enterButton = createButton(title: "OK")
        let enterRoundedView = RoundedShadowView()
        enterRoundedView.addSubview(enterButton)
        setupButtonConstraints(button: enterButton, in: enterRoundedView)
        
        let additionalStack = UIStackView(arrangedSubviews: [clearRoundedView, nineRoundedView, enterRoundedView])
        additionalStack.axis = .horizontal
        additionalStack.distribution = .fillEqually
        additionalStack.spacing = 32
        
        for i in 1..<10 {
            let button = createButton(title: "\(i)")
            let roundedView = RoundedShadowView()
            roundedView.addSubview(button)
            roundedView.clipsToBounds = true
            
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
            stack.spacing = 32
            return stack
        }

        let allNumberStack = UIStackView(arrangedSubviews: numberStacks +  [additionalStack])
        allNumberStack.axis = .vertical
        allNumberStack.distribution = .fillEqually
        allNumberStack.spacing = 20

        containerView.addSubview(allNumberStack)

        // Constraints
        titleStack.snp.makeConstraints { make in
            make.top.equalToSuperview()
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
            make.bottom.equalToSuperview().offset(-32)
        }
        
        self.view.addSubview(faceidImageView)
        faceidImageView.alpha = 0.8
        faceidImageView.textColor = .systemBlue
        faceidImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
        }
        
        faceidImageView.isUserInteractionEnabled = true

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(faceIDTapped))
        faceidImageView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func faceIDTapped() {
        if vaultMode == .verify {
            let faceIDManager = FaceIDManager()

            if faceIDManager.isFaceIDAvailable() {
                faceIDManager.requestFaceIDAuthentication { success, error in
                    if success {
                        DispatchQueue.main.async {
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let homeViewController = storyboard.instantiateViewController(withIdentifier: "Home")
                            self.present(homeViewController, animated: true)
                        }
                    }
                }
            }
        } else {
            super.dismiss(animated: true)
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
        } else if number == "OK" {
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
                Defaults.setString(.password, inputSequence)
                UserDefaultService().setTypeProtection(protectionMode: ProtectionMode.vault)
                super.dismiss(animated: true)
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
