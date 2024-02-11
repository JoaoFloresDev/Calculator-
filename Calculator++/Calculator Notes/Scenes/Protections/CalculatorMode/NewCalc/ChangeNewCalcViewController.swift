import UIKit

class ChangeNewCalcViewController: BaseCalculatorViewController {
    var vaultMode: VaultMode = .verify
    
    // MARK: - IBOutlet
    @IBOutlet weak var instructionsLabel: UILabel!
    
    // MARK: - IBAction
    @IBAction func dismissView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
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
                instructionsLabel.text = "Digite novamente a senha para confirmar (\(runningNumber))"
                runningNumber = ""
                vaultMode = .confirmation
            case .confirmation:
                Defaults.setString(.password, runningNumber)
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        switch vaultMode {
        case .create:
            outputLbl.text = " "
            instructionsLabel.text = "Crie uma senha de 4 digitos"
        default:
            outputLbl.text = "0"
            instructionsLabel.isHidden = true
        }
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


