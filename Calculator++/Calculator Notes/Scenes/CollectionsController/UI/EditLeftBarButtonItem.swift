//
//  GalleryBarButtonItem.swift
//  Calculator Notes
//
//  Created by Joao Victor Flores da Costa on 010/010/103.
//

import UIKit

protocol EditLeftBarButtonItemDelegate: AnyObject {
    func backButtonTapped()
    func selectImagesButtonTapped()
    func shareImageButtonTapped()
    func deleteButtonTapped()
}

class EditLeftBarButtonItem: UIBarButtonItem {
    weak var delegate: EditLeftBarButtonItemDelegate?
    
    var backButton = UIButton()
    var selectImagesButton = UIButton()
    var shareImageButton = UIButton()
    var deleteButton = UIButton()
    
    var isEditMode = false {
        didSet {
            setEditing(isEditMode)
        }
    }
    
    init(basePath: String, delegate: EditLeftBarButtonItemDelegate? = nil) {
        super.init()
        self.delegate = delegate
        backButton = createBackButton()
        selectImagesButton = createSelectImagesButton()
        shareImageButton = createShareImageButton()
        deleteButton = createDeleteButton()
        
        let stackItems = createStackItems(basePath: basePath, buttons: [backButton, selectImagesButton, shareImageButton, deleteButton])
        let stackView = createStackView(arrangedSubviews: stackItems)
        stackView.spacing = 12
        let customView = createCustomView(with: stackView)
        setupButtonStates(deleteButton: deleteButton, shareImageButton: shareImageButton)
        self.customView = customView
    }

    private func createBackButton() -> UIButton {
        let backButton = UIButton()
        backButton.setImage(UIImage(named: Img.leftarrow.name()), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        backButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 10)
        return backButton
    }

    private func createSelectImagesButton() -> UIButton {
        let selectImagesButton = UIButton()
        selectImagesButton.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        selectImagesButton.addTarget(self, action: #selector(selectImagesButtonTapped), for: .touchUpInside)
        selectImagesButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        selectImagesButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        return selectImagesButton
    }

    private func createShareImageButton() -> UIButton {
        let shareImageButton = UIButton()
        shareImageButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        shareImageButton.addTarget(self, action: #selector(shareImageButtonTapped), for: .touchUpInside)
        shareImageButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        shareImageButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        return shareImageButton
    }

    private func createDeleteButton() -> UIButton {
        let deleteButton = UIButton()
        let image = UIImage(systemName: "trash")
        deleteButton.setImage(image, for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        deleteButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        deleteButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        return deleteButton
    }

    private func createStackItems(basePath: String, buttons: [UIButton]) -> [UIView] {
        return basePath == "@" ? Array(buttons[1...]) : buttons
    }

    private func createStackView(arrangedSubviews: [UIView]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 4
        return stackView
    }

    private func createCustomView(with stackView: UIStackView) -> UIView {
        let customView = UIView()
        customView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: customView.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: customView.trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: customView.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: customView.bottomAnchor).isActive = true
        return customView
    }

    private func setupButtonStates(deleteButton: UIButton, shareImageButton: UIButton) {
        deleteButton.isEnabled = false
        deleteButton.tintColor = .darkGray
        deleteButton.isHidden = true
        
        shareImageButton.isEnabled = false
        shareImageButton.tintColor = .darkGray
        shareImageButton.isHidden = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setEditing(_ editing: Bool) {
        deleteButton.isEnabled = editing
        deleteButton.tintColor = editing ? .systemBlue : .darkGray
        deleteButton.isHidden = !editing
        
        shareImageButton.isEnabled = editing
        shareImageButton.tintColor = editing ? .systemBlue : .darkGray
        shareImageButton.isHidden = !editing
    }
    
    // Actions dos botões
    @objc func backButtonTapped() {
        delegate?.backButtonTapped()
    }

    @objc func selectImagesButtonTapped() {
        delegate?.selectImagesButtonTapped()
    }

    @objc func shareImageButtonTapped() {
        delegate?.shareImageButtonTapped()
    }

    @objc func deleteButtonTapped() {
        delegate?.deleteButtonTapped()
    }
}
