//
//  FakeHomeViewController.swift
//  Calculator Notes
//
//  Created by João Flores on 11/10/24.
//

import UIKit
import SnapKit

protocol FakeHomeViewControllerProtocol: AnyObject {
    
}

class FakeHomeViewController: UIViewController, FakeHomeViewControllerProtocol {
    // MARK: - UI Components
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Text.emptyArquives.localized()
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 16.0)
        return label
    }()

    private lazy var squareImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "emptyGalleryIcon")
        return imageView
    }()

    // MARK: - Initialization
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

private extension FakeHomeViewController {
    // MARK: - View Configuration
    func setupUI() {
        view.backgroundColor = .white
        setupNavigationBar()
        setupViewHierarchy()
        setupConstraints()
    }

    func setupNavigationBar() {
        title = Text.arquives.localized()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )
    }

    func setupViewHierarchy() {
        view.addSubview(titleLabel)
        view.addSubview(squareImageView)
    }

    func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(squareImageView.snp.bottom)
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(16)
            make.trailing.lessThanOrEqualToSuperview().offset(-16)
        }
        
        squareImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(240)
        }
    }
}

// MARK: - Actions
private extension FakeHomeViewController {
    @objc func addButtonTapped() {
        // Handle the action for the + button here
    }
}
