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
        let alertController = UIAlertController(title: "Insira a senha", message: "Digite a senha do link secreto para acessar as fotos:", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Senha"
            textField.isSecureTextEntry = true
            textField.autocapitalizationType = .allCharacters
        }
        
        let confirmAction = UIAlertAction(title: "Confirmar", style: .default) { [weak self] _ in
            if let password = alertController.textFields?.first?.text, !password.isEmpty {
                let folderId = url.lastPathComponent + password.uppercased()
                print("Abrindo o app com o folder ID: \(folderId)")
                self?.loadPhotosAndShowModal(folderId: folderId)
            } else {
                print("Senha não fornecida.")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            rootViewController.present(alertController, animated: true, completion: nil)
        }
    }

    func loadPhotosAndShowModal(folderId: String) {
        let folderRef = Storage.storage().reference().child("shared_photos/\(folderId)")
        
        folderRef.listAll { result, error in
            if let error = error {
                print("Erro ao listar fotos: \(error.localizedDescription)")
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
                    self.showAlert(message: "Link ou senha inválidos. Tente novamente.")
                    return
                }
                self.presentPhotoModal(with: photoURLs)
            }
        }
    }

    private func showAlert(message: String) {
        let alertController = UIAlertController(title: "Erro", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            rootViewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    func presentPhotoModal(with photoURLs: [URL]) {
        let photoViewController = PhotoViewController(photoURLs: photoURLs)
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            let navigationController = UINavigationController(rootViewController: photoViewController)
            rootViewController.present(navigationController, animated: true, completion: nil)
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupNotifications()
        Counter().increment()
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
        // remover isso antes de publicar!!!
        return viewControllerFor(storyboard: "Main", withIdentifier: "Home")
        
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
               currentViewController is VaultViewController
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
