//
//  CalculatorViewController.swift
//  Calculator Notes
//
//  Created by Joao Flores on 08/04/20.
//  Copyright © 2020 Joao Flores. All rights reserved.
//

import UIKit

enum Operation:String {
    case Add = "+"
    case Subtract = "-"
    case Divide = "/"
    case Multiply = "*"
    case NULL = "Null"
}

class CalculatorViewController: UIViewController {
    
    @IBOutlet var InstructionsLabel: [UILabel]!
    @IBOutlet weak var outputLbl: UILabel!
    @IBOutlet weak var informationButton: UIButton!
    
    var captureKey = 0
    var runningNumber = ""
    var leftValue = ""
    var rightValue = ""
    var result = ""
    var currentOperation:Operation = .NULL
    
    var senha = UserDefaults.standard.string(forKey: "Key") ?? ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        outputLbl.text = "0"
        
        if(senha == "") {
            InstructionsLabel[0].alpha = 1
            informationButton.alpha = 0
            captureKey = 1
        }
    }
    
    func atualizeKey() {
        UserDefaults.standard.set(senha, forKey: "Key")
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
        if(runningNumber.count <= 6 && runningNumber.count >= 1 && captureKey == 1) {
            senha = String(runningNumber)
            InstructionsLabel[0].text = "senha: \(senha).   Digite-a novamente e confirme com '='"
            captureKey = 2
            UserDefaults.standard.set (senha, forKey: "Key")
            Clear()
            
        } else if(captureKey == 2 && String(runningNumber) == senha && runningNumber.count <= 6 && runningNumber.count >= 1) {
            
            InstructionsLabel[0].text = ""
            InstructionsLabel[0].alpha = 0
            informationButton.alpha = 1
            
            captureKey = 0
        }
        
        if(String(runningNumber) == senha && captureKey == 0 && runningNumber.count <= 6 && runningNumber.count >= 1) {
            captureKey = 0
            runningNumber = ""
            leftValue = ""
            rightValue = ""
            result = ""
            currentOperation = .NULL
            
            outputLbl.text = "0"
            
            self.performSegue(withIdentifier: "showNotes", sender: nil)
        }
        
        operation(operation: currentOperation)
    }
    
    @IBAction func unwindToListNotesViewController (for segue: UIStoryboardSegue) {}
    
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
}


