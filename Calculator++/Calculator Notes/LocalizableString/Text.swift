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
    
    case changepassAlertTitle // Nova senha:
    case changepassAlertText // Senha Alterada com sucesso
    
    case fakepassAlertTitle // Senha Falsa:
    case fakepassAlertText // Senha false criada com sucesso
    
    case loginTocontinueTitle // Faça o login para continuar
    case loginTocontinueText // "Realize o login para habilitar as funcionalidades de backup"

    case wifiConnectTitle // "Conecte-se ao wifi"
    case wifiConnectText // "Conecte-se ao wifi para prosseguir"

    case arquives // "Arquivos"
    case emptyArquives // "Adicione novos arquivos para começar"

    case createFakePasswordNewCalc // "Crie uma senha false de 4 digitos"
    
    case insertCreatedFakePasswordAgainNewCalc // "Digite novamente a senha falsa para confirmar"
    
    case copiedMessage // "Link copiado!"
    case savedMessage // "Fotos salvas!"
    case shareCompleteMessage // "Compartilhamento concluído."
    case shareCancelMessage // "Compartilhamento cancelado."
    case shareErrorMessage // "Erro durante o compartilhamento: "
    case noPhotoToShareMessage // "Nenhuma foto selecionada para compartilhar com outra calculadora."
    case noPhotoToSaveMessage // "Nenhuma foto selecionada para salvar."
    case errorCreatingSharedFolder // "Erro ao criar pasta compartilhada: "
    case sharedLinkTitle // "Link secreto criado"
    case sharedLinkMessagePrefix // "Você pode ver todos seus links criados na aba settings\n\nLink: "
    case sharedLinkMessageSuffix // "\nSenha: "
    case copyLinkButtonTitle // "Copiar Link e Senha"
    case cancelButtonTitle // "Cancelar"
    case downloadAppMessage // "1. Baixe o app https://apps.apple.com/us/app/sg-secret-gallery-vault/id1479873340\n2. Clique no link "
    case downloadAppPasswordPrefix // "\n3. Digite a senha "
    case createPasscodeAndConfrim //"Create a passcode and confirm with '='"
    case sharedPhotosTitle
    
    case savePhotosButtonText // "Salvar fotos"
    case savePhotosErrorTitle // "Erro"
    case savePhotosErrorMessage // "Erro ao baixar a imagem:"
    case processImageErrorMessage // "Erro ao processar a imagem."
    case convertImageErrorMessage // "Erro ao converter a imagem para JPEG."
    case photosSavedTitle ////"Fotos salvas"
    case photosSavedMessage ////"Todas as fotos foram salvas na calculadora."
    case okActionText //"OK"
    case saveVideoErrorMessage
    case limitMessage //"Você atingiu o limite de 5 links. Exclua um link para criar novos."
    case deleteLinkConfirmationTitle //"Excluir Link"
    case deleteConfirmationMessage //"Tem certeza de que deseja excluir este link?"
    case deleteConfirmationCancel //"Cancelar"
    case deleteConfirmationDelete //"Excluir"

    case deleteErrorTitle
    case deleteErrorMessage
    case folderDeletedTitle
    case folderDeletedMessage

    case headerMessage // "Agradecemos por compartilhar suas ideias conosco"
    case emailContact // "Email para Contato (opcional)"
    case writeYourMessage // "Deixe sua Mensagem"
    case emailPlaceholder // "Seu email (opcional)"
    case feedbackPlaceholder // "Queremos ouvir suas ideias, sugestões e feedbacks!"
    case submitButtonTitle // "Enviar Feedback"
    case emptyMessageAlertTitle // "Mensagem em branco"
    case emptyMessageAlertMessage // "Por favor, preencha o campo e tente novamente"
    case errorAlertTitle // "Erro!"
    case errorAlertMessage // "Tente mais tarde"
    case thankYouAlertTitle // "Muito Obrigado!"
    case thankYouAlertMessage // "Sua opinião é muito importante para nós. Sua mensagem foi enviada com sucesso!"
    case suggestionsFeedbackTitle // "Sugestões e Feedback"
    case linkCopied // "Link copiado"
    case secureSharing // "Compartilhamento Seguro"
    case activeLinks // "Links ativos"
    case networkError // "Erro de rede"
    case linkPrefix // "link: "
    case keyPrefix // "key: "
    case linkText // "Link: "
    case keyText // "Senha: "

    case tutorialTitle // "Compartilhe fotos e vídeos com segurança"
    case tutorialDescription // "Agora você pode criar links compartilháveis com fotos e vídeos de maneira segura. Quem receber o link poderá importar as fotos diretamente no app."
    case tutorialHowTo // "Como usar?"
    case tutorialSteps // "1. Selecione as fotos na sua galeria.\n\n2. Toque em compartilhar e escolha 'Criar link seguro'.\n\n3. Envie o link e a senha para quem deseja compartilhar."
    case importingPhotos // "Importando fotos"
    case limitReachedTitle // "Limite Atingido"
    case limitReachedMessage // "Você alcançou o limite de links criados. Por favor, acesse 'Link Seguro' nas configurações e desative um link existente para liberar espaço."
    case chooseDestination // "Escolha o destino"
    case share // "Compartilhar"
    case saveToGallery // "Salvar na galeria"
    case shareWithOtherCalculator // "Compartilhar com outra calculadora"
    case enterURL // "Digite a URL"
    case newTag // "Novo"
    case addFakePassword // "Adicionar senha falsa"
    case secretSharing // "Compartilhamento secreto"
    case improvementSuggestions // "Sugestões de melhoria"
    case biometricAuthentication // "Biometric Authentication"
    case changePassword // "Alterar senha"
    case sendLinkAndPassword // "Enviar link e senha"
    case sharedContentIntro // "Aqui está o link para acessar o conteúdo que compartilhei com você:"
    case sharedContentStep1 // "1. Baixe o app: "
    case sharedContentStep2 // "2. Abra o link: "
    case sharedContentStep3 // "3. Digite a senha para desbloquear: "
    case enterPasswordTitle // "Insira a senha"
    case enterPasswordMessage // "Digite a senha do link secreto para acessar as fotos:"
    case passwordPlaceholder // "Senha"
    case invalidLinkOrPasswordMessage // "Link ou senha inválidos. Tente novamente."
    case noVideoToSaveTitle // "Nenhum vídeo encontrado"
    case noVideoToSaveMessage // "Nenhum vídeo válido foi selecionado para salvar na galeria."
    case noVideoToShareTitle // "Nenhum vídeo encontrado"
    case noVideoToShareMessage // "Nenhum vídeo válido foi selecionado para compartilhar."
    case review // "Avaliar"
    case sugestions // "Sugestões de melhoria?"
    case sugestionsDescription // "Sua opinião é muito importante! nos ajude a melhorar ainda mais"
    
    func localized() -> String {
        return NSLocalizedString(self.rawValue,
                                 tableName: "Localizable",
                                 bundle: .main,
                                 value: self.rawValue,
                                 comment: self.rawValue)
    }
}
