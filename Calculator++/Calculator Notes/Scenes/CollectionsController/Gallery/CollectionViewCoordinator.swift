import FirebaseStorage
import Photos
import Firebase
import Foundation
import AssetsPickerViewController
import UIKit
import ImageViewer

protocol CollectionViewCoordinatorProtocol: AnyObject {
    func presentChangePasswordCalcMode()
    func presentImageGallery(for photoIndex: Int)
    func navigateToFolderViewController(indexPath: IndexPath, folders: [Folder], basePath: String)
    func navigateToSettingsTab()
    func shareImage(modelData: [Photo])
    func addPhotoButtonTapped()
    func presentWelcomeController()
    func shareWithCalculator(modelData: [Photo])
    func saveImages(modelData: [Photo])
}

class CollectionViewCoordinator: CollectionViewCoordinatorProtocol {
    
    // MARK: - Properties
    weak var viewController: CollectionViewController?
    
    // MARK: - Initializer
    init(_ viewController: CollectionViewController) {
        self.viewController = viewController
    }
    
    // MARK: - Protocol Methods
    func presentChangePasswordCalcMode() {
        let vault = VaultViewController(mode: .create)
        vault.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            self.viewController?.present(vault, animated: true)
        }
    }
    
    func presentImageGallery(for photoIndex: Int) {
        guard let viewController = viewController,
              photoIndex < viewController.modelData.count else { return }
        
        let galleryViewController = GalleryViewController(startIndex: photoIndex, itemsDataSource: viewController)
        viewController.presentImageGallery(galleryViewController)
    }
    
    func navigateToFolderViewController(indexPath: IndexPath, folders: [Folder], basePath: String) {
        guard let controller = viewController?.storyboard?.instantiateViewController(withIdentifier: "CollectionViewController") as? CollectionViewController,
              indexPath.row < folders.count else {
            return
        }
        controller.basePath = basePath + folders[indexPath.row].name + Constants.deepSeparatorPath
        controller.navigationTitle = folders[indexPath.row].name.components(separatedBy: Constants.deepSeparatorPath).last
        DispatchQueue.main.async {
            self.viewController?.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func navigateToSettingsTab() {
        selectTab(atIndex: 3)
    }
    
    func shareImage(modelData: [Photo]) {
        guard !modelData.isEmpty else {
            if let viewController = viewController {
                Alerts.showAlert(
                    title: Text.errorTitle.localized(),
                    text: Text.noPhotoToShareMessage.localized(),
                    controller: viewController
                )
            }
                return
            }
        
        let activityVC = UIActivityViewController(activityItems: modelData.map { $0.image }, applicationActivities: nil)
        
        activityVC.completionWithItemsHandler = { (_, completed, _, error) in
            if completed {
                print(Text.shareCompleteMessage)
            } else {
                print(Text.shareCancelMessage)
            }
            
            if let shareError = error {
                print(Text.shareErrorMessage.localized() + "\(shareError.localizedDescription)")
            }
        }
        DispatchQueue.main.async {
            self.viewController?.present(activityVC, animated: true)
        }
    }

    func addPhotoButtonTapped() {
        let pickerConfig = AssetsPickerConfig()
        pickerConfig.albumIsShowHiddenAlbum = true
        let picker = AssetsPickerViewController()
        picker.pickerConfig = pickerConfig
        picker.pickerDelegate = viewController
        DispatchQueue.main.async {
            self.viewController?.present(picker, animated: true)
        }
    }
    
    func presentWelcomeController() {
        guard let viewController = viewController else { return }
        
        let controller = UINavigationController(rootViewController: OnboardingWelcomeViewController())
        controller.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            viewController.present(controller, animated: false)
        }
    }
    
    // MARK: - Helper Methods
    
    private func selectTab(atIndex index: Int) {
        guard let tabBarController = viewController?.tabBarController,
              index < tabBarController.viewControllers?.count ?? 0 else { return }
        
        tabBarController.selectedIndex = index
    }
    
    private func selectedImages(from modelData: [Photo]) -> [UIImage] {
        return modelData.filter { $0.isSelected }.map { $0.image }
    }
    
    internal func shareWithCalculator(modelData: [Photo]) {
        guard let viewController = viewController else { return }

        guard !modelData.isEmpty else {
                Alerts.showAlert(
                    title: Text.errorTitle.localized(),
                    text: Text.noPhotoToShareMessage.localized(),
                    controller: viewController
                )
            return
        }
        
        let loadingAlert = LoadingAlert(in: viewController)
        loadingAlert.startLoading {
            FirebasePhotoSharingService.createSharedFolderWithPhotos(modelData: modelData) { link, key, error in
                loadingAlert.stopLoading {
                    if let error = error {
                        Alerts.showAlert(
                                        title: Text.errorTitle.localized(),
                                        text: Text.errorCreatingSharedFolder.localized() + "\(error.localizedDescription)",
                                        controller: viewController
                                    )
                        return
                    }

                    guard let link = link, let key = key else {
                        Alerts.showGenericError(controller: viewController)
                        return
                    }

                    let message = Text.sharedLinkMessagePrefix.localized() + link + Text.sharedLinkMessageSuffix.localized() + key
                    let alertController = UIAlertController(title: Text.sharedLinkTitle.localized(), message: message, preferredStyle: .alert)

                    let copyAction = UIAlertAction(title: Text.copyLinkButtonTitle.localized(), style: .default) { _ in
                        let appPath = "https://apps.apple.com/sa/app/sg-secret-gallery-vault/id1479873340"
                        let messageToPaste = """
                        \(Text.sharedContentIntro.localized())
                        \(Text.sharedContentStep2.localized())\(link)
                        \(Text.sharedContentStep3.localized())\(key)
                        """
                        UIPasteboard.general.string = messageToPaste
                        self.showCopiedAnimation()
                    }
                    
                    let shareAction = UIAlertAction(title: Text.sendLinkAndPassword.localized(), style: .default) { _ in
                        guard !modelData.isEmpty else { return }
                        let appPath = "https://apps.apple.com/sa/app/sg-secret-gallery-vault/id1479873340"
                        let messageToPaste = """
                        \(Text.sharedContentIntro.localized())
                        \(Text.sharedContentStep2.localized())\(link)
                        \(Text.sharedContentStep3.localized())\(key)
                        """
                        
                        let activityVC = UIActivityViewController(activityItems: [messageToPaste], applicationActivities: nil)
                        
                        activityVC.completionWithItemsHandler = { (_, completed, _, error) in
                            if completed {
                                print(Text.shareCompleteMessage)
                            } else {
                                print(Text.shareCancelMessage)
                            }
                            
                            if let shareError = error {
                                print(Text.shareErrorMessage.localized() + "\(shareError.localizedDescription)")
                            }
                        }
                        DispatchQueue.main.async {
                            viewController.present(activityVC, animated: true)
                        }
                    }
            
                    let cancelAction = UIAlertAction(title: Text.cancelButtonTitle.localized(), style: .cancel, handler: nil)

                    alertController.addAction(copyAction)
                    alertController.addAction(shareAction)
                    alertController.addAction(cancelAction)
                    DispatchQueue.main.async {
                        self.viewController?.present(alertController, animated: true)
                    }
                    if var secretLinks = Defaults.getStringArray(.secretLinks) {
                        secretLinks.append("\(link)@@\(key)")
                        Defaults.setStringArray(.secretLinks, secretLinks)
                    } else {
                        Defaults.setStringArray(.secretLinks, ["\(link)@@\(key)"])
                    }
            
                }
            }
        }
    }
    
    private func showCopiedAnimation() {
        guard let viewController = self.viewController else { return }
        
        let copiedLabel = UILabel()
        copiedLabel.text = Text.copiedMessage.localized()
        copiedLabel.font = .boldSystemFont(ofSize: 16)
        copiedLabel.textColor = .white
        copiedLabel.textAlignment = .center
        copiedLabel.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        copiedLabel.layer.cornerRadius = 10
        copiedLabel.clipsToBounds = true
        
        viewController.view.addSubview(copiedLabel)
        
        copiedLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(viewController.view.safeAreaLayoutGuide.snp.top).offset(50)
            make.width.equalTo(150)
            make.height.equalTo(40)
        }
        
        copiedLabel.alpha = 0
        
        UIView.animate(withDuration: 0.3, animations: {
            copiedLabel.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 1.5, options: .curveEaseOut, animations: {
                copiedLabel.alpha = 0
            }) { _ in
                copiedLabel.removeFromSuperview()
            }
        }
    }

    internal func saveImages(modelData: [Photo]) {
        let selectedPhotos = modelData
        
        guard !selectedPhotos.isEmpty else {
            guard !selectedPhotos.isEmpty else {
                if let viewController = viewController {
                    Alerts.showAlert(
                        title: Text.errorTitle.localized(),
                        text: Text.noPhotoToSaveMessage.localized(),
                        controller: viewController
                    )
                }
                    return
                }
            return
        }

        for photo in selectedPhotos {
            UIImageWriteToSavedPhotosAlbum(photo.image, nil, nil, nil)
        }
        
        showSavedAnimation()
    }

    private func showSavedAnimation() {
        guard let viewController = self.viewController else { return }
        
        let savedLabel = UILabel()
        savedLabel.text = Text.savedMessage.localized()
        savedLabel.font = .boldSystemFont(ofSize: 16)
        savedLabel.textColor = .white
        savedLabel.textAlignment = .center
        savedLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        savedLabel.layer.cornerRadius = 10
        savedLabel.clipsToBounds = true
        
        viewController.view.addSubview(savedLabel)
        
        savedLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(viewController.view.safeAreaLayoutGuide.snp.top).offset(20)
            make.width.equalTo(200)
            make.height.equalTo(40)
        }
        
        savedLabel.alpha = 0
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: {
                savedLabel.alpha = 1
            }) { _ in
                UIView.animate(withDuration: 0.3, delay: 2.0, options: .curveEaseOut, animations: {
                    savedLabel.alpha = 0
                }) { _ in
                    savedLabel.removeFromSuperview()
                }
            }
        }
    }
}
