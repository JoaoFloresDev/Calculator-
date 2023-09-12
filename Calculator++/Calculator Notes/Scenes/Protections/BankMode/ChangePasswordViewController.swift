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
    var keyTemp = ""
    
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
            arrayCircles[x].setImage(.keyEmpty)
        }
        
        arrayCircles[0].setImage(.keyCurrent)
    }

    @IBAction func clear(_ sender: Any) {
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
            arrayCircles[x].setImage(.keyFill)
        }
        
        if(arrayPassword.count < 6) {
            arrayCircles[arrayPassword.count].setImage(.keyCurrent)
        }
    }
    
    func enterPassword() {
        var password = ""
        for word in arrayPassword {
            password += String(word)
        }
        if(captureKey == 1 && arrayPassword.count > 0) {
            var instructionsText = Text.instructionSecondStepBank.localized()
            instructionsText = instructionsText.replacingOccurrences(of: "*****", with: password)
            instructionsLabel.text = instructionsText
            keyTemp = password
            captureKey = 0
            clearAll()
        }
        else if(keyTemp == password) {
            clearAll()
            UserDefaultService().setTypeProtection(protectionMode: ProtectionMode.bank)
            Defaults.setString(.password, keyTemp)
            Defaults.setBool(.needSavePasswordInCloud, true)
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
        
        instructionsLabel.setText(.instructionFirstStepBank)
    }
    
    //    MARK: - Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //    MARK: - Alert
    func showAlert() {
        let refreshAlert = UIAlertController(title: Text.done.localized(),
                                             message: Text.bankModeHasBeenActivated.localized(),
                                             preferredStyle: UIAlertControllerStyle.alert)

        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.dismiss(animated: true, completion: nil)
        }))

        present(refreshAlert, animated: true, completion: nil)
    }
}


