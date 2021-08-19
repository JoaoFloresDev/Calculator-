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
    @IBOutlet weak var calcModeView: UIView!
    @IBOutlet weak var noProtection: UIButton!
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

        navigationController?.navigationBar.backgroundColor = UIColor.black
        
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
                bankModeView.alpha = 0.4
                noProtection.alpha = 0.4
                calcModeView.alpha = 1

            case .noProtection:
                bankModeView.alpha = 0.4
                noProtection.alpha = 1
                calcModeView.alpha = 0.4

            default: // .bank
                bankModeView.alpha = 1
                noProtection.alpha = 0.4
                calcModeView.alpha = 0.4
        }
    }
}
