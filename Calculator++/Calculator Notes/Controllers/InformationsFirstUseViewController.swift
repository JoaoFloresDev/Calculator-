//
//  InformationsFirstUseViewController.swift
//  Calculator Notes
//
//  Created by Joao Flores on 01/07/20.
//  Copyright © 2020 MakeSchool. All rights reserved.
//

import UIKit

class InformationsFirstUseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func showPrivacyPolice(_ sender: Any) {
        guard let url = URL(string: "https://drive.google.com/file/d/1fEHysu7rRdk9Hns4CCgK-4ty2_a57vR_/view?usp=sharing") else { return }
        UIApplication.shared.open(url)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
