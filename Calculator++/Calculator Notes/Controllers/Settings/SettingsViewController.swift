//
//  SettingsViewController.swift
//  Calculator Notes
//
//  Created by Joao Flores on 25/06/20.
//  Copyright © 2020 MakeSchool. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UINavigationControllerDelegate {

    
    @IBOutlet weak var upgradeButton: UIButton!
    @IBOutlet weak var bankModeView: UIView!
    @IBOutlet weak var calcModeView: UIView!
    @IBOutlet weak var noProtection: UIButton!
    @IBOutlet weak var ModeGroupView: UIView!
    
    @IBAction func noProtectionPressed(_ sender: Any) {
        print("aqui")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.backgroundColor = UIColor.black
        
        upgradeButton.layer.cornerRadius = 10

        ModeGroupView.layer.cornerRadius = 10
        ModeGroupView.layer.shadowOffset = CGSize(width: 0, height: 0)
        ModeGroupView.layer.shadowRadius = 5
        ModeGroupView.layer.shadowOpacity = 5
        noProtection.layer.cornerRadius = 10
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let typeProtection = UserDefaultService().getTypeProtection()
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
//        if (UserDefaultService().getTypeProtection() == .calculator) {
//            bankModeView.alpha = 0.4
//            noProtection.alpha = 0.4
//            calcModeView.alpha = 1
//        }
//        else {
//            bankModeView.alpha = 1
//            calcModeView.alpha = 0.4
//        }
    }
    
}
