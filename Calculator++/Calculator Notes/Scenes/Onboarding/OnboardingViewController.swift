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
            self.navigationController?.pushViewController(OnboardingAddPhotosViewController(), animated: false)
        }
    }
    
    func didTapSecondaryButton() {
        self.navigationController?.pushViewController(OnboardingAddPhotosViewController(), animated: true)
    }
}

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
//        Defaults.setBool(.notFirstUse, true)
        
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
        slideAndFadeAnimator = SlideAndFadePresentAnimator()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeViewController = storyboard.instantiateViewController(withIdentifier: "Home")
        homeViewController.modalPresentationStyle = .fullScreen
        homeViewController.transitioningDelegate = slideAndFadeAnimator
        self.present(homeViewController, animated: true)
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

class ScrollableTextViewController: UIViewController {
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    let titleLabel = UILabel()
    let bodyLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .yellow
        // Configura a UIScrollView
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Configura o título e o texto
        titleLabel.text = "Privacy Policy"
        titleLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        contentView.addSubview(titleLabel)
        
        bodyLabel.text =
        """
        Gambit Studio built the Secret Gallery app as a Freemium app. This
        SERVICE is provided by Gambit Studio at no cost and is intended for use as is.
        This page is used to inform visitors regarding my policies with the collection,
        use, and disclosure of Personal Information if anyone decided to use my
        Service.
        If you choose to use my Service, then you agree to the collection and use of
        information in relation to this policy. The Personal Information that I collect is
        used for providing and improving the Service. I will not use or share your
        information with anyone except as described in this Privacy Policy.
        The terms used in this Privacy Policy have the same meanings as in our
        Terms and Conditions, which is accessible at Secret Gallery unless
        otherwise defined in this Privacy Policy.
        Information Collection and Use
        For a better experience, while using our Service, I may require you to provide
        us with certain personally identifiable information. The information that I
        request will be retained on your device and is not collected by me in any way.
        The app does use third party services that may collect information used to
        identify you.
        Link to privacy policy of third party service providers used by the app
        https://www.apple.com/legal/privacy/
        Log Data
        I want to inform you that whenever you use my Service, in a case of an error
        in the app I collect data and information (through third party products) on your
        phone called Log Data. This Log Data may include information such as your
        device Internet Protocol (“IP”) address, device name, operating system
        version, the configuration of the app when utilizing my Service, the time and
        date of your use of the Service, and other statistics.
        Cookies
        Cookies are files with a small amount of data that are commonly used as
        anonymous unique identifiers. These are sent to your browser from the
        websites that you visit and are stored on your device's internal memory.
        This Service does not use these “cookies” explicitly. However, the app may
        use third party code and libraries that use “cookies” to collect information and
        improve their services. You have the option to either accept or refuse these
        cookies and know when a cookie is being sent to your device. If you choose
        to refuse our cookies, you may not be able to use some portions of this
        Service.
        Service Providers
        I may employ third-party companies and individuals due to the following
        reasons:

        To facilitate our Service;
        To provide the Service on our behalf;
        To perform Service-related services; or
        To assist us in analyzing how our Service is used.
        I want to inform users of this Service that these third parties have access to
        your Personal Information. The reason is to perform the tasks assigned to
        them on our behalf. However, they are obligated not to disclose or use the
        information for any other purpose.
        Security
        I value your trust in providing us your Personal Information, thus we are
        striving to use commercially acceptable means of protecting it. But remember
        that no method of transmission over the internet, or method of electronic
        storage is 100% secure and reliable, and I cannot guarantee its absolute
        security.
        Links to Other Sites
        This Service may contain links to other sites. If you click on a third-party link,
        you will be directed to that site. Note that these external sites are not
        operated by me. Therefore, I strongly advise you to review the Privacy Policy
        of these websites. I have no control over and assume no responsibility for the
        content, privacy policies, or practices of any third-party sites or services.
        Children’s Privacy
        These Services do not address anyone under the age of 13. I do not
        knowingly collect personally identifiable information from children under 13. In
        the case I discover that a child under 13 has provided me with personal
        information, I immediately delete this from our servers. If you are a parent or
        guardian and you are aware that your child has provided us with personal
        information, please contact me so that I will be able to do necessary actions.
        Changes to This Privacy Policy
        I may update our Privacy Policy from time to time. Thus, you are advised to
        review this page periodically for any changes. I will notify you of any changes
        by posting the new Privacy Policy on this page. These changes are effective
        immediately after they are posted on this page.
        Contact Us
        If you have any questions or suggestions about my Privacy Policy, do not
        hesitate to contact me at
        https://www.facebook.com/Andr%C3%B4meda-105069994183456/
        All files are saved locally, without cloud backup
        """
        
        bodyLabel.numberOfLines = 0
        bodyLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        contentView.addSubview(bodyLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        
        // ScrollView
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        // ContentView
        contentView.snp.makeConstraints { make in
            make.top.bottom.equalTo(scrollView)
            make.left.right.equalTo(view)
        }
        
        // Título
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(20)
            make.leading.equalTo(contentView).offset(16)
            make.trailing.equalTo(contentView).offset(-16)
        }
        
        // Texto
        bodyLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalTo(titleLabel)
            make.bottom.equalTo(contentView).offset(-20)
        }
    }
}
