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
import MessageUI
import FirebaseFirestore

class CollectionViewController: BasicCollectionViewController, UINavigationControllerDelegate, GADBannerViewDelegate, GADInterstitialDelegate, MFMailComposeViewControllerDelegate {
    // MARK: - Variables
    var modelData: [Photo] = [] {
        didSet {
            if modelData.count == 1 {
                collectionView?.reloadData()
            }
        }
    }
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
        if !Defaults.getBool(.premiumPurchased) {
            setupAds()
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Defaults.getBool(.premiumPurchased) {
            return
        }
        
        if check30DaysPassed() {
            let storyboard = UIStoryboard(name: "Purchase",bundle: nil)
            let changePasswordCalcMode = storyboard.instantiateViewController(withIdentifier: "Purchase")
            self.present(changePasswordCalcMode, animated: true)
        }
    }
    
    func saveTodayDate() {
        let now = Date()
        UserDefaults.standard.set(now, forKey: "LastSavedDate")
    }

    func check30DaysPassed() -> Bool {
        if let lastSavedDate = UserDefaults.standard.object(forKey: "LastSavedDate") as? Date {
            let dayDifference = Calendar.current.dateComponents([.day], from: lastSavedDate, to: Date()).day ?? 0
            if dayDifference >= 14 {
                saveTodayDate()
                return true
            } else {
                return false
            }
        }
        saveTodayDate()
        return false
    }
    
    func setupPlaceholderView() {
        view.addSubview(placeholderView)
        
        placeholderView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.left.equalTo(view.safeAreaLayoutGuide.snp.left)
            make.right.equalTo(view.safeAreaLayoutGuide.snp.right)
        }
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
        handleSelectImagesButton()
    }
    
    func shareImageButtonTapped() {
        handleShareImageButton()
    }
    
    func deleteButtonTapped() {
        handleDeleteButton()
    }
    
    // MARK: - Helper Functions
    
    private func handleSelectImagesButton() {
        deselectAllItems()
        toggleEditModeAndReloadData()
    }
    
    private func handleShareImageButton() {
        coordinator?.shareImage(modelData: modelData)
    }
    
    private func handleDeleteButton() {
        Alerts.showConfirmationDelete(controller: self) { [weak self] in
            self?.performDeletionTasks()
        }
    }
    
    private func performDeletionTasks() {
        deleteSelectedFolders()
        deleteSelectedPhotos()
        reloadCollectionViewSections()
    }
    
    private func deselectAllItems() {
        deselectAllFoldersObjects()
        deselectAllFileObjects()
    }
    
    private func toggleEditModeAndReloadData() {
        if isEditMode {
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
                SKStoreReviewController.requestReview()
            }
        }
        isEditMode.toggle()
    }
    
    private func deleteSelectedFolders() {
        for folder in folders where folder.isSelected {
            foldersService.delete(folder: folder.name, basePath: basePath)
        }
        
        folders.removeAll { $0.isSelected }
        
        updateFilesIsExpanded()
        deselectAllFoldersObjects()
    }
    
    private func deleteSelectedPhotos() {
        deleteImagesFromModel()
        modelData.removeAll { $0.isSelected }
        deselectAllFileObjects()
    }
    
    private func deleteImagesFromModel() {
        modelData.forEach { photo in
            if photo.isSelected {
                ModelController.deleteImageObject(name: photo.name, basePath: basePath)
            }
        }
    }
    
    private func updateFilesIsExpanded() {
        if folders.isEmpty {
            filesIsExpanded = true
        }
    }
    
    private func reloadCollectionViewSections() {
        collectionView?.reloadSections(IndexSet(integersIn: 0...1))
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
        placeholderView.isHidden = !presentPlaceHolderImage
        switch section {
        case 0:
            return folders.count
        default:
            return filesIsExpanded ? modelData.count : .zero
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
        
        let folderName = folders[indexPath.row].name.components(separatedBy: Constants.deepSeparatorPath).last ?? ""
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
        isEditMode ? handleEditModeSelection(at: indexPath) : handleNormalModeSelection(at: indexPath)
    }
    
    private func handleEditModeSelection(at indexPath: IndexPath) {
        updateSelectedPhotos(indexPath: indexPath)
    }
    
    private func handleNormalModeSelection(at indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            coordinator?.navigateToFolderViewController(
                indexPath: indexPath,
                folders: folders,
                basePath: basePath
            )
            
        default:
            coordinator?.presentImageGallery(for: indexPath.item)
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
        guard let collectionView = self.collectionView else {
            print("Erro: collectionView não está inicializado.")
            return
        }

        let group = DispatchGroup()
        var newPhotos: [Photo] = []

        for asset in assets {
            group.enter()
            addImage(asset: asset) { photo in
                if let photo = photo {
                    newPhotos.append(photo)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.modelData.append(contentsOf: newPhotos)
            collectionView.reloadData()
        }
    }
    
    func addImage(asset: PHAsset, completion: @escaping (Photo?) -> Void) {
        if asset.mediaType != .image {
            completion(nil)
            return
        }
        
        getAssetThumbnail(asset: asset) { image in
            if let image = image {
                if let photo = ModelController.saveImageObject(image: image, basePath: self.basePath) {
                    completion(photo)
                } else {
                    print("Erro ao salvar a imagem.")
                    completion(nil)
                }
            } else {
                print("Falha ao carregar a miniatura do asset.")
                completion(nil)
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
            
            guard let info = info else {
                completion(nil)
                return
            }
            
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

extension CollectionViewController {
    private func configureNavigationBar() {
        if let navigationTitle = navigationTitle {
            self.title = navigationTitle
        } else {
            self.title = Text.gallery.localized()
        }
    }
    
    private func handleInitialLaunch() {
        if basePath == Constants.deepSeparatorPath {
            Defaults.incrementInt(.launchCounter)
            Defaults.incrementInt(.disableRecoveryButtonCounter)
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
        NotificationCenter.default.post(name: NSNotification.Name("alertHasBeenDismissed"), object: nil)
    }
    
    private func setupAds() {
        adsHandler.setupAds(controller: self,
                            bannerDelegate: self,
                            interstitialDelegate: self)
    }
}
