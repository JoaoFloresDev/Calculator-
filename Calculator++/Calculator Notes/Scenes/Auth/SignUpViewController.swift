//
//  SignUpViewController.swift
//  Calculator Notes
//
//  Created by Vikram Kumar on 11/06/24.
//  Copyright © 2024 MakeSchool. All rights reserved.
//

import UIKit
import GoogleSignIn

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var confirmPasswordTF: UITextField!
    
    let manager = AuthManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnLoginClicked(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnGoogleSignUpClicked(_ sender: UIButton) {
        handleGoogleSignIn()
    }


    @IBAction func btnSignUpClicked(_ sender: UIButton) {
        let email = emailTF.text ?? ""
        let password = passwordTF.text ?? ""
        let confirmPass = confirmPasswordTF.text ?? ""
        
        if email.isEmpty {
            Alerts.showAlert(title: "Error", text: "Please enter your email address.", controller: self)
        } else if !isValidEmail(email: email) {
            Alerts.showAlert(title: "Error", text: "Please enter a valid email address.", controller: self)
        }else if password.isEmpty {
            Alerts.showAlert(title: "Error", text: "Please enter the password.", controller: self)
        } else if confirmPass.isEmpty {
            Alerts.showAlert(title: "Error", text: "Please enter confirm password.", controller: self)
        } else if password != confirmPass {
            Alerts.showAlert(title: "Error", text: "Password and confirm password not matched. Please enter valid password", controller: self)
        } else {
            manager.createAccount(withEmail: email, password: password) { error in
                if let error {
                    Alerts.showAlert(title: "Error", text: error.localizedDescription, controller: self)
                } else {
                    self.navigationController?.pushViewController(OnboardingAddPhotosViewController(), animated: true)
                }
            }
        }
    }
    
    
    
    func handleGoogleSignIn() {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
            guard let result = signInResult else {
                if (error as? NSError)?.code == -5 {
                    print("User cancelled")
                } else {
                    Alerts.showAlert(title: "Error", text: error?.localizedDescription ?? "Something went wrong", controller: self)
                }
                return
            }
            
            if let googleID = result.user.userID, let email = result.user.profile?.email {
                self.manager.createAccount(withEmail: email, password: googleID) { error in
                    if let error {
                        Alerts.showAlert(title: "Error", text: error.localizedDescription, controller: self)
                    } else {
                        self.navigationController?.pushViewController(OnboardingAddPhotosViewController(), animated: true)
                    }
                }
            } else {
                Alerts.showAlert(title: "Error", text: "Something went wrong.", controller: self)
            }
        }
    }
    

    
    func isValidEmail(email: String) -> Bool {
        // Expressão regular para validar um email
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        // Crie um NSPredicate com a expressão regular
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        // Avalie o email usando o NSPredicate
        return emailPredicate.evaluate(with: email)
    }
}
