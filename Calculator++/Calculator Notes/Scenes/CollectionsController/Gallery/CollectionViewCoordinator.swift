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
        let controller = WelcomeViewController(coordinator: self, delegate: viewController)
        controller.view.backgroundColor = UIColor.clear
        controller.modalPresentationStyle = .overCurrentContext
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
}
