import UIKit
import SnapKit

protocol BackupModalViewControllerDelegate {
    func restoreBackupTapped()
    func enableBackupToggled(status: Bool)
}
class BackupModalViewController: UIViewController {
    var delegate: BackupModalViewControllerDelegate?
    
    lazy var modalTitleView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        let titleLabel = UILabel()
        titleLabel.text = Text.backupSettings.localized()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.textColor = .black
        
        view.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        return view
    }()
    
    lazy var switchControl: UISwitch = {
        let switchControl = UISwitch()
        switchControl.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        return switchControl
    }()
    
    lazy var backupStatus: UIView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        
        let leftLabel = UILabel()
        leftLabel.text = Text.backupStatus.localized()
        leftLabel.font = UIFont.boldSystemFont(ofSize: 17)
        
        stackView.addArrangedSubview(leftLabel)
        stackView.addArrangedSubview(switchControl)
        
        let backupStatusView = UIView()
        backupStatusView.backgroundColor = .systemGray5
        backupStatusView.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview().inset(8)
            make.leading.equalToSuperview().inset(16)
        }
        
        backupStatusView.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        
        return backupStatusView
    }()

    lazy var restoreBackup: UIView = {
        let label = UILabel()
        label.text = "Restaurar backup"
        label.font = UIFont.boldSystemFont(ofSize: 17)
        let restoreBackupView = UIView()
        restoreBackupView.backgroundColor = .systemGray5
        restoreBackupView.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview().inset(8)
            make.leading.equalToSuperview().inset(16)
        }
        
        restoreBackupView.snp.makeConstraints { make in
            make.height.equalTo(50) // Definindo a altura desejada
        }
        
        // Adicionar o gesture recognizer para tornar a view clicável
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.restoreBackupTapped))
        restoreBackupView.addGestureRecognizer(tapGesture)
        
        return restoreBackupView
    }()
    
    lazy var viewBackup: UIView = {
        let label = UILabel()
        label.text = Text.seeMyBackup.localized()
        label.font = UIFont.boldSystemFont(ofSize: 17)
        let viewBackupView = UIView()
        viewBackupView.backgroundColor = .systemGray5
        viewBackupView.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview().inset(8)
            make.leading.equalToSuperview().inset(16)
        }
        
        viewBackupView.snp.makeConstraints { make in
            make.height.equalTo(50) // Definindo a altura desejada
        }
        
        // Adicionar o gesture recognizer para tornar a view clicável
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.viewBackupTapped))
        viewBackupView.addGestureRecognizer(tapGesture)
        
        return viewBackupView
    }()

    @objc func viewBackupTapped() {
        let navigation = UINavigationController(rootViewController: CloudKitItemsViewController())
        present(navigation, animated: true)
    }
    
    @objc func restoreBackupTapped() {
        self.dismiss(animated: false) {
            self.delegate?.restoreBackupTapped()
        }
    }

    lazy var contentStackView: UIStackView = {
        let spacer = UIView()
        let stackView = UIStackView(arrangedSubviews: [backupStatus, restoreBackup, viewBackup, spacer])
        stackView.axis = .vertical
        stackView.spacing = 1
        return stackView
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    let maxDimmedAlpha: CGFloat = 0.6
    lazy var dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = maxDimmedAlpha
        return view
    }()
    
    // Constants
    let defaultHeight: CGFloat = 300
    var currentContainerHeight: CGFloat = 300
    
    // Dynamic container constraint
    var containerViewHeightConstraint: Constraint?
    var containerViewBottomConstraint: Constraint?
    
    init(backupIsActivated: Bool, delegate: BackupModalViewControllerDelegate) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
        switchControl.isOn = Defaults.getBool(.iCloudEnabled)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        
        // Adiciona um gesto de tap para fechar o modal
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleCloseAction))
        dimmedView.addGestureRecognizer(tapGesture)
        
        // Adiciona um gesto de swipe para baixo
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipeDown))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
    }
    
    @objc func handleCloseAction() {
        animateDismissView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animatePresentContainer()
    }
    
    func setupView() {
        view.backgroundColor = .clear
    }
    
    func setupConstraints() {
        // Add subviews
        view.addSubview(dimmedView)
        view.addSubview(containerView)
        
        containerView.addSubview(modalTitleView)
        
        modalTitleView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().offset(8)
            make.height.equalTo(44)  // Altura da barra de título
        }
        
        dimmedView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            containerViewBottomConstraint = make.bottom.equalTo(view.snp.bottom).offset(defaultHeight).constraint
            containerViewHeightConstraint = make.height.equalTo(defaultHeight).constraint
        }
        
        containerView.addSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.top.equalTo(modalTitleView.snp.bottom).offset(8)
            make.bottom.equalTo(containerView.snp.bottom).offset(-20)
            make.leading.trailing.equalTo(containerView)
        }
        
        // Activate constraints
        containerViewHeightConstraint?.activate()
        containerViewBottomConstraint?.activate()
    }
    
    @objc func handleSwipeDown(_ gesture: UISwipeGestureRecognizer) {
        animateDismissView()
    }
    
    func animateContainerHeight(_ height: CGFloat) {
        UIView.animate(withDuration: 0.4) {
            self.containerViewHeightConstraint?.update(offset: height)
            self.view.layoutIfNeeded()
        }
        currentContainerHeight = height
    }
    
    // MARK: Present and dismiss animation
    func animatePresentContainer() {
        // update bottom constraint in animation block
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.update(offset: 0)
            // call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
    }
    
    func animateDismissView() {
        dimmedView.alpha = maxDimmedAlpha
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false)
        }
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.update(offset: self.defaultHeight)
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func switchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            CloudKitImageService.enableICloudSync { success in
                if success {
                    self.delegate?.enableBackupToggled(status: true)
                } else {
                    DispatchQueue.main.async {
                        sender.isOn = false
                    }
                    Alerts.showGoToSettingsToEnbaleCloud(controller: self) { _ in
                        CloudKitImageService.redirectToICloudSettings()
                    }
                }
            }
        } else {
            Defaults.setBool(.iCloudEnabled, false)
            delegate?.enableBackupToggled(status: false)
        }
    }
}
