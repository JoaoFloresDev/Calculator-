import UIKit
import AVKit
import MobileCoreServices
import Photos
import CoreData
import os.log

class VideoCollectionViewController: BasicCollectionViewController, UINavigationControllerDelegate {
    
    // MARK: -  Variables
    var modelData: [Video] = []
    var videoPaths: [String] = []
    var folders: [Folder] = []
    var modelController = VideoModelController()
    
    var isPremium: Bool {
        return RazeFaceProducts.store.isProductPurchased("NoAds.Calc") || UserDefaults.standard.object(forKey: "NoAds.Calc") != nil
    }
    
    var isEditMode = false {
        didSet {
            editLeftBarButtonItem?.setEditing(isEditMode)
        }
    }
    
    // MARK: - IBOutlet
    @IBOutlet weak var placeholderImage: UIImageView!
    
    // MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        placeholderImage.image = isPremium ? UIImage(named: "placeholderVideo") : UIImage(named: "placeholderPremium")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modelData = modelController.fetchImageObjectsInit(basePath: basePath)
        videoPaths = modelController.fetchPathVideosObjectsInit(basePath: basePath)
        commonViewDidLoad()
        setupNavigationItems(delegate: self)
        setupFolders()
        setText(.video)
        
        if let navigationTitle = navigationTitle {
            self.title = navigationTitle
        } else {
            self.setText(.video)
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
            self.collectionView?.reloadSections(IndexSet(integer: .zero))
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
            collectionView?.reloadData()
        }
        isEditMode.toggle()
    }
    
    func shareImageButtonTapped() {
        var fileURLs = [String]()
        for video in modelData where video.isSelected == true {
            if let index = self.modelData.firstIndex(where: { $0.name == video.name }),
               let fileURL = videoPaths[safe: index] {
                fileURLs.append(fileURL)
            }
        }
        
        if !fileURLs.isEmpty {
            let activityController = UIActivityViewController(activityItems: fileURLs, applicationActivities: nil)
            activityController.popoverPresentationController?.sourceView = view
            activityController.popoverPresentationController?.sourceRect = view.frame
            
            present(activityController, animated: true, completion: nil)
        }
    }
    
    func deleteButtonTapped() {
        showConfirmationDelete {
            for folder in self.folders where folder.isSelected == true {
                self.folders = self.foldersService.delete(folder: folder.name, basePath: self.basePath).map { folderName in
                    return Folder(name: folderName, isSelected: false)
                }
            }
            if self.folders.isEmpty {
                self.filesIsExpanded = true
            }
            self.deselectAllFoldersObjects()
            self.collectionView?.reloadSections(IndexSet(integer: 0))
            
            for video in self.modelData where video.isSelected == true {
                self.modelController.deleteImageObject(name: video.name, basePath: self.basePath)
                if let index = self.modelData.firstIndex(where: { $0.name == video.name }) {
                    self.modelData.remove(at: index)
                }
            }
            self.deselectAllFileObjects()
            self.collectionView?.reloadSections(IndexSet(integer: 1))
        }
    }
}

extension VideoCollectionViewController: AdditionsRightBarButtonItemDelegate {
    func addPhotoButtonTapped() {
        if isPremium {
            presentPickerController()
        } else {
            showBePremiumToUse()
        }
    }
    
    func addFolderButtonTapped() {
        if isPremium {
            addFolder()
        } else {
            showBePremiumToUse()
        }
    }
    
    func addFolder() {
        showInputDialog(title: Text.folderTitle.rawValue.localized(),
                        actionTitle: Text.createActionTitle.rawValue.localized(),
                        cancelTitle: Text.cancelTitle.rawValue.localized(),
                        inputPlaceholder: Text.inputPlaceholder.rawValue.localized(),
                        actionHandler: { (input: String?) in
            if let input = input {
                if !self.foldersService.checkAlreadyExist(folder: input, basePath: self.basePath) {
                    self.folders = self.foldersService.add(folder: input, basePath: self.basePath).map { folderName in
                        return Folder(name: folderName, isSelected: false)
                    }
                    self.collectionView?.reloadSections(IndexSet(integer: .zero))
                } else {
                    self.showError(title: Text.folderNameAlreadyUsedTitle.rawValue.localized(),
                                   text: Text.folderNameAlreadyUsedText.rawValue.localized(),
                                   completion: {
                        self.addFolder()
                    })
                }
            }
        })
    }
}

// Collection view DataSource & Delegate
extension VideoCollectionViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let presentPlaceHolderImage = modelData.isEmpty && folders.isEmpty
        placeholderImage.isHidden = !presentPlaceHolderImage
        
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
                if let folderName = folders[indexPath.row].name.components(separatedBy: deepSeparatorPath).last {
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
            switch indexPath.section {
            case 0:
                let storyboard = UIStoryboard(name: "VideoPlayer", bundle: nil)
                if let controller = storyboard.instantiateViewController(withIdentifier: "VideoCollectionViewController") as? VideoCollectionViewController {
                    if indexPath.row < folders.count {
                        controller.basePath = basePath + folders[indexPath.row].name + "@"
                        controller.navigationTitle = folders[indexPath.row].name.components(separatedBy: "@").last
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                }
            default:
                // Reproduz o vídeo
                guard let videoURL = videoPaths[safe: indexPath.item],
                      let path = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(videoURL) else {
                    os_log("Failed to retrieve video URL", log: .default, type: .error)
                    showGenericError()
                    return
                }
                
                let player = AVPlayer(url: path)
                let playerController = AVPlayerViewController()
                playerController.player = player
                present(playerController, animated: true) {
                    player.play()
                }
            }
        } else {
            updateSelectedPhotos(indexPath: indexPath)
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
            let result = self.modelController.saveImageObject(image: image, video: videoData, basePath: self.basePath)
            if let pathVideo = result.0,
               let imageName = result.1 {
                self.modelData.append(Video(image: image, name: imageName))
                self.videoPaths.append(pathVideo)
                self.collectionView?.reloadSections(IndexSet(integer: 1))
            }
        }
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
        guard UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) else {
            showGenericError()
            return
        }
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .savedPhotosAlbum
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [kUTTypeMovie as String]
        present(imagePickerController, animated: true, completion: nil)
    }
}
