//
//  ChangeCalculatorViewController.swift
//  Calculator Notes
//
//  Created by Joao Flores on 25/06/20.
//  Copyright © 2020 MakeSchool. All rights reserved.
//

import UIKit

class ChangeCalculatorViewController: UIViewController {
    
    @IBOutlet var InstructionsLabel: [UILabel]!
    @IBOutlet weak var outputLbl: UILabel!
    
    var captureKey = 0
    var runningNumber = ""
    var leftValue = ""
    var rightValue = ""
    var result = ""
    var currentOperation:Operation = .NULL
    
    var senha = UserDefaults.standard.string(forKey: "Key") ?? ""
    var keyTemp = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        captureKey = 1
        outputLbl.text = "0"
    }
    
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
        
        if runningNumber.count <= 8 {
            runningNumber += "."
            outputLbl.text = runningNumber
        }
    }
    
    @IBAction func equalsPressed(_ sender: UIButton) {
        if(runningNumber.count > 0 && captureKey == 1) {
            senha = String(runningNumber)
            keyTemp = senha
            InstructionsLabel[0].text = "Key: \(senha). Repeat the Key and confirm change with '='"
            captureKey = 2
            Clear()
            
        } else if(captureKey == 2 && String(runningNumber) == keyTemp) {
            InstructionsLabel[0].text = ""
            InstructionsLabel[0].alpha = 0
            
            captureKey = 0
            runningNumber = ""
            leftValue = ""
            rightValue = ""
            result = ""
            currentOperation = .NULL
            outputLbl.text = "0"
            
            UserDefaults.standard.set(true, forKey: "Mode")
            UserDefaults.standard.set(keyTemp, forKey: "Key")
            showAlert()
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
    
    func Clear() {
        
        runningNumber = ""
        leftValue = ""
        rightValue = ""
        result = ""
        currentOperation = .NULL
        outputLbl.text = "0 "
    }
    
    @IBAction func allClearPerssed(_ sender: UIButton) {
        Clear()
    }
    
    func operation(operation: Operation) {
        if currentOperation != .NULL {
            if runningNumber != "" {
                rightValue = runningNumber
                runningNumber = ""
                
                if currentOperation == .Add {
                    result = "\((Double(leftValue) ?? Double(0)) + (Double(rightValue) ?? Double(0)))"
                } else if currentOperation == .Subtract {
                    result = "\((Double(leftValue) ?? Double(0)) - (Double(rightValue) ?? Double(0)))"
                } else if currentOperation == .Multiply {
                    result = "\((Double(leftValue) ?? Double(0)) * (Double(rightValue) ?? Double(0)))"
                } else if currentOperation == .Divide {
                    result = "\((Double(leftValue) ?? Double(0)) / (Double(rightValue) ?? Double(0)))"
                }
                
                leftValue = result
                if ((Double(result) ?? Double(0)).truncatingRemainder(dividingBy: 1) == 0) {
                    result = "\((Int(Double(result) ?? Double(0))))"
                }
                outputLbl.text = result
            }
            currentOperation = operation
        } else {
            leftValue = runningNumber
            runningNumber = ""
            currentOperation = operation
        }
    }
    
    //    MARK: - Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //    MARK: - Alert
    func showAlert() {
        let refreshAlert = UIAlertController(title: "Done", message: "Calculator mode has been activated", preferredStyle: UIAlertControllerStyle.alert)

        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.dismiss(animated: true, completion: nil)
        }))

        present(refreshAlert, animated: true, completion: nil)
    }
}


