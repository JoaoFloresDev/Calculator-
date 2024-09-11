import Photos
import SnapKit
import Foundation
import Network
import UIKit
import Photos
//import AssetsPickerViewController
import DTPhotoViewerController
import CoreData
import NYTPhotoViewer
//import ImageViewer
import StoreKit
import GoogleMobileAds
import SceneKit
import simd
import Photos
import StoreKit
import Foundation
import AVFoundation
import AVKit
import MessageUI
import FirebaseFirestore

// MARK: - THIRTY SCREEN
class OnboardingAddPhotosViewController: UIViewController {
    var slideAndFadeAnimator: SlideAndFadePresentAnimator?
    
    lazy var onboardingView = OnboardingView(
        title: Text.addPhotosOnboarding_title.localized(),
        subtitle: Text.addPhotosOnboarding_subtitle.localized(),
        startButtonTitle: Text.addPhotosOnboarding_startButtonTitle.localized(),
        skipButtonTitle: Text.addPhotosOnboarding_skipButtonTitle.localized(),
        delegate: self
    )
    
    private var totalAssets = 0 // Contador para o número total de assets
    private var processedAssets = 0 // Contador para o número de assets processados
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Defaults.setBool(.notFirstUse, true)
        
        view.addSubview(onboardingView)
        navigationController?.navigationBar.isHidden = true
        
        onboardingView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        didTapSecondaryButton()
    }
    
    override  func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: NSNotification.Name("alertHasBeenDismissed"), object: nil)
    }
}

extension OnboardingAddPhotosViewController: OnboardingViewDelegate, AssetsPickerViewControllerDelegate {
    
    func didTapPrimaryButton() {
        let picker = AssetsPickerViewController()
        picker.pickerConfig = AssetsPickerConfig()
        picker.pickerDelegate = self
        self.present(picker, animated: true)
    }
    
    func didTapSecondaryButton() {
        slideAndFadeAnimator = SlideAndFadePresentAnimator()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeViewController = storyboard.instantiateViewController(withIdentifier: "Home")
        homeViewController.modalPresentationStyle = .fullScreen
        homeViewController.transitioningDelegate = slideAndFadeAnimator
        self.present(homeViewController, animated: false)
    }
    
    func assetsPicker(controller: AssetsPickerViewController, selected assets: [PHAsset]) {
        totalAssets = assets.count
        processedAssets = 0 // Zerar o contador de assets processados
        
        for asset in assets {
            addImage(asset: asset) { [weak self] photo in
                guard let self = self else {
                    print("Erro: self foi desalocado.")
                    return
                }
                self.processedAssets += 1
                if self.processedAssets == self.totalAssets {
                    slideAndFadeAnimator = SlideAndFadePresentAnimator()
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let homeViewController = storyboard.instantiateViewController(withIdentifier: "Home")
                    homeViewController.modalPresentationStyle = .fullScreen
                    homeViewController.transitioningDelegate = slideAndFadeAnimator
                    self.present(homeViewController, animated: true)
                }
            }
        }
    }
    
    func addImage(asset: PHAsset, completion: @escaping (Photo?) -> Void) {
        if asset.mediaType != .image {
            completion(nil)
            return
        }
        
        getAssetThumbnail(asset: asset) { image in
            if let image = image {
                if let photo = ModelController.saveImageObject(image: image, basePath: Constants.deepSeparatorPath) {
                    completion(photo)
                } else {
                    print("Erro ao salvar a imagem.")
                    completion(nil)
                }
            } else {
                print("Falha ao carregar a miniatura do asset.")
                completion(nil)
            }
        }
    }
        
    func getAssetThumbnail(asset: PHAsset, completion: @escaping (UIImage?) -> Void) {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.isSynchronous = false
        option.isNetworkAccessAllowed = true
        
        manager.requestImage(for: asset,
                             targetSize: CGSize(width: 1500, height: 1500),
                             contentMode: .aspectFit,
                             options: option) { (result, info) in
            
            guard let info = info else {
                completion(nil)
                return
            }
            
            let isDegraded = (info[PHImageResultIsDegradedKey] as? NSNumber)?.boolValue ?? false
            
            if !isDegraded, let result = result {
                completion(result)
            } else if !isDegraded {
                print("Não foi possível obter a imagem.")
                completion(nil)
            }
        }
    }
}
