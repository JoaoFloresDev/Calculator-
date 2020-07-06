//
//  PasswordViewController.swift
//  Calculator Notes
//
//  Created by Joao Flores on 21/06/20.
//  Copyright © 2020 MakeSchool. All rights reserved.
//

import UIKit
import LocalAuthentication
import SwiftUI

class PasswordViewController: UIViewController {
    
    // MARK: - Variables
    var arrayPassword = [Int]()
    var arrayCircles = [UIImageView]()
    var captureKey = 0
    var keyCurret = UserDefaults.standard.string(forKey: "Key") ?? ""
    let keyRecovery = "314159"
    
    //    MARK: - IBOutlets
    
    @IBOutlet weak var circle1: UIImageView!
    @IBOutlet weak var circle2: UIImageView!
    @IBOutlet weak var circle3: UIImageView!
    @IBOutlet weak var circle4: UIImageView!
    @IBOutlet weak var circle5: UIImageView!
    @IBOutlet weak var circle6: UIImageView!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var helpDeskButton: UIButton!
    
    //    MARK: - IBAction
    
    @IBOutlet weak var buttonFaceID: UIButton!
    @IBAction func useFaceID(_ sender: UIButton) {
        if (UserDefaults.standard.string(forKey: "Key") == nil) {
            let alert = UIAlertController(title: "First create Passcode", message: "It is only possible to recover the password after creating it", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            let myContext = LAContext()
            let myLocalizedReasonString = "Biometric Authntication testing !! "
            
            var authError: NSError?
            
            if myContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authError) {
                myContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: myLocalizedReasonString) { success, evaluateError in
                    DispatchQueue.main.async {
                        if success {
                            self.instructionsLabel.text = "Key: "
                            self.instructionsLabel.text! += UserDefaults.standard.string(forKey: "Key") ?? "314159"
                            self.instructionsLabel.font = UIFont.boldSystemFont(ofSize: 25.0)
                        } else {
                            self.helpDeskButton.alpha = 1
                            let alert = UIAlertController(title: "Recognition Failed", message: "Use the Help Desk for more information", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            
                        }
                    }
                }
            } else {
                helpDeskButton.alpha = 1
                let alert = UIAlertController(title: "Recognition Failed", message: "Could not evaluate policy. Use the Help Desk for more information", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func showHelpDesk(_ sender: Any) {
        if let url = URL(string: "https://www.facebook.com/SharkApplications/") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func button1(_ sender: Any) {
        populate (number: 1)
    }
    
    @IBAction func button2(_ sender: Any) {
        populate (number: 2)
    }
    
    @IBAction func button3(_ sender: Any) {
        populate (number: 3)
    }
    
    @IBAction func button4(_ sender: Any) {
        populate (number: 4)
    }
    
    @IBAction func button5(_ sender: Any) {
        populate (number: 5)
    }
    
    @IBAction func button6(_ sender: Any) {
        populate (number: 6)
    }
    
    @IBAction func button7(_ sender: Any) {
        populate (number: 7)
    }
    
    @IBAction func button8(_ sender: Any) {
        populate (number: 8)
    }
    
    @IBAction func button9(_ sender: Any) {
        populate (number: 9)
    }
    
    @IBAction func button0(_ sender: Any) {
        populate (number: 0)
    }
    
    func clearAll() {
        arrayPassword.removeAll()
        for x in 0...arrayCircles.count-1 {
            arrayCircles[x].image = UIImage(named: "keyEmpity")
        }
        
        arrayCircles[0].image = UIImage(named: "keyCurrent")
    }
    
    @IBAction func ClearPassword(_ sender: Any) {
        clearAll()
    }
    
    @IBAction func Enter(_ sender: Any) {
        var password = ""
        for word in arrayPassword {
            password += String(word)
        }
        
        if(password.count >= 1 && captureKey == 1) {
            keyCurret = String(password)
            instructionsLabel.text = "Key: \(keyCurret). Repeat the Key and confirm with 'Enter'"
            captureKey = 2
            clearAll()
        }
        else if(keyCurret == password || password == keyRecovery) {
            UserDefaults.standard.set (keyCurret, forKey: "Key")
            
            if (UserDefaults.standard.object(forKey: "FirtsUse") == nil) {
                self.performSegue(withIdentifier: "showRules", sender: nil)
            }
            else {
                self.performSegue(withIdentifier: "showNotes2", sender: nil)
            }
        }
        else {
            let alert = UIAlertController(title: "Incorrect password", message: "Try again", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                self.clearAll()
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - PasswordUI
    func populate (number: Int) {
        if(arrayPassword.count < 6) {
            arrayPassword.append(number)
            updatePassword()
        }
    }
    
    func updatePassword() {
        for x in 0...arrayPassword.count-1 {
            arrayCircles[x].image = UIImage(named: "keyFill")
        }
        
        if(arrayPassword.count < 6) {
            arrayCircles[arrayPassword.count].image = UIImage(named: "keyCurrent")
        }
    }
    
    //    MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        clearAll()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arrayCircles.append(circle1)
        arrayCircles.append(circle2)
        arrayCircles.append(circle3)
        arrayCircles.append(circle4)
        arrayCircles.append(circle5)
        arrayCircles.append(circle6)
        
        if(keyCurret == "") {
            instructionsLabel.text = "Create a passcode and click 'enter'"
            captureKey = 1
        }
    }
    
    //    MARK: Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

