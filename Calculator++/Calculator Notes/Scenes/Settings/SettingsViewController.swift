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
    
    @IBOutlet weak var switchButton: UISwitch!
    @IBOutlet weak var recoverLabel: UILabel!
    
    @IBOutlet weak var chooseProtectionLabel: UILabel!
    
    @IBOutlet weak var bankModeView: UIView!
    @IBOutlet weak var bankModeImage: UIImageView!
    
    @IBOutlet weak var calcModeView: UIView!
    @IBOutlet weak var calcModeImage: UIImageView!

    @IBOutlet weak var noProtectionImage: UIImageView!
    @IBOutlet weak var noProtection: UIButton!
    
    @IBOutlet weak var ModeGroupView: UIView!
    
    @IBOutlet weak var upgradeButton: UIButton!
    
    @IBOutlet weak var customTabBar: UITabBarItem!
    
    
    // MARK: - IBAction
    @IBAction func switchButtonAction(_ sender: UISwitch) {
        UserDefaultService().setRecoveryStatus(status: sender.isOn)
    }

    @IBAction func noProtectionPressed(_ sender: Any) {
        UserDefaultService().setTypeProtection(protectionMode: .noProtection)
        showProtectionType(typeProtection: .noProtection)
    }

    @IBAction func showBankMode(_ sender: Any) {
        performSegue(withIdentifier: Segue.ChangePasswordSegue.rawValue, sender: nil)
    }

    @IBAction func showCalculatorMode(_ sender: Any) {
        performSegue(withIdentifier: Segue.ChangeCalculatorSegue.rawValue, sender: nil)
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setup()
        setupViewStyle()
        switchButton.isOn = UserDefaultService().getRecoveryStatus()
        setupTexts()
    }

    override func viewWillAppear(_ animated: Bool) {
        let typeProtection = UserDefaultService().getTypeProtection()
        showProtectionType(typeProtection: typeProtection)
    }

    // MARK: - Private Methods
    private func showProtectionType(typeProtection: ProtectionMode) {
        switch typeProtection {
            case .calculator:
                bankModeImage.setImage(.diselectedIndicator)
                calcModeImage.setImage(.selectedIndicator)
                noProtectionImage.setImage(.diselectedIndicator)
            
            case .noProtection:
                bankModeImage.setImage(.diselectedIndicator)
                calcModeImage.setImage(.diselectedIndicator)
                noProtectionImage.setImage(.selectedIndicator)

            default: // .bank
                bankModeImage.setImage(.selectedIndicator)
                calcModeImage.setImage(.diselectedIndicator)
                noProtectionImage.setImage(.diselectedIndicator)
        }
    }
    
    // MARK: - UI
    private func setupTexts() {
        self.setText(.settings)
        noProtection.setText(.noProtection)
        upgradeButton.setText(.premiumVersion)
        recoverLabel.setText(.hideRecoverButton)
        chooseProtectionLabel.setText(.chooseProtectionMode)
    }
    
    private func setupViewStyle() {
        upgradeButton.layer.cornerRadius = 8
        ModeGroupView.layer.cornerRadius = 8
        ModeGroupView.layer.shadowOffset = CGSize(width: 0, height: 0)
        ModeGroupView.layer.shadowRadius = 4
        ModeGroupView.layer.shadowOpacity = 0.5
        noProtection.layer.cornerRadius = 8
    }
}
