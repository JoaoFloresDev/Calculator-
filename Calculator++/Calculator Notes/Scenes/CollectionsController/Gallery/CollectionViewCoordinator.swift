
import FirebaseStorage
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
        viewController?.present(vault, animated: true)
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
        viewController?.navigationController?.pushViewController(controller, animated: true)
    }
    
    func navigateToSettingsTab() {
        selectTab(atIndex: 3)
    }
    
    func shareImage(modelData: [Photo]) {
        let photoArray = selectedImages(from: modelData)
        
        if !photoArray.isEmpty {
            let activityVC = UIActivityViewController(activityItems: photoArray, applicationActivities: nil)
            
            activityVC.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
                if completed {
                    print("Compartilhamento concluído.")
                } else {
                    print("Compartilhamento cancelado.")
                }
                if let shareError = error {
                    print("Erro durante o compartilhamento: \(shareError.localizedDescription)")
                }
            }

            viewController?.present(activityVC, animated: true, completion: {
                print("aqui")
            })
        }
    }
    
    func addPhotoButtonTapped() {
        let picker = AssetsPickerViewController()
        picker.pickerConfig = AssetsPickerConfig()
        picker.pickerDelegate = viewController
        viewController?.present(picker, animated: true)
    }
    
    func presentWelcomeController() {
        guard let viewController = viewController else {
            return
        }
        
        let controller = UINavigationController(rootViewController: OnboardingWelcomeViewController())
        controller.modalPresentationStyle = .fullScreen
        viewController.present(controller, animated: false)
    }
    
    // MARK: - Helper Methods
    
    private func instantiateViewController(from storyboardName: String?, withIdentifier identifier: String) -> UIViewController {
        let storyboard = UIStoryboard(name: storyboardName ?? "", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: identifier)
    }
    
    private func selectTab(atIndex index: Int) {
        guard let tabBarController = viewController?.tabBarController,
              index < tabBarController.viewControllers?.count ?? 0 else { return }
        
        tabBarController.selectedIndex = index
    }
    
    private func selectedImages(from modelData: [Photo]) -> [UIImage] {
        return modelData.filter { $0.isSelected }.map { $0.image }
    }
    
    internal func shareWithCalculator(modelData: [Photo]) {
        guard !modelData.isEmpty else {
            print("Nenhuma foto selecionada para compartilhar com outra calculadora.")
            return
        }
        
        guard let viewController = viewController else {
            return
        }

        var loadingAlert = LoadingAlert(in: viewController)
        loadingAlert.startLoading()
        FirebasePhotoSharingService.createSharedFolderWithPhotos(modelData: modelData) { link, key, error in
            loadingAlert.stopLoading {
                if let error = error {
                    print("Erro ao criar pasta compartilhada: \(error.localizedDescription)")
                    return
                }

                guard let link = link, let key = key else {
                    print("Erro: link de compartilhamento não gerado.")
                    return
                }

                // Agora que o link foi gerado, vamos criar a mensagem com o link real
                let message = "Você pode ver todos seus links criados na aba settings\n\nLink: \(link)\nSenha: \(key)"

                // Cria o alerta com o link real e a senha
                let alertController = UIAlertController(title: "Link secreto criado", message: message, preferredStyle: .alert)

                let copyAction = UIAlertAction(title: "Copiar Link e Senha", style: .default) { _ in
                    let messageToPast = "1. Baixe o app https://apps.apple.com/us/app/sg-secret-gallery-vault/id1479873340\n2. Clique no link \(link)\n3. Digite a senha \(key)"
                    UIPasteboard.general.string = message
                    self.showCopiedAnimation()
                }


                let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)

                alertController.addAction(copyAction)
                alertController.addAction(cancelAction)

                self.viewController?.present(alertController, animated: true)
            }
        }
    }
    
    private func showCopiedAnimation() {
        guard let viewController = self.viewController else { return }
        
        let copiedLabel = UILabel()
        copiedLabel.text = "Link copiado!"
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

    internal func saveImages(modelData: [Photo]) {
        let selectedPhotos = modelData.filter { $0.isSelected }
        
        guard !selectedPhotos.isEmpty else {
            print("Nenhuma foto selecionada para salvar.")
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
        savedLabel.text = "Fotos salvas!"
        savedLabel.font = .boldSystemFont(ofSize: 16)
        savedLabel.textColor = .white
        savedLabel.textAlignment = .center
        savedLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        savedLabel.layer.cornerRadius = 10
        savedLabel.clipsToBounds = true
        
        viewController.view.addSubview(savedLabel)
        
        savedLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(viewController.view.safeAreaLayoutGuide.snp.bottom).offset(-50)
            make.width.equalTo(150)
            make.height.equalTo(40)
        }
        
        savedLabel.alpha = 0
        
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

struct FirebasePhotoSharingService {
   
    // MARK: - Properties
    private static let storage = Storage.storage()
   
    // MARK: - Public Methods
    static func createSharedFolderWithPhotos(modelData: [Photo], completion: @escaping (String?, String?, Error?) -> ()) {
        guard !modelData.isEmpty else {
            completion(nil, nil, NSError(domain: "No photos to upload", code: 400, userInfo: nil))
            return
        }
        
        // Criar uma pasta única com UUID
        let folderName = UUID().uuidString
        let folderRef = storage.reference().child("shared_photos/\(folderName)")
        
        let dispatchGroup = DispatchGroup()
        var uploadErrors: [Error] = []
        
        // Fazer o upload de cada imagem para o Firebase
        for photo in modelData {
            guard let imageData = UIImageJPEGRepresentation(photo.image, 0.8) else {
                print("Erro ao converter a imagem para JPEG.")
                uploadErrors.append(NSError(domain: "Image conversion failed", code: 401, userInfo: nil))
                continue
            }

            let imageName = UUID().uuidString + ".jpg"
            let imageRef = folderRef.child(imageName)
            
            dispatchGroup.enter()
            
            imageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Erro ao fazer upload da imagem: \(error.localizedDescription)")
                    uploadErrors.append(error)
                }
                dispatchGroup.leave()
            }
        }
        
        // Quando todos os uploads forem concluídos, gerar o deep link
        dispatchGroup.notify(queue: .main) {
            if uploadErrors.isEmpty {
                createDynamicLink(for: folderName, completion: completion)
            } else {
                completion(nil,nil, uploadErrors.first)
            }
        }
    }
    
    // MARK: - Private Methods
    private static func createDynamicLink(for folderName: String, completion: @escaping (String?, String?, Error?) -> ()) {
        // Criar um link customizado no formato myapp://photos/folderId
        let folderId = String(folderName.dropLast(4))
        let deepLinkURL = "secrets://shared_photos/\(folderId)"
        let password = String(folderName.suffix(4))
        
        // Retorna o deeplink gerado
        completion(deepLinkURL, password, nil)
    }
}
