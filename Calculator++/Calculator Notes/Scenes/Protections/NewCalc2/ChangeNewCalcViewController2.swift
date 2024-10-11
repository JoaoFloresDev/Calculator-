import UIKit
import LocalAuthentication
import SnapKit

protocol ChangeNewCalcViewController2Delegate: AnyObject {
    func changed()
    func fakePassChanged()
}

class ChangeNewCalcViewController2: BaseCalculatorViewController {
    weak var delegate: ChangeNewCalcViewController2Delegate?
    var vaultMode: VaultMode = .verify
    private var initialPassword: String?

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
    
    var instructionsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "Create a passcode and confirm with '='"
        label.isHidden = false
        label.alpha = 1
        label.textColor = .white
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        return label
    }()

    
    var backButton: UIButton = {
        let button = UIButton(type: .system)
        let backImage = UIImage(systemName: "chevron.backward")
        button.setImage(backImage, for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    @objc private func backButtonTapped() {
        if vaultMode == .confirmation {
            vaultMode = .create
            runningNumber = ""
            outputLbl.text = " "
            instructionsLabel.text = Text.createPasswordNewCalc.localized()
            backButton.isHidden = true
        }
    }
    
    @objc private func faceIDButtonTapped() {
        useFaceID()
    }
    
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
                }
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
            if char.isNumber || char == "." || (char == "-" && (previousChar == nil || "+-*/".contains(previousChar!))) {
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
            guard index < operands.count - 1 else { return nil }
            let op = operators.remove(at: index)
            let left = operands.remove(at: index)
            let right = operands.remove(at: index)
            let result = op == "*" ? left * right : left / right
            operands.insert(result, at: index)
        }
        
        while let index = operators.firstIndex(where: { $0 == "+" || $0 == "-" }) {
            guard index < operands.count - 1 else { return nil }
            let op = operators.remove(at: index)
            let left = operands.remove(at: index)
            let right = operands.remove(at: index)
            let result = op == "+" ? left + right : left - right
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
                    presentHomeViewController()
                }
            case .create:
                initialPassword = runningNumber
                outputLbl.text = " "
                instructionsLabel.text = "\(Text.insertCreatedPasswordAgainNewCalc.localized()) (\(runningNumber))"
                runningNumber = ""
                vaultMode = .confirmation
                backButton.isHidden = false
            case .confirmation:
                if runningNumber == initialPassword {
                    Defaults.setString(.password, runningNumber)
                    UserDefaultService().setTypeProtection(protectionMode: ProtectionMode.newCalc2)
                    delegate?.changed()
                    super.dismiss(animated: true)
                } else {
                    runningNumber = ""
                    outputLbl.text = "0"
                }
            case .createFakePass: 
                initialPassword = runningNumber
                outputLbl.text = " "
                instructionsLabel.text = "\(Text.insertCreatedFakePasswordAgainNewCalc.localized()) (\(runningNumber))"
                runningNumber = ""
                vaultMode = .confirmationFakePass
                backButton.isHidden = false
            case .confirmationFakePass:
                if runningNumber == initialPassword {
                    Defaults.setString(.fakePass, runningNumber)
                    UserDefaultService().setTypeProtection(protectionMode: ProtectionMode.newCalc2)
                    delegate?.fakePassChanged()
                    super.dismiss(animated: true)
                } else {
                    runningNumber = ""
                    outputLbl.text = "0"
                }
            }
        }
        
        if runningNumber == Constants.recoverPassword {
            presentHomeViewController()
        }
    }
    
    private func presentHomeViewController() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let homeViewController = storyboard.instantiateViewController(withIdentifier: "Home")
            self.present(homeViewController, animated: true)
        }
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        faceIDButton.isHidden = Defaults.getBool(.recoveryStatus) || vaultMode != .verify
        
        view.addSubview(faceIDButton)
        view.addSubview(backButton)
        view.addSubview(instructionsLabel)
        
        faceIDButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-10)
            make.height.equalTo(44)
            make.width.equalTo(120)
        }
        
        instructionsLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.leading.equalTo(backButton.snp.trailing).offset(0)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-10)
            make.height.width.equalTo(60)
        }
        
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(10)
            make.height.width.equalTo(44)
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
        super.viewWillAppear(animated)
        switch vaultMode {
        case .create:
            outputLbl.text = " "
            instructionsLabel.text = Text.createPasswordNewCalc.localized()
            
        case .createFakePass:
            outputLbl.text = " "
            instructionsLabel.text = Text.createFakePasswordNewCalc.localized()
            
        default:
            outputLbl.text = "0"
            instructionsLabel.isHidden = true
        }
    }
}
