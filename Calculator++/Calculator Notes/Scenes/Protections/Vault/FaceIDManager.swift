//
//  FaceIDManager.swift
//  Calculator Notes
//
//  Created by Joao Victor Flores da Costa on 12/09/23.
//  Copyright © 2023 MakeSchool. All rights reserved.
//

import LocalAuthentication

class FaceIDManager {
    
    private let context = LAContext()
    
    // Verifica se o Face ID está disponível no dispositivo
    func isFaceIDAvailable() -> Bool {
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    // Solicita a autenticação via Face ID
    func requestFaceIDAuthentication(completion: @escaping (Bool, Error?) -> Void) {
        guard isFaceIDAvailable() else {
            completion(false, NSError(domain: "FaceID", code: -1, userInfo: [NSLocalizedDescriptionKey: "Face ID is not avaliable"]))
            return
        }
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: Text.faceidreason.localized()) { success, error in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                completion(success, error)
            }
        }
    }
}

