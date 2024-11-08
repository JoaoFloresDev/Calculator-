import UIKit
import AVKit
import MobileCoreServices
import Photos
import CoreData
import os.log
import SnapKit

struct Video {
    var image: UIImage
    var name: String
    var isSelected: Bool = false
}

extension VideoCollectionViewController: BackupModalViewControllerDelegate {
    func backupExecuted() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.modelData = VideoModelController.fetchImageObjectsInit(basePath: self.basePath)
            self.videoPaths = VideoModelController.fetchPathVideosObjectsInit(basePath: self.basePath)
            
            UIView.performWithoutAnimation {
                self.collectionView?.reloadData()
            }
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

class VideoCollectionViewController: BasicCollectionViewController, UINavigationControllerDelegate {
    
    // MARK: -  Variables
    var modelData: [Video] = [] {
        didSet {
            if modelData.count == 1 {
                UIView.performWithoutAnimation {
                    self.collectionView?.reloadData()
                }
            }
        }
    }
    lazy var loadingAlert = LoadingAlert(in: self)
    
    var videoPaths: [String] = []
    var folders: [Folder] = []
    var modelController = VideoModelController()
    lazy var coordinator = VideoCollectionCoordinator(viewController: self)
    
    var isPremium: Bool {
        return RazeFaceProducts.store.isProductPurchased("Calc.noads.mensal") ||
        RazeFaceProducts.store.isProductPurchased("calcanual") ||
        RazeFaceProducts.store.isProductPurchased("NoAds.Calc") || modelData.count < 3
    }
    
    var isEditMode = false {
        didSet {
            editLeftBarButtonItem?.setEditing(isEditMode)
        }
    }
    
    lazy var placeholderView: PlaceholderView = {
        return PlaceholderView(
            title: Text.emptyVideosTitle.localized(),
            subtitle: Text.emptyVideosSubtitle.localized(),
            image: UIImage(named: Img.emptyVideoIcon.name())
        )
    }()
    
    // MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isPremium {
            self.placeholderView.update(
                title: Text.emptyVideosTitle.localized(),
                subtitle: Text.emptyVideosSubtitle.localized(),
                image: UIImage(named: Img.emptyVideoIcon.name()),
                buttonText: nil,
                buttonAction: nil
            )
        }
        commonViewWillAppear()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modelData = VideoModelController.fetchImageObjectsInit(basePath: basePath)
        videoPaths = VideoModelController.fetchPathVideosObjectsInit(basePath: basePath)
        commonViewDidLoad()
        setupNavigationItems(delegate: self)
        setupFolders()
        self.title = Text.video.localized()
        
        setupPlaceholderView()
        
        if let navigationTitle = navigationTitle {
            self.title = navigationTitle
        } else {
            self.title = Text.video.localized()
        }
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
    
    func setupFolders() {
        foldersService = FoldersService(type: .video)
        folders = foldersService.getFolders(basePath: basePath).map { folderName in
            return Folder(name: folderName, isSelected: false)
        }
        if folders.isEmpty {
            filesIsExpanded = true
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.collectionView?.reloadSections(IndexSet(integer: .zero))
            }
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

extension VideoCollectionViewController: EditLeftBarButtonItemDelegate {
    func selectImagesButtonTapped() {
        self.deselectAllFoldersObjects()
        self.deselectAllFileObjects()
        if isEditMode {
            DispatchQueue.main.async { [weak self] in
                UIView.performWithoutAnimation {
                    self?.collectionView?.reloadData()
                }
            }
        }
        isEditMode.toggle()
    }
    
    func shareImageButtonTapped() {
        let alertController = UIAlertController(
            title: Text.chooseDestination.localized(),
            message: nil,
            preferredStyle: .actionSheet
        )

        let shareAction = UIAlertAction(title: Text.share.localized(), style: .default) { _ in
            var fileURLs = [URL]()
            
            let selectedItems = self.modelData.filter { $0.isSelected }
            
            for video in selectedItems {
                if let index = self.modelData.firstIndex(where: { $0.name == video.name }),
                   let fileURL = self.videoPaths[safe: index],
                   let path = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(fileURL) {
                    fileURLs.append(path)
                }
            }
            
            let selectedFolders = self.folders.filter { $0.isSelected }
            for folder in selectedFolders {
                let folderItems = VideoModelController.fetchPathVideosObjectsInit(basePath: folder.name)
                for folderItem in folderItems {
                    if let folderURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(folderItem) {
                        fileURLs.append(folderURL)
                    }
                }
            }

            if fileURLs.isEmpty {
                return
            }
            self.coordinator.shareImage(modelData: fileURLs)
        }

        let saveAction = UIAlertAction(title: Text.saveToGallery.localized(), style: .default) { _ in
            var fileURLs = [URL]()
            
            let selectedItems = self.modelData.filter { $0.isSelected }
            
            for video in selectedItems {
                if let index = self.modelData.firstIndex(where: { $0.name == video.name }),
                   let videoPath = self.videoPaths[safe: index] {
                    if let documentDirectoryURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
                        let fullPath = documentDirectoryURL.appendingPathComponent(videoPath)
                        
                        // Verificar se o arquivo realmente existe
                        if FileManager.default.fileExists(atPath: fullPath.path) {
                            fileURLs.append(fullPath)
                        } else {
                            print("Erro: arquivo não encontrado em \(fullPath.path)")
                        }
                    } else {
                        print("Erro: não foi possível obter a URL do diretório de documentos.")
                    }
                }
            }
            
            let selectedFolders = self.folders.filter { $0.isSelected }
            for folder in selectedFolders {
                let folderItems = VideoModelController.fetchPathVideosObjectsInit(basePath: folder.name)
                for folderItem in folderItems {
                    if let documentDirectoryURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
                        let folderURL = documentDirectoryURL.appendingPathComponent(folderItem)
                        
                        // Verificar se o arquivo realmente existe
                        if FileManager.default.fileExists(atPath: folderURL.path) {
                            fileURLs.append(folderURL)
                        } else {
                            print("Erro: arquivo não encontrado em \(folderURL.path)")
                        }
                    } else {
                        print("Erro: não foi possível obter a URL do diretório de documentos para a pasta.")
                    }
                }
            }

            // Validar se existem URLs de vídeos válidas
            guard !fileURLs.isEmpty else {
                print("Nenhum vídeo válido encontrado para salvar.")
                return
            }
            
            // Chamar a função para salvar os vídeos
            self.coordinator.saveVideos(modelData: fileURLs)
        }


        let shareWithCalculatorAction = UIAlertAction(title: Text.shareWithOtherCalculator.localized(), style: .default) { _ in
            var fileURLs = [URL]()
            
            let selectedItems = self.modelData.filter { $0.isSelected }
                for video in selectedItems {
                    if let index = self.modelData.firstIndex(where: { $0.name == video.name }),
                       let fileURL = self.videoPaths[safe: index],
                       let path = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(fileURL) {
                        fileURLs.append(path)
                    }
                }
            
            let selectedFolders = self.folders.filter { $0.isSelected }
                for folder in selectedFolders {
                    let folderItems = VideoModelController.fetchPathVideosObjectsInit(basePath: folder.name)
                    for folderItem in folderItems {
                        if let folderURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(folderItem) {
                            fileURLs.append(folderURL)
                        }
                    }
                }

            if fileURLs.isEmpty {
                return
            }
            self.coordinator.shareWithCalculator(modelData: fileURLs)
        }

        let cancelAction = UIAlertAction(title: Text.cancel.localized(), style: .cancel, handler: nil)

        alertController.addAction(shareAction)
        alertController.addAction(shareWithCalculatorAction)
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
    }
    
    func deleteButtonTapped() {
        Alerts.showConfirmationDelete(controller: self) {
            for folder in self.folders where folder.isSelected == true {
                self.folders = self.foldersService.delete(folder: folder.name, basePath: self.basePath).map { folderName in
                    return Folder(name: folderName, isSelected: false)
                }
            }
            if self.folders.isEmpty {
                self.filesIsExpanded = true
            }
            self.deselectAllFoldersObjects()
            for video in self.modelData where video.isSelected == true {
                VideoModelController.deleteImageObject(name: video.name, basePath: self.basePath)
                if let index = self.modelData.firstIndex(where: { $0.name == video.name }) {
                    self.modelData.remove(at: index)
                }
            }
            self.deselectAllFileObjects()
            DispatchQueue.main.async { [weak self] in
                UIView.performWithoutAnimation {
                    self?.collectionView?.reloadData()
                }
            }
        }
    }
}

extension VideoCollectionViewController: AdditionsRightBarButtonItemDelegate {
    func cloudButtonTapped() {
        let controllers = self.tabBarController?.viewControllers
        let navigation = controllers?[0] as? UINavigationController
        
        let collectionViewController = navigation?.viewControllers.first as? CollectionViewController
        
        let navigation1 = controllers?[1] as? UINavigationController
        let videosRootController = navigation1?.viewControllers.first as? VideoCollectionViewController
        
        let vc = BackupModalViewController(
            delegate: self, 
            imagesRootController: collectionViewController,
            videosRootController: videosRootController
        )
        
        vc.modalPresentationStyle = .overCurrentContext
        if let tabBarController = self.tabBarController {
            tabBarController.present(vc, animated: false, completion: nil)
        }
    }
    
    func addPhotoButtonTapped() {
        if isPremium {
            presentPickerController()
        } else {
            Alerts.showBePremiumToUse(controller: self) {
                self.coordinator.presentPurshes()
            }
        }
    }
    
    func addFolderButtonTapped() {
        if isPremium {
            addFolder()
        } else {
            Alerts.showBePremiumToUse(controller: self) {
                self.coordinator.presentPurshes()
            }
        }
    }
    
    func addFolder() {
            showAddFolderDialog()
        }

        private func showAddFolderDialog() {
            Alerts.showInputDialog(
                title: Text.folderTitle.localized(),
                controller: self,
                actionTitle: Text.createActionTitle.localized(),
                cancelTitle: Text.cancelTitle.localized(),
                inputPlaceholder: Text.inputPlaceholder.localized(), actionHandler:  { [weak self] input in
                    self?.handleAddFolderInput(input)
                })
        }

        private func handleAddFolderInput(_ input: String?) {
            guard let input = input else { return }

            if foldersService.checkAlreadyExist(folder: input, basePath: basePath) {
                showFolderAlreadyExistsError()
            } else {
                addNewFolder(input)
            }
        }

        private func addNewFolder(_ folderName: String) {
            folders = foldersService.add(folder: folderName, basePath: basePath).map { folderName in
                return Folder(name: folderName, isSelected: false)
            }
            if folders.count  > 0 {
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else {
                        return
                    }
                    
                    self?.collectionView?.insertItems(at: [IndexPath(item: strongSelf.folders.count - 1, section: 0)])
                }
            } else  {
                collectionView?.reloadSections(IndexSet(integer: .zero))
            }
        }

        private func showFolderAlreadyExistsError() {
            Alerts.showError(
                title: Text.folderNameAlreadyUsedTitle.localized(),
                text: Text.folderNameAlreadyUsedText.localized(),
                controller: self
            ) { [weak self] in
                self?.showAddFolderDialog()
            }
        }
}

// Collection view DataSource & Delegate
extension VideoCollectionViewController {
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
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: folderReuseIdentifier, for: indexPath) as? FolderCollectionViewCell {
                if let folderName = folders[indexPath.row].name.components(separatedBy: Constants.deepSeparatorPath).last {
                    cell.setup(name: folderName)
                    cell.isSelectedCell = folders[indexPath.row].isSelected
                }
                return cell
            }
        default:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? CollectionViewCell {
                if indexPath.item < modelData.count {
                    let image = modelData[indexPath.item]
                    cell.imageCell.image = UI.cropToBounds(image: image.image, width: 200, height: 200)
                    cell.isSelectedCell = modelData[indexPath.item].isSelected
                }
                cell.applyshadowWithCorner()
                
                return cell
            }
        }
        return collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isEditMode {
            handleNormalModeSelection(for: indexPath)
        } else {
            updateSelectedPhotos(indexPath: indexPath)
        }
    }

    // Trata da seleção quando não está em modo de edição
    private func handleNormalModeSelection(for indexPath: IndexPath) {
        switch indexPath.section {
        case .zero:
            coordinator.navigateToVideoCollectionViewController(for: indexPath, folders: folders, basePath: basePath)
        default:
            coordinator.playVideo(videoPaths: videoPaths, indexPath: indexPath)
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
        if kind == UICollectionElementKindSectionHeader {
            // Dequeue and configure the header view
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerView", for: indexPath) as? HeaderView else {
                return UICollectionReusableView()
            }
            if indexPath.section == .zero {
                headerView.messageLabel.text = String()
                headerView.activityIndicatorView.isHidden = true
                headerView.gradientView?.isHidden = false
                headerView.isUserInteractionEnabled = false
            } else if indexPath.section == 1 {
                if !modelData.isEmpty {
                    if filesIsExpanded {
                        headerView.messageLabel.text = Text.hideAllVideos.localized()
                    } else {
                        headerView.messageLabel.text = Text.showAllVideos.localized()
                    }
                }
                headerView.isUserInteractionEnabled = true
                headerView.activityIndicatorView.isHidden = true
                headerView.gradientView?.isHidden = true
                headerView.delegate = self
            }
            return headerView
        } else if kind == UICollectionElementKindSectionFooter {
            // Dequeue and configure the footer view
            guard let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "footerView", for: indexPath) as? FooterView else {
                return UICollectionReusableView()
            }
            
            return footerView
        }
        
        // Return an empty view for other supplementary elements
        return UICollectionReusableView()
    }
}

extension VideoCollectionViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        guard let videoURL = info[UIImagePickerControllerMediaURL] as? URL else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        guard let videoData = try? Data(contentsOf: videoURL) else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        self.dismiss(animated: true, completion: nil)
        
        self.getThumbnailImageFromVideoUrl(url: videoURL) { thumbImage in
            guard let image = thumbImage else { return }
            let result = VideoModelController.saveVideoObject(image: image, video: videoData, basePath: self.basePath)
            if let pathVideo = result.0,
               let imageName = result.1 {
                self.modelData.append(Video(image: image, name: imageName))
                self.videoPaths.append(pathVideo)
                self.collectionView?.reloadSections(IndexSet(integer: 1))
                DispatchQueue.global().async {
                    FirebaseBackupService.updateBackup { _ in
                        Defaults.setString(.lastBackupUpdate, self.getCurrentDateTimeFormatted())
                        Defaults.setInt(.numberOfNonSincronizatedPhotos, 0)
                    }
                }
            }
        }
    }
    
    func getCurrentDateTimeFormatted() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        let currentDate = Date()
        return dateFormatter.string(from: currentDate)
    }
    
    
    func getThumbnailImageFromVideoUrl(url: URL, completion: @escaping ((_ image: UIImage?) -> Void)) {
        DispatchQueue.global().async {
            let asset = AVURLAsset(url: url)
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset)
            avAssetImageGenerator.appliesPreferredTrackTransform = true
            let thumbnailTime = CMTimeMake(2, 1)
            
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumbnailTime, actualTime: nil)
                let thumbImage = UIImage(cgImage: cgThumbImage)
                
                DispatchQueue.main.async {
                    completion(thumbImage)
                }
            } catch {
                os_log("Failed to retrieve thumbnail image from video URL", log: .default, type: .error)
                print(error.localizedDescription)
                
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    private func presentPickerController() {
        coordinator.presentPickerController()
    }
}

extension VideoCollectionViewController: PurchaseViewControllerDelegate {
    func purchased() {
        viewWillAppear(false)
    }
}
