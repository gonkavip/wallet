// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Gonka Wallet';

  @override
  String get splashLoading => 'Carregando...';

  @override
  String get splashCheckingNodes => 'Verificando nós...';

  @override
  String get onboardingCreateTitle => 'Gonka Wallet';

  @override
  String get onboardingCreateSubtitle =>
      'Carteira segura para a blockchain Gonka';

  @override
  String get onboardingCreateNewWallet => 'Criar nova carteira';

  @override
  String get onboardingCreateImportWallet => 'Importar carteira existente';

  @override
  String get onboardingCreateTerms => 'Termos de uso';

  @override
  String get onboardingCreatePrivacy => 'Política de privacidade';

  @override
  String get onboardingBackupTitle => 'Backup da frase semente';

  @override
  String get onboardingBackupWarning =>
      'Anote estas 24 palavras em ordem. Nunca as compartilhe. Qualquer pessoa com esta frase pode acessar seus fundos.';

  @override
  String get onboardingBackupCheckbox => 'Anotei a frase semente';

  @override
  String get onboardingBackupContinue => 'Continuar';

  @override
  String get onboardingBackupVerifyTitle => 'Verificar backup';

  @override
  String onboardingBackupVerifyPrompt(int index) {
    return 'Qual é a palavra nº $index?';
  }

  @override
  String onboardingBackupVerifyHint(int index) {
    return 'Digite a palavra nº $index';
  }

  @override
  String get onboardingBackupVerifyButton => 'Verificar';

  @override
  String get onboardingBackupVerifyError =>
      'Palavra incorreta. Tente novamente.';

  @override
  String get onboardingImportTitle => 'Importar carteira';

  @override
  String get onboardingImportWordByWord => 'Palavra por palavra';

  @override
  String get onboardingImportPastePhrase => 'Colar frase';

  @override
  String get onboardingImportHint =>
      'Cole aqui sua frase semente de 24 palavras...';

  @override
  String get onboardingImportButton => 'Importar';

  @override
  String onboardingImportErrorWordCount(int count) {
    return 'A frase semente deve ter exatamente 24 palavras (há $count)';
  }

  @override
  String get onboardingImportErrorFillAll => 'Preencha todas as 24 palavras';

  @override
  String get onboardingImportErrorInvalid => 'Frase semente inválida';

  @override
  String get onboardingImportPrivateKey => 'Chave privada';

  @override
  String get onboardingImportPrivateKeyHint =>
      'Cole sua chave privada (64 caracteres hex)';

  @override
  String get onboardingImportPrivateKeyErrorInvalid =>
      'Chave privada inválida. Esperados 64 caracteres hex.';

  @override
  String get onboardingNameTitle => 'Nomeie sua carteira';

  @override
  String get onboardingNameHeading => 'Dê um nome à sua carteira';

  @override
  String get onboardingNameSubtext => 'É apenas para sua referência.';

  @override
  String get onboardingNameLabel => 'Nome da carteira';

  @override
  String get onboardingNameValidationEmpty => 'Digite um nome';

  @override
  String get onboardingNameDefault => 'Minha carteira';

  @override
  String get onboardingNameContinue => 'Continuar';

  @override
  String get onboardingPinTitle => 'Definir PIN';

  @override
  String get onboardingPinCreateHeading => 'Crie um PIN de 6 dígitos';

  @override
  String get onboardingPinConfirmHeading => 'Confirme seu PIN';

  @override
  String get onboardingPinMismatch => 'Os PINs não coincidem. Tente novamente.';

  @override
  String get onboardingPinBiometricTitle => 'Ativar biometria?';

  @override
  String get onboardingPinBiometricBody =>
      'Usar Face ID / impressão digital para desbloquear sua carteira?';

  @override
  String get onboardingPinBiometricSkip => 'Pular';

  @override
  String get onboardingPinBiometricEnable => 'Ativar';

  @override
  String get authEnterPin => 'Digite o PIN';

  @override
  String get authEnterCurrentPin => 'Digite o PIN atual';

  @override
  String get authEnterNewPin => 'Digite o novo PIN';

  @override
  String authWrongPin(int remaining) {
    return 'PIN incorreto. Restam $remaining tentativas.';
  }

  @override
  String authCooldown(int seconds) {
    return 'Muitas tentativas. Aguarde $seconds s.';
  }

  @override
  String get homeTitle => 'Gonka Wallet';

  @override
  String get homeEmpty => 'Nenhuma carteira ainda';

  @override
  String get homeCreateWallet => 'Criar carteira';

  @override
  String get homeAddWallet => 'Adicionar carteira';

  @override
  String get walletDetailTitle => 'Carteira';

  @override
  String get walletDetailNotFound => 'Carteira não encontrada';

  @override
  String get walletDetailShowSeed => 'Mostrar frase semente';

  @override
  String get walletDetailExportPk => 'Exportar chave privada';

  @override
  String get walletDetailExportPkDialogTitle => 'Chave privada';

  @override
  String get walletDetailExportPkWarning =>
      'Qualquer pessoa com esta chave pode acessar seus fundos. Nunca a compartilhe.';

  @override
  String get walletDetailExportPkCopied => 'Chave privada copiada';

  @override
  String get walletDetailRename => 'Renomear carteira';

  @override
  String get walletDetailDelete => 'Excluir carteira';

  @override
  String get walletDetailSend => 'Enviar';

  @override
  String get walletDetailReceive => 'Receber';

  @override
  String get walletDetailHostTools => 'Ferramentas de host';

  @override
  String get walletDetailTxHistory => 'Histórico de transações';

  @override
  String get walletDetailNoTx => 'Nenhuma transação ainda';

  @override
  String get walletDetailTxError => 'Falha ao carregar histórico';

  @override
  String walletDetailBalanceError(String error) {
    return 'Falha ao carregar saldo: $error';
  }

  @override
  String get walletDetailSeedDialogTitle => 'Frase semente';

  @override
  String get walletDetailRenameDialogTitle => 'Renomear carteira';

  @override
  String get walletDetailRenameLabel => 'Nome';

  @override
  String walletDetailDeleteDialogBody(String name) {
    return 'Tem certeza de que deseja excluir \"$name\"?\n\nIsso removerá a carteira e sua frase semente deste dispositivo. Certifique-se de ter um backup da frase semente!';
  }

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonSave => 'Salvar';

  @override
  String get commonDelete => 'Excluir';

  @override
  String get commonRetry => 'Tentar novamente';

  @override
  String get commonDone => 'Concluído';

  @override
  String get commonClose => 'Fechar';

  @override
  String get commonCopy => 'Copiar';

  @override
  String get commonFrom => 'De';

  @override
  String get commonTo => 'Para';

  @override
  String get commonAmount => 'Quantia';

  @override
  String get commonFee => 'Taxa';

  @override
  String get commonFeeZero => '0 GNK';

  @override
  String get commonAddress => 'Endereço';

  @override
  String get commonAction => 'Ação';

  @override
  String get commonStatus => 'Status';

  @override
  String get commonType => 'Tipo';

  @override
  String get commonHash => 'Hash';

  @override
  String get commonHeight => 'Bloco';

  @override
  String get commonTime => 'Hora';

  @override
  String get commonMemo => 'Memo';

  @override
  String get commonSuccess => 'Sucesso';

  @override
  String get commonFailed => 'Falha';

  @override
  String get commonContract => 'Contrato';

  @override
  String get commonValidator => 'Validador';

  @override
  String get commonGranter => 'Concedente';

  @override
  String get commonGrantee => 'Beneficiário';

  @override
  String get commonProposal => 'Proposta';

  @override
  String get commonOption => 'Opção';

  @override
  String get commonEpoch => 'Época';

  @override
  String get balanceTotal => 'Saldo total';

  @override
  String get balanceAvailable => 'Disponível';

  @override
  String get balanceVesting => 'Em vesting';

  @override
  String get authBiometricReason => 'Autentique-se para acessar sua carteira';

  @override
  String get errorNoActiveNode => 'Sem nó ativo';

  @override
  String get errorMnemonicNotFound => 'Frase semente não encontrada';

  @override
  String get errorInvalidMnemonic => 'Frase semente inválida';

  @override
  String get errorGeneric => 'Algo deu errado';

  @override
  String get txTypeReceived => 'Recebido';

  @override
  String get txTypeSent => 'Enviado';

  @override
  String get txTypeContract => 'Contrato';

  @override
  String get txTypeContractDeposit => 'Depósito';

  @override
  String get txTypeContractWithdraw => 'Saque';

  @override
  String get txTypeUnjail => 'Liberar validador';

  @override
  String get txTypeGrant => 'Conceder permissões';

  @override
  String get txTypeCollateralDeposit => 'Depósito de garantia';

  @override
  String get txTypeCollateralWithdraw => 'Saque de garantia';

  @override
  String get txTypeVestingReward => 'Recompensa de vesting';

  @override
  String txTypeEpochReward(int epoch) {
    return 'Recompensa da época $epoch';
  }

  @override
  String txTypeVote(String option) {
    return 'Voto: $option';
  }

  @override
  String get txTimeJustNow => 'Agora mesmo';

  @override
  String txTimeMinutesAgo(int minutes) {
    return 'há $minutes min';
  }

  @override
  String txTimeHoursAgo(int hours) {
    return 'há $hours h';
  }

  @override
  String txTimeDaysAgo(int days) {
    return 'há $days d';
  }

  @override
  String get sendTitle => 'Enviar';

  @override
  String get sendRecipientLabel => 'Endereço do destinatário';

  @override
  String get sendAmountLabel => 'Quantia';

  @override
  String get sendMaxButton => 'MÁX';

  @override
  String get sendUnitGnk => 'GNK';

  @override
  String get sendUnitNgonka => 'ngonka';

  @override
  String get sendContinue => 'Continuar';

  @override
  String get sendErrorEnterAddress => 'Digite o endereço do destinatário';

  @override
  String get sendErrorInvalidAddress => 'Endereço Gonka inválido';

  @override
  String get sendErrorSelfSend => 'Não é possível enviar para si mesmo';

  @override
  String get sendErrorEnterAmount => 'Digite a quantia';

  @override
  String get sendErrorAmountPositive => 'A quantia deve ser positiva';

  @override
  String get sendErrorInsufficient => 'Saldo insuficiente';

  @override
  String get sendErrorInvalidAmount => 'Quantia inválida';

  @override
  String get sendScanQr => 'Escanear código QR';

  @override
  String get confirmSendTitle => 'Confirmar envio';

  @override
  String get confirmSendButton => 'Confirmar e enviar';

  @override
  String get confirmSendAuthenticating => 'Autenticando...';

  @override
  String get sendResultSuccess => 'Transação enviada!';

  @override
  String get sendResultFailed => 'Falha na transação';

  @override
  String get receiveTitle => 'Receber';

  @override
  String get receiveNoWallet => 'Sem carteira';

  @override
  String get receiveTapToCopy => 'Toque no endereço para copiar';

  @override
  String get minersTitle => 'Ferramentas de host';

  @override
  String get minersPubKey => 'Minha chave pública';

  @override
  String get minersPubKeySubtitle => 'Ver e copiar sua chave pública';

  @override
  String get minersPubKeyCopied => 'Chave pública copiada';

  @override
  String get minersCollateral => 'Garantia';

  @override
  String get minersCollateralSubtitle => 'Gerencie sua garantia de mineração';

  @override
  String get minersGrant => 'Conceder permissões';

  @override
  String get minersGrantSubtitle =>
      'Conceder permissões à chave operacional de ML';

  @override
  String get minersUnjail => 'Liberar validador';

  @override
  String get minersUnjailSubtitle => 'Libere seu validador';

  @override
  String get minersGovernance => 'Governança';

  @override
  String get minersGovernanceSubtitle => 'Votar em propostas';

  @override
  String get minersTracker => 'Monitor';

  @override
  String get minersTrackerSubtitle => 'Painel profissional';

  @override
  String get collateralTitle => 'Garantia';

  @override
  String get collateralCurrent => 'Garantia atual';

  @override
  String get collateralDeposit => 'Depositar';

  @override
  String get collateralWithdraw => 'Sacar';

  @override
  String get collateralUnbonding => 'Desvinculação';

  @override
  String collateralCompletionEpoch(int epoch) {
    return 'Época de conclusão: $epoch';
  }

  @override
  String get collateralEmpty => 'Ainda sem garantia';

  @override
  String get collateralDepositTitle => 'Depositar garantia';

  @override
  String get collateralWithdrawTitle => 'Sacar garantia';

  @override
  String collateralCurrentInfo(String amount) {
    return 'Garantia atual: $amount GNK';
  }

  @override
  String get collateralErrorExceeds => 'Excede a garantia atual';

  @override
  String get collateralConfirmDeposit => 'Confirmar depósito';

  @override
  String get collateralConfirmWithdraw => 'Confirmar saque';

  @override
  String get collateralConfirmDepositButton => 'Confirmar e depositar';

  @override
  String get collateralConfirmWithdrawButton => 'Confirmar e sacar';

  @override
  String get collateralResultDepositSuccess => 'Depósito realizado!';

  @override
  String get collateralResultWithdrawSuccess => 'Saque realizado!';

  @override
  String get collateralResultDepositFailed => 'Falha no depósito';

  @override
  String get collateralResultWithdrawFailed => 'Falha no saque';

  @override
  String get grantTitle => 'Conceder permissões';

  @override
  String get grantInfo =>
      'Conceda à sua chave operacional de ML permissão para realizar inferência, treinamento e outras operações de ML em seu nome. Isso não concede acesso aos seus fundos.';

  @override
  String get grantOpKeyLabel => 'Endereço da chave operacional';

  @override
  String get grantOpKeyHint => 'gonka1...';

  @override
  String get grantErrorEnterAddress => 'Digite o endereço da chave operacional';

  @override
  String get grantErrorInvalidAddress => 'Endereço Gonka inválido';

  @override
  String get grantErrorSelf => 'Não é possível conceder permissões a si mesmo';

  @override
  String get grantContinue => 'Continuar';

  @override
  String get grantScanQr => 'Escanear código QR';

  @override
  String get grantConfirmTitle => 'Confirmar concessão';

  @override
  String get grantConfirmAction => 'Conceder permissões de ML';

  @override
  String get grantConfirmExpiration => 'Expiração';

  @override
  String get grantConfirmExpirationValue => '2 anos';

  @override
  String get grantConfirmPermissions => 'Permissões';

  @override
  String get grantConfirmPermissionsValue => '27 operações de ML';

  @override
  String get grantConfirmButton => 'Confirmar e conceder';

  @override
  String get grantResultSuccess => 'Permissões concedidas!';

  @override
  String get grantResultFailed => 'Falha na concessão';

  @override
  String get unjailTitle => 'Liberar validador';

  @override
  String get unjailWarningJailed =>
      'Seu validador está preso. Envie uma transação de liberação para retomar as operações.';

  @override
  String get unjailInfoNotJailed =>
      'Seu validador não está preso. Nenhuma ação necessária.';

  @override
  String get unjailInfoNotFound =>
      'Validador não encontrado na cadeia. Certifique-se de que seu validador foi criado.';

  @override
  String get unjailAction => 'Liberar validador';

  @override
  String get unjailValidatorAddress => 'Endereço do validador';

  @override
  String get unjailConfirmButton => 'Confirmar e liberar';

  @override
  String get unjailResultSuccess => 'Liberação bem-sucedida';

  @override
  String get unjailResultFailed => 'Falha na liberação';

  @override
  String get governanceTitle => 'Governança';

  @override
  String get governanceTabAll => 'Todas';

  @override
  String get governanceTabActive => 'Ativas';

  @override
  String get governanceTabClosed => 'Encerradas';

  @override
  String governanceErrorLoad(String error) {
    return 'Falha ao carregar propostas: $error';
  }

  @override
  String get governanceEmptyAll => 'Nenhuma proposta encontrada';

  @override
  String get governanceEmptyActive => 'Nenhuma proposta ativa';

  @override
  String get governanceEmptyClosed => 'Nenhuma proposta encerrada';

  @override
  String get governanceStatusActive => 'Ativa';

  @override
  String get governanceStatusPassed => 'Aprovada';

  @override
  String get governanceStatusRejected => 'Rejeitada';

  @override
  String get governanceEndingSoon => 'Terminando em breve';

  @override
  String governanceEndsInDays(int days, int hours) {
    return 'Termina em $days d $hours h';
  }

  @override
  String governanceEndsInHours(int hours, int minutes) {
    return 'Termina em $hours h $minutes min';
  }

  @override
  String governanceEndsInMinutes(int minutes) {
    return 'Termina em $minutes min';
  }

  @override
  String governanceEndedDaysAgo(int days) {
    return 'Encerrada há $days d';
  }

  @override
  String governanceEndedOn(String date) {
    return 'Encerrada em $date';
  }

  @override
  String proposalDetailTitle(int id) {
    return 'Proposta #$id';
  }

  @override
  String proposalDetailErrorLoad(String error) {
    return 'Falha ao carregar proposta: $error';
  }

  @override
  String get proposalDetailNotFound => 'Proposta não encontrada';

  @override
  String get proposalDetailSummary => 'Resumo';

  @override
  String get proposalDetailProposer => 'Proponente';

  @override
  String get proposalDetailVotingPeriod => 'Período de votação';

  @override
  String get proposalDetailTally => 'Resultados da votação';

  @override
  String get proposalVoteYes => 'Sim';

  @override
  String get proposalVoteAbstain => 'Abstenção';

  @override
  String get proposalVoteNo => 'Não';

  @override
  String get proposalVoteNoWithVeto => 'Não com veto';

  @override
  String get proposalCastYourVote => 'Dê seu voto';

  @override
  String get proposalSubmitVote => 'Enviar voto';

  @override
  String get proposalVotingEnded => 'A votação desta proposta foi encerrada.';

  @override
  String get proposalVoteSubmitted => 'Voto enviado';

  @override
  String get proposalVoteFailed => 'Falha no voto';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsNodeSettings => 'Configurações do nó';

  @override
  String get settingsSecurity => 'Segurança';

  @override
  String get settingsSecuritySubtitle => 'PIN e biometria';

  @override
  String get settingsTerms => 'Termos de uso';

  @override
  String get settingsPrivacy => 'Política de privacidade';

  @override
  String get securityTitle => 'Segurança';

  @override
  String get securityChangePin => 'Alterar PIN';

  @override
  String get securityBiometric => 'Autenticação biométrica';

  @override
  String get securityWipe => 'Apagar carteiras após PIN inválido';

  @override
  String securityWipeSubtitle(int max) {
    return 'Excluir todas as carteiras após $max tentativas incorretas';
  }

  @override
  String get securityPinChanged => 'PIN alterado';

  @override
  String get securityPinNotChanged => 'PIN não alterado';

  @override
  String get nodeSettingsTitle => 'Configurações do nó';

  @override
  String get nodeSettingsRefresh => 'Atualizar nós';

  @override
  String get nodeStatusChecking => 'Verificando...';

  @override
  String get nodeStatusSyncing => 'Sincronizando...';

  @override
  String get nodeStatusNotSynced => 'Não sincronizado';

  @override
  String get nodeStatusOffline => 'Offline';

  @override
  String nodeStatusLatency(int ms) {
    return '$ms ms';
  }

  @override
  String get nodeActive => 'Ativo';

  @override
  String get nodeAdd => 'Adicionar nó';

  @override
  String get nodeUrlLabel => 'URL do nó';

  @override
  String get nodeUrlHint => 'https://node.example.com:8000';

  @override
  String get nodeLabelLabel => 'Rótulo';

  @override
  String get nodeProxyMode => 'Modo proxy';

  @override
  String get nodeProxyModeSubtitle => '/chain-api/ + /chain-rpc/';

  @override
  String get nodeDefaultLabel => 'Nó personalizado';

  @override
  String get nodeAddButton => 'Adicionar';

  @override
  String get securityWarningTitle => 'Aviso de segurança';

  @override
  String get securityWarningBody =>
      'Este dispositivo parece ter root ou jailbreak. Executar um app de carteira em um dispositivo comprometido coloca seus fundos em risco.';

  @override
  String get securityWarningAck => 'Eu entendo os riscos';

  @override
  String get widgetHashCopied => 'Hash copiado';

  @override
  String get widgetAddressCopied => 'Endereço copiado';

  @override
  String get widgetTxHash => 'Hash da transação';

  @override
  String get scanUnrecognized => 'Código QR não reconhecido';

  @override
  String get addressbookTitle => 'Agenda de endereços';

  @override
  String get addressbookEmpty => 'Nenhum endereço salvo';

  @override
  String get addressbookAdd => 'Adicionar endereço';

  @override
  String get addressbookNameLabel => 'Nome';

  @override
  String get addressbookAddressLabel => 'Endereço';

  @override
  String get addressbookDelete => 'Excluir';

  @override
  String get addressbookDeleteConfirm => 'Excluir este endereço?';

  @override
  String get addressbookEdit => 'Editar';

  @override
  String get addressbookSave => 'Salvar';

  @override
  String get addressbookInvalidAddress => 'Endereço gonka inválido';

  @override
  String get addressbookDuplicate => 'Este endereço já está salvo';

  @override
  String get addressbookSelectTitle => 'Escolher destinatário';

  @override
  String get wcConnectTitle => 'Conectar DApp';

  @override
  String get wcConnectScan => 'Escanear QR';

  @override
  String get wcConnectPaste => 'Colar URI';

  @override
  String get wcConnectContinue => 'Continuar';

  @override
  String get wcConnectUriHint => 'wc:...';

  @override
  String get wcConnectInvalidUri => 'URI do WalletConnect inválido';

  @override
  String get wcConnectExpiredUri => 'Esta solicitação de conexão expirou';

  @override
  String get wcApproveTitle => 'Solicitação de conexão';

  @override
  String get wcApproveChooseWallet => 'Escolher carteira';

  @override
  String get wcApproveChainsLabel => 'Redes';

  @override
  String get wcApproveMethodsLabel => 'Métodos';

  @override
  String get wcApproveApprove => 'Aprovar';

  @override
  String get wcApproveReject => 'Rejeitar';

  @override
  String get wcApproveUnsupportedChain =>
      'Este DApp solicita uma rede não suportada. Apenas cosmos:gonka-mainnet é permitida.';

  @override
  String get wcApproveUnsupportedMethod =>
      'Este DApp solicita um método não suportado.';

  @override
  String get wcSignTitle => 'Assinar transação';

  @override
  String get wcSignDapp => 'DApp';

  @override
  String get wcSignSigner => 'Assinante';

  @override
  String get wcSignMemo => 'Nota';

  @override
  String get wcSignApprove => 'Aprovar e assinar';

  @override
  String get wcSignReject => 'Rejeitar';

  @override
  String get wcSignUnknownMessage =>
      'Tipo de mensagem desconhecido. Revise os dados cuidadosamente.';

  @override
  String get wcPermissionsTitle => 'Permissões';

  @override
  String get wcPermissionsActive => 'Sessões ativas';

  @override
  String get wcPermissionsNamespaces => 'Namespace';

  @override
  String get wcPermissionsDisconnect => 'Desconectar';

  @override
  String get wcPermissionsDisconnectConfirm => 'Desconectar este DApp?';

  @override
  String get wcPermissionsAddSession => 'Adicionar conexão';

  @override
  String get wcPermissionsEmpty => 'Nenhum DApp conectado';

  @override
  String wcPermissionsApproved(String date) {
    return 'Conectado em $date';
  }

  @override
  String get walletDetailPermissions => 'Permissões';

  @override
  String get wcErrorNoWallets => 'Crie uma carteira antes de conectar DApps';

  @override
  String get wcErrorChainMismatch =>
      'Rede incorreta: esperava cosmos:gonka-mainnet';

  @override
  String get wcErrorSignerMismatch =>
      'Endereço do assinante não corresponde à carteira conectada';

  @override
  String wcErrorGeneric(String error) {
    return 'Erro do WalletConnect: $error';
  }

  @override
  String get wcBiometricReason => 'Autentique-se para assinar a transação';

  @override
  String get wcMsgSendFrom => 'De';

  @override
  String get wcMsgSendTo => 'Para';

  @override
  String get wcMsgSendAmount => 'Quantia';

  @override
  String get wcMsgRawTypeUrl => 'Tipo';

  @override
  String get wcMsgRawValueHex => 'Dados brutos (hex)';
}
