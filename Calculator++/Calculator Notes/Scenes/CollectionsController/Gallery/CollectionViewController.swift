import Network
import FirebaseAuth
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
import MessageUI
import FirebaseFirestore
import MapKit

import Foundation

extension CollectionViewController: BackupModalViewControllerDelegate {
    func backupExecuted() {
        self.modelData = ModelController.listPhotosOf(basePath: self.basePath)
        UIView.performWithoutAnimation {
            self.collectionView?.reloadData()
        }
    }
    
    func enableBackupToggled(status: Bool) {
        if status {
            if let cloudImage = UIImage(systemName: "icloud.fill")?.withRenderingMode(.alwaysTemplate) {
                additionsRightBarButtonItem?.cloudButton.setImage(cloudImage, for: .normal)
            }
            additionsRightBarButtonItem?.cloudButton.tintColor = .systemBlue
        } else {
            if let cloudImage = UIImage(systemName: "exclamationmark.icloud")?.withRenderingMode(.alwaysTemplate) {
                additionsRightBarButtonItem?.cloudButton.setImage(cloudImage, for: .normal)
            }
            additionsRightBarButtonItem?.cloudButton.tintColor = .systemGray
        }
    }
}

class CollectionViewController: BasicCollectionViewController, UINavigationControllerDelegate, GADBannerViewDelegate, GADInterstitialDelegate, MFMailComposeViewControllerDelegate, EditLeftBarButtonItemDelegate, AdditionsRightBarButtonItemDelegate {
    // MARK: - Variables
    var modelData: [Photo] = []
    var folders: [Folder] = []
    lazy var loadingAlert = LoadingAlert(in: self)
    var coordinator: CollectionViewCoordinatorProtocol?
    
    var isEditMode = false {
        didSet {
            editLeftBarButtonItem?.setEditing(isEditMode)
        }
    }
    
    lazy var placeholderView = PlaceholderView(
        title: Text.emptyGalleryTitle.localized(),
        subtitle: Text.emptyGallerySubtitle.localized(),
        image: UIImage(named: Img.emptyGalleryIcon.name())
    )
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        coordinator = CollectionViewCoordinator(self)
        setupData()
        configureNavigationBar()
        setupTabBars()
        handleInitialLaunch()
        setupPlaceholderView()
        handleAdsSetup()
        Defaults.setBool(.notFirstUse, true)
    }

    func presentWithCustomDissolve(viewController: UIViewController, from presenter: UIViewController, duration: TimeInterval = 1.0) {
        viewController.view.alpha = 0
        
        presenter.present(viewController, animated: false) {
            UIView.animate(withDuration: duration, animations: {
                viewController.view.alpha = 1
            })
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        commonViewWillAppear()
        checkPurchase()
    }
    
    // MARK: - Purchase Check
    private func checkPurchase() {
        if isProductPurchased() {
            removeAdsView()
        }
    }

    private func removeAdsView() {
        self.view.viewWithTag(100)?.removeFromSuperview()
    }
    
    private func isProductPurchased() -> Bool {
        return RazeFaceProducts.store.isProductPurchased("Calc.noads.mensal") ||
               RazeFaceProducts.store.isProductPurchased("calcanual") ||
               RazeFaceProducts.store.isProductPurchased("NoAds.Calc")
    }
    
    private func setupPlaceholderView() {
        view.addSubview(placeholderView)
        placeholderView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func deselectAllFoldersObjects() {
        for index in folders.indices {
            folders[index].isSelected = false
        }
    }
    
    private func deselectAllFileObjects() {
        for index in modelData.indices {
            modelData[index].isSelected = false
        }
    }
    
    // MARK: - Ads Setup
    private func handleAdsSetup() {
        if !isProductPurchased() {
            setupAds()
        } else {
            checkRevenuePurchases()
        }
    }
    
    private func checkRevenuePurchases() {
        let dataManager = DateManager()
        Connectivity.shared.checkConnection { isConnected in
            if isConnected && dataManager.hasDatesBeforeToday() {
                UserDefaults.standard.set(false, forKey: "calcanual")
                UserDefaults.standard.set(false, forKey: "Calc.noads.mensal")
                RazeFaceProducts.store.restorePurchases()
                dataManager.deleteDatesBeforeToday()
            }
        }
    }

    // MARK: - EditLeftBarButtonItemDelegate
    func selectImagesButtonTapped() {
        handleSelectImagesButton()
    }
    
    func shareImageButtonTapped() {
        handleShareImageButton()
    }
    
    func deleteButtonTapped() {
        handleDeleteButton()
    }
    
    private func handleSelectImagesButton() {
        deselectAllItems()
        toggleEditModeAndReloadData()
    }
    
    // MARK: - Handle Share Image

    private func handleShareImageButton() {
        guard !modelData.isEmpty else {
            Alerts.showSelectImagesToShareFirts(controller: self)
            return
        }
        
        let alertController = UIAlertController(
            title: Text.chooseDestination.localized(),
            message: nil,
            preferredStyle: .actionSheet
        )
             
        let shareAction = UIAlertAction(title: Text.share.localized(), style: .default) { [weak self] _ in
            self?.shareSelectedImages()
        }
             
        let saveAction = UIAlertAction(title: Text.saveToGallery.localized(), style: .default) { [weak self] _ in
            self?.saveSelectedImages()
        }
             
        let shareWithCalculatorAction = UIAlertAction(title: Text.secureSharing.localized(), style: .default) { [weak self] _ in
            self?.shareWithCalculator()
        }
             
        let cancelAction = UIAlertAction(title: Text.cancel.localized(), style: .cancel, handler: nil)
        
        alertController.addAction(shareAction)
        alertController.addAction(shareWithCalculatorAction)
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }

    // MARK: - Private Actions

    private func shareSelectedImages() {
        let selectedItems = getSelectedItems()
        coordinator?.shareImage(modelData: selectedItems)
    }

    private func saveSelectedImages() {
        let selectedItems = getSelectedItems()
        coordinator?.saveImages(modelData: selectedItems)
    }

    private func shareWithCalculator() {
        let selectedItems = getSelectedItems()
        let createdLinks: [String] = Defaults.getStringArray(.secretLinks) ?? []
        if createdLinks.count >= 5 {
            Alerts.showAlert(
                title: Text.limitReachedTitle.localized(),
                text: Text.limitReachedMessage.localized(),
                controller: self
            )
        }
        coordinator?.shareWithCalculator(modelData: selectedItems)
    }

    // MARK: - Helper Methods

    private func getSelectedItems() -> [Photo] {
        var selectedItems = modelData.filter { $0.isSelected }
        let selectedFolders = folders.filter { $0.isSelected }
        
        for folder in selectedFolders {
            let folderItems = ModelController.listPhotosOf(basePath: buildFolderPath(for: folder.name))
            selectedItems.append(contentsOf: folderItems)
        }
        
        return selectedItems
    }

    private func buildFolderPath(for folderName: String) -> String {
        return basePath + folderName + Constants.deepSeparatorPath
    }
    
    private func handleDeleteButton() {
        var selectedItems = modelData.filter { $0.isSelected }
        let selectedFolders = folders.filter { $0.isSelected }
        guard !selectedItems.isEmpty || !selectedFolders.isEmpty else {
            Alerts.showSelectImagesToDeleteFirts(controller: self)
            return
        }
        Alerts.showConfirmationDelete(controller: self) { [weak self] in
            self?.performDeletionTasks()
        }
    }
    
    private func performDeletionTasks() {
        UIView.performWithoutAnimation {
            deleteSelectedFolders()
            deleteSelectedPhotos()
            reloadCollectionViewSections()
        }
    }
    
    private func deselectAllItems() {
        deselectAllFoldersObjects()
        deselectAllFileObjects()
    }
    
    private func toggleEditModeAndReloadData() {
        if isEditMode {
            DispatchQueue.main.async {
                self.ensureLayoutConsistency()
                UIView.performWithoutAnimation {
                    self.collectionView?.reloadData()
                }
            }
        }
        isEditMode.toggle()
    }
    
    func ensureLayoutConsistency() {
        self.collectionView?.layoutIfNeeded()
    }

    private func deleteSelectedFolders() {
        folders.filter { $0.isSelected }.forEach {
            foldersService.delete(folder: $0.name, basePath: basePath)
        }
        folders.removeAll { $0.isSelected }
        updateFilesIsExpanded()
        deselectAllFoldersObjects()
    }
    
    private func deleteSelectedPhotos() {
        modelData.filter { $0.isSelected }.forEach {
            ModelController.deleteImageObject(name: $0.name, basePath: basePath)
        }
        modelData.removeAll { $0.isSelected }
        deselectAllFileObjects()
    }
    
    private func updateFilesIsExpanded() {
        if folders.isEmpty {
            filesIsExpanded = true
        }
    }
    
    private func reloadCollectionViewSections() {
        UIView.performWithoutAnimation {
            collectionView?.reloadData()
        }
    }
    
    // MARK: - AdditionsRightBarButtonItemDelegate
    func cloudButtonTapped() {
        if isProductPurchased() {
            presentBackupModalViewController()
        } else {
            presentPurchaseController()
        }
    }
    
    private func presentBackupModalViewController() {
        guard let tabBar = self.tabBarController else { return }
        let vc = BackupModalViewController(
            delegate: self,
            imagesRootController: self,
            videosRootController: getVideoCollectionViewController(from: tabBar, index: 1)
        )
        vc.modalPresentationStyle = .overCurrentContext
        tabBar.present(vc, animated: false, completion: nil)
    }
    
    private func getCollectionViewController(from tabBar: UITabBarController, index: Int) -> CollectionViewController? {
        let navigation = tabBar.viewControllers?[index] as? UINavigationController
        return navigation?.viewControllers.first as? CollectionViewController
    }
    
    private func getVideoCollectionViewController(from tabBar: UITabBarController, index: Int) -> VideoCollectionViewController? {
        let navigation = tabBar.viewControllers?[index] as? UINavigationController
        return navigation?.viewControllers.first as? VideoCollectionViewController
    }
    
    private func presentPurchaseController() {
        Alerts.showBePremiumToUseBackup(controller: self) { [weak self] _ in
            guard let self = self else { return }
            let storyboard = UIStoryboard(name: "Purchase", bundle: nil)
            let purchaseViewController = storyboard.instantiateViewController(withIdentifier: "Purchase")
            self.present(purchaseViewController, animated: true)
        }
    }
    
    func addPhotoButtonTapped() {
        coordinator?.addPhotoButtonTapped()
        self.filesIsExpanded = true
    }
    
    func addFolderButtonTapped() {
        addFolder()
    }
    
    private func addFolder() {
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
        self.folders = self.foldersService.add(folder: input, basePath: self.basePath).map { Folder(name: $0, isSelected: false) }
        collectionView?.performBatchUpdates {
            collectionView?.reloadSections(IndexSet(integer: .zero))
        }
    }
    
    private func showErrorAndPromptForRetry() {
        Alerts.showError(title: Text.folderNameAlreadyUsedTitle.localized(),
                         text: Text.folderNameAlreadyUsedText.localized(),
                         controller: self) { [weak self] in
            self?.addFolder()
        }
    }
    
    // MARK: - CollectionView DataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let presentPlaceHolderImage = modelData.isEmpty && folders.isEmpty
        placeholderView.isHidden = !presentPlaceHolderImage
        return section == 0 ? folders.count : (filesIsExpanded ? modelData.count : 0)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return indexPath.section == 0 ? folderCell(collectionView, cellForItemAt: indexPath) : photoCell(collectionView, cellForItemAt: indexPath)
    }
    
    private func folderCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: folderReuseIdentifier, for: indexPath) as? FolderCollectionViewCell else {
            return UICollectionViewCell()
        }
        let folderName = folders[indexPath.row].name.components(separatedBy: Constants.deepSeparatorPath).last ?? ""
        cell.setup(name: folderName)
        cell.isSelectedCell = folders[indexPath.row].isSelected
        return cell
    }
    
    private let imageProcessingQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 8
        return queue
    }()
    
    private func photoCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? CollectionViewCell, indexPath.item < modelData.count else {
            return UICollectionViewCell()
        }
        
        let photo = modelData[indexPath.item]
        
        cell.imageCell.image = nil
        cell.backgroundColor = .clear
        cell.imageCell.contentMode = .scaleAspectFill
        cell.isSelectedCell = photo.isSelected
        cell.applyshadowWithCorner()
        
        if let thumbImage = photo.thumbImage {
            cell.imageCell.image = thumbImage
        } else {
            // Adiciona um indicador de carregamento
            let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .medium)
            loadingIndicator.color = .lightGray
            loadingIndicator.startAnimating()
            cell.contentView.addSubview(loadingIndicator)
            loadingIndicator.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
            
            // Processa a imagem em segundo plano usando `imageProcessingQueue`
            imageProcessingQueue.addOperation {
                let resizedImage = photo.image.resizedTo150x150()
                self.modelData[indexPath.item].thumbImage = resizedImage
                
                // Atualiza a interface na main thread
                OperationQueue.main.addOperation {
                    loadingIndicator.stopAnimating()
                    loadingIndicator.removeFromSuperview()
                    
                    // Verifica se a célula ainda está visível na posição correta
                    if collectionView.indexPath(for: cell) == indexPath {
                        cell.imageCell.image = resizedImage
                    }
                }
            }
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        isEditMode ? handleEditModeSelection(at: indexPath) : handleNormalModeSelection(at: indexPath)
    }
    
    private func handleEditModeSelection(at indexPath: IndexPath) {
        updateSelectedPhotos(indexPath: indexPath)
    }
    
    private func handleNormalModeSelection(at indexPath: IndexPath) {
        if indexPath.section == 0 {
            coordinator?.navigateToFolderViewController(indexPath: indexPath, folders: folders, basePath: basePath)
        } else {
            coordinator?.presentImageGallery(for: indexPath.item)
        }
    }
    
    func updateSelectedPhotos(indexPath: IndexPath) {
        if indexPath.section == 0 {
            folders[indexPath.row].isSelected.toggle()
        } else {
            modelData[indexPath.row].isSelected.toggle()
        }
        collectionView?.reloadItems(at: [indexPath])
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return kind == UICollectionElementKindSectionHeader ? dequeueHeaderView(for: indexPath) : dequeueFooterView(for: indexPath)
    }
    
    private func dequeueHeaderView(for indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView?.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerView", for: indexPath) as? HeaderView else {
            return UICollectionReusableView()
        }
        configureHeaderView(headerView, for: indexPath.section)
        return headerView
    }
    
    private func configureHeaderView(_ headerView: HeaderView, for section: Int) {
        if section == 0 {
            configureHeaderViewForFolderSection(headerView)
        } else {
            configureHeaderViewForPhotoSection(headerView)
        }
    }
    
    private func configureHeaderViewForFolderSection(_ headerView: HeaderView) {
        headerView.messageLabel.text = ""
        headerView.activityIndicatorView.isHidden = true
        headerView.gradientView?.isHidden = false
        headerView.isUserInteractionEnabled = false
    }
    
    private func configureHeaderViewForPhotoSection(_ headerView: HeaderView) {
        if !modelData.isEmpty {
            headerView.messageLabel.text = filesIsExpanded ? Text.hideAllPhotos.localized() : Text.showAllPhotos.localized()
        } else {
            headerView.messageLabel.text = ""
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
        guard let _ = self.collectionView else {
            print("Erro: collectionView não está inicializado.")
            return
        }
        handleAssetSelection(assets)
    }

    private func handleAssetSelection(_ assets: [PHAsset]) {
        DispatchQueue.main.async {
            self.showImportAnimation()
            DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.1) {
                for asset in assets {
                    self.addImage(asset: asset) { photo in
                        if let photo = photo {
                            DispatchQueue.main.async {
                                self.modelData.append(photo)
                                UIView.performWithoutAnimation {
                                    self.collectionView?.reloadData()
                                }
                            }
                        }
                    }
                }
                self.updateBackupTapped(numberOfNewPhotos: assets.count)
            }
        }
    }

    private func showImportAnimation() {
        let savedLabel = UILabel()
        savedLabel.text = Text.importingPhotos.localized()
        savedLabel.font = .boldSystemFont(ofSize: 18)
        savedLabel.textColor = .white
        savedLabel.textAlignment = .center
        savedLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        savedLabel.layer.cornerRadius = 10
        savedLabel.clipsToBounds = true
        
        view.addSubview(savedLabel)
        
        savedLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.width.equalTo(200)
            make.height.equalTo(40)
        }
        
        savedLabel.alpha = 0
        
        UIView.animate(withDuration: 0.6, animations: {
            savedLabel.alpha = 0.8
        }) { _ in
            UIView.animate(withDuration: 0.6, delay: 2, options: .curveEaseOut, animations: {
                savedLabel.alpha = 0
            }) { _ in
                savedLabel.removeFromSuperview()
            }
        }
    }
    
    private func addImage(asset: PHAsset, completion: @escaping (Photo?) -> Void) {
        guard asset.mediaType == .image else {
            completion(nil)
            return
        }
        getAssetThumbnail(asset: asset) { image in
            if let image = image, let photo = ModelController.saveImageObject(image: image, basePath: self.basePath) {
                completion(photo)
            } else {
                completion(nil)
            }
        }
    }
    
    private func getAssetThumbnail(asset: PHAsset, completion: @escaping (UIImage?) -> Void) {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.isSynchronous = false
        option.isNetworkAccessAllowed = true
        manager.requestImage(for: asset,
                             targetSize: CGSize(width: 1500, height: 1500),
                             contentMode: .aspectFit,
                             options: option) { result, info in
            guard let info = info, !(info[PHImageResultIsDegradedKey] as? Bool ?? false), let result = result else {
                completion(nil)
                return
            }
            completion(result)
        }
    }
    
    func getCurrentDateTimeFormatted() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: Date())
    }
    
    func updateBackupTapped(numberOfNewPhotos: Int) {
        if isProductPurchased() && isUserLoggedIn() && Defaults.getBool(.recurrentBackupUpdate) {
            let numberOfPhotos = Defaults.getInt(.numberOfNonSincronizatedPhotos) + numberOfNewPhotos
            Defaults.setInt(.numberOfNonSincronizatedPhotos, numberOfPhotos)
            if numberOfPhotos > 3 {
                updateBackup()
            }
        }
    }
    
    private func updateBackup() {
        DispatchQueue.global().async {
            FirebaseBackupService.updateBackup { _ in
                Defaults.setString(.lastBackupUpdate, self.getCurrentDateTimeFormatted())
                Defaults.setInt(.numberOfNonSincronizatedPhotos, 0)
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
        return GalleryItem.image { $0(imageView.image) }
    }
}

// MARK: - Private Methods
extension CollectionViewController {
    private func configureNavigationBar() {
        title = navigationTitle ?? Text.gallery.localized()
    }
    
    private func handleInitialLaunch() {
        if basePath == Constants.deepSeparatorPath {
            Defaults.incrementInt(.launchCounter)
            Defaults.incrementInt(.disableRecoveryButtonCounter)
        }
    }
    
    private func setupFolders() {
        folders = foldersService.getFolders(basePath: basePath).map { Folder(name: $0, isSelected: false) }
        if folders.isEmpty {
            filesIsExpanded = true
        } else {
            collectionView?.performBatchUpdates {
                collectionView?.reloadSections(IndexSet(integer: .zero))
            }
        }
    }
    
    private func setupData() {
        self.modelData = ModelController.listPhotosOf(basePath: self.basePath)
        commonViewDidLoad()
        setupNavigationItems(delegate: self)
        setupFolders()
    }
    
    private func setupTabBars() {
        guard let controllers = tabBarController?.viewControllers else { return }
        controllers[2].title = Text.notes.localized()
        controllers[3].title = Text.settings.localized()
    }
    
    private func setupAds() {
        adsHandler.setupAds(controller: self,
                            bannerDelegate: self,
                            interstitialDelegate: self)
    }
    
    // MARK: - GADInterstitialDelegate
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        adsHandler.interstitialDidReceiveAd(ad)
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        adsHandler.interstitialDidDismissScreen(delegate: self)
        NotificationCenter.default.post(name: NSNotification.Name("alertHasBeenDismissed"), object: nil)
    }
}

extension SKStoreReviewController {
    public static func requestReviewInCurrentScene(completion: @escaping () -> Void) {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            DispatchQueue.main.async {
                requestReview(in: scene)
                completion()
            }
        } else {
            completion()
        }
    }
}
