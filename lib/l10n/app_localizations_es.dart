// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Gonka Wallet';

  @override
  String get splashLoading => 'Cargando...';

  @override
  String get splashCheckingNodes => 'Comprobando nodos...';

  @override
  String get onboardingCreateTitle => 'Gonka Wallet';

  @override
  String get onboardingCreateSubtitle =>
      'Monedero seguro para la blockchain Gonka';

  @override
  String get onboardingCreateNewWallet => 'Crear nuevo monedero';

  @override
  String get onboardingCreateImportWallet => 'Importar monedero existente';

  @override
  String get onboardingCreateTerms => 'Términos de uso';

  @override
  String get onboardingCreatePrivacy => 'Política de privacidad';

  @override
  String get onboardingBackupTitle => 'Copia de seguridad de la frase semilla';

  @override
  String get onboardingBackupWarning =>
      'Escribe estas 24 palabras en orden. No las compartas con nadie. Cualquiera que tenga esta frase puede acceder a tus fondos.';

  @override
  String get onboardingBackupCheckbox => 'He anotado la frase semilla';

  @override
  String get onboardingBackupContinue => 'Continuar';

  @override
  String get onboardingBackupVerifyTitle => 'Verificar copia de seguridad';

  @override
  String onboardingBackupVerifyPrompt(int index) {
    return '¿Cuál es la palabra #$index?';
  }

  @override
  String onboardingBackupVerifyHint(int index) {
    return 'Introduce la palabra #$index';
  }

  @override
  String get onboardingBackupVerifyButton => 'Verificar';

  @override
  String get onboardingBackupVerifyError =>
      'Palabra incorrecta. Inténtalo de nuevo.';

  @override
  String get onboardingImportTitle => 'Importar monedero';

  @override
  String get onboardingImportWordByWord => 'Palabra por palabra';

  @override
  String get onboardingImportPastePhrase => 'Pegar frase';

  @override
  String get onboardingImportHint =>
      'Pega aquí tu frase semilla de 24 palabras...';

  @override
  String get onboardingImportButton => 'Importar';

  @override
  String onboardingImportErrorWordCount(int count) {
    return 'La frase semilla debe tener exactamente 24 palabras (hay $count)';
  }

  @override
  String get onboardingImportErrorFillAll => 'Rellena las 24 palabras';

  @override
  String get onboardingImportErrorInvalid => 'Frase semilla inválida';

  @override
  String get onboardingImportPrivateKey => 'Clave privada';

  @override
  String get onboardingImportPrivateKeyHint =>
      'Pega tu clave privada (64 caracteres hex)';

  @override
  String get onboardingImportPrivateKeyErrorInvalid =>
      'Clave privada inválida. Se esperan 64 caracteres hex.';

  @override
  String get onboardingNameTitle => 'Nombra tu monedero';

  @override
  String get onboardingNameHeading => 'Dale un nombre a tu monedero';

  @override
  String get onboardingNameSubtext => 'Es sólo para tu referencia.';

  @override
  String get onboardingNameLabel => 'Nombre del monedero';

  @override
  String get onboardingNameValidationEmpty => 'Introduce un nombre';

  @override
  String get onboardingNameDefault => 'Mi monedero';

  @override
  String get onboardingNameContinue => 'Continuar';

  @override
  String get onboardingPinTitle => 'Establecer PIN';

  @override
  String get onboardingPinCreateHeading => 'Crea un PIN de 6 dígitos';

  @override
  String get onboardingPinConfirmHeading => 'Confirma tu PIN';

  @override
  String get onboardingPinMismatch =>
      'Los PIN no coinciden. Inténtalo de nuevo.';

  @override
  String get onboardingPinBiometricTitle => '¿Activar biometría?';

  @override
  String get onboardingPinBiometricBody =>
      '¿Usar Face ID / huella para desbloquear tu monedero?';

  @override
  String get onboardingPinBiometricSkip => 'Omitir';

  @override
  String get onboardingPinBiometricEnable => 'Activar';

  @override
  String get authEnterPin => 'Introduce el PIN';

  @override
  String get authEnterCurrentPin => 'Introduce el PIN actual';

  @override
  String get authEnterNewPin => 'Introduce el nuevo PIN';

  @override
  String authWrongPin(int remaining) {
    return 'PIN incorrecto. Te quedan $remaining intentos.';
  }

  @override
  String authCooldown(int seconds) {
    return 'Demasiados intentos. Espera $seconds s.';
  }

  @override
  String get homeTitle => 'Gonka Wallet';

  @override
  String get homeEmpty => 'Aún no tienes monederos';

  @override
  String get homeCreateWallet => 'Crear monedero';

  @override
  String get homeAddWallet => 'Añadir monedero';

  @override
  String get walletDetailTitle => 'Monedero';

  @override
  String get walletDetailNotFound => 'Monedero no encontrado';

  @override
  String get walletDetailShowSeed => 'Mostrar frase semilla';

  @override
  String get walletDetailExportPk => 'Exportar clave privada';

  @override
  String get walletDetailExportPkDialogTitle => 'Clave privada';

  @override
  String get walletDetailExportPkWarning =>
      'Cualquiera que tenga esta clave puede acceder a tus fondos. No la compartas con nadie.';

  @override
  String get walletDetailExportPkCopied => 'Clave privada copiada';

  @override
  String get walletDetailRename => 'Renombrar monedero';

  @override
  String get walletDetailDelete => 'Eliminar monedero';

  @override
  String get walletDetailSend => 'Enviar';

  @override
  String get walletDetailReceive => 'Recibir';

  @override
  String get walletDetailHostTools => 'Herramientas de host';

  @override
  String get walletDetailTxHistory => 'Historial de transacciones';

  @override
  String get walletDetailNoTx => 'Aún no hay transacciones';

  @override
  String get walletDetailTxError => 'Error al cargar el historial';

  @override
  String walletDetailBalanceError(String error) {
    return 'Error al cargar el saldo: $error';
  }

  @override
  String get walletDetailSeedDialogTitle => 'Frase semilla';

  @override
  String get walletDetailRenameDialogTitle => 'Renombrar monedero';

  @override
  String get walletDetailRenameLabel => 'Nombre';

  @override
  String walletDetailDeleteDialogBody(String name) {
    return '¿Seguro que quieres eliminar «$name»?\n\nEsto eliminará el monedero y su frase semilla de este dispositivo. ¡Asegúrate de haber guardado una copia de la frase semilla!';
  }

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get commonDone => 'Hecho';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get commonCopy => 'Copiar';

  @override
  String get commonFrom => 'De';

  @override
  String get commonTo => 'A';

  @override
  String get commonAmount => 'Cantidad';

  @override
  String get commonFee => 'Comisión';

  @override
  String get commonFeeZero => '0 GNK';

  @override
  String get commonAddress => 'Dirección';

  @override
  String get commonAction => 'Acción';

  @override
  String get commonStatus => 'Estado';

  @override
  String get commonType => 'Tipo';

  @override
  String get commonHash => 'Hash';

  @override
  String get commonHeight => 'Bloque';

  @override
  String get commonTime => 'Hora';

  @override
  String get commonMemo => 'Memo';

  @override
  String get commonSuccess => 'Éxito';

  @override
  String get commonFailed => 'Error';

  @override
  String get commonContract => 'Contrato';

  @override
  String get commonValidator => 'Validador';

  @override
  String get commonGranter => 'Otorgante';

  @override
  String get commonGrantee => 'Beneficiario';

  @override
  String get commonProposal => 'Propuesta';

  @override
  String get commonOption => 'Opción';

  @override
  String get commonEpoch => 'Época';

  @override
  String get balanceTotal => 'Saldo total';

  @override
  String get balanceAvailable => 'Disponible';

  @override
  String get balanceVesting => 'En vesting';

  @override
  String get authBiometricReason => 'Autentícate para acceder a tu monedero';

  @override
  String get errorNoActiveNode => 'Sin nodo activo';

  @override
  String get errorMnemonicNotFound => 'Frase semilla no encontrada';

  @override
  String get errorInvalidMnemonic => 'Frase semilla inválida';

  @override
  String get errorGeneric => 'Algo salió mal';

  @override
  String get txTypeReceived => 'Recibido';

  @override
  String get txTypeSent => 'Enviado';

  @override
  String get txTypeContract => 'Contrato';

  @override
  String get txTypeContractDeposit => 'Depósito';

  @override
  String get txTypeContractWithdraw => 'Retiro';

  @override
  String get txTypeUnjail => 'Desencarcelar';

  @override
  String get txTypeGrant => 'Otorgar permisos';

  @override
  String get txTypeCollateralDeposit => 'Depósito de garantía';

  @override
  String get txTypeCollateralWithdraw => 'Retiro de garantía';

  @override
  String get txTypeVestingReward => 'Recompensa de vesting';

  @override
  String txTypeEpochReward(int epoch) {
    return 'Recompensa de la época $epoch';
  }

  @override
  String txTypeVote(String option) {
    return 'Voto: $option';
  }

  @override
  String get txTimeJustNow => 'Ahora mismo';

  @override
  String txTimeMinutesAgo(int minutes) {
    return 'hace $minutes min';
  }

  @override
  String txTimeHoursAgo(int hours) {
    return 'hace $hours h';
  }

  @override
  String txTimeDaysAgo(int days) {
    return 'hace $days d';
  }

  @override
  String get sendTitle => 'Enviar';

  @override
  String get sendRecipientLabel => 'Dirección del destinatario';

  @override
  String get sendAmountLabel => 'Cantidad';

  @override
  String get sendMaxButton => 'MÁX';

  @override
  String get sendUnitGnk => 'GNK';

  @override
  String get sendUnitNgonka => 'ngonka';

  @override
  String get sendContinue => 'Continuar';

  @override
  String get sendErrorEnterAddress => 'Introduce la dirección del destinatario';

  @override
  String get sendErrorInvalidAddress => 'Dirección Gonka inválida';

  @override
  String get sendErrorSelfSend => 'No puedes enviarte a ti mismo';

  @override
  String get sendErrorEnterAmount => 'Introduce la cantidad';

  @override
  String get sendErrorAmountPositive => 'La cantidad debe ser positiva';

  @override
  String get sendErrorInsufficient => 'Saldo insuficiente';

  @override
  String get sendErrorInvalidAmount => 'Cantidad inválida';

  @override
  String get sendScanQr => 'Escanear código QR';

  @override
  String get confirmSendTitle => 'Confirmar envío';

  @override
  String get confirmSendButton => 'Confirmar y enviar';

  @override
  String get confirmSendAuthenticating => 'Autenticando...';

  @override
  String get sendResultSuccess => '¡Transacción enviada!';

  @override
  String get sendResultFailed => 'Error en la transacción';

  @override
  String get receiveTitle => 'Recibir';

  @override
  String get receiveNoWallet => 'Sin monedero';

  @override
  String get receiveTapToCopy => 'Toca la dirección para copiar';

  @override
  String get minersTitle => 'Herramientas de host';

  @override
  String get minersPubKey => 'Mi clave pública';

  @override
  String get minersPubKeySubtitle => 'Ver y copiar tu clave pública';

  @override
  String get minersPubKeyCopied => 'Clave pública copiada';

  @override
  String get minersCollateral => 'Garantía';

  @override
  String get minersCollateralSubtitle => 'Gestiona tu garantía de minería';

  @override
  String get minersGrant => 'Otorgar permisos';

  @override
  String get minersGrantSubtitle =>
      'Otorga permisos a la clave operativa de ML';

  @override
  String get minersUnjail => 'Desencarcelar';

  @override
  String get minersUnjailSubtitle => 'Desencarcela tu validador';

  @override
  String get minersGovernance => 'Gobernanza';

  @override
  String get minersGovernanceSubtitle => 'Vota propuestas';

  @override
  String get minersTracker => 'Monitor';

  @override
  String get minersTrackerSubtitle => 'Panel profesional';

  @override
  String get collateralTitle => 'Garantía';

  @override
  String get collateralCurrent => 'Garantía actual';

  @override
  String get collateralDeposit => 'Depositar';

  @override
  String get collateralWithdraw => 'Retirar';

  @override
  String get collateralUnbonding => 'Desvinculación';

  @override
  String collateralCompletionEpoch(int epoch) {
    return 'Época de finalización: $epoch';
  }

  @override
  String get collateralEmpty => 'Aún no hay garantía';

  @override
  String get collateralDepositTitle => 'Depositar garantía';

  @override
  String get collateralWithdrawTitle => 'Retirar garantía';

  @override
  String collateralCurrentInfo(String amount) {
    return 'Garantía actual: $amount GNK';
  }

  @override
  String get collateralErrorExceeds => 'Excede la garantía actual';

  @override
  String get collateralConfirmDeposit => 'Confirmar depósito';

  @override
  String get collateralConfirmWithdraw => 'Confirmar retiro';

  @override
  String get collateralConfirmDepositButton => 'Confirmar y depositar';

  @override
  String get collateralConfirmWithdrawButton => 'Confirmar y retirar';

  @override
  String get collateralResultDepositSuccess => '¡Depósito realizado!';

  @override
  String get collateralResultWithdrawSuccess => '¡Retiro realizado!';

  @override
  String get collateralResultDepositFailed => 'Error en el depósito';

  @override
  String get collateralResultWithdrawFailed => 'Error en el retiro';

  @override
  String get grantTitle => 'Otorgar permisos';

  @override
  String get grantInfo =>
      'Otorga a tu clave operativa de ML permiso para realizar inferencia, entrenamiento y otras operaciones de ML en tu nombre. Esto no concede acceso a tus fondos.';

  @override
  String get grantOpKeyLabel => 'Dirección de la clave operativa';

  @override
  String get grantOpKeyHint => 'gonka1...';

  @override
  String get grantErrorEnterAddress =>
      'Introduce la dirección de la clave operativa';

  @override
  String get grantErrorInvalidAddress => 'Dirección Gonka inválida';

  @override
  String get grantErrorSelf => 'No puedes otorgarte permisos a ti mismo';

  @override
  String get grantContinue => 'Continuar';

  @override
  String get grantScanQr => 'Escanear código QR';

  @override
  String get grantConfirmTitle => 'Confirmar otorgamiento';

  @override
  String get grantConfirmAction => 'Otorgar permisos de ML';

  @override
  String get grantConfirmExpiration => 'Vencimiento';

  @override
  String get grantConfirmExpirationValue => '2 años';

  @override
  String get grantConfirmPermissions => 'Permisos';

  @override
  String get grantConfirmPermissionsValue => '27 operaciones de ML';

  @override
  String get grantConfirmButton => 'Confirmar y otorgar';

  @override
  String get grantResultSuccess => '¡Permisos otorgados!';

  @override
  String get grantResultFailed => 'Error al otorgar';

  @override
  String get unjailTitle => 'Desencarcelar validador';

  @override
  String get unjailWarningJailed =>
      'Tu validador está encarcelado. Envía una transacción de desencarcelamiento para reanudar las operaciones.';

  @override
  String get unjailInfoNotJailed =>
      'Tu validador no está encarcelado. No es necesario realizar ninguna acción.';

  @override
  String get unjailInfoNotFound =>
      'Validador no encontrado en la cadena. Asegúrate de que tu validador haya sido creado.';

  @override
  String get unjailAction => 'Desencarcelar validador';

  @override
  String get unjailValidatorAddress => 'Dirección del validador';

  @override
  String get unjailConfirmButton => 'Confirmar y desencarcelar';

  @override
  String get unjailResultSuccess => 'Desencarcelamiento exitoso';

  @override
  String get unjailResultFailed => 'Error al desencarcelar';

  @override
  String get governanceTitle => 'Gobernanza';

  @override
  String get governanceTabAll => 'Todas';

  @override
  String get governanceTabActive => 'Activas';

  @override
  String get governanceTabClosed => 'Cerradas';

  @override
  String governanceErrorLoad(String error) {
    return 'Error al cargar las propuestas: $error';
  }

  @override
  String get governanceEmptyAll => 'No se encontraron propuestas';

  @override
  String get governanceEmptyActive => 'No hay propuestas activas';

  @override
  String get governanceEmptyClosed => 'No hay propuestas cerradas';

  @override
  String get governanceStatusActive => 'Activa';

  @override
  String get governanceStatusPassed => 'Aprobada';

  @override
  String get governanceStatusRejected => 'Rechazada';

  @override
  String get governanceEndingSoon => 'Terminando pronto';

  @override
  String governanceEndsInDays(int days, int hours) {
    return 'Termina en $days d $hours h';
  }

  @override
  String governanceEndsInHours(int hours, int minutes) {
    return 'Termina en $hours h $minutes min';
  }

  @override
  String governanceEndsInMinutes(int minutes) {
    return 'Termina en $minutes min';
  }

  @override
  String governanceEndedDaysAgo(int days) {
    return 'Terminó hace $days d';
  }

  @override
  String governanceEndedOn(String date) {
    return 'Terminó el $date';
  }

  @override
  String proposalDetailTitle(int id) {
    return 'Propuesta #$id';
  }

  @override
  String proposalDetailErrorLoad(String error) {
    return 'Error al cargar la propuesta: $error';
  }

  @override
  String get proposalDetailNotFound => 'Propuesta no encontrada';

  @override
  String get proposalDetailSummary => 'Resumen';

  @override
  String get proposalDetailProposer => 'Proponente';

  @override
  String get proposalDetailVotingPeriod => 'Período de votación';

  @override
  String get proposalDetailTally => 'Resultados del recuento';

  @override
  String get proposalVoteYes => 'Sí';

  @override
  String get proposalVoteAbstain => 'Abstención';

  @override
  String get proposalVoteNo => 'No';

  @override
  String get proposalVoteNoWithVeto => 'No con veto';

  @override
  String get proposalCastYourVote => 'Emite tu voto';

  @override
  String get proposalSubmitVote => 'Enviar voto';

  @override
  String get proposalVotingEnded =>
      'La votación de esta propuesta ha terminado.';

  @override
  String get proposalVoteSubmitted => 'Voto enviado';

  @override
  String get proposalVoteFailed => 'Error al votar';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsNodeSettings => 'Ajustes del nodo';

  @override
  String get settingsSecurity => 'Seguridad';

  @override
  String get settingsSecuritySubtitle => 'PIN y biometría';

  @override
  String get settingsTerms => 'Términos de uso';

  @override
  String get settingsPrivacy => 'Política de privacidad';

  @override
  String get securityTitle => 'Seguridad';

  @override
  String get securityChangePin => 'Cambiar PIN';

  @override
  String get securityBiometric => 'Autenticación biométrica';

  @override
  String get securityWipe => 'Borrar monederos tras PIN fallido';

  @override
  String securityWipeSubtitle(int max) {
    return 'Eliminar todos los monederos tras $max intentos fallidos';
  }

  @override
  String get securityPinChanged => 'PIN cambiado';

  @override
  String get securityPinNotChanged => 'PIN no cambiado';

  @override
  String get nodeSettingsTitle => 'Ajustes del nodo';

  @override
  String get nodeSettingsRefresh => 'Actualizar nodos';

  @override
  String get nodeStatusChecking => 'Comprobando...';

  @override
  String get nodeStatusSyncing => 'Sincronizando...';

  @override
  String get nodeStatusNotSynced => 'No sincronizado';

  @override
  String get nodeStatusOffline => 'Desconectado';

  @override
  String nodeStatusLatency(int ms) {
    return '$ms ms';
  }

  @override
  String get nodeActive => 'Activo';

  @override
  String get nodeAdd => 'Añadir nodo';

  @override
  String get nodeUrlLabel => 'URL del nodo';

  @override
  String get nodeUrlHint => 'https://node.example.com:8000';

  @override
  String get nodeLabelLabel => 'Etiqueta';

  @override
  String get nodeProxyMode => 'Modo proxy';

  @override
  String get nodeProxyModeSubtitle => '/chain-api/ + /chain-rpc/';

  @override
  String get nodeDefaultLabel => 'Nodo personalizado';

  @override
  String get nodeAddButton => 'Añadir';

  @override
  String get securityWarningTitle => 'Advertencia de seguridad';

  @override
  String get securityWarningBody =>
      'Este dispositivo parece estar rooteado o con jailbreak. Ejecutar una app de monedero en un dispositivo comprometido pone tus fondos en riesgo.';

  @override
  String get securityWarningAck => 'Entiendo los riesgos';

  @override
  String get widgetHashCopied => 'Hash copiado';

  @override
  String get widgetAddressCopied => 'Dirección copiada';

  @override
  String get widgetTxHash => 'Hash de transacción';

  @override
  String get scanUnrecognized => 'Código QR no reconocido';

  @override
  String get addressbookTitle => 'Libreta de direcciones';

  @override
  String get addressbookEmpty => 'No hay direcciones guardadas';

  @override
  String get addressbookAdd => 'Añadir dirección';

  @override
  String get addressbookNameLabel => 'Nombre';

  @override
  String get addressbookAddressLabel => 'Dirección';

  @override
  String get addressbookDelete => 'Eliminar';

  @override
  String get addressbookDeleteConfirm => '¿Eliminar esta dirección?';

  @override
  String get addressbookEdit => 'Editar';

  @override
  String get addressbookSave => 'Guardar';

  @override
  String get addressbookInvalidAddress => 'Dirección gonka no válida';

  @override
  String get addressbookDuplicate => 'Esta dirección ya está guardada';

  @override
  String get addressbookSelectTitle => 'Elegir destinatario';

  @override
  String get wcConnectTitle => 'Conectar DApp';

  @override
  String get wcConnectScan => 'Escanear QR';

  @override
  String get wcConnectPaste => 'Pegar URI';

  @override
  String get wcConnectContinue => 'Continuar';

  @override
  String get wcConnectUriHint => 'wc:...';

  @override
  String get wcConnectInvalidUri => 'URI de WalletConnect no válido';

  @override
  String get wcConnectExpiredUri => 'Esta solicitud de conexión ha expirado';

  @override
  String get wcApproveTitle => 'Solicitud de conexión';

  @override
  String get wcApproveChooseWallet => 'Elegir monedero';

  @override
  String get wcApproveChainsLabel => 'Redes';

  @override
  String get wcApproveMethodsLabel => 'Métodos';

  @override
  String get wcApproveApprove => 'Aprobar';

  @override
  String get wcApproveReject => 'Rechazar';

  @override
  String get wcApproveUnsupportedChain =>
      'Esta DApp solicita una red no compatible. Solo se admite cosmos:gonka-mainnet.';

  @override
  String get wcApproveUnsupportedMethod =>
      'Esta DApp solicita un método no compatible.';

  @override
  String get wcSignTitle => 'Firmar transacción';

  @override
  String get wcSignDapp => 'DApp';

  @override
  String get wcSignSigner => 'Firmante';

  @override
  String get wcSignMemo => 'Nota';

  @override
  String get wcSignApprove => 'Aprobar y firmar';

  @override
  String get wcSignReject => 'Rechazar';

  @override
  String get wcSignUnknownMessage =>
      'Tipo de mensaje desconocido. Revisa los datos con atención.';

  @override
  String get wcPermissionsTitle => 'Permisos';

  @override
  String get wcPermissionsActive => 'Sesiones activas';

  @override
  String get wcPermissionsNamespaces => 'Namespace';

  @override
  String get wcPermissionsDisconnect => 'Desconectar';

  @override
  String get wcPermissionsDisconnectConfirm => '¿Desconectar esta DApp?';

  @override
  String get wcPermissionsAddSession => 'Añadir conexión';

  @override
  String get wcPermissionsEmpty => 'Ninguna DApp conectada';

  @override
  String wcPermissionsApproved(String date) {
    return 'Conectado $date';
  }

  @override
  String get walletDetailPermissions => 'Permisos';

  @override
  String get wcErrorNoWallets => 'Crea un monedero antes de conectar DApps';

  @override
  String get wcErrorChainMismatch =>
      'Red incorrecta: se esperaba cosmos:gonka-mainnet';

  @override
  String get wcErrorSignerMismatch =>
      'La dirección del firmante no coincide con el monedero conectado';

  @override
  String wcErrorGeneric(String error) {
    return 'Error de WalletConnect: $error';
  }

  @override
  String get wcBiometricReason => 'Autentícate para firmar la transacción';

  @override
  String get wcMsgSendFrom => 'De';

  @override
  String get wcMsgSendTo => 'Para';

  @override
  String get wcMsgSendAmount => 'Cantidad';

  @override
  String get wcMsgRawTypeUrl => 'Tipo';

  @override
  String get wcMsgRawValueHex => 'Valor sin procesar (hex)';
}
