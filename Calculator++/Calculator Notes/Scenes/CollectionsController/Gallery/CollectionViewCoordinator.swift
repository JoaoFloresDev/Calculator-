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
}

class SlideAndFadePushAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to) else {
            return
        }
        
        let finalFrame = transitionContext.finalFrame(for: toViewController)
        let containerView = transitionContext.containerView
        let duration = transitionDuration(using: transitionContext)
        
        // Configurações iniciais para o estado de "toViewController"
        toViewController.view.frame = finalFrame.offsetBy(dx: finalFrame.width, dy: 0)
        toViewController.view.alpha = 0.0
        
        // Adiciona a view no containerView
        containerView.addSubview(toViewController.view)
        
        // Animação
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0.8, options: [], animations: {
            toViewController.view.frame = finalFrame
            toViewController.view.alpha = 1.0
        }) { (finished) in
            transitionContext.completeTransition(finished)
        }
    }
}

class SlideAndFadePresentAnimator: NSObject, UIViewControllerTransitioningDelegate {

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideAndFadePresentLikePushAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideAndFadeDismissLikePushAnimator()
    }
}

class SlideAndFadePresentLikePushAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from),
              let toViewController = transitionContext.viewController(forKey: .to) else {
            return
        }
        
        let finalFrame = transitionContext.finalFrame(for: toViewController)
        let initialFrame = finalFrame.offsetBy(dx: finalFrame.width, dy: 0)
        
        let containerView = transitionContext.containerView
        let duration = transitionDuration(using: transitionContext)
        
        // Configurações iniciais para o estado de "toViewController"
        toViewController.view.frame = initialFrame
        
        // Adiciona a view no containerView
        containerView.addSubview(toViewController.view)
        
        // Animação
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0.8, options: [], animations: {
            toViewController.view.frame = finalFrame
            fromViewController.view.frame = fromViewController.view.frame.offsetBy(dx: -finalFrame.width, dy: 0)
        }) { (finished) in
            transitionContext.completeTransition(finished)
        }
    }
}


class SlideAndFadeDismissLikePushAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from),
              let toViewController = transitionContext.viewController(forKey: .to) else {
            return
        }
        
        let initialFrame = transitionContext.initialFrame(for: fromViewController)
        let finalFrame = initialFrame.offsetBy(dx: -initialFrame.width, dy: 0)
        
        let containerView = transitionContext.containerView
        let duration = transitionDuration(using: transitionContext)
        
        // Coloca o "toViewController" abaixo do "fromViewController"
        toViewController.view.frame = initialFrame.offsetBy(dx: initialFrame.width, dy: 0)
        containerView.insertSubview(toViewController.view, belowSubview: fromViewController.view)
        
        // Animação
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0.8, options: [], animations: {
            fromViewController.view.frame = finalFrame
            toViewController.view.frame = initialFrame
        }) { (finished) in
            transitionContext.completeTransition(finished)
        }
    }
}

