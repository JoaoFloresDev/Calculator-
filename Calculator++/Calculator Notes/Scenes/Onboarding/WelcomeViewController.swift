import UIKit
import SnapKit

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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(onboardingView)
        navigationController?.navigationBar.isHidden = true
        
        onboardingView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension OnboardingAddPhotosViewController: OnboardingViewDelegate {
    func didTapPrimaryButton() {
        
    }
    
    func didTapSecondaryButton() {
        self.dismiss(animated: true)
    }
}
