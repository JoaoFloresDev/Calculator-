import UIKit
import SnapKit
import AVKit

class PhotoViewController: UIViewController {

    // MARK: - Properties
    private var photoURLs: [URL]
    private var collectionView: UICollectionView!
    private var downloadButton: UIButton!
    private let hideDeleteButton: Bool
    lazy var loadingAlert = LoadingAlert(in: self)  // Usando o loadingAlert personalizado
    let fileID: String
    
    init(photoURLs: [URL], fileID: String, hideDeleteButton: Bool = false) {
        self.photoURLs = photoURLs
        self.fileID = fileID
        self.hideDeleteButton = hideDeleteButton
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupCloseButton()
        setupDeleteButton()  // Configura o botão de exclusão
        setupCollectionView()
        setupDownloadButton()
    }

    // MARK: - Setup Methods
    private func setupView() {
        view.backgroundColor = .white
        title = Text.sharedPhotosTitle.localized()
        navigationController?.navigationBar.prefersLargeTitles = false
    }

    private func setupCloseButton() {
        let closeButton = UIBarButtonItem(title: Text.close.localized(), style: .plain, target: self, action: #selector(closeViewController))
        navigationItem.leftBarButtonItem = closeButton
    }

    private func setupDeleteButton() {
        let deleteButton = UIButton(type: .system)
        let deleteImage = UIImage(systemName: "trash")?.withRenderingMode(.alwaysTemplate)
        
        deleteButton.setImage(deleteImage, for: .normal)
        deleteButton.tintColor = .systemRed
        deleteButton.imageView?.contentMode = .scaleAspectFit
        deleteButton.imageEdgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        deleteButton.addTarget(self, action: #selector(confirmDelete), for: .touchUpInside)

        deleteButton.isHidden = hideDeleteButton
        
        let barButtonItem = UIBarButtonItem(customView: deleteButton)
        navigationItem.rightBarButtonItem = barButtonItem
    }

    @objc private func closeViewController() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc private func confirmDelete() {
        let alert = UIAlertController(
            title: Text.deleteConfirmationTitle.localized(),
            message: Text.deleteConfirmationMessage.localized(),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: Text.deleteConfirmationCancel.localized(), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: Text.deleteConfirmationDelete.localized(), style: .destructive) { _ in
            self.deleteSharedFolder()
        })
        present(alert, animated: true, completion: nil)
    }

    private func deleteSharedFolder() {
        loadingAlert.startLoading {
            FirebasePhotoSharingService.deleteSharedFolderWithPhotos(folderId: self.fileID) { error in
                self.loadingAlert.stopLoading {
                    if let error = error {
                        if (error as NSError).domain == "FIRStorageErrorDomain" && (error as NSError).code == -13021 {
                            Alerts.showError(title: Text.deleteErrorTitle.localized(), text: Text.deleteErrorMessage.localized(), controller: self, completion: {})
                        } else {
                            Alerts.showError(title: Text.deleteErrorTitle.localized(), text: Text.deleteErrorMessage.localized(), controller: self, completion: {
                                self.dismiss(animated: true)
                            })
                        }
                    } else {
                        Alerts.showAlert(title: Text.folderDeletedTitle.localized(), text: Text.folderDeletedMessage.localized(), controller: self) {
                            self.removeLinkFromDefaults()
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }

    private func removeLinkFromDefaults() {
        var updatedCellTitles = Defaults.getStringArray(.secretLinks) ?? []
        if let index = updatedCellTitles.firstIndex(of: self.fileID) {
            updatedCellTitles.remove(at: index)
            Defaults.setStringArray(.secretLinks, updatedCellTitles)
        }
    }


    private func setupCollectionView() {
        let screenWidth = self.view.frame.size.width - 100
        let layout = FlowLayout(screenWidth: screenWidth)
        let spacing: CGFloat = 10
        let itemWidth = (view.bounds.width - (4 * spacing)) / 3

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        view.addSubview(collectionView)

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.left.right.equalToSuperview().inset(10)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-60)
        }
    }

    private func setupDownloadButton() {
        downloadButton = UIButton(type: .system)
        downloadButton.setTitle(Text.savePhotosButtonText.localized(), for: .normal)
        downloadButton.backgroundColor = .systemBlue
        downloadButton.tintColor = .white
        downloadButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        downloadButton.layer.cornerRadius = 8
        downloadButton.addTarget(self, action: #selector(downloadAllPhotos), for: .touchUpInside)
        view.addSubview(downloadButton)
        
        downloadButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(60)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-24)
        }
    }

    // MARK: - Download Logic
    @objc private func downloadAllPhotos() {
        loadingAlert.startLoading {
            let dispatchGroup = DispatchGroup()
            
            for url in self.photoURLs {
                dispatchGroup.enter()
                URLSession.shared.dataTask(with: url) { data, response, error in
                    if let error = error {
                        DispatchQueue.main.async {
                            Alerts.showError(title: Text.savePhotosErrorTitle.localized(), text: "\(Text.savePhotosErrorMessage.localized()) \(error.localizedDescription)", controller: self, completion: {})
                        }
                        dispatchGroup.leave()
                        return
                    }
                    
                    guard let data = data else {
                        DispatchQueue.main.async {
                            Alerts.showError(title: Text.savePhotosErrorTitle.localized(), text: Text.processImageErrorMessage.localized(), controller: self, completion: {})
                        }
                        dispatchGroup.leave()
                        return
                    }

                    if url.pathExtension == "mov" || url.pathExtension == "mp4" {
                        self.saveVideoToLocal(data: data, url: url)
                    } else if let image = UIImage(data: data) {
                        self.saveImageToLocal(image: image)
                    }
                    
                    dispatchGroup.leave()
                }.resume()
            }
            
            dispatchGroup.notify(queue: .main) {
                self.loadingAlert.stopLoading()  // Para o loadingAlert após concluir o download e salvamento
                Alerts.showAlert(title: Text.photosSavedTitle.localized(), text: Text.photosSavedMessage.localized(), controller: self)
            }
        }
    }

    private func saveImageToLocal(image: UIImage) {
        ModelController.saveImageObject(image: image, basePath: "@")
    }
    
    private func saveVideoToLocal(data: Data, url: URL) {
        guard let thumbnailImage = getThumbnailImage(forUrl: url) else {
            return
        }
        
        let (videoName, imageName) = VideoModelController.saveVideoObject(image: thumbnailImage, video: data, basePath: "@")
        
        if videoName == nil || imageName == nil {
            Alerts.showError(title: Text.savePhotosErrorTitle.localized(), text: Text.saveVideoErrorMessage.localized(), controller: self, completion: {})
        }
    }

    private func getThumbnailImage(forUrl url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let assetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImageGenerator.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 1, preferredTimescale: 60)
        do {
            let cgImage = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension PhotoViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoURLs.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        let url = photoURLs[indexPath.item]

        cell.startLoading()
        
        if url.pathExtension == "mov" || url.pathExtension == "mp4" {
            DispatchQueue.global().async {
                if let thumbnail = self.getThumbnailImage(forUrl: url) {
                    DispatchQueue.main.async {
                        cell.imageView.image = thumbnail
                        cell.stopLoading()
                    }
                }
            }
        } else {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        cell.imageView.image = image
                        cell.stopLoading()
                    }
                }
            }.resume()
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let url = photoURLs[indexPath.item]
        if url.pathExtension == "mov" || url.pathExtension == "mp4" {
            let player = AVPlayer(url: url)
            let playerController = AVPlayerViewController()
            playerController.player = player
            present(playerController, animated: true) {
                player.play()
            }
        }
    }
}

// MARK: - PhotoCell
class PhotoCell: UICollectionViewCell {
    
    let imageView = UIImageView()
    private let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .medium)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        contentView.addSubview(activityIndicator)
        
        imageView.backgroundColor = .white
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        setupShadow()  // Configuração da sombra
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startLoading() {
        activityIndicator.startAnimating()
    }
    
    func stopLoading() {
        activityIndicator.stopAnimating()
    }
    
    private func setupShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 4
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.masksToBounds = false
    }
}
