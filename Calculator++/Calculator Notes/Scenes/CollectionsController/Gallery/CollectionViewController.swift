import Network
import UIKit
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

class CollectionViewController: BasicCollectionViewController, UINavigationControllerDelegate, GADBannerViewDelegate, GADInterstitialDelegate {
    // MARK: - Variables
    var modelData: [Photo] = []
    var folders: [Folder] = []
    var loadingAlert = LoadingAlert()
    var coordinator: CollectionViewCoordinatorProtocol?
    
    var isEditMode = false {
        didSet {
            editLeftBarButtonItem?.setEditing(isEditMode)
        }
    }
    
    // MARK: - IBOutlet
    @IBOutlet weak var placeHolderImage: UIImageView!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        configureNavigationBar()
        setupAds()
        setupFirstUse()
        setupTabBars()
        handleInitialLaunch()
        monitorWiFiAndPerformActions()
        coordinator = CollectionViewCoordinator(self)
    }
    
    func deselectAllFoldersObjects() {
        for index in 0 ..< folders.count {
            folders[index].isSelected = false
        }
    }
    
    func deselectAllFileObjects() {
        for index in 0 ..< modelData.count {
            modelData[index].isSelected = false
        }
    }
}

// MARK: - EditLeftBarButtonItemDelegate
extension CollectionViewController: EditLeftBarButtonItemDelegate {
    func selectImagesButtonTapped() {
        self.deselectAllFoldersObjects()
        self.deselectAllFileObjects()
        if isEditMode {
            collectionView?.reloadData()
        } else {
            SKStoreReviewController.requestReview()
        }
        isEditMode.toggle()
    }
    
    func shareImageButtonTapped() {
        coordinator?.shareImage(modelData: modelData)
    }
    
    func deleteButtonTapped() {
        Alerts.showConfirmationDelete(controller: self) { [weak self] in
            guard let self = self else { return }
            
            self.deleteSelectedFolders()
            self.deleteSelectedPhotos()
            
            self.reloadCollectionViewSections()
        }
    }
    
    private func deleteSelectedFolders() {
        folders.removeAll { folder in
            folder.isSelected
        }
        if folders.isEmpty {
            filesIsExpanded = true
        }
        deselectAllFoldersObjects()
    }
    
    private func deleteSelectedPhotos() {
        modelData.removeAll { photo in
            photo.isSelected
        }
        modelData.forEach { photo in
            ModelController.deleteImageObject(name: photo.name, basePath: basePath)
        }
        deselectAllFileObjects()
    }
    
    private func reloadCollectionViewSections() {
        collectionView?.reloadSections(IndexSet(integer: 0))
        collectionView?.reloadSections(IndexSet(integer: 1))
    }
}

// MARK: - AdditionsRightBarButtonItemDelegate
extension CollectionViewController: AdditionsRightBarButtonItemDelegate {
    func addPhotoButtonTapped() {
        coordinator?.addPhotoButtonTapped()
        self.filesIsExpanded = true
    }
    
    func addFolderButtonTapped() {
        addFolder()
    }
    
    func addFolder() {
        Alerts.showInputDialog(title: Text.folderTitle.localized(),
                               controller: self,
                               actionTitle: Text.createActionTitle.localized(),
                               cancelTitle: Text.cancelTitle.rawValue.localized(),
                               inputPlaceholder: Text.inputPlaceholder.localized(),
                               actionHandler: { [weak self] (input: String?) in
            guard let self = self, let input = input else { return }
            
            if !self.foldersService.checkAlreadyExist(folder: input, basePath: self.basePath) {
                self.createNewFolderAndReloadCollectionView(input: input)
            } else {
                self.showErrorAndPromptForRetry()
            }
        })
    }
    
    private func createNewFolderAndReloadCollectionView(input: String) {
        self.folders = self.foldersService.add(folder: input, basePath: self.basePath).map { folderName in
            return Folder(name: folderName, isSelected: false)
        }
        self.collectionView?.reloadSections(IndexSet(integer: .zero))
    }
    
    private func showErrorAndPromptForRetry() {
        Alerts.showError(title: Text.folderNameAlreadyUsedTitle.localized(),
                         text: Text.folderNameAlreadyUsedText.localized(),
                         controller: self) { [weak self] in
            self?.addFolder()
        }
    }
}

extension CollectionViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let presentPlaceHolderImage = modelData.isEmpty && folders.isEmpty
        placeHolderImage.isHidden = !presentPlaceHolderImage
        switch section {
        case 0:
            return folders.count
        default:
            if filesIsExpanded {
                return modelData.count
            } else {
                return 0
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            return folderCell(collectionView, cellForItemAt: indexPath)
        default:
            return photoCell(collectionView, cellForItemAt: indexPath)
        }
    }
    
    private func folderCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: folderReuseIdentifier, for: indexPath) as? FolderCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let folderName = folders[indexPath.row].name.components(separatedBy: Constants.deepSeparatorPath.value()).last ?? ""
        cell.setup(name: folderName)
        cell.isSelectedCell = folders[indexPath.row].isSelected
        
        return cell
    }
    
    private func photoCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? CollectionViewCell,
              indexPath.item < modelData.count else {
            return UICollectionViewCell()
        }
        
        let image = modelData[indexPath.item]
        cell.imageCell.image = UI.cropToBounds(image: image.image, width: 200, height: 200)
        cell.isSelectedCell = modelData[indexPath.item].isSelected
        cell.applyshadowWithCorner()
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isEditMode {
            updateSelectedPhotos(indexPath: indexPath)
        } else {
            switch indexPath.section {
            case 0:
                coordinator?.navigateToFolderViewController(indexPath: indexPath, folders: folders, basePath: basePath)
            default:
                coordinator?.presentImageGallery(for: indexPath.item)
            }
        }
    }
    
    func updateSelectedPhotos(indexPath: IndexPath) {
        if indexPath.section == .zero {
            folders[indexPath.row].isSelected.toggle()
        } else {
            modelData[indexPath.row].isSelected.toggle()
        }
        self.collectionView?.reloadItems(at: [indexPath])
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            return dequeueHeaderView(for: indexPath)
        case UICollectionElementKindSectionFooter:
            return dequeueFooterView(for: indexPath)
        default:
            return UICollectionReusableView()
        }
    }
    
    private func dequeueHeaderView(for indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView?.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerView", for: indexPath) as? HeaderView else {
            return UICollectionReusableView()
        }
        
        if indexPath.section == 0 {
            configureHeaderViewForFolderSection(headerView)
        } else if indexPath.section == 1 {
            configureHeaderViewForPhotoSection(headerView)
        }
        
        return headerView
    }
    
    private func configureHeaderViewForFolderSection(_ headerView: HeaderView) {
        headerView.messageLabel.text = String()
        headerView.activityIndicatorView.isHidden = true
        headerView.gradientView?.isHidden = false
        headerView.isUserInteractionEnabled = false
    }
    
    private func configureHeaderViewForPhotoSection(_ headerView: HeaderView) {
        if !modelData.isEmpty {
            if filesIsExpanded {
                headerView.messageLabel.text = Text.hideAllPhotos.localized()
            } else {
                headerView.messageLabel.text = Text.showAllPhotos.localized()
            }
        } else {
            headerView.messageLabel.text = String()
        }
        headerView.isUserInteractionEnabled = true
        headerView.activityIndicatorView.isHidden = true
        headerView.gradientView?.isHidden = true
        headerView.delegate = self
    }
    
    private func dequeueFooterView(for indexPath: IndexPath) -> UICollectionReusableView {
        guard let footerView = collectionView?.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "footerView", for: indexPath) as? FooterView else {
            return UICollectionReusableView()
        }
        
        return footerView
    }
    
}


// MARK: - AssetsPickerViewControllerDelegate
extension CollectionViewController: AssetsPickerViewControllerDelegate {
    func assetsPicker(controller: AssetsPickerViewController, selected assets: [PHAsset]) {
        for asset in assets {
            addImage(asset: asset)
        }
    }
    
    func addImage(asset: PHAsset) {
        if asset.mediaType != .image {
            return
        }
        
        getAssetThumbnail(asset: asset) { image in
            if let image = image {
                if let photo = ModelController.saveImageObject(image: image, basePath: self.basePath) {
                    self.modelData.append(photo)
                    DispatchQueue.main.async {
                        self.collectionView?.reloadSections(IndexSet(integer: 1))
                    }
                } else {
                    print("Erro ao salvar a imagem.")
                }
            } else {
                print("Falha ao carregar a miniatura do asset.")
            }
        }
    }

    func getAssetThumbnail(asset: PHAsset, completion: @escaping (UIImage?) -> Void) {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.isSynchronous = false
        option.isNetworkAccessAllowed = true
        
        manager.requestImage(for: asset,
                             targetSize: CGSize(width: 1500, height: 1500),
                             contentMode: .aspectFit,
                             options: option) { (result, info) in
                             
            guard let info = info else { return }

            let isDegraded = (info[PHImageResultIsDegradedKey] as? NSNumber)?.boolValue ?? false
            
            if !isDegraded, let result = result {
                completion(result)
            } else if !isDegraded {
                print("Não foi possível obter a imagem.")
                completion(nil)
            }
        }
    }
    
    func assetsPicker(controller: AssetsPickerViewController, shouldSelect asset: PHAsset, at indexPath: IndexPath) -> Bool {
        return true
    }
    
    func assetsPicker(controller: AssetsPickerViewController, shouldDeselect asset: PHAsset, at indexPath: IndexPath) -> Bool {
        return true
    }
}

// MARK: - Extension Viewer Image
extension CollectionViewController: GalleryItemsDataSource {
    func itemCount() -> Int {
        return modelData.count
    }
    
    func provideGalleryItem(_ index: Int) -> GalleryItem {
        let imageView = UIImageView(image: modelData[index].image)
        let galleryItem = GalleryItem.image { $0(imageView.image) }
        
        return galleryItem
    }
}

// MARK: - First use
extension CollectionViewController {
    private func setupFirstUse() {
        if !Defaults.getBool(.notFirstUse) {
            Defaults.setBool(.notFirstUse, true)
            performFirstUseSetup()
        }
    }
    
    private func performFirstUseSetup() {
        loadingAlert.startLoading(in: self)
        CloudKitPasswordService.fetchAllPasswords { [weak self] password, error in
            guard let self = self, let password = password, error == nil else {
                self?.loadingAlert.stopLoading {
                    self?.showSetProtectionOrNavigateToSettings()
                }
                return
            }
            self.loadingAlert.stopLoading {
                self.handleFirstUseCompletion(with: password)
            }
        }
    }
    
    private func handleFirstUseCompletion(with password: [String]) {
        Alerts.askUserToRestoreBackup(on: self) { [weak self] restoreBackup in
            if restoreBackup {
                self?.handleRestoreBackup(password: password)
            } else {
                self?.showSetProtectionOrNavigateToSettings()
            }
        }
    }
    
    private func handleRestoreBackup(password: [String]) {
        Alerts.insertPassword(controller: self) { [weak self] insertedPassword in
            guard let self = self, let insertedPassword = insertedPassword else {
                return
            }
            if password.contains(insertedPassword) {
                self.loadingAlert.startLoading(in: self)
                BackupService.hasDataInCloudKit { [weak self] hasData, _, items in
                    self?.loadingAlert.stopLoading {
                        guard let self = self, let items = items, !items.isEmpty, hasData else {
                            self?.showSetProtectionOrNavigateToSettings()
                            return
                        }
                        self.restoreBackupAndReloadData(photos: items)
                    }
                }
            }
        }
    }
    
    private func showSetProtectionOrNavigateToSettings() {
        Alerts.showSetProtectionAsk(controller: self) { [weak self] createProtection in
            if createProtection {
                self?.coordinator?.presentChangePasswordCalcMode()
            } else {
                self?.coordinator?.navigateToSettingsTab()
            }
        }
    }
    
    private func restoreBackupAndReloadData(photos: [(String, UIImage)]) {
        loadingAlert.startLoading(in: self)
        BackupService.restoreBackup(photos: photos) { [weak self] success, _ in
            self?.loadingAlert.stopLoading {
                if success {
                    self?.setupData()
                    self?.collectionView?.reloadData()
                    self?.showSetProtectionOrNavigateToSettings()
                } else {
                    guard let strongSelf = self else {
                        return
                    }
                    Alerts.showBackupError(controller: strongSelf)
                }
            }
        }
    }
    
    private func monitorWiFiAndPerformActions() {
        guard Defaults.getBool(.iCloudPurchased) else {
            return
        }
        
        isConnectedToWiFi { isConnected in
            if isConnected {
                BackupService.updateBackup()
                if Defaults.getBool(.needSavePasswordInCloud) {
                    CloudKitPasswordService.updatePassword(newPassword: Defaults.getString(.password)) { success, error in
                        if success && error == nil {
                            Defaults.setBool(.needSavePasswordInCloud, false)
                        }
                    }
                }
            }
        }
    }
    
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
}

extension CollectionViewController {
    private func configureNavigationBar() {
        if let navigationTitle = navigationTitle {
            self.title = navigationTitle
        } else {
            self.title = Text.gallery.localized()
        }
    }
    
    private func handleInitialLaunch() {
        if basePath == Constants.deepSeparatorPath.value() {
            let launchCounter = Defaults.getInt(.launchCounter)
            Defaults.setInt(.launchCounter, launchCounter + 1)
            
            let disableRecoveryButtonCounter = Defaults.getInt(.disableRecoveryButtonCounter)
            Defaults.setInt(.launchCounter, disableRecoveryButtonCounter + 1)
        }
    }
    
    private func setupFolders() {
        folders = foldersService.getFolders(basePath: basePath).map { folderName in
            return Folder(name: folderName, isSelected: false)
        }
        if folders.isEmpty {
            filesIsExpanded = true
        } else {
            self.collectionView?.reloadSections(IndexSet(integer: .zero))
        }
    }
    
    private func setupData() {
        modelData = ModelController.listPhotosOf(basePath: basePath)
        commonViewDidLoad()
        setupNavigationItems(delegate: self)
        setupFolders()
    }
    
    private func setupTabBars() {
        let controllers = self.tabBarController?.viewControllers
        controllers?[2].title = Text.notes.localized()
        controllers?[3].title = Text.settings.localized()
    }
}

// MARK: - GADInterstitialDelegate
extension CollectionViewController {
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        adsHandler.interstitialDidReceiveAd(ad)
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        adsHandler.interstitialDidDismissScreen(delegate: self)
    }
    
    private func setupAds() {
        adsHandler.setupAds(controller: self,
                            bannerDelegate: self,
                            interstitialDelegate: self)
    }
}
