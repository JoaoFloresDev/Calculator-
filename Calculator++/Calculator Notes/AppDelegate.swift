//
//  AppDelegate.swift
//  Calculator Notes
//
//  Created by Joao Flores on 08/04/20.
//  Copyright © 2020 Joao Flores. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds
import WLEmptyState

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        NotificationCenter.default.addObserver(self, selector: #selector(alertWillBePresented), name: NSNotification.Name("alertWillBePresented"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(alertHasBeenDismissed), name: NSNotification.Name("alertHasBeenDismissed"), object: nil)
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)

        if UserDefaultService().getTypeProtection() == ProtectionMode.noProtection {
                return true
        }
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        if UserDefaultService().getTypeProtection() == ProtectionMode.calculator {
            let storyboard = UIStoryboard(name: "CalculatorMode", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "CalcMode")
            
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        } else {
            let storyboard = UIStoryboard(name: "BankMode", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "BankMode")
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }
        
        WLEmptyState.configure()
        return true
    }
    
    var isAlertBeingPresented = false
    
    @objc func alertWillBePresented() {
        isAlertBeingPresented = true
    }

    @objc func alertHasBeenDismissed() {
        isAlertBeingPresented = false
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        if isShieldViewController() {
            return
        }
        
        if UserDefaultService().getTypeProtection() == .noProtection {
            return
        }
        
        if isAlertBeingPresented {
            return
        }
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        if (UserDefaultService().getTypeProtection() == .calculator) {
            let storyboard = UIStoryboard(name: "CalculatorMode", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "CalcMode")
            
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        } else {
            let storyboard = UIStoryboard(name: "BankMode", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "BankMode")
            
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }
        
        if let rootViewController = window?.rootViewController as? CalculatorViewController,
           let presentedViewController = rootViewController.presentedViewController{
            presentedViewController.dismiss(animated: false, completion: nil)
        }
        
        else if let rootViewController = window?.rootViewController as? PasswordViewController,
                let presentedViewController = rootViewController.presentedViewController{
            presentedViewController.dismiss(animated: false, completion: nil)
        }
    }
    
    func isShieldViewController() -> Bool {
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            var currentViewController = rootViewController
            
            while let presentedViewController = currentViewController.presentedViewController {
                currentViewController = presentedViewController
            }
            return currentViewController is PasswordViewController ||
            currentViewController is ChangePasswordViewController ||
            currentViewController is CalculatorViewController ||
            currentViewController is ChangeCalculatorViewController
        }
        
        return false
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MakeSchoolNotes")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
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

