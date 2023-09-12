//
//  Text.swift
//  Calculator Notes
//
//  Created by Joao Victor Flores da Costa on 06/02/22.
//  Copyright © 2022 MakeSchool. All rights reserved.
//

import Foundation

// ASSETS
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
    case premiumTooliCloudMessage
    
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
    case enableiCloudTitle
    case enableiCloudSubtitle
    case enableiCloudAction
    
    case delete
    case backupNavigationSubtitle
    
    case emptyVideosTitle
    case emptyVideosSubtitle
    case premiumVideosSubtitle
    
    case emptyGalleryTitle
    case emptyGallerySubtitle
    case emptyNotesTitle
    case emptyNotesSubtitle
    case seeMore
    case AC
    case Enter
    
    case backupSettings // "Configurações de Backup"
    case backupStatus // "Backup Criptografado"
    case seeMyBackup //"Ver meu backup"
    case restoreBackup //"Restaurar backup"
    case updateBackup //"Atualizar backup"
    case faceIDReasin // "We will use authentication to show you the password for the app"
    case myBackupItens // "Meus itens no Backup"
    case backupNavigationTitle// "Meu Backup"
    case vaultMode// "Modo cofre"
    case recover// "Recuperar"
    
    case createPassword // "Crie uma senha e confirme com enter"
    case insertCreatedPasswordAgain // "Digite a senha novamente"
    case insertPassword //  "Digite sua senha e confirme com enter"
    case faceidreason // "Usaremos a autenticação por Face ID para abrir a galeria"
    
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
    case folder
    case leftarrow
    case emptyGalleryIcon
    case emptyVideoIcon
    case premiumIcon
    case emptyNotesIcon
    
    func name() -> String {
        self.rawValue
    }
}
