//
//  AuthManager.swift
//  Calculator Notes
//
//  Created by Vikram Kumar on 12/06/24.
//  Copyright © 2024 MakeSchool. All rights reserved.
//

import Foundation
import FirebaseAuth

class AuthManager: NSObject, ObservableObject {
   
    // MARK: - Initialization
    
    override init() {
        super.init()
        
    }

    
    // MARK: Sign Out
    
    /// Signs out the current user.
    /// - Parameter completion: Closure called upon completion with an optional error.
    func signOut(completion: @escaping (Error?) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(nil)
        } catch let signOutError as NSError {
            completion(signOutError)
        }
    }
}

// MARK: - Account Creation and Sign In

extension AuthManager {
    
    // MARK: Create Account
    
    /// Creates a new user account with the provided email and password.
    /// - Parameters:
    ///   - email: User's email address.
    ///   - password: User's desired password.
    ///   - completion: Closure called upon completion with an optional error.
    func createAccount(withEmail email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    // MARK: Sign In with Email and Password
    
    /// Signs in the user with the provided email and password.
    /// - Parameters:
    ///   - email: User's email address.
    ///   - password: User's password.
    ///   - completion: Closure called upon completion with an optional error.
    func signInWithEmail(withEmail email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
}
