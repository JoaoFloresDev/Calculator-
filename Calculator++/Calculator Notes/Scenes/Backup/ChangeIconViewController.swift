import UIKit
import CloudKit
import SnapKit
import AVFoundation

class CloudKitItemsViewController: UIViewController {
    private let closeBarButtonTitle = Text.close.localized()
    private let deleteItemTitle = Text.deleteFiles.localized()
    private let deleteActionTitle = Text.delete.localized()
    private let cancelActionTitle = Text.cancel.localized()
    private let navigationTitle = Text.myBackupItens.localized()
    
    private var viewModel = CloudKitImageService()
    lazy var alert = LoadingAlert(in: self)
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let numberOfItemsPerRow: CGFloat = 4
        let spacingBetweenCells: CGFloat = 12

        let totalSpacing = (2 * 12) + ((numberOfItemsPerRow - 1) * spacingBetweenCells) // left + right + in-between items
        let width = (UIScreen.main.bounds.width - totalSpacing) / numberOfItemsPerRow

        layout.itemSize = CGSize(width: width, height: width)
        layout.sectionInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        alert.startLoading()
        CloudKitImageService.fetchImages { _, _ in
            self.alert.stopLoading {
                self.collectionView.reloadData()
            }
            
            CloudKitVideoService.fetchVideosPlaceholders { fetchedItems, error in
                self.collectionView.reloadData()
            }
        }
    }
    
    private func setupUI() {
        view.addSubview(collectionView)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Registrar a classe da célula customizada
        collectionView.register(ItemCollectionViewCell.self, forCellWithReuseIdentifier: "ItemCell")
        collectionView.register(CollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView")
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let closeButton = UIBarButtonItem(title: closeBarButtonTitle, style: .plain, target: self, action: #selector(closeButtonTapped))
        closeButton.tintColor = .systemBlue
        navigationItem.leftBarButtonItem = closeButton
        
        navigationItem.title = Text.backupNavigationTitle.localized()
    }
    
    @objc private func closeButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension CloudKitItemsViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return CloudKitImageService.images.count
            
        default:
            return CloudKitVideoService.videos.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as! ItemCollectionViewCell
            let (_, userImage) = CloudKitImageService.images[indexPath.row]
            cell.itemImageView.image = userImage
            cell.itemImageView.contentMode = .scaleAspectFit
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as! ItemCollectionViewCell
            let (_, userImage) = CloudKitVideoService.videos[indexPath.row]
            cell.itemImageView.image = userImage
            cell.itemImageView.contentMode = .scaleAspectFit
            return cell
        }
    }
}

extension CloudKitItemsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            collectionView.deselectItem(at: indexPath, animated: true)
            let alertController = UIAlertController(title: Text.deleteFiles.localized(), message: String(), preferredStyle: .alert)

            let deleteAction = UIAlertAction(title: Text.delete.localized(), style: .destructive) { _ in
                let (itemName, _) = CloudKitImageService.images[indexPath.row]
                self.alert.startLoading()
                CloudKitImageService.deleteImage(name: itemName) { success, error in
                    self.alert.stopLoading()
                    if success {
                        CloudKitImageService.fetchImages { _, _ in
                            self.collectionView.reloadData()
                        }
                    } else {
                        // Handle error here
                    }
                }
            }

            let cancelAction = UIAlertAction(title: Text.cancel.localized(), style: .cancel, handler: nil)

            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)

            present(alertController, animated: true, completion: nil)
        default:
            collectionView.deselectItem(at: indexPath, animated: true)
            let alertController = UIAlertController(title: Text.deleteFiles.localized(), message: String(), preferredStyle: .alert)

            let deleteAction = UIAlertAction(title: Text.delete.localized(), style: .destructive) { _ in
                let (itemName, _) = CloudKitVideoService.videos[indexPath.row]
                self.alert.startLoading()
                CloudKitVideoService.deleteVideoByName(name: itemName) { success, error in
                    CloudKitVideoService.fetchVideos { success, error in
                        self.alert.stopLoading()
                        self.collectionView.reloadData()
                    }
                }
            }

            let cancelAction = UIAlertAction(title: Text.cancel.localized(), style: .cancel, handler: nil)

            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)

            present(alertController, animated: true, completion: nil)
        }
    }
}

class ItemCollectionViewCell: UICollectionViewCell {
    let itemImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill // ajusta o modo de conteúdo
        imageView.clipsToBounds = true // corta a imagem para preencher o espaço
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(itemImageView)
        
        itemImageView.snp.makeConstraints { make in
            make.leading.equalTo(self.snp.leading)
            make.trailing.equalTo(self.snp.trailing)
            make.top.equalTo(self.snp.top)
            make.bottom.equalTo(self.snp.bottom)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CollectionHeaderView: UICollectionReusableView {
    let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = Text.myBackupNavigationSubtitle.localized()
        label.textColor = .lightGray
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview().inset(8)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

import UIKit
import SnapKit
import Network
import Photos
import AssetsPickerViewController
import DTPhotoViewerController
import CoreData
import NYTPhotoViewer
import ImageViewer
import StoreKit
import GoogleMobileAds
import SceneKit
import simd
import Photos
import StoreKit
import Foundation
import AVFoundation
import AVKit
import CloudKit

protocol BackupModalViewControllerDelegate {
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
        titleLabel.font = UIFont.boldSystemFont(ofSize: 14)
        titleLabel.textColor = .black
        
        view.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        return view
    }()
    
    lazy var modalSubtitleView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        let titleLabel = UILabel()
        titleLabel.text = Text.backupNavigationSubtitle.localized()
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.textColor = .lightGray
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        
        view.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
        leftLabel.font = UIFont.systemFont(ofSize: 14)
        
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
        label.text = "Restaurar backup"//Text.restoreBackup.localized()
        label.font = UIFont.systemFont(ofSize: 14)
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
    
    lazy var updateBackup: UIView = {
        let label = UILabel()
        label.text = "Atualizar backup"//Text.updateBackup.localized()
        label.font = UIFont.systemFont(ofSize: 14)
        let restoreBackupView = UIView()
        restoreBackupView.backgroundColor = .systemGray5
        restoreBackupView.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview().inset(8)
            make.leading.equalToSuperview().inset(16)
        }
        
        restoreBackupView.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.updateBackupTapped))
        restoreBackupView.addGestureRecognizer(tapGesture)
        
        return restoreBackupView
    }()
    
    lazy var viewBackup: UIView = {
        let label = UILabel()
        label.text = "Ver meu backup"//Text.seeMyBackup.localized()
        label.font = UIFont.systemFont(ofSize: 14)
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
    
    lazy var backupImageQuality: UIView = {
        let titleLabel = UILabel()
        titleLabel.text = "Qualidade de imagem"
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        let qualitySelector = UISegmentedControl(items: ["Baixa", "Média", "Alta"])
        qualitySelector.selectedSegmentIndex = setImageSegmentedControlIndex()
        
        qualitySelector.addTarget(self, action: #selector(imageQualityChanged), for: .valueChanged)
        
        let viewBackupView = UIView()
        viewBackupView.backgroundColor = .systemGray5
        viewBackupView.addSubview(titleLabel)
        viewBackupView.addSubview(qualitySelector)
        
        titleLabel.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview().inset(8)
            make.leading.equalToSuperview().inset(16)
        }
        
        qualitySelector.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview().inset(8)
            make.trailing.equalToSuperview().inset(16)
        }
        
        viewBackupView.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.viewBackupTapped))
        viewBackupView.addGestureRecognizer(tapGesture)
        
        return viewBackupView
    }()
    
    func setImageSegmentedControlIndex() -> Int {
        switch Defaults.getInt(.imageCompressionQuality) {
        case 3:
            return 0
        case 6:
            return 1
        case 10:
            return 2
        default:
            return 2
        }
    }
    
    @objc func imageQualityChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            Defaults.setInt(.imageCompressionQuality, 3)
        case 1:
            Defaults.setInt(.imageCompressionQuality, 6)
        case 2:
            Defaults.setInt(.imageCompressionQuality, 10)
        default:
            break
        }
    }
    
    lazy var backupVideoQuality: UIView = {
        let titleLabel = UILabel()
        titleLabel.text = "Qualidade de video"
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        let qualitySelector = UISegmentedControl(items: ["Baixa", "Média", "Alta"])
        qualitySelector.selectedSegmentIndex = setVideoSegmentedControlIndex()
        qualitySelector.addTarget(self, action: #selector(videoQualityChanged), for: .valueChanged)
        
        let viewBackupView = UIView()
        viewBackupView.backgroundColor = .systemGray5
        viewBackupView.addSubview(titleLabel)
        viewBackupView.addSubview(qualitySelector)
        
        titleLabel.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview().inset(8)
            make.leading.equalToSuperview().inset(16)
        }
        
        qualitySelector.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview().inset(8)
            make.trailing.equalToSuperview().inset(16)
        }
        
        viewBackupView.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.viewBackupTapped))
        viewBackupView.addGestureRecognizer(tapGesture)
        
        return viewBackupView
    }()

    func setVideoSegmentedControlIndex() -> Int {
        switch Defaults.getInt(.videoCompressionQuality) {
        case 3:
            return 0
        case 6:
            return 1
        case 10:
            return 2
        default:
            return 2
        }
    }
    
    @objc func videoQualityChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            Defaults.setInt(.videoCompressionQuality, 3)
        case 1:
            Defaults.setInt(.videoCompressionQuality, 6)
        case 2:
            Defaults.setInt(.videoCompressionQuality, 10)
        default:
            break
        }
    }
    
    @objc func viewBackupTapped() {
        let navigation = UINavigationController(rootViewController: CloudKitItemsViewController())
        present(navigation, animated: true)
    }
    
    @objc func updateBackupTapped() {
        isConnectedToWiFi { isConnected in
            guard Defaults.getBool(.iCloudEnabled) else {
                Alerts.showBackupDisabled(controller: self)
                return
            }
            
            if isConnected {
                self.loadingAlert.startLoading {
                    FirebaseBackupService.updateBackup(completion: { _ in
                        DispatchQueue.main.async {
                            self.loadingAlert.stopLoading {
                                Alerts.showBackupSuccess(controller: self)
                            }
                        }
                    })

                    if Defaults.getBool(.needSavePasswordInCloud) {
                        CloudKitPasswordService.updatePassword(newPassword: Defaults.getString(.password)) { success, error in
                            if success && error == nil {
                                Defaults.setBool(.needSavePasswordInCloud, false)
                            }
                        }
                    }
                }
            } else {
                Alerts.showBackupErrorWifi(controller: self)
            }
        }
    }
    
    lazy var loadingAlert = LoadingAlert(in: self)
    
    func isConnectedToWiFi(completion: @escaping (Bool) -> Void) {
        let monitor = NWPathMonitor()
        
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied && path.usesInterfaceType(.wifi) {
                completion(true)
            } else {
                completion(false)
            }
        }
        
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
    
    lazy var contentStackView: UIStackView = {
        let spacer = UIView()
        let stackView = UIStackView(arrangedSubviews: [backupStatus, backupImageQuality, backupVideoQuality, restoreBackup, updateBackup, viewBackup, spacer])
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
    let defaultHeight: CGFloat = 530
    var currentContainerHeight: CGFloat = 460
    
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
        containerView.addSubview(modalSubtitleView)
        
        modalTitleView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().offset(8)
            make.height.equalTo(44)  // Altura da barra de título
        }
        
        modalSubtitleView.snp.makeConstraints { make in
            make.top.equalTo(modalTitleView.snp.bottom)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
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
            make.top.equalTo(modalSubtitleView.snp.bottom).offset(24)
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
            Defaults.setBool(.iCloudEnabled, true)
            self.delegate?.enableBackupToggled(status: true)
        } else {
            Defaults.setBool(.iCloudEnabled, false)
            delegate?.enableBackupToggled(status: false)
        }
    }
}

extension BackupModalViewController {
    @objc func restoreBackupTapped() {
        
        guard Defaults.getBool(.iCloudEnabled) else {
            Alerts.showBackupDisabled(controller: self)
            return
        }
        
        self.checkBackupData()
        // self.fetchCloudKitPassword()
    }
    
    private func fetchCloudKitPassword() {
        loadingAlert.startLoading()
        CloudKitPasswordService.fetchUserPasswords { password, error in
            self.loadingAlert.stopLoading {
                if let password = password {
                self.insertPasswordAndCheckBackup(password: password)
                } else {
                    Alerts.showPasswordError(controller: self)
                }
            }
        }
    }
    
    private func insertPasswordAndCheckBackup(password: [String]) {
        Alerts.insertPassword(controller: self) { insertedPassword in
            guard let insertedPassword = insertedPassword else {
                return
            }
            if password.contains(insertedPassword) || insertedPassword == Constants.recoverPassword {
                self.checkBackupData()
            } else {
                Alerts.showPasswordError(controller: self)
            }
        }
    }
    
    private func checkBackupData() {
        loadingAlert.startLoading()
        FirebaseBackupService.hasDataInFirebase { hasData, _, items  in
            self.loadingAlert.stopLoading {
                if let items = items, !items.isEmpty, hasData {
                    self.askUserToRestoreBackup(backupItems: items)
                } else {
                    Alerts.showBackupError(controller: self)
                }
            }
        }
    }

    private func askUserToRestoreBackup(backupItems: [MediaItem]) {
        Alerts.askUserToRestoreBackup(on: self) { restoreBackup in
            if restoreBackup {
                self.startLoadingForBackupRestore(backupItems: backupItems)
            }
        }
    }

    private func startLoadingForBackupRestore(backupItems: [MediaItem]) {
        loadingAlert.startLoading()
        restoreBackup(backupItems: backupItems)
    }

    private func restoreBackup(backupItems: [MediaItem]) {
        FirebaseBackupService.restoreBackup(items: backupItems) { success, _ in
            self.loadingAlert.stopLoading {
                if success {
                    Alerts.showBackupSuccess(controller: self)
                    let controllers = self.tabBarController?.viewControllers
                    let navigation = controllers?[0] as? UINavigationController
                    let collectionViewController = navigation?.viewControllers.first as? CollectionViewController
                    collectionViewController?.viewDidLoad()
                } else {
                    Alerts.showBackupError(controller: self)
                }
            }
        }
    }
}
import UIKit
import SnapKit
import Network
import Photos
import AssetsPickerViewController
import DTPhotoViewerController
import CoreData
import NYTPhotoViewer
import ImageViewer
import StoreKit
import GoogleMobileAds
import SceneKit
import simd
import Photos
import StoreKit
import Foundation
import AVFoundation
import AVKit
import CloudKit

class ChangeIconViewController: UIViewController {
    lazy var modalTitleView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        let titleLabel = UILabel()
        titleLabel.text = Text.selectNewIcon.localized()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = .black
        
        view.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        return view
    }()

    func createIconImage(_ image: UIImage?, action: Selector) -> UIView {
        let view = UIView()
        let imageView = UIImageView(image: image)
        
        view.addSubview(imageView)
        
        view.snp.makeConstraints { make in
            make.width.height.equalTo(80)
        }
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 5
        
        // Adiciona interatividade
        imageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: action)
        imageView.addGestureRecognizer(tapGesture)

        return view
    }
    
    func setIcon(name: String) {
        let app = UIApplication.shared
        if #available(iOS 10.3, *) {
            if app.supportsAlternateIcons {
                app.setAlternateIconName(name, completionHandler: { (error) in
                    if error != nil {
                        print("error => \(String(describing: error?.localizedDescription))")
                    } else {
                        print("Changed Icon Sucessfully.")
                    }
                })
            }
        }
    }
    
    @objc func metodoExemplo() {
        setIcon(name: "icon1")
    }
    
    @objc func metodoExemplo2() {
        setIcon(name: "Icon2")
    }
    
    @objc func metodoExemplo3() {
        setIcon(name: "icon3")
    }
    
    @objc func metodoExemplo4() {
        setIcon(name: "icon4")
    }
    
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                createIconImage(UIImage(named: "calculadora"), action: #selector(metodoExemplo)),
                createIconImage(UIImage(named: "foguetinho"), action: #selector(metodoExemplo2)),
                createIconImage(UIImage(named: "iPhotos"), action: #selector(metodoExemplo3)),
                createIconImage(UIImage(named: "iconeOriginal"), action: #selector(metodoExemplo4))
            ]
        )
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
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
    let defaultHeight: CGFloat = 240
    var currentContainerHeight: CGFloat = 460
    
    // Dynamic container constraint
    var containerViewHeightConstraint: Constraint?
    var containerViewBottomConstraint: Constraint?
    
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
            make.height.equalTo(44)
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
            make.top.equalTo(modalTitleView.snp.bottom).offset(24)
            make.leading.trailing.equalTo(containerView).inset(16)
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
}

