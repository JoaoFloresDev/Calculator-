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
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
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

        if let rootViewController = getRootViewController() {
            if UIDevice.current.userInterfaceIdiom == .pad {
                alert.modalPresentationStyle = .popover
                if let popover = alert.popoverPresentationController {
                    popover.sourceView = rootViewController.view
                    popover.sourceRect = CGRect(
                        x: rootViewController.view.bounds.midX,
                        y: rootViewController.view.bounds.midY,
                        width: 0,
                        height: 0
                    )
                    popover.permittedArrowDirections = []
                }
            }
            rootViewController.present(alert, animated: true, completion: nil)
        }
    }

    private func presentErrorAlert(_ rootViewController: UIViewController, message: String) {
        let alertController = UIAlertController(title: Text.errorTitle.localized(), message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: Text.okActionText.localized(), style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(okAction)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            rootViewController.present(alertController, animated: true, completion: nil)
        }
    }

    private func showAlert(message: String) {
        let alertController = UIAlertController(title: Text.savePhotosErrorTitle.localized(), message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: Text.okActionText.localized(), style: .default, handler: nil)
        alertController.addAction(okAction)
        
        if let rootViewController = getRootViewController() {
            rootViewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    func presentPhotoModal(with photoURLs: [URL], fileID: String) {
        let photoViewController = PhotoViewController(photoURLs: photoURLs, fileID: fileID)
        if let rootViewController = getRootViewController() {
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
        guard let rootViewController = getRootViewController() else {
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
               currentViewController is ChangeNewCalcViewController2 ||
               currentViewController is AssetsPickerViewController
    }
    
    private func getRootViewController() -> UIViewController? {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            return scene.windows.first(where: { $0.isKeyWindow })?.rootViewController
        }
        return nil
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
