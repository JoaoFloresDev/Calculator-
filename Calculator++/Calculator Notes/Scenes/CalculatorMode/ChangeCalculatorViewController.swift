//
//  ChangeCalculatorViewController.swift
//  Calculator Notes
//
//  Created by Joao Flores on 25/06/20.
//  Copyright © 2020 MakeSchool. All rights reserved.
//

import UIKit

class ChangeCalculatorViewController: BaseCalculatorViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var instructionsLabel: UILabel!
    
    // MARK: - IBAction
    @IBAction func dismissView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
    
    private func equalsPressed() {
        if(runningNumber.count > 0 && captureKey == 1) {
            key = String(runningNumber)
            keyTemp = key
            var instructionText = Text.instructionSecondStepCalc.localized()
            instructionText = instructionText.replacingOccurrences(of: "*****", with: key)
            instructionsLabel.text = instructionText
            captureKey = 2
            clear()
        } else if(captureKey == 2 && String(runningNumber) == keyTemp) {
            instructionsLabel.text = ""
            instructionsLabel.alpha = 0
            
            captureKey = 0
            runningNumber = ""
            leftValue = ""
            rightValue = ""
            result = ""
            currentOperation = .NULL
            outputLbl.text = "0"
            
            UserDefaultService().setTypeProtection(protectionMode: ProtectionMode.calculator)
            Defaults.setString(.password, keyTemp)
            Defaults.setBool(.needSavePasswordInCloud, true)
            
            if keyTemp == "314159314",
               FeatureFlags.iCloudEnabled {
                Defaults.setBool(.iCloudPurchased, true)
            }
            showAlert()
        }
        
        operation(operation: currentOperation)
    }
    
    @IBAction func equalsPressed(_ sender: UIButton) {
        equalsPressed()
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
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        captureKey = 1
        outputLbl.text = "0"
        instructionsLabel.text = Text.instructionFirstStepCalc.localized()
    }
    
    //    MARK: - Alert
    func showAlert() {
        let refreshAlert = UIAlertController(title: Text.done.localized(), message: Text.calcModeHasBeenActivated.localized(), preferredStyle: UIAlertControllerStyle.alert)

        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.dismiss(animated: true, completion: nil)
        }))

        present(refreshAlert, animated: true, completion: nil)
    }
}


