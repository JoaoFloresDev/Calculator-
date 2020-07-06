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

class CalculatorViewController: UIViewController {
    
    var keyTemp = ""
    var captureKey = 0
    var runningNumber = ""
    var leftValue = ""
    var rightValue = ""
    var result = ""
    var currentOperation:Operation = .NULL
    
    var senha = UserDefaults.standard.string(forKey: "Key") ?? ""
    
    let recoveryKey = "314159"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        outputLbl.text = "0"
        
        if(senha == "") {
            captureKey = 1
        }
        
    }

    @IBOutlet weak var outputLbl: UILabel!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var helpDeskButton: UIButton!

    @IBAction func showHelpDesk(_ sender: Any) {
        if let url = URL(string: "https://www.facebook.com/SharkApplications/") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func useFaceID(_ sender: UIButton) {
        
        let myContext = LAContext()
        let myLocalizedReasonString = "We will use authentication to show you the password for the app"
        
        var authError: NSError?
        
        if myContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authError) {
            myContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: myLocalizedReasonString) { success, evaluateError in
                DispatchQueue.main.async {
                    if success {
                        print("sucesso")
                        self.instructionsLabel.text = "Key: "
                        self.instructionsLabel.text! += UserDefaults.standard.string(forKey: "Key") ?? "314159"
                        self.instructionsLabel.text! += ". Write the Key and confirm with '='"
                        self.instructionsLabel.font = UIFont.boldSystemFont(ofSize: 22.0)
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
            captureKey = 2
            keyTemp = senha

            Clear()
            
        } else if(captureKey == 2 && String(runningNumber) == keyTemp && runningNumber.count <= 6 && runningNumber.count >= 1) {
            UserDefaults.standard.set (senha, forKey: "Key")
            captureKey = 0
        }
        else if((String(runningNumber) == senha && captureKey == 0) || runningNumber == recoveryKey) {
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
    
    func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage {
        
        let cgimage = image.cgImage!
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        let contextSize: CGSize = contextImage.size
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)
        
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
        
        let imageRef: CGImage = cgimage.cropping(to: rect)!
        
        let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return image
    }
    
//    MARK: Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}


