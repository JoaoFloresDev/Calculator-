//
//  Text.swift
//  Calculator Notes
//
//  Created by Joao Victor Flores da Costa on 06/02/22.
//  Copyright © 2022 MakeSchool. All rights reserved.
//

import Foundation

enum Text: String {
    case premiumVersion
    case noProtection
    case hideRecoverButton
    case chooseProtectionMode
    case settings
    
    case instructionFirstStepCalc
    case instructionSecondStepCalc
    
    case instructionFirstStepBank
    case instructionSecondStepBank
}

enum Img: String {
    case diselectedIndicator
    case selectedIndicator
    case keyEmpty
    case keyCurrent
    case placeholderVideo
    case placeholderNotes
    case keyFill
}

enum Segue: String {
    case ChangePasswordSegue
    case ChangeCalculatorSegue
    case showNotes
}
