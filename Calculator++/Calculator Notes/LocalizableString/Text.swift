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
    case updateBackup //"Atualizar backup"
    case faceIDReasin // "We will use authentication to show you the password for the app"
    case myBackupItens // "Meus itens no Backup"
    case backupNavigationTitle// "Meu Backup"
    case vaultMode// "Modo cofre"
    case recover// "Entrar"
    case createPassword // "Crie uma senha e confirme com enter"
    case insertCreatedPasswordAgain // "Digite a senha novamente"
    case insertPassword //  "Digite sua senha e confirme com enter"
    case faceidreason // "Usaremos a autenticação por Face ID para abrir a galeria"
    case backupEnabled // "Ativado"
    case backupDisabled // "Desativado"
    
    case backupNavigationSubtitle // "Clique em  "recuperar backup" no menu de anterior para importar as fotos para sua galeria"
    case continueText // Continuar
    
    case welcomeOnboarding_title // "Bem-vindo ao Secret Gallery"
    case welcomeOnboarding_subtitle // "Proteja suas fotos e vídeos com segurança"
    case welcomeOnboarding_startButtonTitle // "Começar"
    case welcomeOnboarding_skipButtonTitle // "Ao clicar em ”Começar”, você concorda com a politica de privacidade e os termos de uso"
    
    case createCodeOnboarding_title // "Crie um código de acesso"
    case createCodeOnboarding_subtitle // "Crie uma senha para acessar suas fotos guardadas"
    case createCodeOnboarding_startButtonTitle // "Continuar"
    case createCodeOnboarding_skipButtonTitle // "Agora não"
    
    case addPhotosOnboarding_title // "Adicione suas fotos"
    case addPhotosOnboarding_subtitle // "Adicione as fotos que deseja guardar de forma segura"
    case addPhotosOnboarding_startButtonTitle // "Continuar"
    case addPhotosOnboarding_skipButtonTitle // "Agora não"
    case myBackupNavigationSubtitle
    
    case emailErrorTitle // E-mail inválido
    case emailErrorDescription // Confira o e-mail adicionado e tente novamente
    case insertEmailTitle // "Digite o e-mail que será utilizado para recuperação de senha:"
    case insertEmailDescription // "Digite seu e-mail"
    case insertEmailButtonText // "Confirmar E-mail"
    
    case emailPopupTitle // "Enviar email com senha de recuperação?"
    case emailmessage // "Enviaremos um email com a senha de recuperação para você"
    case emailCancelButtonTitle // "Não"
    case emailOkButtonTitle // "Sim"
    case emailNotRegisteredTitle // "Você não cadastrou email para recuperação"
    case emailNotRegisteredMessage // "Não encontramos email pré cadastrado para a conta"
    case successEmailTitle // "Email enviado com sucesso"
    case successEmailMessage // "Confira sua caixa do email, dentro de 48h você receberá um email com a senha de recuperação"
    case errorEmailTitle // "Erro ao enviar email"
    case errorEmailMessage // "Tivemos problemas para enviar o email, confira a conexão com a internet e tente novamente"
    case remindMyPasscode 
    case selectNewIcon // "Selecione o icone desejado"
    case changeIconTitle // "Alterar icone"
    
    case unlimitedStorage // "Armazenamento ilimitado"
    case noAds // "Sem anúncios"
    case videoSuport // "Suporte para vídeos"
    case callToActionPurchase
    case selectImagesToShare // "Selecione as imagens que deseja compartilhar";
    case selectImagesToDelete // "Selecione as imagens que deseja deletar";
    
    case monthlySubscription //    "Assinatura Mensal - "
    case yearlySubscription //    "Assinatura Anual - "
    case termsOfUse //    "Termos de uso"
    case privacyPolicy //    "Politica de privacidade"
    case augmentedReality // "Realidade Aumentada"
    
    case createPasswordNewCalc // "Crie uma senha de 4 digitos"
    case insertCreatedPasswordAgainNewCalc // "Digite novamente a senha para confirmar"
    case oneWeekToTest // "Teste uma semana grátis"
    
    case hasAccount // ""Já possui uma conta?""
    case notHasAccount // "Ainda não? Crie agora"
    case genericLoginError // "Algo deu errado"
    case createLoginError // "Se você ainda não possui uma conta, selecione 'Sign up with google'
    case createLoginErrorTitle //"Try create account"
    case successLogin // "Login efetuado com sucesso!"
    case successLoginDescription // "Suas fotos serão sincronizadas sempre que adicionar novas fotos ou clicar no botão 'atualizar backup'"
    case syncAut // "Sincronização automática"
    case logout // "Logout"
    case pending // "Pendente"
    case downloadBackup // "Baixar backup"
    
    case loginWithGoogle // "Login With Google"
    case signUpWithGoogle // "Sign Up With Google"
    
    case browser // Navegador de internet
    
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
    case iconMrk
    case noads
    case videosupport
    case unlimited
    
    func name() -> String {
        self.rawValue
    }
}
