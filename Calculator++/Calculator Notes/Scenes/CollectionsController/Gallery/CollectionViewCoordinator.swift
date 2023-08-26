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
}

class CollectionViewCoordinator: CollectionViewCoordinatorProtocol {
    weak var viewController: CollectionViewController?
    
    init(_ viewController: CollectionViewController) {
        self.viewController = viewController
    }
    
    func presentChangePasswordCalcMode() {
        let storyboard = UIStoryboard(name: "CalculatorMode", bundle: nil)
        let changePasswordCalcMode = storyboard.instantiateViewController(withIdentifier: "ChangePasswordCalcMode")
        viewController?.present(changePasswordCalcMode, animated: true)
    }
    
    func presentImageGallery(for photoIndex: Int) {
        guard let viewController = viewController else {
            return
        }
        
        guard photoIndex < viewController.modelData.count else {
            return
        }

        let galleryViewController = GalleryViewController(startIndex: photoIndex, itemsDataSource: viewController)
        viewController.presentImageGallery(galleryViewController)
    }
    
    func navigateToFolderViewController(indexPath: IndexPath, folders: [Folder], basePath: String) {
        guard let controller = viewController?.storyboard?.instantiateViewController(withIdentifier: "CollectionViewController") as? CollectionViewController,
              indexPath.row < folders.count else {
            return
        }

        controller.basePath = basePath + folders[indexPath.row].name + Constants.deepSeparatorPath.value()
        controller.navigationTitle = folders[indexPath.row].name.components(separatedBy: Constants.deepSeparatorPath.value()).last
        viewController?.navigationController?.pushViewController(controller, animated: true)
    }
    
    func navigateToSettingsTab() {
        if let tabBarController = viewController?.tabBarController {
            let desiredTabIndex = 3
            if desiredTabIndex < tabBarController.viewControllers?.count ?? 0 {
                tabBarController.selectedIndex = desiredTabIndex
            }
        }
    }
    
    func shareImage(modelData: [Photo]) {
        var photoArray = [UIImage]()
        for photo in modelData where photo.isSelected == true {
            photoArray.append(photo.image)
        }

        if !photoArray.isEmpty {
            let activityVC = UIActivityViewController(activityItems: photoArray, applicationActivities: nil)
            viewController?.present(activityVC, animated: true)
        }
    }
    
    func addPhotoButtonTapped() {
        let picker = AssetsPickerViewController()
        picker.pickerConfig = AssetsPickerConfig()
        picker.pickerDelegate = viewController
        viewController?.present(picker, animated: true)
    }
}
