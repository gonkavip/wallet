import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Gonka Wallet'**
  String get appTitle;

  /// No description provided for @splashLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get splashLoading;

  /// No description provided for @splashCheckingNodes.
  ///
  /// In en, this message translates to:
  /// **'Checking nodes...'**
  String get splashCheckingNodes;

  /// No description provided for @onboardingCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Gonka Wallet'**
  String get onboardingCreateTitle;

  /// No description provided for @onboardingCreateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Secure wallet for the Gonka blockchain'**
  String get onboardingCreateSubtitle;

  /// No description provided for @onboardingCreateNewWallet.
  ///
  /// In en, this message translates to:
  /// **'Create New Wallet'**
  String get onboardingCreateNewWallet;

  /// No description provided for @onboardingCreateImportWallet.
  ///
  /// In en, this message translates to:
  /// **'Import Existing Wallet'**
  String get onboardingCreateImportWallet;

  /// No description provided for @onboardingCreateTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get onboardingCreateTerms;

  /// No description provided for @onboardingCreatePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get onboardingCreatePrivacy;

  /// No description provided for @onboardingBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Back Up Seed Phrase'**
  String get onboardingBackupTitle;

  /// No description provided for @onboardingBackupWarning.
  ///
  /// In en, this message translates to:
  /// **'Write down these 24 words in order. Never share them. Anyone with this phrase can access your funds.'**
  String get onboardingBackupWarning;

  /// No description provided for @onboardingBackupCheckbox.
  ///
  /// In en, this message translates to:
  /// **'I have written down the seed phrase'**
  String get onboardingBackupCheckbox;

  /// No description provided for @onboardingBackupContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingBackupContinue;

  /// No description provided for @onboardingBackupVerifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Backup'**
  String get onboardingBackupVerifyTitle;

  /// No description provided for @onboardingBackupVerifyPrompt.
  ///
  /// In en, this message translates to:
  /// **'What is word #{index}?'**
  String onboardingBackupVerifyPrompt(int index);

  /// No description provided for @onboardingBackupVerifyHint.
  ///
  /// In en, this message translates to:
  /// **'Enter word #{index}'**
  String onboardingBackupVerifyHint(int index);

  /// No description provided for @onboardingBackupVerifyButton.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get onboardingBackupVerifyButton;

  /// No description provided for @onboardingBackupVerifyError.
  ///
  /// In en, this message translates to:
  /// **'Incorrect word. Please try again.'**
  String get onboardingBackupVerifyError;

  /// No description provided for @onboardingImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Wallet'**
  String get onboardingImportTitle;

  /// No description provided for @onboardingImportWordByWord.
  ///
  /// In en, this message translates to:
  /// **'Word by word'**
  String get onboardingImportWordByWord;

  /// No description provided for @onboardingImportPastePhrase.
  ///
  /// In en, this message translates to:
  /// **'Paste phrase'**
  String get onboardingImportPastePhrase;

  /// No description provided for @onboardingImportHint.
  ///
  /// In en, this message translates to:
  /// **'Paste your 24-word seed phrase here...'**
  String get onboardingImportHint;

  /// No description provided for @onboardingImportButton.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get onboardingImportButton;

  /// No description provided for @onboardingImportErrorWordCount.
  ///
  /// In en, this message translates to:
  /// **'Seed phrase must be exactly 24 words (got {count})'**
  String onboardingImportErrorWordCount(int count);

  /// No description provided for @onboardingImportErrorFillAll.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all 24 words'**
  String get onboardingImportErrorFillAll;

  /// No description provided for @onboardingImportErrorInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid seed phrase'**
  String get onboardingImportErrorInvalid;

  /// No description provided for @onboardingImportPrivateKey.
  ///
  /// In en, this message translates to:
  /// **'Private key'**
  String get onboardingImportPrivateKey;

  /// No description provided for @onboardingImportPrivateKeyHint.
  ///
  /// In en, this message translates to:
  /// **'Paste your private key (64 hex characters)'**
  String get onboardingImportPrivateKeyHint;

  /// No description provided for @onboardingImportPrivateKeyErrorInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid private key. Expected 64 hex characters.'**
  String get onboardingImportPrivateKeyErrorInvalid;

  /// No description provided for @onboardingNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Name Your Wallet'**
  String get onboardingNameTitle;

  /// No description provided for @onboardingNameHeading.
  ///
  /// In en, this message translates to:
  /// **'Give your wallet a name'**
  String get onboardingNameHeading;

  /// No description provided for @onboardingNameSubtext.
  ///
  /// In en, this message translates to:
  /// **'This is just for your reference.'**
  String get onboardingNameSubtext;

  /// No description provided for @onboardingNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Wallet Name'**
  String get onboardingNameLabel;

  /// No description provided for @onboardingNameValidationEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get onboardingNameValidationEmpty;

  /// No description provided for @onboardingNameDefault.
  ///
  /// In en, this message translates to:
  /// **'My Wallet'**
  String get onboardingNameDefault;

  /// No description provided for @onboardingNameContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingNameContinue;

  /// No description provided for @onboardingPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Set PIN'**
  String get onboardingPinTitle;

  /// No description provided for @onboardingPinCreateHeading.
  ///
  /// In en, this message translates to:
  /// **'Create a 6-digit PIN'**
  String get onboardingPinCreateHeading;

  /// No description provided for @onboardingPinConfirmHeading.
  ///
  /// In en, this message translates to:
  /// **'Confirm your PIN'**
  String get onboardingPinConfirmHeading;

  /// No description provided for @onboardingPinMismatch.
  ///
  /// In en, this message translates to:
  /// **'PINs do not match. Try again.'**
  String get onboardingPinMismatch;

  /// No description provided for @onboardingPinBiometricTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable Biometrics?'**
  String get onboardingPinBiometricTitle;

  /// No description provided for @onboardingPinBiometricBody.
  ///
  /// In en, this message translates to:
  /// **'Use Face ID / fingerprint to unlock your wallet?'**
  String get onboardingPinBiometricBody;

  /// No description provided for @onboardingPinBiometricSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingPinBiometricSkip;

  /// No description provided for @onboardingPinBiometricEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get onboardingPinBiometricEnable;

  /// No description provided for @authEnterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get authEnterPin;

  /// No description provided for @authEnterCurrentPin.
  ///
  /// In en, this message translates to:
  /// **'Enter Current PIN'**
  String get authEnterCurrentPin;

  /// No description provided for @authEnterNewPin.
  ///
  /// In en, this message translates to:
  /// **'Enter New PIN'**
  String get authEnterNewPin;

  /// No description provided for @authWrongPin.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN. {remaining} attempts remaining.'**
  String authWrongPin(int remaining);

  /// No description provided for @authCooldown.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Wait {seconds}s.'**
  String authCooldown(int seconds);

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Gonka Wallet'**
  String get homeTitle;

  /// No description provided for @homeEmpty.
  ///
  /// In en, this message translates to:
  /// **'No wallets yet'**
  String get homeEmpty;

  /// No description provided for @homeCreateWallet.
  ///
  /// In en, this message translates to:
  /// **'Create Wallet'**
  String get homeCreateWallet;

  /// No description provided for @homeAddWallet.
  ///
  /// In en, this message translates to:
  /// **'Add Wallet'**
  String get homeAddWallet;

  /// No description provided for @walletDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get walletDetailTitle;

  /// No description provided for @walletDetailNotFound.
  ///
  /// In en, this message translates to:
  /// **'Wallet not found'**
  String get walletDetailNotFound;

  /// No description provided for @walletDetailShowSeed.
  ///
  /// In en, this message translates to:
  /// **'Show Seed Phrase'**
  String get walletDetailShowSeed;

  /// No description provided for @walletDetailExportPk.
  ///
  /// In en, this message translates to:
  /// **'Export Private Key'**
  String get walletDetailExportPk;

  /// No description provided for @walletDetailExportPkDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Private Key'**
  String get walletDetailExportPkDialogTitle;

  /// No description provided for @walletDetailExportPkWarning.
  ///
  /// In en, this message translates to:
  /// **'Anyone with this key can access your funds. Never share it.'**
  String get walletDetailExportPkWarning;

  /// No description provided for @walletDetailExportPkCopied.
  ///
  /// In en, this message translates to:
  /// **'Private key copied'**
  String get walletDetailExportPkCopied;

  /// No description provided for @walletDetailRename.
  ///
  /// In en, this message translates to:
  /// **'Rename Wallet'**
  String get walletDetailRename;

  /// No description provided for @walletDetailDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Wallet'**
  String get walletDetailDelete;

  /// No description provided for @walletDetailSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get walletDetailSend;

  /// No description provided for @walletDetailReceive.
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get walletDetailReceive;

  /// No description provided for @walletDetailHostTools.
  ///
  /// In en, this message translates to:
  /// **'Host Tools'**
  String get walletDetailHostTools;

  /// No description provided for @walletDetailTxHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get walletDetailTxHistory;

  /// No description provided for @walletDetailNoTx.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get walletDetailNoTx;

  /// No description provided for @walletDetailTxError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load history'**
  String get walletDetailTxError;

  /// No description provided for @walletDetailBalanceError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load balance: {error}'**
  String walletDetailBalanceError(String error);

  /// No description provided for @walletDetailSeedDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Seed Phrase'**
  String get walletDetailSeedDialogTitle;

  /// No description provided for @walletDetailRenameDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename Wallet'**
  String get walletDetailRenameDialogTitle;

  /// No description provided for @walletDetailRenameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get walletDetailRenameLabel;

  /// No description provided for @walletDetailDeleteDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?\n\nThis will remove the wallet and its seed phrase from this device. Make sure you have backed up your seed phrase!'**
  String walletDetailDeleteDialogBody(String name);

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get commonCopy;

  /// No description provided for @commonFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get commonFrom;

  /// No description provided for @commonTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get commonTo;

  /// No description provided for @commonAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get commonAmount;

  /// No description provided for @commonFee.
  ///
  /// In en, this message translates to:
  /// **'Fee'**
  String get commonFee;

  /// No description provided for @commonFeeZero.
  ///
  /// In en, this message translates to:
  /// **'0 GNK'**
  String get commonFeeZero;

  /// No description provided for @commonAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get commonAddress;

  /// No description provided for @commonAction.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get commonAction;

  /// No description provided for @commonStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get commonStatus;

  /// No description provided for @commonType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get commonType;

  /// No description provided for @commonHash.
  ///
  /// In en, this message translates to:
  /// **'Hash'**
  String get commonHash;

  /// No description provided for @commonHeight.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get commonHeight;

  /// No description provided for @commonTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get commonTime;

  /// No description provided for @commonMemo.
  ///
  /// In en, this message translates to:
  /// **'Memo'**
  String get commonMemo;

  /// No description provided for @commonSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get commonSuccess;

  /// No description provided for @commonFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get commonFailed;

  /// No description provided for @commonContract.
  ///
  /// In en, this message translates to:
  /// **'Contract'**
  String get commonContract;

  /// No description provided for @commonValidator.
  ///
  /// In en, this message translates to:
  /// **'Validator'**
  String get commonValidator;

  /// No description provided for @commonGranter.
  ///
  /// In en, this message translates to:
  /// **'Granter'**
  String get commonGranter;

  /// No description provided for @commonGrantee.
  ///
  /// In en, this message translates to:
  /// **'Grantee'**
  String get commonGrantee;

  /// No description provided for @commonProposal.
  ///
  /// In en, this message translates to:
  /// **'Proposal'**
  String get commonProposal;

  /// No description provided for @commonOption.
  ///
  /// In en, this message translates to:
  /// **'Option'**
  String get commonOption;

  /// No description provided for @commonEpoch.
  ///
  /// In en, this message translates to:
  /// **'Epoch'**
  String get commonEpoch;

  /// No description provided for @balanceTotal.
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get balanceTotal;

  /// No description provided for @balanceAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get balanceAvailable;

  /// No description provided for @balanceVesting.
  ///
  /// In en, this message translates to:
  /// **'Vesting'**
  String get balanceVesting;

  /// No description provided for @authBiometricReason.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to access your wallet'**
  String get authBiometricReason;

  /// No description provided for @errorNoActiveNode.
  ///
  /// In en, this message translates to:
  /// **'No active node'**
  String get errorNoActiveNode;

  /// No description provided for @errorMnemonicNotFound.
  ///
  /// In en, this message translates to:
  /// **'Mnemonic not found'**
  String get errorMnemonicNotFound;

  /// No description provided for @errorInvalidMnemonic.
  ///
  /// In en, this message translates to:
  /// **'Invalid mnemonic'**
  String get errorInvalidMnemonic;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorGeneric;

  /// No description provided for @txTypeReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get txTypeReceived;

  /// No description provided for @txTypeSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get txTypeSent;

  /// No description provided for @txTypeContract.
  ///
  /// In en, this message translates to:
  /// **'Contract'**
  String get txTypeContract;

  /// No description provided for @txTypeContractDeposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get txTypeContractDeposit;

  /// No description provided for @txTypeContractWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get txTypeContractWithdraw;

  /// No description provided for @txTypeUnjail.
  ///
  /// In en, this message translates to:
  /// **'Unjail'**
  String get txTypeUnjail;

  /// No description provided for @txTypeGrant.
  ///
  /// In en, this message translates to:
  /// **'Grant Permissions'**
  String get txTypeGrant;

  /// No description provided for @txTypeCollateralDeposit.
  ///
  /// In en, this message translates to:
  /// **'Collateral Deposit'**
  String get txTypeCollateralDeposit;

  /// No description provided for @txTypeCollateralWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Collateral Withdraw'**
  String get txTypeCollateralWithdraw;

  /// No description provided for @txTypeVestingReward.
  ///
  /// In en, this message translates to:
  /// **'Vesting Reward'**
  String get txTypeVestingReward;

  /// No description provided for @txTypeEpochReward.
  ///
  /// In en, this message translates to:
  /// **'Epoch {epoch} Reward'**
  String txTypeEpochReward(int epoch);

  /// No description provided for @txTypeVote.
  ///
  /// In en, this message translates to:
  /// **'Vote: {option}'**
  String txTypeVote(String option);

  /// No description provided for @txTimeJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get txTimeJustNow;

  /// No description provided for @txTimeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String txTimeMinutesAgo(int minutes);

  /// No description provided for @txTimeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String txTimeHoursAgo(int hours);

  /// No description provided for @txTimeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String txTimeDaysAgo(int days);

  /// No description provided for @sendTitle.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendTitle;

  /// No description provided for @sendRecipientLabel.
  ///
  /// In en, this message translates to:
  /// **'Recipient Address'**
  String get sendRecipientLabel;

  /// No description provided for @sendAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get sendAmountLabel;

  /// No description provided for @sendMaxButton.
  ///
  /// In en, this message translates to:
  /// **'MAX'**
  String get sendMaxButton;

  /// No description provided for @sendUnitGnk.
  ///
  /// In en, this message translates to:
  /// **'GNK'**
  String get sendUnitGnk;

  /// No description provided for @sendUnitNgonka.
  ///
  /// In en, this message translates to:
  /// **'ngonka'**
  String get sendUnitNgonka;

  /// No description provided for @sendContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get sendContinue;

  /// No description provided for @sendErrorEnterAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter recipient address'**
  String get sendErrorEnterAddress;

  /// No description provided for @sendErrorInvalidAddress.
  ///
  /// In en, this message translates to:
  /// **'Invalid Gonka address'**
  String get sendErrorInvalidAddress;

  /// No description provided for @sendErrorSelfSend.
  ///
  /// In en, this message translates to:
  /// **'Cannot send to yourself'**
  String get sendErrorSelfSend;

  /// No description provided for @sendErrorEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get sendErrorEnterAmount;

  /// No description provided for @sendErrorAmountPositive.
  ///
  /// In en, this message translates to:
  /// **'Amount must be positive'**
  String get sendErrorAmountPositive;

  /// No description provided for @sendErrorInsufficient.
  ///
  /// In en, this message translates to:
  /// **'Insufficient balance'**
  String get sendErrorInsufficient;

  /// No description provided for @sendErrorInvalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Invalid amount'**
  String get sendErrorInvalidAmount;

  /// No description provided for @sendScanQr.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get sendScanQr;

  /// No description provided for @confirmSendTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Send'**
  String get confirmSendTitle;

  /// No description provided for @confirmSendButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Send'**
  String get confirmSendButton;

  /// No description provided for @confirmSendAuthenticating.
  ///
  /// In en, this message translates to:
  /// **'Authenticating...'**
  String get confirmSendAuthenticating;

  /// No description provided for @sendResultSuccess.
  ///
  /// In en, this message translates to:
  /// **'Transaction Sent!'**
  String get sendResultSuccess;

  /// No description provided for @sendResultFailed.
  ///
  /// In en, this message translates to:
  /// **'Transaction Failed'**
  String get sendResultFailed;

  /// No description provided for @receiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get receiveTitle;

  /// No description provided for @receiveNoWallet.
  ///
  /// In en, this message translates to:
  /// **'No wallet'**
  String get receiveNoWallet;

  /// No description provided for @receiveTapToCopy.
  ///
  /// In en, this message translates to:
  /// **'Tap address to copy'**
  String get receiveTapToCopy;

  /// No description provided for @minersTitle.
  ///
  /// In en, this message translates to:
  /// **'Host Tools'**
  String get minersTitle;

  /// No description provided for @minersPubKey.
  ///
  /// In en, this message translates to:
  /// **'My PubKey'**
  String get minersPubKey;

  /// No description provided for @minersPubKeySubtitle.
  ///
  /// In en, this message translates to:
  /// **'View and copy your public key'**
  String get minersPubKeySubtitle;

  /// No description provided for @minersPubKeyCopied.
  ///
  /// In en, this message translates to:
  /// **'Public key copied'**
  String get minersPubKeyCopied;

  /// No description provided for @minersCollateral.
  ///
  /// In en, this message translates to:
  /// **'Collateral'**
  String get minersCollateral;

  /// No description provided for @minersCollateralSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your mining collateral'**
  String get minersCollateralSubtitle;

  /// No description provided for @minersGrant.
  ///
  /// In en, this message translates to:
  /// **'Grant Permissions'**
  String get minersGrant;

  /// No description provided for @minersGrantSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Grant permissions to ML operational key'**
  String get minersGrantSubtitle;

  /// No description provided for @minersUnjail.
  ///
  /// In en, this message translates to:
  /// **'Unjail'**
  String get minersUnjail;

  /// No description provided for @minersUnjailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unjail your validator'**
  String get minersUnjailSubtitle;

  /// No description provided for @minersGovernance.
  ///
  /// In en, this message translates to:
  /// **'Governance'**
  String get minersGovernance;

  /// No description provided for @minersGovernanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Vote on proposals'**
  String get minersGovernanceSubtitle;

  /// No description provided for @minersTracker.
  ///
  /// In en, this message translates to:
  /// **'Tracker'**
  String get minersTracker;

  /// No description provided for @minersTrackerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Professional Dashboard'**
  String get minersTrackerSubtitle;

  /// No description provided for @collateralTitle.
  ///
  /// In en, this message translates to:
  /// **'Collateral'**
  String get collateralTitle;

  /// No description provided for @collateralCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current Collateral'**
  String get collateralCurrent;

  /// No description provided for @collateralDeposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get collateralDeposit;

  /// No description provided for @collateralWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get collateralWithdraw;

  /// No description provided for @collateralUnbonding.
  ///
  /// In en, this message translates to:
  /// **'Unbonding'**
  String get collateralUnbonding;

  /// No description provided for @collateralCompletionEpoch.
  ///
  /// In en, this message translates to:
  /// **'Completion epoch: {epoch}'**
  String collateralCompletionEpoch(int epoch);

  /// No description provided for @collateralEmpty.
  ///
  /// In en, this message translates to:
  /// **'No collateral yet'**
  String get collateralEmpty;

  /// No description provided for @collateralDepositTitle.
  ///
  /// In en, this message translates to:
  /// **'Deposit Collateral'**
  String get collateralDepositTitle;

  /// No description provided for @collateralWithdrawTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Collateral'**
  String get collateralWithdrawTitle;

  /// No description provided for @collateralCurrentInfo.
  ///
  /// In en, this message translates to:
  /// **'Current collateral: {amount} GNK'**
  String collateralCurrentInfo(String amount);

  /// No description provided for @collateralErrorExceeds.
  ///
  /// In en, this message translates to:
  /// **'Exceeds current collateral'**
  String get collateralErrorExceeds;

  /// No description provided for @collateralConfirmDeposit.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deposit'**
  String get collateralConfirmDeposit;

  /// No description provided for @collateralConfirmWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Confirm Withdraw'**
  String get collateralConfirmWithdraw;

  /// No description provided for @collateralConfirmDepositButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Deposit'**
  String get collateralConfirmDepositButton;

  /// No description provided for @collateralConfirmWithdrawButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Withdraw'**
  String get collateralConfirmWithdrawButton;

  /// No description provided for @collateralResultDepositSuccess.
  ///
  /// In en, this message translates to:
  /// **'Deposit Successful!'**
  String get collateralResultDepositSuccess;

  /// No description provided for @collateralResultWithdrawSuccess.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal Successful!'**
  String get collateralResultWithdrawSuccess;

  /// No description provided for @collateralResultDepositFailed.
  ///
  /// In en, this message translates to:
  /// **'Deposit Failed'**
  String get collateralResultDepositFailed;

  /// No description provided for @collateralResultWithdrawFailed.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal Failed'**
  String get collateralResultWithdrawFailed;

  /// No description provided for @grantTitle.
  ///
  /// In en, this message translates to:
  /// **'Grant Permissions'**
  String get grantTitle;

  /// No description provided for @grantInfo.
  ///
  /// In en, this message translates to:
  /// **'Grant your ML operational key permission to perform inference, training, and other ML operations on your behalf. This does not grant access to your funds.'**
  String get grantInfo;

  /// No description provided for @grantOpKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'Operational Key Address'**
  String get grantOpKeyLabel;

  /// No description provided for @grantOpKeyHint.
  ///
  /// In en, this message translates to:
  /// **'gonka1...'**
  String get grantOpKeyHint;

  /// No description provided for @grantErrorEnterAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter operational key address'**
  String get grantErrorEnterAddress;

  /// No description provided for @grantErrorInvalidAddress.
  ///
  /// In en, this message translates to:
  /// **'Invalid Gonka address'**
  String get grantErrorInvalidAddress;

  /// No description provided for @grantErrorSelf.
  ///
  /// In en, this message translates to:
  /// **'Cannot grant permissions to yourself'**
  String get grantErrorSelf;

  /// No description provided for @grantContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get grantContinue;

  /// No description provided for @grantScanQr.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get grantScanQr;

  /// No description provided for @grantConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Grant'**
  String get grantConfirmTitle;

  /// No description provided for @grantConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Grant ML Permissions'**
  String get grantConfirmAction;

  /// No description provided for @grantConfirmExpiration.
  ///
  /// In en, this message translates to:
  /// **'Expiration'**
  String get grantConfirmExpiration;

  /// No description provided for @grantConfirmExpirationValue.
  ///
  /// In en, this message translates to:
  /// **'2 years'**
  String get grantConfirmExpirationValue;

  /// No description provided for @grantConfirmPermissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get grantConfirmPermissions;

  /// No description provided for @grantConfirmPermissionsValue.
  ///
  /// In en, this message translates to:
  /// **'27 ML operations'**
  String get grantConfirmPermissionsValue;

  /// No description provided for @grantConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Grant'**
  String get grantConfirmButton;

  /// No description provided for @grantResultSuccess.
  ///
  /// In en, this message translates to:
  /// **'Permissions Granted!'**
  String get grantResultSuccess;

  /// No description provided for @grantResultFailed.
  ///
  /// In en, this message translates to:
  /// **'Grant Failed'**
  String get grantResultFailed;

  /// No description provided for @unjailTitle.
  ///
  /// In en, this message translates to:
  /// **'Unjail Validator'**
  String get unjailTitle;

  /// No description provided for @unjailWarningJailed.
  ///
  /// In en, this message translates to:
  /// **'Your validator is jailed. Send an unjail transaction to resume operations.'**
  String get unjailWarningJailed;

  /// No description provided for @unjailInfoNotJailed.
  ///
  /// In en, this message translates to:
  /// **'Your validator is not jailed. No action needed.'**
  String get unjailInfoNotJailed;

  /// No description provided for @unjailInfoNotFound.
  ///
  /// In en, this message translates to:
  /// **'Validator not found on chain. Make sure your validator has been created.'**
  String get unjailInfoNotFound;

  /// No description provided for @unjailAction.
  ///
  /// In en, this message translates to:
  /// **'Unjail Validator'**
  String get unjailAction;

  /// No description provided for @unjailValidatorAddress.
  ///
  /// In en, this message translates to:
  /// **'Validator Address'**
  String get unjailValidatorAddress;

  /// No description provided for @unjailConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Unjail'**
  String get unjailConfirmButton;

  /// No description provided for @unjailResultSuccess.
  ///
  /// In en, this message translates to:
  /// **'Unjail Successful'**
  String get unjailResultSuccess;

  /// No description provided for @unjailResultFailed.
  ///
  /// In en, this message translates to:
  /// **'Unjail Failed'**
  String get unjailResultFailed;

  /// No description provided for @governanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Governance'**
  String get governanceTitle;

  /// No description provided for @governanceTabAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get governanceTabAll;

  /// No description provided for @governanceTabActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get governanceTabActive;

  /// No description provided for @governanceTabClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get governanceTabClosed;

  /// No description provided for @governanceErrorLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load proposals: {error}'**
  String governanceErrorLoad(String error);

  /// No description provided for @governanceEmptyAll.
  ///
  /// In en, this message translates to:
  /// **'No proposals found'**
  String get governanceEmptyAll;

  /// No description provided for @governanceEmptyActive.
  ///
  /// In en, this message translates to:
  /// **'No active proposals'**
  String get governanceEmptyActive;

  /// No description provided for @governanceEmptyClosed.
  ///
  /// In en, this message translates to:
  /// **'No closed proposals'**
  String get governanceEmptyClosed;

  /// No description provided for @governanceStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get governanceStatusActive;

  /// No description provided for @governanceStatusPassed.
  ///
  /// In en, this message translates to:
  /// **'Passed'**
  String get governanceStatusPassed;

  /// No description provided for @governanceStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get governanceStatusRejected;

  /// No description provided for @governanceEndingSoon.
  ///
  /// In en, this message translates to:
  /// **'Ending soon'**
  String get governanceEndingSoon;

  /// No description provided for @governanceEndsInDays.
  ///
  /// In en, this message translates to:
  /// **'Ends in {days}d {hours}h'**
  String governanceEndsInDays(int days, int hours);

  /// No description provided for @governanceEndsInHours.
  ///
  /// In en, this message translates to:
  /// **'Ends in {hours}h {minutes}m'**
  String governanceEndsInHours(int hours, int minutes);

  /// No description provided for @governanceEndsInMinutes.
  ///
  /// In en, this message translates to:
  /// **'Ends in {minutes}m'**
  String governanceEndsInMinutes(int minutes);

  /// No description provided for @governanceEndedDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'Ended {days}d ago'**
  String governanceEndedDaysAgo(int days);

  /// No description provided for @governanceEndedOn.
  ///
  /// In en, this message translates to:
  /// **'Ended {date}'**
  String governanceEndedOn(String date);

  /// No description provided for @proposalDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Proposal #{id}'**
  String proposalDetailTitle(int id);

  /// No description provided for @proposalDetailErrorLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load proposal: {error}'**
  String proposalDetailErrorLoad(String error);

  /// No description provided for @proposalDetailNotFound.
  ///
  /// In en, this message translates to:
  /// **'Proposal not found'**
  String get proposalDetailNotFound;

  /// No description provided for @proposalDetailSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get proposalDetailSummary;

  /// No description provided for @proposalDetailProposer.
  ///
  /// In en, this message translates to:
  /// **'Proposer'**
  String get proposalDetailProposer;

  /// No description provided for @proposalDetailVotingPeriod.
  ///
  /// In en, this message translates to:
  /// **'Voting Period'**
  String get proposalDetailVotingPeriod;

  /// No description provided for @proposalDetailTally.
  ///
  /// In en, this message translates to:
  /// **'Tally Results'**
  String get proposalDetailTally;

  /// No description provided for @proposalVoteYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get proposalVoteYes;

  /// No description provided for @proposalVoteAbstain.
  ///
  /// In en, this message translates to:
  /// **'Abstain'**
  String get proposalVoteAbstain;

  /// No description provided for @proposalVoteNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get proposalVoteNo;

  /// No description provided for @proposalVoteNoWithVeto.
  ///
  /// In en, this message translates to:
  /// **'No with Veto'**
  String get proposalVoteNoWithVeto;

  /// No description provided for @proposalCastYourVote.
  ///
  /// In en, this message translates to:
  /// **'Cast Your Vote'**
  String get proposalCastYourVote;

  /// No description provided for @proposalSubmitVote.
  ///
  /// In en, this message translates to:
  /// **'Submit Vote'**
  String get proposalSubmitVote;

  /// No description provided for @proposalVotingEnded.
  ///
  /// In en, this message translates to:
  /// **'Voting has ended for this proposal.'**
  String get proposalVotingEnded;

  /// No description provided for @proposalVoteSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Vote Submitted'**
  String get proposalVoteSubmitted;

  /// No description provided for @proposalVoteFailed.
  ///
  /// In en, this message translates to:
  /// **'Vote Failed'**
  String get proposalVoteFailed;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsNodeSettings.
  ///
  /// In en, this message translates to:
  /// **'Node Settings'**
  String get settingsNodeSettings;

  /// No description provided for @settingsSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settingsSecurity;

  /// No description provided for @settingsSecuritySubtitle.
  ///
  /// In en, this message translates to:
  /// **'PIN & biometrics'**
  String get settingsSecuritySubtitle;

  /// No description provided for @settingsTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get settingsTerms;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacy;

  /// No description provided for @securityTitle.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get securityTitle;

  /// No description provided for @securityChangePin.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get securityChangePin;

  /// No description provided for @securityBiometric.
  ///
  /// In en, this message translates to:
  /// **'Biometric Authentication'**
  String get securityBiometric;

  /// No description provided for @securityWipe.
  ///
  /// In en, this message translates to:
  /// **'Erase wallets after failed PIN'**
  String get securityWipe;

  /// No description provided for @securityWipeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all wallets after {max} wrong attempts'**
  String securityWipeSubtitle(int max);

  /// No description provided for @securityPinChanged.
  ///
  /// In en, this message translates to:
  /// **'PIN changed'**
  String get securityPinChanged;

  /// No description provided for @securityPinNotChanged.
  ///
  /// In en, this message translates to:
  /// **'PIN not changed'**
  String get securityPinNotChanged;

  /// No description provided for @nodeSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Node Settings'**
  String get nodeSettingsTitle;

  /// No description provided for @nodeSettingsRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh Nodes'**
  String get nodeSettingsRefresh;

  /// No description provided for @nodeStatusChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get nodeStatusChecking;

  /// No description provided for @nodeStatusSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get nodeStatusSyncing;

  /// No description provided for @nodeStatusNotSynced.
  ///
  /// In en, this message translates to:
  /// **'Not synced'**
  String get nodeStatusNotSynced;

  /// No description provided for @nodeStatusOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get nodeStatusOffline;

  /// No description provided for @nodeStatusLatency.
  ///
  /// In en, this message translates to:
  /// **'{ms}ms'**
  String nodeStatusLatency(int ms);

  /// No description provided for @nodeActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get nodeActive;

  /// No description provided for @nodeAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Node'**
  String get nodeAdd;

  /// No description provided for @nodeUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Node URL'**
  String get nodeUrlLabel;

  /// No description provided for @nodeUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://node.example.com:8000'**
  String get nodeUrlHint;

  /// No description provided for @nodeLabelLabel.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get nodeLabelLabel;

  /// No description provided for @nodeProxyMode.
  ///
  /// In en, this message translates to:
  /// **'Proxy Mode'**
  String get nodeProxyMode;

  /// No description provided for @nodeProxyModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'/chain-api/ + /chain-rpc/'**
  String get nodeProxyModeSubtitle;

  /// No description provided for @nodeDefaultLabel.
  ///
  /// In en, this message translates to:
  /// **'Custom Node'**
  String get nodeDefaultLabel;

  /// No description provided for @nodeAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get nodeAddButton;

  /// No description provided for @securityWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Security Warning'**
  String get securityWarningTitle;

  /// No description provided for @securityWarningBody.
  ///
  /// In en, this message translates to:
  /// **'This device appears to be rooted or jailbroken. Running a wallet app on a compromised device puts your funds at risk.'**
  String get securityWarningBody;

  /// No description provided for @securityWarningAck.
  ///
  /// In en, this message translates to:
  /// **'I understand the risks'**
  String get securityWarningAck;

  /// No description provided for @widgetHashCopied.
  ///
  /// In en, this message translates to:
  /// **'Hash copied'**
  String get widgetHashCopied;

  /// No description provided for @widgetAddressCopied.
  ///
  /// In en, this message translates to:
  /// **'Address copied'**
  String get widgetAddressCopied;

  /// No description provided for @widgetTxHash.
  ///
  /// In en, this message translates to:
  /// **'Transaction Hash'**
  String get widgetTxHash;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt', 'ru', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
