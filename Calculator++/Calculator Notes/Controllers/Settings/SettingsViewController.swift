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
    @IBOutlet weak var ModeGroupView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.backgroundColor = UIColor.black
        
        upgradeButton.layer.cornerRadius = 10

        ModeGroupView.layer.cornerRadius = 10
        ModeGroupView.layer.shadowOffset = CGSize(width: 0, height: 0)
        ModeGroupView.layer.shadowRadius = 5
        ModeGroupView.layer.shadowOpacity = 5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (UserDefaults.standard.bool(forKey: "Mode") == true) {
            bankModeView.alpha = 0.4
            calcModeView.alpha = 1
        }
        else {
            bankModeView.alpha = 1
            calcModeView.alpha = 0.4
        }
    }
    
}
