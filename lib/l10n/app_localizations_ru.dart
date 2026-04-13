// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Gonka Wallet';

  @override
  String get splashLoading => 'Загрузка...';

  @override
  String get splashCheckingNodes => 'Проверка нод...';

  @override
  String get onboardingCreateTitle => 'Gonka Wallet';

  @override
  String get onboardingCreateSubtitle =>
      'Безопасный кошелёк для блокчейна Gonka';

  @override
  String get onboardingCreateNewWallet => 'Создать новый кошелёк';

  @override
  String get onboardingCreateImportWallet => 'Импортировать кошелёк';

  @override
  String get onboardingCreateTerms => 'Условия использования';

  @override
  String get onboardingCreatePrivacy => 'Политика конфиденциальности';

  @override
  String get onboardingBackupTitle => 'Резервная копия';

  @override
  String get onboardingBackupWarning =>
      'Запишите эти 24 слова по порядку. Никому их не показывайте. Любой, кто знает эту фразу, получит доступ к вашим средствам.';

  @override
  String get onboardingBackupCheckbox => 'Я записал seed-фразу';

  @override
  String get onboardingBackupContinue => 'Продолжить';

  @override
  String get onboardingBackupVerifyTitle => 'Проверка резервной копии';

  @override
  String onboardingBackupVerifyPrompt(int index) {
    return 'Какое слово под №$index?';
  }

  @override
  String onboardingBackupVerifyHint(int index) {
    return 'Введите слово №$index';
  }

  @override
  String get onboardingBackupVerifyButton => 'Проверить';

  @override
  String get onboardingBackupVerifyError =>
      'Неверное слово. Попробуйте ещё раз.';

  @override
  String get onboardingImportTitle => 'Импорт кошелька';

  @override
  String get onboardingImportWordByWord => 'По словам';

  @override
  String get onboardingImportPastePhrase => 'Вставить фразу';

  @override
  String get onboardingImportHint =>
      'Вставьте сюда вашу seed-фразу из 24 слов...';

  @override
  String get onboardingImportButton => 'Импортировать';

  @override
  String onboardingImportErrorWordCount(int count) {
    return 'Seed-фраза должна содержать ровно 24 слова (сейчас $count)';
  }

  @override
  String get onboardingImportErrorFillAll => 'Заполните все 24 слова';

  @override
  String get onboardingImportErrorInvalid => 'Неверная seed-фраза';

  @override
  String get onboardingImportPrivateKey => 'Приватный ключ';

  @override
  String get onboardingImportPrivateKeyHint =>
      'Вставьте приватный ключ (64 hex-символа)';

  @override
  String get onboardingImportPrivateKeyErrorInvalid =>
      'Неверный приватный ключ. Ожидается 64 hex-символа.';

  @override
  String get onboardingNameTitle => 'Название кошелька';

  @override
  String get onboardingNameHeading => 'Дайте кошельку название';

  @override
  String get onboardingNameSubtext => 'Это только для вашего удобства.';

  @override
  String get onboardingNameLabel => 'Название кошелька';

  @override
  String get onboardingNameValidationEmpty => 'Введите название';

  @override
  String get onboardingNameDefault => 'Мой кошелёк';

  @override
  String get onboardingNameContinue => 'Продолжить';

  @override
  String get onboardingPinTitle => 'Установить PIN';

  @override
  String get onboardingPinCreateHeading => 'Создайте PIN из 6 цифр';

  @override
  String get onboardingPinConfirmHeading => 'Повторите PIN';

  @override
  String get onboardingPinMismatch =>
      'PIN-коды не совпадают. Попробуйте ещё раз.';

  @override
  String get onboardingPinBiometricTitle => 'Включить биометрию?';

  @override
  String get onboardingPinBiometricBody =>
      'Использовать Face ID / отпечаток для разблокировки кошелька?';

  @override
  String get onboardingPinBiometricSkip => 'Пропустить';

  @override
  String get onboardingPinBiometricEnable => 'Включить';

  @override
  String get authEnterPin => 'Введите PIN';

  @override
  String get authEnterCurrentPin => 'Введите текущий PIN';

  @override
  String get authEnterNewPin => 'Введите новый PIN';

  @override
  String authWrongPin(int remaining) {
    return 'Неверный PIN. Осталось попыток: $remaining.';
  }

  @override
  String authCooldown(int seconds) {
    return 'Слишком много попыток. Подождите $seconds с.';
  }

  @override
  String get homeTitle => 'Gonka Wallet';

  @override
  String get homeEmpty => 'Кошельков пока нет';

  @override
  String get homeCreateWallet => 'Создать кошелёк';

  @override
  String get homeAddWallet => 'Добавить кошелёк';

  @override
  String get walletDetailTitle => 'Кошелёк';

  @override
  String get walletDetailNotFound => 'Кошелёк не найден';

  @override
  String get walletDetailShowSeed => 'Показать seed-фразу';

  @override
  String get walletDetailExportPk => 'Экспорт приватного ключа';

  @override
  String get walletDetailExportPkDialogTitle => 'Приватный ключ';

  @override
  String get walletDetailExportPkWarning =>
      'Любой, у кого есть этот ключ, получит доступ к вашим средствам. Никому его не передавайте.';

  @override
  String get walletDetailExportPkCopied => 'Приватный ключ скопирован';

  @override
  String get walletDetailRename => 'Переименовать кошелёк';

  @override
  String get walletDetailDelete => 'Удалить кошелёк';

  @override
  String get walletDetailSend => 'Отправить';

  @override
  String get walletDetailReceive => 'Получить';

  @override
  String get walletDetailHostTools => 'Инструменты хоста';

  @override
  String get walletDetailTxHistory => 'История транзакций';

  @override
  String get walletDetailNoTx => 'Транзакций пока нет';

  @override
  String get walletDetailTxError => 'Не удалось загрузить историю';

  @override
  String walletDetailBalanceError(String error) {
    return 'Не удалось загрузить баланс: $error';
  }

  @override
  String get walletDetailSeedDialogTitle => 'Seed-фраза';

  @override
  String get walletDetailRenameDialogTitle => 'Переименовать кошелёк';

  @override
  String get walletDetailRenameLabel => 'Название';

  @override
  String walletDetailDeleteDialogBody(String name) {
    return 'Вы действительно хотите удалить «$name»?\n\nКошелёк и его seed-фраза будут удалены с этого устройства. Убедитесь, что у вас есть резервная копия seed-фразы!';
  }

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonSave => 'Сохранить';

  @override
  String get commonDelete => 'Удалить';

  @override
  String get commonRetry => 'Повторить';

  @override
  String get commonDone => 'Готово';

  @override
  String get commonClose => 'Закрыть';

  @override
  String get commonCopy => 'Копировать';

  @override
  String get commonFrom => 'От';

  @override
  String get commonTo => 'Кому';

  @override
  String get commonAmount => 'Сумма';

  @override
  String get commonFee => 'Комиссия';

  @override
  String get commonFeeZero => '0 GNK';

  @override
  String get commonAddress => 'Адрес';

  @override
  String get commonAction => 'Действие';

  @override
  String get commonStatus => 'Статус';

  @override
  String get commonType => 'Тип';

  @override
  String get commonHash => 'Хэш';

  @override
  String get commonHeight => 'Блок';

  @override
  String get commonTime => 'Время';

  @override
  String get commonMemo => 'Комментарий';

  @override
  String get commonSuccess => 'Успешно';

  @override
  String get commonFailed => 'Ошибка';

  @override
  String get commonContract => 'Контракт';

  @override
  String get commonValidator => 'Валидатор';

  @override
  String get commonGranter => 'Делегирующий';

  @override
  String get commonGrantee => 'Получатель';

  @override
  String get commonProposal => 'Предложение';

  @override
  String get commonOption => 'Вариант';

  @override
  String get commonEpoch => 'Эпоха';

  @override
  String get balanceTotal => 'Общий баланс';

  @override
  String get balanceAvailable => 'Доступно';

  @override
  String get balanceVesting => 'Вестинг';

  @override
  String get authBiometricReason =>
      'Подтвердите личность для доступа к кошельку';

  @override
  String get errorNoActiveNode => 'Нет активной ноды';

  @override
  String get errorMnemonicNotFound => 'Seed-фраза не найдена';

  @override
  String get errorInvalidMnemonic => 'Неверная seed-фраза';

  @override
  String get errorGeneric => 'Что-то пошло не так';

  @override
  String get txTypeReceived => 'Получено';

  @override
  String get txTypeSent => 'Отправлено';

  @override
  String get txTypeContract => 'Контракт';

  @override
  String get txTypeContractDeposit => 'Депозит';

  @override
  String get txTypeContractWithdraw => 'Снятие';

  @override
  String get txTypeUnjail => 'Разблокировка';

  @override
  String get txTypeGrant => 'Выдача разрешений';

  @override
  String get txTypeCollateralDeposit => 'Внесение залога';

  @override
  String get txTypeCollateralWithdraw => 'Вывод залога';

  @override
  String get txTypeVestingReward => 'Вестинг-награда';

  @override
  String txTypeEpochReward(int epoch) {
    return 'Награда за эпоху $epoch';
  }

  @override
  String txTypeVote(String option) {
    return 'Голос: $option';
  }

  @override
  String get txTimeJustNow => 'Только что';

  @override
  String txTimeMinutesAgo(int minutes) {
    return '$minutes мин назад';
  }

  @override
  String txTimeHoursAgo(int hours) {
    return '$hours ч назад';
  }

  @override
  String txTimeDaysAgo(int days) {
    return '$days д назад';
  }

  @override
  String get sendTitle => 'Отправить';

  @override
  String get sendRecipientLabel => 'Адрес получателя';

  @override
  String get sendAmountLabel => 'Сумма';

  @override
  String get sendMaxButton => 'МАКС';

  @override
  String get sendUnitGnk => 'GNK';

  @override
  String get sendUnitNgonka => 'ngonka';

  @override
  String get sendContinue => 'Продолжить';

  @override
  String get sendErrorEnterAddress => 'Введите адрес получателя';

  @override
  String get sendErrorInvalidAddress => 'Неверный адрес Gonka';

  @override
  String get sendErrorSelfSend => 'Нельзя отправить самому себе';

  @override
  String get sendErrorEnterAmount => 'Введите сумму';

  @override
  String get sendErrorAmountPositive => 'Сумма должна быть больше нуля';

  @override
  String get sendErrorInsufficient => 'Недостаточно средств';

  @override
  String get sendErrorInvalidAmount => 'Неверная сумма';

  @override
  String get sendScanQr => 'Сканировать QR-код';

  @override
  String get confirmSendTitle => 'Подтверждение отправки';

  @override
  String get confirmSendButton => 'Подтвердить и отправить';

  @override
  String get confirmSendAuthenticating => 'Аутентификация...';

  @override
  String get sendResultSuccess => 'Транзакция отправлена!';

  @override
  String get sendResultFailed => 'Ошибка транзакции';

  @override
  String get receiveTitle => 'Получить';

  @override
  String get receiveNoWallet => 'Нет кошелька';

  @override
  String get receiveTapToCopy => 'Нажмите на адрес, чтобы скопировать';

  @override
  String get minersTitle => 'Инструменты хоста';

  @override
  String get minersPubKey => 'Мой публичный ключ';

  @override
  String get minersPubKeySubtitle => 'Посмотреть и скопировать публичный ключ';

  @override
  String get minersPubKeyCopied => 'Публичный ключ скопирован';

  @override
  String get minersCollateral => 'Залог';

  @override
  String get minersCollateralSubtitle => 'Управление залогом для майнинга';

  @override
  String get minersGrant => 'Выдача разрешений';

  @override
  String get minersGrantSubtitle => 'Выдать разрешения операционному ML-ключу';

  @override
  String get minersUnjail => 'Разблокировка';

  @override
  String get minersUnjailSubtitle => 'Разблокировать вашего валидатора';

  @override
  String get minersGovernance => 'Управление';

  @override
  String get minersGovernanceSubtitle => 'Голосование по предложениям';

  @override
  String get minersTracker => 'Трекер';

  @override
  String get minersTrackerSubtitle => 'Профессиональная панель';

  @override
  String get collateralTitle => 'Залог';

  @override
  String get collateralCurrent => 'Текущий залог';

  @override
  String get collateralDeposit => 'Внести';

  @override
  String get collateralWithdraw => 'Вывести';

  @override
  String get collateralUnbonding => 'Разблокировка';

  @override
  String collateralCompletionEpoch(int epoch) {
    return 'Эпоха завершения: $epoch';
  }

  @override
  String get collateralEmpty => 'Залога пока нет';

  @override
  String get collateralDepositTitle => 'Внесение залога';

  @override
  String get collateralWithdrawTitle => 'Вывод залога';

  @override
  String collateralCurrentInfo(String amount) {
    return 'Текущий залог: $amount GNK';
  }

  @override
  String get collateralErrorExceeds => 'Превышает текущий залог';

  @override
  String get collateralConfirmDeposit => 'Подтверждение внесения';

  @override
  String get collateralConfirmWithdraw => 'Подтверждение вывода';

  @override
  String get collateralConfirmDepositButton => 'Подтвердить и внести';

  @override
  String get collateralConfirmWithdrawButton => 'Подтвердить и вывести';

  @override
  String get collateralResultDepositSuccess => 'Залог внесён!';

  @override
  String get collateralResultWithdrawSuccess => 'Залог выведен!';

  @override
  String get collateralResultDepositFailed => 'Ошибка внесения';

  @override
  String get collateralResultWithdrawFailed => 'Ошибка вывода';

  @override
  String get grantTitle => 'Выдача разрешений';

  @override
  String get grantInfo =>
      'Выдайте вашему операционному ML-ключу разрешение выполнять инференс, обучение и другие ML-операции от вашего имени. Это не даёт доступа к вашим средствам.';

  @override
  String get grantOpKeyLabel => 'Адрес операционного ключа';

  @override
  String get grantOpKeyHint => 'gonka1...';

  @override
  String get grantErrorEnterAddress => 'Введите адрес операционного ключа';

  @override
  String get grantErrorInvalidAddress => 'Неверный адрес Gonka';

  @override
  String get grantErrorSelf => 'Нельзя выдать разрешения самому себе';

  @override
  String get grantContinue => 'Продолжить';

  @override
  String get grantScanQr => 'Сканировать QR-код';

  @override
  String get grantConfirmTitle => 'Подтверждение выдачи';

  @override
  String get grantConfirmAction => 'Выдать ML-разрешения';

  @override
  String get grantConfirmExpiration => 'Срок действия';

  @override
  String get grantConfirmExpirationValue => '2 года';

  @override
  String get grantConfirmPermissions => 'Разрешения';

  @override
  String get grantConfirmPermissionsValue => '27 ML-операций';

  @override
  String get grantConfirmButton => 'Подтвердить и выдать';

  @override
  String get grantResultSuccess => 'Разрешения выданы!';

  @override
  String get grantResultFailed => 'Ошибка выдачи';

  @override
  String get unjailTitle => 'Разблокировка валидатора';

  @override
  String get unjailWarningJailed =>
      'Ваш валидатор заблокирован. Отправьте транзакцию разблокировки, чтобы возобновить работу.';

  @override
  String get unjailInfoNotJailed =>
      'Ваш валидатор не заблокирован. Действия не требуются.';

  @override
  String get unjailInfoNotFound =>
      'Валидатор не найден в сети. Убедитесь, что валидатор был создан.';

  @override
  String get unjailAction => 'Разблокировать валидатор';

  @override
  String get unjailValidatorAddress => 'Адрес валидатора';

  @override
  String get unjailConfirmButton => 'Подтвердить и разблокировать';

  @override
  String get unjailResultSuccess => 'Валидатор разблокирован';

  @override
  String get unjailResultFailed => 'Ошибка разблокировки';

  @override
  String get governanceTitle => 'Управление';

  @override
  String get governanceTabAll => 'Все';

  @override
  String get governanceTabActive => 'Активные';

  @override
  String get governanceTabClosed => 'Закрытые';

  @override
  String governanceErrorLoad(String error) {
    return 'Не удалось загрузить предложения: $error';
  }

  @override
  String get governanceEmptyAll => 'Предложений не найдено';

  @override
  String get governanceEmptyActive => 'Нет активных предложений';

  @override
  String get governanceEmptyClosed => 'Нет закрытых предложений';

  @override
  String get governanceStatusActive => 'Активно';

  @override
  String get governanceStatusPassed => 'Принято';

  @override
  String get governanceStatusRejected => 'Отклонено';

  @override
  String get governanceEndingSoon => 'Скоро завершится';

  @override
  String governanceEndsInDays(int days, int hours) {
    return 'Завершается через $days д $hours ч';
  }

  @override
  String governanceEndsInHours(int hours, int minutes) {
    return 'Завершается через $hours ч $minutes мин';
  }

  @override
  String governanceEndsInMinutes(int minutes) {
    return 'Завершается через $minutes мин';
  }

  @override
  String governanceEndedDaysAgo(int days) {
    return 'Завершено $days д назад';
  }

  @override
  String governanceEndedOn(String date) {
    return 'Завершено $date';
  }

  @override
  String proposalDetailTitle(int id) {
    return 'Предложение #$id';
  }

  @override
  String proposalDetailErrorLoad(String error) {
    return 'Не удалось загрузить предложение: $error';
  }

  @override
  String get proposalDetailNotFound => 'Предложение не найдено';

  @override
  String get proposalDetailSummary => 'Описание';

  @override
  String get proposalDetailProposer => 'Автор';

  @override
  String get proposalDetailVotingPeriod => 'Период голосования';

  @override
  String get proposalDetailTally => 'Результаты голосования';

  @override
  String get proposalVoteYes => 'За';

  @override
  String get proposalVoteAbstain => 'Воздержаться';

  @override
  String get proposalVoteNo => 'Против';

  @override
  String get proposalVoteNoWithVeto => 'Против с вето';

  @override
  String get proposalCastYourVote => 'Ваш голос';

  @override
  String get proposalSubmitVote => 'Отправить голос';

  @override
  String get proposalVotingEnded =>
      'Голосование по этому предложению завершено.';

  @override
  String get proposalVoteSubmitted => 'Голос отправлен';

  @override
  String get proposalVoteFailed => 'Ошибка голосования';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsNodeSettings => 'Настройки ноды';

  @override
  String get settingsSecurity => 'Безопасность';

  @override
  String get settingsSecuritySubtitle => 'PIN и биометрия';

  @override
  String get settingsTerms => 'Условия использования';

  @override
  String get settingsPrivacy => 'Политика конфиденциальности';

  @override
  String get securityTitle => 'Безопасность';

  @override
  String get securityChangePin => 'Изменить PIN';

  @override
  String get securityBiometric => 'Биометрическая аутентификация';

  @override
  String get securityWipe => 'Удалять кошельки после неверного PIN';

  @override
  String securityWipeSubtitle(int max) {
    return 'Удалить все кошельки после $max неверных попыток';
  }

  @override
  String get securityPinChanged => 'PIN изменён';

  @override
  String get securityPinNotChanged => 'PIN не изменён';

  @override
  String get nodeSettingsTitle => 'Настройки ноды';

  @override
  String get nodeSettingsRefresh => 'Обновить ноды';

  @override
  String get nodeStatusChecking => 'Проверка...';

  @override
  String get nodeStatusSyncing => 'Синхронизация...';

  @override
  String get nodeStatusNotSynced => 'Не синхронизирована';

  @override
  String get nodeStatusOffline => 'Не в сети';

  @override
  String nodeStatusLatency(int ms) {
    return '$ms мс';
  }

  @override
  String get nodeActive => 'Активна';

  @override
  String get nodeAdd => 'Добавить ноду';

  @override
  String get nodeUrlLabel => 'URL ноды';

  @override
  String get nodeUrlHint => 'https://node.example.com:8000';

  @override
  String get nodeLabelLabel => 'Метка';

  @override
  String get nodeProxyMode => 'Прокси-режим';

  @override
  String get nodeProxyModeSubtitle => '/chain-api/ + /chain-rpc/';

  @override
  String get nodeDefaultLabel => 'Своя нода';

  @override
  String get nodeAddButton => 'Добавить';

  @override
  String get securityWarningTitle => 'Предупреждение безопасности';

  @override
  String get securityWarningBody =>
      'Это устройство может быть рутовано или взломано. Использование кошелька на скомпрометированном устройстве ставит ваши средства под угрозу.';

  @override
  String get securityWarningAck => 'Я понимаю риски';

  @override
  String get widgetHashCopied => 'Хэш скопирован';

  @override
  String get widgetAddressCopied => 'Адрес скопирован';

  @override
  String get widgetTxHash => 'Хэш транзакции';
}
