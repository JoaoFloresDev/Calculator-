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
import FirebaseFirestore

// MARK: - FIRST SCREEN
class OnboardingWelcomeViewController: UIViewController, UINavigationControllerDelegate {

    lazy var onboardingView = OnboardingView(
        title: Text.welcomeOnboarding_title.localized(),
        subtitle: Text.welcomeOnboarding_subtitle.localized(),
        startButtonTitle: Text.welcomeOnboarding_startButtonTitle.localized(),
        skipButtonTitle: Text.welcomeOnboarding_skipButtonTitle.localized(),
        delegate: self
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(onboardingView)
        NotificationCenter.default.post(name: NSNotification.Name("alertWillBePresented"), object: nil)
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
        self.navigationController?.pushViewController(ScrollableTextViewController(), animated: true)
    }
}

// MARK: - SECOND SCREEN
class OnboardingCreateCodeViewController: UIViewController {
    var slideAndFadeAnimator: SlideAndFadePresentAnimator?
    
    lazy var onboardingView = OnboardingView(
        title: Text.createCodeOnboarding_title.localized(),
        subtitle: Text.createCodeOnboarding_subtitle.localized(),
        startButtonTitle: Text.createCodeOnboarding_startButtonTitle.localized(),
        skipButtonTitle: Text.createCodeOnboarding_skipButtonTitle.localized(),
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
            self.presentNextStep()
        }
    }
    
    func didTapSecondaryButton() {
        presentNextStep()
    }
    
    func presentNextStep() {
        self.navigationController?.pushViewController(InsertRecoverEmailViewController(), animated: true)
    }
}