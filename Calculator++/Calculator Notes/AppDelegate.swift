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
        
        UserDefaults.standard.set(true, forKey: "NoAds.Calc")
        UserDefaults.standard.set(false, forKey: "InGallery")
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        //        select root
        if (UserDefaults.standard.bool(forKey: "Mode") == true) {
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "CalcMode")

            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }
        else {
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "BankMode")

            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }
        
        WLEmptyState.configure()
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {

        if (UserDefaults.standard.bool(forKey: "InGallery") == true) {
            if (UserDefaults.standard.bool(forKey: "Mode") == true) {
                self.window = UIWindow(frame: UIScreen.main.bounds)

                let storyboard = UIStoryboard(name: "Main", bundle: nil)

                let initialViewController = storyboard.instantiateViewController(withIdentifier: "CalcMode")

                self.window?.rootViewController = initialViewController
                self.window?.makeKeyAndVisible()
            }
            else {
                self.window = UIWindow(frame: UIScreen.main.bounds)

                let storyboard = UIStoryboard(name: "Main", bundle: nil)

                let initialViewController = storyboard.instantiateViewController(withIdentifier: "BankMode")

                self.window?.rootViewController = initialViewController
                self.window?.makeKeyAndVisible()
            }

            if let rootViewController = window?.rootViewController as? CalculatorViewController,
                let presentedViewController = rootViewController.presentedViewController{
                print("\(rootViewController)")
                presentedViewController.dismiss(animated: false, completion: nil)
            }
            else if let rootViewController = window?.rootViewController as? PasswordViewController,
                let presentedViewController = rootViewController.presentedViewController{
                print("\(rootViewController)")
                presentedViewController.dismiss(animated: false, completion: nil)
            }
            UserDefaults.standard.set(false, forKey: "InGallery")
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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

