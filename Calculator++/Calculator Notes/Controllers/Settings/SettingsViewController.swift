//
//  SettingsViewController.swift
//  Calculator Notes
//
//  Created by Joao Flores on 25/06/20.
//  Copyright © 2020 MakeSchool. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UINavigationControllerDelegate {

    // MARK: - IBOutlet
    @IBOutlet weak var upgradeButton: UIButton!

    @IBOutlet weak var bankModeView: UIView!
    @IBOutlet weak var bankModeImage: UIImageView!
    @IBOutlet weak var calcModeView: UIView!
    @IBOutlet weak var calcModeImage: UIImageView!
    @IBOutlet weak var noProtection: UIButton!
    @IBOutlet weak var noProtectionImage: UIImageView!
    @IBOutlet weak var ModeGroupView: UIView!
    @IBOutlet weak var switchButton: UISwitch!

    // MARK: - IBAction
    @IBAction func switchButtonAction(_ sender: UISwitch) {
        UserDefaultService().setRecoveryStatus(status: sender.isOn)
    }

    @IBAction func noProtectionPressed(_ sender: Any) {
        UserDefaultService().setTypeProtection(protectionMode: .noProtection)
        showProtectionType(typeProtection: .noProtection)
    }

    @IBAction func showBankMode(_ sender: Any) {
        performSegue(withIdentifier: "ChangePasswordSegue", sender: nil)
    }

    @IBAction func showCalculatorMode(_ sender: Any) {
        performSegue(withIdentifier: "ChangeCalculatorSegue", sender: nil)
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        upgradeButton.layer.cornerRadius = 8
        ModeGroupView.layer.cornerRadius = 8
        ModeGroupView.layer.shadowOffset = CGSize(width: 0, height: 0)
        ModeGroupView.layer.shadowRadius = 4
        ModeGroupView.layer.shadowOpacity = 0.5
        noProtection.layer.cornerRadius = 8

        switchButton.isOn = UserDefaultService().getRecoveryStatus()
    }

    override func viewWillAppear(_ animated: Bool) {
        let typeProtection = UserDefaultService().getTypeProtection()
        showProtectionType(typeProtection: typeProtection)
    }

    // MARK: - Private Methods
    private func showProtectionType(typeProtection: ProtectionMode) {
        switch typeProtection {
            case .calculator:
                bankModeImage.image = UIImage(named: "diselectedIndicator")
                calcModeImage.image = UIImage(named: "selectedIndicator")
                noProtectionImage.image = UIImage(named: "diselectedIndicator")

            case .noProtection:
                bankModeImage.image = UIImage(named: "diselectedIndicator")
                calcModeImage.image = UIImage(named: "diselectedIndicator")
                noProtectionImage.image = UIImage(named: "selectedIndicator")

            default: // .bank
                bankModeImage.image = UIImage(named: "selectedIndicator")
                calcModeImage.image = UIImage(named: "diselectedIndicator")
                noProtectionImage.image = UIImage(named: "diselectedIndicator")
        }
    }
}
