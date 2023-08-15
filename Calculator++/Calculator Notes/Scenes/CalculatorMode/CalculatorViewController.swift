//
//  CalculatorViewController.swift
//  Calculator Notes
//
//  Created by Joao Flores on 08/04/20.
//  Copyright © 2020 Joao Flores. All rights reserved.
//

import UIKit
import LocalAuthentication

enum Operation:String {
    case Add = "+"
    case Subtract = "-"
    case Divide = "/"
    case Multiply = "*"
    case NULL = "Null"
}

class CalculatorViewController: BaseCalculatorViewController {
    
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var faceIDButton: UIButton!
    @IBAction func useFaceID(_ sender: UIButton) {
        
        let myContext = LAContext()
        let myLocalizedReasonString = "We will use authentication to show you the password for the app"
        
        var authError: NSError?
        
        if myContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authError) {
            myContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: myLocalizedReasonString) { success, evaluateError in
                if success {
                    DispatchQueue.main.async {
                        var instructionText = Text.instructionSecondStepCalc.localized()
                        let key = UserDefaults.standard.string(forKey: "Key") ?? "314159"
                        instructionText = instructionText.replacingOccurrences(of: "*****", with: key)
                        self.instructionsLabel.text = instructionText
                        self.instructionsLabel.font = UIFont.boldSystemFont(ofSize: 22.0)
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let homeViewController = storyboard.instantiateViewController(withIdentifier: "Home")
                        self.present(homeViewController, animated: true)
                    }
                } else {
                    DispatchQueue.main.async {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let homeViewController = storyboard.instantiateViewController(withIdentifier: "Home")
                        self.present(homeViewController, animated: true)
                    }
                }
                
            }
        } else {
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let homeViewController = storyboard.instantiateViewController(withIdentifier: "Home")
                self.present(homeViewController, animated: true)
            }
        }
        
    }
    
    @IBAction func numberPressed(_ sender: UIButton) {
        if runningNumber.count <= 9 {
            runningNumber += "\(sender.tag)"
            outputLbl.text = runningNumber
        }
    }
    
    @IBAction func dotPressed(_ sender: UIButton) {
        dotPressed()
    }
    
    @IBAction func equalsPressed(_ sender: UIButton) {
        if(runningNumber.count <= 6 && runningNumber.count >= 1 && captureKey == 1) {
            key = String(runningNumber)
            captureKey = 2
            keyTemp = key
            
            clear()
            
        } else if(captureKey == 2 && String(runningNumber) == keyTemp && runningNumber.count <= 6 && runningNumber.count >= 1) {
            UserDefaults.standard.set (key, forKey: "Key")
            captureKey = 0
        }
        else if((String(runningNumber) == key && captureKey == 0) || runningNumber == recoveryKey) {
            captureKey = 0
            runningNumber = ""
            leftValue = ""
            rightValue = ""
            result = ""
            currentOperation = .NULL
            
            outputLbl.text = "0"
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let homeViewController = storyboard.instantiateViewController(withIdentifier: "Home")
            self.present(homeViewController, animated: true)
        }
        
        operation(operation: currentOperation)
    }
    
    @IBAction func addPressed(_ sender: UIButton) {
        operation(operation: .Add)
    }
    
    @IBAction func substractPressed(_ sender: UIButton) {
        
        operation(operation: .Subtract)
    }
    
    @IBAction func multiplyPressed(_ sender: UIButton) {
        operation(operation: .Multiply)
    }
    
    @IBAction func dividePressed(_ sender: UIButton) {
        operation(operation: .Divide)
    }
    
    @IBAction func allClearPerssed(_ sender: UIButton) {
        clear()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        outputLbl.text = "0"
        if(key == "") {
            captureKey = 1
        }
        faceIDButton.isHidden = Key.recoveryStatus.getBoolean()
    }
}
