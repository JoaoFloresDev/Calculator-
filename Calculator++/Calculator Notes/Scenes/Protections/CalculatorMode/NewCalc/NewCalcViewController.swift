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

class NewCalcViewController: BaseNewCalcViewController {
    
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
                        let key = Defaults.getString(.password)
                        instructionText = instructionText.replacingOccurrences(of: "*****", with: key)
                        self.instructionsLabel.text = instructionText
                        self.instructionsLabel.font = UIFont.boldSystemFont(ofSize: 22.0)
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let homeViewController = storyboard.instantiateViewController(withIdentifier: "Home")
                        self.present(homeViewController, animated: true)
                    }
                } else {
                    DispatchQueue.main.async {
                        if Defaults.getInt(.disableRecoveryButtonCounter) < 10 {
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let homeViewController = storyboard.instantiateViewController(withIdentifier: "Home")
                            self.present(homeViewController, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func numberPressed(_ sender: UIButton) {
        runningNumber += "\(sender.tag)"
        outputLbl.text = runningNumber
    }
    
    @IBAction func dotPressed(_ sender: UIButton) {
        runningNumber += "."
        outputLbl.text = runningNumber
    }
    
    @IBAction func equalsPressed(_ sender: UIButton) {
        runningNumber += "="
        outputLbl.text = runningNumber
    }
    
    @IBAction func addPressed(_ sender: UIButton) {
        runningNumber += "x"
        outputLbl.text = runningNumber
    }
    
    @IBAction func substractPressed(_ sender: UIButton) {
        runningNumber += "π"
        outputLbl.text = runningNumber
    }
    
    @IBAction func multiplyPressed(_ sender: UIButton) {
        runningNumber += "∑"
        outputLbl.text = runningNumber
    }
    
    @IBAction func dividePressed(_ sender: UIButton) {
        runningNumber += "√"
        outputLbl.text = runningNumber
    }
    
    @IBAction func allClearPerssed(_ sender: UIButton) {
        clear()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        outputLbl.text = "02"
        if(key == "") {
            captureKey = 1
        }
        faceIDButton.isHidden = Defaults.getBool(.recoveryStatus)
    }
}
