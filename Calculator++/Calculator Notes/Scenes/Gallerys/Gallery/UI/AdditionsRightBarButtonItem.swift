//
//  GalleryBarButtonItem.swift
//  Calculator Notes
//
//  Created by Joao Victor Flores da Costa on 04/06/43.
//

import UIKit

protocol AdditionsRightBarButtonItemDelegate: AnyObject {
    func addPhotoButtonTapped()
    func addFolderButtonTapped()
}

class AdditionsRightBarButtonItem: UIBarButtonItem {
    weak var delegate: AdditionsRightBarButtonItemDelegate?
    
    var addPhotoButton = UIButton()
    var addFolderButton = UIButton()
    
    init(delegate: AdditionsRightBarButtonItemDelegate? = nil) {
        super.init()
        self.delegate = delegate
        addPhotoButton = createAddPhotoButton()
        addFolderButton = createAddFolderButton()
        
        let stackItems = createStackItems(buttons: [addFolderButton, addPhotoButton])
        let stackView = createStackView(arrangedSubviews: stackItems)
        let customView = createCustomView(with: stackView)
        self.customView = customView
    }

    private func createAddPhotoButton() -> UIButton {
        let addPhotoButton = UIButton()
        if #available(iOS 13.0, *) {
            addPhotoButton.setImage(UIImage(systemName: "plus"), for: .normal)
        } else {
            addPhotoButton.setTitle("Add", for: .normal)
        }
        addPhotoButton.addTarget(self, action: #selector(addPhotoButtonTapped), for: .touchUpInside)
        addPhotoButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        return addPhotoButton
    }

    private func createAddFolderButton() -> UIButton {
        let addFolderButton = UIButton()
        if #available(iOS 13.0, *) {
            addFolderButton.setImage(UIImage(systemName: "folder.badge.plus"), for: .normal)
        } else {
            addFolderButton.setTitle("Folder", for: .normal)
        }
        addFolderButton.addTarget(self, action: #selector(addFolderButtonTapped), for: .touchUpInside)
        addFolderButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        return addFolderButton
    }

    private func createStackItems(buttons: [UIButton]) -> [UIView] {
        return buttons
    }

    private func createStackView(arrangedSubviews: [UIView]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
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

    // Actions dos botões
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
