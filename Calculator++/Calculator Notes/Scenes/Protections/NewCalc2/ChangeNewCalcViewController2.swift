import UIKit
import StoreKit
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
        let iconImage = UIImage(systemName: "shield")
        button.setImage(iconImage, for: .normal)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .right
        
        button.contentHorizontalAlignment = .right
        button.contentVerticalAlignment = .center
        button.tintColor = .systemBlue
        button.semanticContentAttribute = .forceRightToLeft
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        
        button.addTarget(self, action: #selector(faceIDButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var instructionsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = Text.createPasscodeAndConfrim.localized() //"Create a passcode and confirm with '='"
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
        if !Defaults.getBool(.notFirstUse) {
            button.isHidden = true
        }
        return button
    }()
    
    @objc private func backButtonTapped() {
        if (vaultMode == .create || vaultMode == .createFakePass) {
            self.dismiss(animated: true)
        }
        if vaultMode == .confirmation {
            vaultMode = .create
            runningNumber = ""
            outputLbl.text = " "
            instructionsLabel.text = Text.createPasswordNewCalc.localized()
            if !Defaults.getBool(.notFirstUse) {
                backButton.isHidden = true
            }
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
                else if runningNumber == Defaults.getString(.fakePass) {
                    let controller = FakeHomeFactory.makeScene()
                    let navigation = UINavigationController(rootViewController: controller)
                    navigation.modalPresentationStyle = .fullScreen
                    
                    self.present(navigation, animated: true)
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
                    super.dismiss(animated: true) {
                        self.delegate?.changed()
                    }
                } else {
                    runningNumber = ""
                    outputLbl.text = "0"
                }
            case .createFakePass:
                if runningNumber == Defaults.getString(.password) {
                    runningNumber = ""
                    outputLbl.text = "0"
                    return
                }
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
                    super.dismiss(animated: true) {
                        self.delegate?.fakePassChanged()
                    }
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
            let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .large)
            loadingIndicator.center = self.view.center
            loadingIndicator.startAnimating()
            self.view.addSubview(loadingIndicator)
            let couter = Counter()
            couter.increment()
            let storyboard =
            UIStoryboard(name: "Main", bundle: nil)
            let homeViewController = storyboard.instantiateViewController(withIdentifier: "Home")
            self.present(homeViewController, animated: true) {
                loadingIndicator.stopAnimating()
                loadingIndicator.removeFromSuperview()
                if couter.count > 8 && !UserDefaults.standard.bool(forKey: "userGoToFastReview") {
                    SKStoreReviewController.requestReviewInCurrentScene {
                        UserDefaults.standard.set(true, forKey: "userGoToFastReview")
                    }
                    return
                }
                else if couter.count > 16 && !UserDefaults.standard.bool(forKey: "userGoToReview") {
                    Alerts.showReviewNow(controller: homeViewController) { showReview in
                        UserDefaults.standard.set(true, forKey: "userGoToReview")
                        if showReview {
                            let appID = "1479873340"
                            if let url = URL(string: "itms-apps://itunes.apple.com/app/id\(appID)?action=write-review"),
                               UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        }
                    }
                    return
                }
                else if couter.count % 4 != 0 && couter.count > 30 {
                    if RazeFaceProducts.store.isProductPurchased("Calc.noads.mensal") ||
                        RazeFaceProducts.store.isProductPurchased("calcanual") ||
                        RazeFaceProducts.store.isProductPurchased("NoAds.Calc") {
                        return
                    } else {
                        let storyboard = UIStoryboard(name: "Purchase", bundle: nil)
                        if let purchaseViewController = storyboard.instantiateViewController(withIdentifier: "Purchase") as? UIViewController {
                            self.presentWithCustomDissolve(viewController: purchaseViewController, from: homeViewController, duration: 0.5)
                        }
                        return
                    }
                }
            }
        }
    }
    
    func presentWithCustomDissolve(viewController: UIViewController, from presenter: UIViewController, duration: TimeInterval = 1.0) {
        viewController.view.alpha = 0
        
        presenter.present(viewController, animated: false) {
            UIView.animate(withDuration: duration, animations: {
                viewController.view.alpha = 1
            })
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
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(15)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(0)
            make.height.width.equalTo(50)
        }
    }
    
    func useFaceID() {
        let myContext = LAContext()
        let myLocalizedReasonString = Text.biometricAuthentication.localized()
        var authError: NSError?
        
        if myContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authError) {
            myContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: myLocalizedReasonString) { success, evaluateError in
                if success {
                    DispatchQueue.main.async {
                        self.presentHomeViewController()
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
            backButton.isHidden = true
            outputLbl.text = "0"
            instructionsLabel.isHidden = true
        }
    }
}
