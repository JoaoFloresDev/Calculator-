//
//  ChangePasswordViewController.swift
//  Calculator Notes
//
//  Created by Joao Flores on 25/06/20.
//  Copyright © 2020 MakeSchool. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController {
    
    // MARK: - Variables
    var arrayPassword = [Int]()
    var arrayCircles = [UIImageView]()
    var captureKey = 0
    var KeyCurret = UserDefaults.standard.string(forKey: "Key") ?? ""
    var KeyTemp = ""
    
    //    MARK: - IBOutlets
    
    @IBAction func dismissScreen(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var circle1: UIImageView!
    @IBOutlet weak var circle2: UIImageView!
    @IBOutlet weak var circle3: UIImageView!
    @IBOutlet weak var circle4: UIImageView!
    @IBOutlet weak var circle5: UIImageView!
    @IBOutlet weak var circle6: UIImageView!
    @IBOutlet weak var instructionsLabel: UILabel!
    
    //    MARK: - IBAction
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
        enterPassword()
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
    
    func enterPassword() {
        var password = ""
        for word in arrayPassword {
            password += String(word)
        }
        if(captureKey == 1 && arrayPassword.count > 0) {
            instructionsLabel.text = "Key: \(password). Repeat the Key and confirm change with 'Enter'"
            KeyTemp = password
            captureKey = 0
            clearAll()
        }
        else if(KeyTemp == password) {
            clearAll()
            UserDefaults.standard.set(false, forKey: "Mode")
            UserDefaults.standard.set(KeyTemp, forKey: "Key")
            
            showAlert()
        }
    }
    
    //    MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arrayCircles.append(circle1)
        arrayCircles.append(circle2)
        arrayCircles.append(circle3)
        arrayCircles.append(circle4)
        arrayCircles.append(circle5)
        arrayCircles.append(circle6)
        
        captureKey = 1
    }
    
    //    MARK: - Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //    MARK: - Alert
    func showAlert() {
        let refreshAlert = UIAlertController(title: "Done", message: "Bank mode has been activated", preferredStyle: UIAlertControllerStyle.alert)

        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.dismiss(animated: true, completion: nil)
        }))

        present(refreshAlert, animated: true, completion: nil)
    }
}
