import UIKit
import AVKit
import MobileCoreServices
import Photos
import CoreData
import os.log

struct VideoModel {
    var image: UIImage
    var name: String
}

class VideoCollectionViewController: BasicCollectionViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // Variables
    var modelData: [Video] = []
    var modelDataVideo: [String] = []
    var modelController = VideoModelController()
    
    // Video adaptation
    var imagePickerController = UIImagePickerController()
    var videoURL: URL?
    
    var isPremium: Bool {
        return RazeFaceProducts.store.isProductPurchased("NoAds.Calc") || UserDefaults.standard.object(forKey: "NoAds.Calc") != nil
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        placeholderImage.image = isPremium ? UIImage(named: "placeholderVideo") : UIImage(named: "placeholderPremium")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonViewDidLoad()
        setupNavigationItems(delegate: self)
        setupFolders()
        setText(.video)
        modelData = modelController.fetchImageObjectsInit(basePath: basePath)
        modelDataVideo = modelController.fetchPathVideosObjectsInit(basePath: basePath)
        
        if let navigationTitle = navigationTitle {
            self.title = navigationTitle
        } else {
            self.setText(.video)
        }
    }
    
    func setupFolders() {
        foldersService = FoldersService(type: .video)
        folders = foldersService.getFolders(basePath: basePath)
        if folders.isEmpty {
            filesIsExpanded = true
        } else {
            self.collectionView?.reloadSections(IndexSet(integer: .zero))
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
                    cell.imageCell.image = UI.cropToBounds(image: image.image, width: 200, height: 200)
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
        }
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
            } else if indexPath.section == 1 {
                if !modelData.isEmpty {
                    if filesIsExpanded {
                        headerView.messageLabel.text = Text.hideAllVideos.localized()
                    } else {
                        headerView.messageLabel.text = Text.showAllVideos.localized()
                    }
                }
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
    
    func confirmationDelete() {
        showConfirmationDelete {
            if let selectedCells = self.collectionView?.indexPathsForSelectedItems {
                for cell in selectedCells {
                    if cell.section == 0 {
                        if cell.row < self.folders.count {
                            self.folders = self.foldersService.delete(folder: self.folders[cell.row], basePath: self.basePath)
                        }
                        self.collectionView?.reloadSections(IndexSet(integer: 0))
                    } else {
                        if cell.row < self.modelData.count {
                            self.modelController.deleteImageObject(name: self.modelData[cell.row].name)
                            self.modelData.remove(at: cell.row)
                        }
                        self.collectionView?.reloadSections(IndexSet(integer: 1))
                    }
                }
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
            let result = self.modelController.saveImageObject(image: image, video: videoData, basePath: self.basePath)
            if let pathVideo = result.0,
               let imageName = result.1 {
                self.modelData.append(Video(image: image, name: imageName))
                self.modelDataVideo.append(pathVideo)
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
            os_log("Failed to share video", log: .default, type: .error)
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
        if isPremium {
            addFolder()
        } else {
            showBePremiumToUse()
        }
    }
}
