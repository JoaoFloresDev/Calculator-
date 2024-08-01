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

    private func determineInitialViewController() -> UIViewController {
        let userDefaultService = UserDefaultService()

        if !Defaults.getBool(.notFirstUse) {
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
               currentViewController is VaultViewController
    }
    
    // MARK: - Core Data Stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MakeSchoolNotes")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
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
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
