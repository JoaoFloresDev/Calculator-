import UIKit
import LocalAuthentication
import SnapKit

class ChangeNewCalcViewController2: BaseCalculatorViewController {
    var vaultMode: VaultMode = .verify
    
    var faceIDButton: UIButton = {
        let button = UIButton(type: .system)
        let title = "..."
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .right
        
        let attributedTitle = NSAttributedString(string: title, attributes: [
            .foregroundColor: UIColor.systemBlue,
            .paragraphStyle: paragraphStyle
        ])
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.contentHorizontalAlignment = .right
        button.contentVerticalAlignment = .center
        
        button.addTarget(self, action: #selector(faceIDButtonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc private func faceIDButtonTapped() {
        useFaceID()
    }
    
    // MARK: - IBOutlet
    @IBOutlet weak var instructionsLabel: UILabel!
    
    // MARK: - IBAction
    @IBAction func numberPressed(_ sender: UIButton) {
        switch sender.tag {
        case 10:
            runningNumber += "÷"
        case 11:
            runningNumber += "×"
        case 12:
            runningNumber += "-"
        case 13:
            runningNumber += "+"
        case 14:
            if vaultMode == .verify {
                if let newValue = evaluate(runningNumber) {
                    runningNumber = String(newValue)
                    outputLbl.text = runningNumber
                } else {
                    return
                }
            } else {
                return
            }
        case 15:
            runningNumber += "."
        default:
            runningNumber += "\(sender.tag)"
        }
        outputLbl.text = runningNumber
        saveKeyIfNeed()
    }
    
    @IBAction func allClearPerssed(_ sender: UIButton) {
        clear()
    }
    
    func equalPressed() {
        if vaultMode == .verify {
            if let newValue = evaluate(runningNumber) {
                runningNumber = String(newValue)
                outputLbl.text = runningNumber
            }
        }
    }
    
    private func evaluate(_ expression: String) -> String? {
        let formattedExpression = expression
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "×", with: "*")
            .replacingOccurrences(of: "÷", with: "/")
        
        var operands = [Double]()
        var operators = [Character]()
        
        var currentNumber = ""
        var previousChar: Character? = nil
        
        for char in formattedExpression {
            if char.isNumber || char == "." || (char == "-" && (previousChar == nil || previousChar == "+" || previousChar == "-" || previousChar == "*" || previousChar == "/")) {
                currentNumber.append(char)
            } else {
                if let number = Double(currentNumber) {
                    operands.append(number)
                    currentNumber = ""
                }
                operators.append(char)
            }
            previousChar = char
        }
        
        if let number = Double(currentNumber) {
            operands.append(number)
        }
        
        while let index = operators.firstIndex(where: { $0 == "*" || $0 == "/" }) {
            guard index < operands.count - 1 else {
                return nil
            }
            
            let operatorSymbol = operators.remove(at: index)
            let leftOperand = operands.remove(at: index)
            let rightOperand = operands.remove(at: index)
            let result: Double
            if operatorSymbol == "*" {
                result = leftOperand * rightOperand
            } else {
                result = leftOperand / rightOperand
            }
            operands.insert(result, at: index)
        }
        
        while let index = operators.firstIndex(where: { $0 == "+" || $0 == "-" }) {
            guard index < operands.count - 1 else {
                return nil
            }
            
            let operatorSymbol = operators.remove(at: index)
            let leftOperand = operands.remove(at: index)
            let rightOperand = operands.remove(at: index)
            let result: Double
            if operatorSymbol == "+" {
                result = leftOperand + rightOperand
            } else {
                result = leftOperand - rightOperand
            }
            operands.insert(result, at: index)
        }
        
        let result = operands.first ?? 0.0
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 10
        formatter.minimumFractionDigits = 0
        formatter.usesGroupingSeparator = false
        
        return formatter.string(from: NSNumber(value: result))
    }

    
    func saveKeyIfNeed() {
        if runningNumber.count == 4 {
            switch vaultMode {
            case .verify:
                if runningNumber == Defaults.getString(.password) {
                    DispatchQueue.main.async {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let homeViewController = storyboard.instantiateViewController(withIdentifier: "Home")
                        self.present(homeViewController, animated: true)
                    }
                }
            case .create:
                outputLbl.text = " "
                instructionsLabel.text = "\(Text.insertCreatedPasswordAgainNewCalc.localized()) (\(runningNumber))"
                runningNumber = ""
                vaultMode = .confirmation
            case .confirmation:
                Defaults.setString(.password, runningNumber)
                UserDefaultService().setTypeProtection(protectionMode: ProtectionMode.newCalc2)
                super.dismiss(animated: true)
            }
        }
        
        if runningNumber == Constants.recoverPassword {
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let homeViewController = storyboard.instantiateViewController(withIdentifier: "Home")
                self.present(homeViewController, animated: true)
            }
        }
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        faceIDButton.isHidden = Defaults.getBool(.recoveryStatus) || vaultMode != .verify
        view.addSubview(faceIDButton)
        faceIDButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(0)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-10)
            make.height.equalTo(90)
            make.width.equalTo(120)
        }
    }
    
    func useFaceID() {
        let myContext = LAContext()
        let myLocalizedReasonString = "Biometric Authentication"
        
        var authError: NSError?
        
        if myContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authError) {
            myContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: myLocalizedReasonString) { success, evaluateError in
                if success {
                    DispatchQueue.main.async {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        if let homeViewController = storyboard.instantiateViewController(withIdentifier: "Home") as? UIViewController {
                            UIApplication.shared.delegate?.window??.rootViewController = homeViewController
                            UIApplication.shared.delegate?.window??.makeKeyAndVisible()
                        }
                    }
                } else if let error = evaluateError {
                    print(error.localizedDescription)
                }
            }
        } else if let error = authError {
            print(error.localizedDescription)
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        switch vaultMode {
        case .create:
            outputLbl.text = " "
            instructionsLabel.text = Text.createPasswordNewCalc.localized()
        default:
            outputLbl.text = "0"
            instructionsLabel.isHidden = true
        }
    }
}


