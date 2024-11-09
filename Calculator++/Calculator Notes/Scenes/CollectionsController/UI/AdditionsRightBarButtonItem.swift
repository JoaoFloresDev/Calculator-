//
//  GalleryBarButtonItem.swift
//  Calculator Notes
//
//  Created by Joao Victor Flores da Costa on 04/06/43.
//

import UIKit
import FirebaseAuth

protocol AdditionsRightBarButtonItemDelegate: AnyObject {
    func addPhotoButtonTapped()
    func addFolderButtonTapped()
    func cloudButtonTapped()
}

class AdditionsRightBarButtonItem: UIBarButtonItem {
    weak var delegate: AdditionsRightBarButtonItemDelegate?
    
    var addPhotoButton = UIButton()
    var addFolderButton = UIButton()
    var cloudButton = UIButton()
    
    init(delegate: AdditionsRightBarButtonItemDelegate? = nil) {
        super.init()
        self.delegate = delegate
        cloudButton = createcloudButton()
        addPhotoButton = createAddPhotoButton()
        addFolderButton = createAddFolderButton()
        
        let stackItems = createStackItems(buttons: [cloudButton, addFolderButton, addPhotoButton])
        let stackView = createStackView(arrangedSubviews: stackItems)
        let customView = createCustomView(with: stackView)
        self.customView = customView
    }

    private func createAddPhotoButton() -> UIButton {
        let addPhotoButton = UIButton()
        addPhotoButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addPhotoButton.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
        addPhotoButton.addTarget(self, action: #selector(addPhotoButtonTapped), for: .touchUpInside)
//        addPhotoButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 0)
        return addPhotoButton
    }

    private func createcloudButton() -> UIButton {
        let cloudButton = UIButton()
        if let cloudImage = UIImage(systemName: "exclamationmark.icloud")?.withRenderingMode(.alwaysTemplate) {
            cloudButton.setImage(cloudImage, for: .normal)
        }
        cloudButton.tintColor = .systemGray
        cloudButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)

        if isUserLoggedIn() {
            if let cloudImage = UIImage(systemName: "icloud.fill")?.withRenderingMode(.alwaysTemplate) {
                cloudButton.setImage(cloudImage, for: .normal)
            }
            cloudButton.tintColor = .systemBlue
        }

        cloudButton.addTarget(self, action: #selector(cloudButtonTapped), for: .touchUpInside)
        cloudButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        return cloudButton
    }

    private func createAddFolderButton() -> UIButton {
        let addFolderButton = UIButton()
        addFolderButton.setImage(UIImage(systemName: "folder.badge.plus"), for: .normal)
        addFolderButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        addFolderButton.addTarget(self, action: #selector(addFolderButtonTapped), for: .touchUpInside)
        addFolderButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        return addFolderButton
    }

    
    func isUserLoggedIn() -> Bool {
        return Auth.auth().currentUser != nil && Auth.auth().currentUser?.email != nil
    }

    private func createStackItems(buttons: [UIButton]) -> [UIView] {
        return buttons
    }

    private func createStackView(arrangedSubviews: [UIView]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 12
        return stackView
    }

    private func createCustomView(with stackView: UIStackView) -> UIView {
        let customView = UIView()
        customView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: customView.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: customView.trailingAnchor, constant: -2).isActive = true
        stackView.topAnchor.constraint(equalTo: customView.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: customView.bottomAnchor).isActive = true
        return customView
    }
    
    @objc func cloudButtonTapped() {
        delegate?.cloudButtonTapped()
    }
    
    @objc func addPhotoButtonTapped() {
        delegate?.addPhotoButtonTapped()
    }

    @objc func addFolderButtonTapped() {
        delegate?.addFolderButtonTapped()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
