import Photos
import SnapKit
import Foundation
import Network
import UIKit
import Photos
import AssetsPickerViewController
import DTPhotoViewerController
import CoreData
import NYTPhotoViewer
import ImageViewer
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

class OnboardingWelcomeViewController: UIViewController, UINavigationControllerDelegate {

    lazy var onboardingView = OnboardingView(
        title: "Bem-vindo ao Secret Gallery",
        subtitle: "Proteja suas fotos e vídeos com segurança",
        startButtonTitle: "Começar",
        skipButtonTitle: "Ao clicar em ”Começar”, você concorda com a politica de privacidade e os termos de uso",
        delegate: self
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(onboardingView)
        self.navigationController?.delegate = self
        onboardingView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
            return SlideAndFadePushAnimator()
        }
        return nil
    }
}

extension OnboardingWelcomeViewController: OnboardingViewDelegate {
    func didTapPrimaryButton() {
        self.navigationController?.pushViewController(OnboardingCreateCodeViewController(), animated: true)
    }
    
    func didTapSecondaryButton() {
        
    }
}

// ------------------------------------

class OnboardingCreateCodeViewController: UIViewController {
    var slideAndFadeAnimator: SlideAndFadePresentAnimator?
    
    lazy var onboardingView = OnboardingView(
        title: "Crie um código de acesso",
        subtitle: "Crie uma senha para acessar suas fotos guardadas",
        startButtonTitle: "Continuar",
        skipButtonTitle: "Agora não",
        delegate: self
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(onboardingView)
        navigationController?.navigationBar.isHidden = true
        
        onboardingView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension OnboardingCreateCodeViewController: OnboardingViewDelegate {
    func didTapPrimaryButton() {
        apresentarVaultViewController()
    }

    func apresentarVaultViewController() {
        slideAndFadeAnimator = SlideAndFadePresentAnimator()
        
        let vaultViewController = VaultViewController(mode: .create)
        vaultViewController.modalPresentationStyle = .fullScreen
        vaultViewController.transitioningDelegate = slideAndFadeAnimator
        self.present(vaultViewController, animated: true) {
            self.navigationController?.pushViewController(OnboardingAddPhotosViewController(), animated: false)
        }
    }
    
    func didTapSecondaryButton() {
        self.navigationController?.pushViewController(OnboardingAddPhotosViewController(), animated: true)
    }
}

// ------------------------------------

class OnboardingAddPhotosViewController: UIViewController {
    
    lazy var onboardingView = OnboardingView(
        title: "Adicione suas fotos",
        subtitle: "Adicione as fotos que deseja guardar de forma segura",
        startButtonTitle: "Continuar",
        skipButtonTitle: "Agora não",
        delegate: self
    )
    
    private var totalAssets = 0 // Contador para o número total de assets
    private var processedAssets = 0 // Contador para o número de assets processados
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(onboardingView)
        navigationController?.navigationBar.isHidden = true
        
        onboardingView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
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
        self.dismiss(animated: true)
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
                    self.dismiss(animated: true)
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
