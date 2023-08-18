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
    case gallery
    case video
    case notes
    
    case instructionFirstStepCalc
    case instructionSecondStepCalc
    
    case instructionFirstStepBank
    case instructionSecondStepBank
    case welcomeInstructionBank
    
    case done
    case edit
    
    case bankModeHasBeenActivated
    case calcModeHasBeenActivated
    
    case premiumToolTitle
    case premiumToolMessage
    
    case save
    case cancel
    
    case errorTitle
    case errorMessage
    
    case incorrectPassword
    case tryAgain
    
    case deleteFiles
    
    case loading
    case close
    case restore
    case buy
    case products
    
    case folderTitle
    case createActionTitle
    case cancelTitle
    case inputPlaceholder
    case folderNameAlreadyUsedTitle
    case folderNameAlreadyUsedText
    
    case deleteConfirmationTitle
    case hideAllVideos
    case showAllVideos
    case hideAllPhotos
    case showAllPhotos
    
    case wouldLikeSetProtection
    case ok
    case see
    
    case confirm
    case yes
    case no
    case askToRestoreBackupTitle
    case askToRestoreBackupMessage
    case backupSuccessTitle
    case backupSuccessMessage
    case backupErrorTitle
    case backupErrorMessage
    case incorrectPasswordTitle
    case incorrectPasswordMessage
    case insertPasswordTitle
    case insertPasswordMessage
    
    func localized() -> String {
        return NSLocalizedString(self.rawValue,
                                 tableName: "Localizable",
                                 bundle: .main,
                                 value: self.rawValue,
                                 comment: self.rawValue)
    }
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
