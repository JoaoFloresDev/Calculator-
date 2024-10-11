import UIKit
import LocalAuthentication

class ChangeNewCalcViewController: BaseCalculatorViewController {
    var vaultMode: VaultMode = .verify
    
    var faceIDButton: UIButton = {
        let button = UIButton()
        button.setText(.recover)
        button.setTitleColor(.systemBlue, for: .normal)
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
            runningNumber += "√"
        case 11:
            runningNumber += "∑"
        case 12:
            runningNumber += "π"
        case 13:
            runningNumber += "x"
        case 14:
            runningNumber += "="
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
                UserDefaultService().setTypeProtection(protectionMode: ProtectionMode.newCalc)
                super.dismiss(animated: true)
            case .createFakePass:
                outputLbl.text = " "
                instructionsLabel.text = "\(Text.insertCreatedPasswordAgainNewCalc.localized()) (\(runningNumber))"
                runningNumber = ""
                vaultMode = .confirmationFakePass
            case .confirmationFakePass:
                Defaults.setString(.fakePass, runningNumber)
                UserDefaultService().setTypeProtection(protectionMode: ProtectionMode.newCalc)
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
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10) // Ajuste conforme necessário
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-10) // Ajuste conforme necessário
            make.height.equalTo(50)
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
                            // Configura homeViewController como rootViewController da janela principal.
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


