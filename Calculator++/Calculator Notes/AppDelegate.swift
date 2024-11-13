import AssetsPickerViewController
import UIKit
import CoreData
import GoogleMobileAds
import WLEmptyState
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var isAlertBeingPresented = false
    
    // MARK: - App Life Cycle
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let urlString = url.absoluteString
        if urlString.hasPrefix("secrets://") {
            handleDeepLink(url: url)
            return true
        }
        return false
    }

    func handleDeepLink(url: URL) {
        if "shared_photos" == url.host {
            showPasswordAlert(url: url)
        }
    }

    func showPasswordAlert(url: URL) {
        let alert = PasswordAlertViewController(
            title: Text.enterPasswordTitle.localized(),
            message: Text.enterPasswordMessage.localized(),
            url: url
        ) { [weak self] photoURLs in
            self?.presentPhotoModal(with: photoURLs, fileID: url.lastPathComponent)
        }
        
        alert.modalPresentationStyle = .overFullScreen
        alert.modalTransitionStyle = .crossDissolve
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            rootViewController.present(alert, animated: true, completion: nil)
        }
    }

    private func presentErrorAlert(_ rootViewController: UIViewController, message: String) {
        let alertController = UIAlertController(title: Text.errorTitle.localized(), message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: Text.okActionText.localized(), style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(okAction)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // Atraso pequeno para evitar conflitos
            rootViewController.present(alertController, animated: true, completion: nil)
        }
    }

    private func showAlert(message: String) {
        let alertController = UIAlertController(title: Text.savePhotosErrorTitle.localized(), message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: Text.okActionText.localized(), style: .default, handler: nil)
        alertController.addAction(okAction)
        
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            rootViewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    func presentPhotoModal(with photoURLs: [URL], fileID: String) {
        let photoViewController = PhotoViewController(photoURLs: photoURLs, fileID: fileID)
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            let navigationController = UINavigationController(rootViewController: photoViewController)
            rootViewController.present(navigationController, animated: true, completion: nil)
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupNotifications()
        WLEmptyState.configure()
        FirebaseApp.configure()
        if shouldInitializeWindow() {
            initializeWindow()
        }
        Connectivity.shared.startMonitoring()
        return true
    }
    
    // MARK: - Setup Functions
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(alertWillBePresented), name: NSNotification.Name("alertWillBePresented"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(alertHasBeenDismissed), name: NSNotification.Name("alertHasBeenDismissed"), object: nil)
    }
    
    private func shouldInitializeWindow() -> Bool {
        return UserDefaultService().getTypeProtection() != ProtectionMode.noProtection ||
               !Defaults.getBool(.notFirstUse)
    }
    
    private func initializeWindow() {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = determineInitialViewController()
        self.window?.makeKeyAndVisible()
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }

    func isUserLoggedIn() -> Bool {
        return Auth.auth().currentUser != nil && Auth.auth().currentUser?.email != nil
    }
    
    private func determineInitialViewController() -> UIViewController {
        let userDefaultService = UserDefaultService()

        if !Defaults.getBool(.notFirstUse) {
            if isUserLoggedIn() {
                Defaults.setBool(.recurrentBackupUpdate, true)
            }
            Defaults.setBool(.recoveryStatus, true)
            return UINavigationController(rootViewController: OnboardingWelcomeViewController())
        }
        
        switch userDefaultService.getTypeProtection() {
        case .calculator:
            return viewControllerFor(storyboard: "CalculatorMode", withIdentifier: "CalcMode")
        case .bank:
            return viewControllerFor(storyboard: "BankMode", withIdentifier: "BankMode")
        case .vault:
            return VaultViewController(mode: .verify)
        case .newCalc:
            let controller = viewControllerFor(storyboard: "NewCalc", withIdentifier: "NewCalcChange")
            return controller
        case .noProtection:
            return viewControllerFor(storyboard: "Main", withIdentifier: "Home")
        case .newCalc2:
            let controller = viewControllerFor(storyboard: "NewCalc2", withIdentifier: "NewCalcChange")
            return controller
        }
    }

    private func viewControllerFor(storyboard storyboardName: String, withIdentifier viewControllerID: String) -> UIViewController {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: viewControllerID)
    }

    
    // MARK: - Notification Actions
    
    @objc private func alertWillBePresented() {
        isAlertBeingPresented = true
    }
    
    @objc private func alertHasBeenDismissed() {
        isAlertBeingPresented = false
    }
    
    // MARK: - App State Handling
    
    func applicationWillResignActive(_ application: UIApplication) {
        guard !isShieldViewController(),
              UserDefaultService().getTypeProtection() != .noProtection,
              !isAlertBeingPresented else {
            return
        }
        
        initializeWindow()
    }
    
    // MARK: - Utility Functions
    
    private func isShieldViewController() -> Bool {
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
            return false
        }
        
        var currentViewController = rootViewController
        while let presentedViewController = currentViewController.presentedViewController {
            currentViewController = presentedViewController
        }
        
        return currentViewController is PasswordViewController ||
               currentViewController is ChangePasswordViewController ||
               currentViewController is CalculatorViewController ||
               currentViewController is ChangeCalculatorViewController ||
               currentViewController is VaultViewController ||
               currentViewController is ChangeNewCalcViewController2
        currentViewController is AssetsPickerViewController
    }
    
    // MARK: - Core Data Stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MakeSchoolNotes")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print("Erro ao carregar persistent store: \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving Support
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("Erro ao salvar contexto: \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

import UIKit
import FirebaseStorage
import SnapKit

import UIKit
import FirebaseStorage
import SnapKit

class PasswordAlertViewController: UIViewController {
    
    private let alertContainer = UIView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let passwordTextField = UITextField()
    private let confirmButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)
    private let url: URL
    private var loadingAlert: LoadingAlert?
    private let confirmAction: ([URL]) -> Void // Declaração do bloco de confirmação

    init(title: String, message: String, url: URL, confirmAction: @escaping ([URL]) -> Void) {
        self.url = url
        self.confirmAction = confirmAction // Inicialização do bloco
        super.init(nibName: nil, bundle: nil)
        
        titleLabel.text = title
        messageLabel.text = message
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        alertContainer.backgroundColor = .white
        alertContainer.layer.cornerRadius = 12
        view.addSubview(alertContainer)
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center
        alertContainer.addSubview(titleLabel)
        
        messageLabel.font = UIFont.systemFont(ofSize: 14)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        alertContainer.addSubview(messageLabel)
        
        passwordTextField.placeholder = "Digite a senha"
        passwordTextField.isSecureTextEntry = true
        passwordTextField.borderStyle = .roundedRect
        alertContainer.addSubview(passwordTextField)
        
        confirmButton.setTitle("OK", for: .normal)
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        alertContainer.addSubview(confirmButton)
        
        cancelButton.setTitle("Cancelar", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        alertContainer.addSubview(cancelButton)
    }
    
    private func setupConstraints() {
        alertContainer.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(300)
            make.height.equalTo(200)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(alertContainer).offset(16)
            make.left.right.equalTo(alertContainer).inset(16)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.right.equalTo(titleLabel)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(16)
            make.left.right.equalTo(alertContainer).inset(16)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(16)
            make.right.equalTo(alertContainer.snp.centerX).offset(-8)
            make.bottom.equalTo(alertContainer).offset(-16)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(16)
            make.left.equalTo(alertContainer.snp.centerX).offset(8)
            make.bottom.equalTo(alertContainer).offset(-16)
        }
    }
    
    @objc private func confirmTapped() {
        guard let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: Text.invalidLinkOrPasswordMessage.localized())
            return
        }
        
        let folderId = url.lastPathComponent + password
        loadPhotos(folderId: folderId)
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }

    private func loadPhotos(folderId: String) {
        let folderRef = Storage.storage().reference().child("shared_photos/\(folderId)")
        
        if let rootViewController = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            
            loadingAlert = LoadingAlert(in: self)
            
            loadingAlert?.startLoading {
                folderRef.listAll { result, error in
                    if let error = error {
                        print("Erro ao listar fotos: \(error.localizedDescription)")
                        self.loadingAlert?.stopLoading {
                            self.showAlert(message: Text.invalidLinkOrPasswordMessage.localized())
                        }
                        return
                    }
                    
                    var photoURLs: [URL] = []
                    let dispatchGroup = DispatchGroup()
                    
                    result?.items.forEach { item in
                        dispatchGroup.enter()
                        item.downloadURL { url, error in
                            if let url = url {
                                photoURLs.append(url)
                            }
                            dispatchGroup.leave()
                        }
                    }
                    
                    dispatchGroup.notify(queue: .main) {
                        guard !photoURLs.isEmpty else {
                            self.loadingAlert?.stopLoading {
                                self.showAlert(message: Text.invalidLinkOrPasswordMessage.localized())
                            }
                            return
                        }
                        self.loadingAlert?.stopLoading {
                            self.dismiss(animated: true) {
                                self.confirmAction(photoURLs) // Chamada do bloco confirmAction com os URLs
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func showAlert(message: String) {
        let alertController = UIAlertController(title: Text.errorTitle.localized(), message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: Text.okActionText.localized(), style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(okAction)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
