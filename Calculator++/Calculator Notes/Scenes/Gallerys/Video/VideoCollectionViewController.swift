import UIKit
import AVKit
import MobileCoreServices
import Photos
import CoreData

class VideoCollectionViewController: BasicCollectionViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // Variables
    var modelData: [UIImage] = []
    var modelDataVideo: [String] = []
    var modelController = VideoModelController()
    
    // Video adaptation
    var imagePickerController = UIImagePickerController()
    var videoURL: URL?
    
    var isPremium: Bool {
        UserDefaults.standard.set(true, forKey: "NoAds.Calc")
        return RazeFaceProducts.store.isProductPurchased("NoAds.Calc") || UserDefaults.standard.object(forKey: "NoAds.Calc") != nil
    }
    
    var isEditMode = false {
        didSet {
            setEditionMode(isEditMode, animated: true)
        }
    }
    
    // IBOutlet
    @IBOutlet weak var placeholderImage: UIImageView!
    
    // IBAction
    private func presentPickerController() {
        guard UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) else {
            showGenericError()
            return
        }
        
        imagePickerController.sourceType = .savedPhotosAlbum
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [kUTTypeMovie as String]
        present(imagePickerController, animated: true, completion: nil)
    }
    
    // Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionViewLayout()
        setupNavigationItems(delegate: self)
        setupFolders()
        setText(.video)
        modelData = modelController.fetchImageObjectsInit(basePath: basePath)
        modelDataVideo = modelController.fetchPathVideosObjectsInit()
        if let navigationTitle = navigationTitle {
            self.title = navigationTitle
        } else {
            self.setText(.video)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        placeholderImage.image = isPremium ? UIImage(named: "placeholderVideo") : UIImage(named: "placeholderPremium")
    }
    
    func setupFolders() {
        foldersService = FoldersService(type: .video)
        folders = foldersService.getFolders(basePath: basePath)
        self.collectionView?.reloadData()
    }
    
    // Collection View
    func setEditionMode(_ editing: Bool, animated: Bool) {
        editLeftBarButtonItem?.setEditing(editing)
        
        collectionView?.allowsMultipleSelection = editing
        
        if let indexPaths = collectionView?.indexPathsForVisibleItems {
            for indexPath in indexPaths {
                if let cell = collectionView?.cellForItem(at: indexPath) as? CollectionViewCell {
                    cell.isInEditingMode = editing
                }
                if let cell = collectionView?.cellForItem(at: indexPath) as? FolderCollectionViewCell {
                    cell.isInEditingMode = editing
                }
            }
        }
    }
    
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
            return modelData.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: folderReuseIdentifier, for: indexPath) as? FolderCollectionViewCell {
                if let folderName = folders[indexPath.row].components(separatedBy: "@").last {
                    cell.setup(name: folderName)
                }
                return cell
            }
        default:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? CollectionViewCell {
                cell.isInEditingMode = isEditMode
                if indexPath.item < modelData.count {
                    let image = modelData[indexPath.item]
                    cell.imageCell.image = UI.cropToBounds(image: image, width: 200, height: 200)
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
                        controller.basePath = basePath + folders[indexPath.row] + "@"
                        controller.navigationTitle = folders[indexPath.row].components(separatedBy: "@").last
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                }
            default:
                // Reproduz o vídeo
                guard let videoURL = modelDataVideo[safe: indexPath.item],
                      let path = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(videoURL) else {
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
        }
    }
    
    func confirmationDelete() {
        showConfirmationDelete {
            if let selectedCells = self.collectionView?.indexPathsForSelectedItems {
                for cell in selectedCells {
                    if cell.section == 0 {
                        if cell.row < self.folders.count {
                            self.folders = self.foldersService.delete(folder: self.folders[cell.row], basePath: self.basePath)
                        }
                    } else {
                        if cell.row < self.modelData.count {
                            self.modelData.remove(at: cell.row)
                            self.modelController.deleteImageObject(imageIndex: cell.row)
                        }
                    }
                }
                self.collectionView?.deleteItems(at: selectedCells)
            }
        }
    }
    
    // imagePickerController
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
            
            let indexPath = IndexPath(row: self.modelData.count - 1, section: 1)
            self.collectionView?.insertItems(at: [indexPath])
            
            if let pathVideo = self.modelController.saveImageObject(image: image, video: videoData, basePath: self.basePath) {
                self.modelData.append(image)
                self.modelDataVideo.append(pathVideo)
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
                print(error.localizedDescription)
                
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
}

extension VideoCollectionViewController: EditLeftBarButtonItemDelegate {
    func selectImagesButtonTapped() {
        isEditMode.toggle()
    }
    
    func shareImageButtonTapped() {
        guard let selectedCells = collectionView?.indexPathsForSelectedItems,
              !selectedCells.isEmpty else {
            return
        }
        
        do {
            let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            
            let fileURLs = selectedCells.compactMap { indexPath -> URL? in
                let itemIndex = indexPath.item
                
                guard itemIndex < modelDataVideo.count else {
                    return nil
                }
                
                let fileName = modelDataVideo[itemIndex]
                let fileURL = documentsURL.appendingPathComponent(fileName)
                
                return fileURL
            }
            
            let activityController = UIActivityViewController(activityItems: fileURLs, applicationActivities: nil)
            activityController.popoverPresentationController?.sourceView = view
            activityController.popoverPresentationController?.sourceRect = view.frame
            
            present(activityController, animated: true, completion: nil)
        } catch {
            showGenericError()
        }
    }
    
    func deleteButtonTapped() {
        confirmationDelete()
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
        addFolder()
    }
}