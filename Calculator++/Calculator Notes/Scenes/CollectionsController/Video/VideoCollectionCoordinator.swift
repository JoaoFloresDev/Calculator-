import Photos
import FirebaseStorage
import Firebase
import Foundation
import AssetsPickerViewController
import UIKit
import ImageViewer
import UIKit
import AVKit
import MobileCoreServices
import Photos
import CoreData
import os.log
import SnapKit

protocol VideoCollectionCoordinatorProtocol {
    func presentPurshes()
    func navigateToVideoCollectionViewController(
        for indexPath: IndexPath,
        folders: [Folder],
        basePath: String
    )
    func playVideo(
        videoPaths: [String],
        indexPath: IndexPath
    )
    func presentPickerController()
    func shareImage(modelData: [URL])
    func saveVideos(modelData: [URL])
    func shareWithCalculator(modelData: [URL])
}

class VideoCollectionCoordinator: VideoCollectionCoordinatorProtocol {
    func shareImage(modelData: [URL]) {
        guard let viewController = viewController else { return }
        let activityController = UIActivityViewController(activityItems: modelData, applicationActivities: nil)
        activityController.popoverPresentationController?.sourceView = viewController.view
        activityController.popoverPresentationController?.sourceRect = viewController.view.frame
        
        viewController.present(activityController, animated: true, completion: nil)
    }

    func saveVideos(modelData: [URL]) {
        let validURLs = modelData.filter { FileManager.default.fileExists(atPath: $0.path) }
        
        guard !validURLs.isEmpty else {
            print("Nenhum vídeo válido para salvar.")
            return
        }
        
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                print("Permissão para acessar a galeria foi negada.")
                return
            }
            
            for fileURL in validURLs {
                self.saveVideoToPhotoLibrary(fileURL: fileURL)
            }
        }
    }

    private func saveVideoToPhotoLibrary(fileURL: URL) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileURL)
        }) { success, error in
            if let error = error {
                print("Erro ao salvar o vídeo: \(error.localizedDescription)")
            } else if success {
                print("Vídeo salvo com sucesso na galeria!")
            }
        }
    }


    internal func shareWithCalculator(modelData: [URL]) {
        guard !modelData.isEmpty else {
//            print(Text.noVideoToShareMessage)
            return
        }
        
        guard let viewController = viewController else { return }

        var loadingAlert = LoadingAlert(in: viewController)
        loadingAlert.startLoading()
        
        // Simula a criação de uma pasta compartilhada no Firebase
        FirebasePhotoSharingService.createSharedFolderWithVideos(modelData: modelData) { link, key, error in
            loadingAlert.stopLoading {
                if let error = error {
                    print(Text.errorCreatingSharedFolder.rawValue + "\(error.localizedDescription)")
                    return
                }

                guard let link = link, let key = key else {
                    print("Erro: link de compartilhamento não gerado.")
                    return
                }

                let message = Text.sharedLinkMessagePrefix.localized() + link + Text.sharedLinkMessageSuffix.localized() + key
                let alertController = UIAlertController(title: Text.sharedLinkTitle.localized(), message: message, preferredStyle: .alert)

                let copyAction = UIAlertAction(title: Text.copyLinkButtonTitle.localized(), style: .default) { _ in
                    let messageToPaste = Text.downloadAppMessage.localized() + " " + link + " " + Text.downloadAppPasswordPrefix.localized() + " " + key
                    UIPasteboard.general.string = messageToPaste
                    self.showCopiedAnimation()
                }

                let cancelAction = UIAlertAction(title: Text.cancelButtonTitle.localized(), style: .cancel, handler: nil)

                alertController.addAction(copyAction)
                alertController.addAction(cancelAction)

                self.viewController?.present(alertController, animated: true)
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
            make.bottom.equalTo(viewController.view.safeAreaLayoutGuide.snp.bottom).offset(-50)
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
    
    typealias Controller = UIViewController & UIImagePickerControllerDelegate & UINavigationControllerDelegate & PurchaseViewControllerDelegate
    weak var viewController: Controller?
    
    init(viewController: Controller) {
        self.viewController = viewController
    }
    
    func presentPurshes() {
        let storyboard = UIStoryboard(name: "Purchase",bundle: nil)
        let changePasswordCalcMode = storyboard.instantiateViewController(withIdentifier: "Purchase")
        if let changePasswordCalcMode = changePasswordCalcMode as? PurchaseViewController {
            changePasswordCalcMode.delegate = viewController
        }
        DispatchQueue.main.async {
            self.viewController?.present(changePasswordCalcMode, animated: true)
        }
    }
    
    func navigateToVideoCollectionViewController(
        for indexPath: IndexPath,
        folders: [Folder],
        basePath: String
    ) {
        let storyboard = UIStoryboard(name: "VideoPlayer", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "VideoCollectionViewController") as? VideoCollectionViewController,
              indexPath.row < folders.count else { return }
        
        controller.basePath = basePath + folders[indexPath.row].name + Constants.deepSeparatorPath
        controller.navigationTitle = folders[indexPath.row].name.components(separatedBy: Constants.deepSeparatorPath).last
        DispatchQueue.main.async {
            self.viewController?.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func playVideo(
        videoPaths: [String],
        indexPath: IndexPath
    ) {
        guard let viewController = viewController else { return }

        guard let videoURL = videoPaths[safe: indexPath.item],
              let path = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(videoURL) else {
            DispatchQueue.main.async {
                os_log("Failed to retrieve video URL", log: .default, type: .error)
                Alerts.showGenericError(controller: viewController)
            }
            return
        }

        let player = AVPlayer(url: path)
        let playerController = AVPlayerViewController()
        playerController.player = player
        DispatchQueue.main.async {
            viewController.present(playerController, animated: true) {
                player.play()
            }
        }
    }
    
    func presentPickerController() {
        guard let viewController = viewController else { return }
        
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                DispatchQueue.main.async {
                    guard UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) else {
                        Alerts.showGenericError(controller: viewController)
                        return
                    }
                    let imagePickerController = UIImagePickerController()
                    imagePickerController.sourceType = .savedPhotosAlbum
                    imagePickerController.delegate = viewController
                    imagePickerController.mediaTypes = [kUTTypeMovie as String]
                    viewController.present(imagePickerController, animated: true, completion: nil)
                }
            case .denied, .restricted, .notDetermined:
                DispatchQueue.main.async {
                    Alerts.showGenericError(controller: viewController)
                }
            default:
                break
            }
        }
    }
}
