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
    var slideAndFadeAnimator: SlideAndFadePresentAnimator?
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
         apresentarVaultViewController()
    }
    
    func apresentarVaultViewController() {
        slideAndFadeAnimator = SlideAndFadePresentAnimator()
        
        if isCurrentDateBeforeAprilFirst2024() {
            let vaultViewController = VaultViewController(mode: .create)
            vaultViewController.modalPresentationStyle = .fullScreen
            vaultViewController.transitioningDelegate = slideAndFadeAnimator
            self.present(vaultViewController, animated: true) {
                self.presentNextStep()
            }
        } else {
            let vaultViewController = viewControllerFor(storyboard: "NewCalc2", withIdentifier: "NewCalcChange")
            vaultViewController.modalPresentationStyle = .fullScreen
            vaultViewController.transitioningDelegate = slideAndFadeAnimator
            guard let controller = vaultViewController as? ChangeNewCalcViewController2 else {
                self.presentNextStep()
                return
            }
            controller.vaultMode = .create
            controller.faceIDButton.isHidden = true
            self.present(controller, animated: true) {
                self.presentNextStep()
            }
        }
    }
    
    func isCurrentDateBeforeAprilFirst2024() -> Bool {
        // Configura o calendário e as opções de zona horária
        var calendar = Calendar.current
        if let timeZone = TimeZone(identifier: "UTC") {
            calendar.timeZone = timeZone
        }
        
        // Cria componentes da data para 1º de abril de 2024
        var dateComponents = DateComponents()
        dateComponents.year = 2024
        dateComponents.month = 4
        dateComponents.day = 1
        
        // Gera a data de 1º de abril de 2024
        guard let aprilFirst2024 = calendar.date(from: dateComponents) else {
            print("Erro ao gerar a data de 1º de abril de 2024.")
            return false
        }
        
        // Compara com a data atual
        return Date() < aprilFirst2024
    }
    
    private func viewControllerFor(storyboard storyboardName: String, withIdentifier viewControllerID: String) -> UIViewController {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: viewControllerID)
    }
    
    func presentNextStep() {
        NotificationCenter.default.post(name: NSNotification.Name("alertHasBeenDismissed"), object: nil)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeViewController = storyboard.instantiateViewController(withIdentifier: "Home")
        homeViewController.modalPresentationStyle = .fullScreen
        homeViewController.transitioningDelegate = slideAndFadeAnimator
        self.navigationController?.pushViewController(homeViewController, animated: false)
        navigationController?.setNavigationBarHidden(true, animated: false)
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
        self.navigationController?.pushViewController(OnboardingAddPhotosViewController(), animated: true)
    }
}
