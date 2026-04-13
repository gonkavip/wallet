// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Gonka Wallet';

  @override
  String get splashLoading => 'Loading...';

  @override
  String get splashCheckingNodes => 'Checking nodes...';

  @override
  String get onboardingCreateTitle => 'Gonka Wallet';

  @override
  String get onboardingCreateSubtitle =>
      'Secure wallet for the Gonka blockchain';

  @override
  String get onboardingCreateNewWallet => 'Create New Wallet';

  @override
  String get onboardingCreateImportWallet => 'Import Existing Wallet';

  @override
  String get onboardingCreateTerms => 'Terms of Use';

  @override
  String get onboardingCreatePrivacy => 'Privacy Policy';

  @override
  String get onboardingBackupTitle => 'Back Up Seed Phrase';

  @override
  String get onboardingBackupWarning =>
      'Write down these 24 words in order. Never share them. Anyone with this phrase can access your funds.';

  @override
  String get onboardingBackupCheckbox => 'I have written down the seed phrase';

  @override
  String get onboardingBackupContinue => 'Continue';

  @override
  String get onboardingBackupVerifyTitle => 'Verify Backup';

  @override
  String onboardingBackupVerifyPrompt(int index) {
    return 'What is word #$index?';
  }

  @override
  String onboardingBackupVerifyHint(int index) {
    return 'Enter word #$index';
  }

  @override
  String get onboardingBackupVerifyButton => 'Verify';

  @override
  String get onboardingBackupVerifyError => 'Incorrect word. Please try again.';

  @override
  String get onboardingImportTitle => 'Import Wallet';

  @override
  String get onboardingImportWordByWord => 'Word by word';

  @override
  String get onboardingImportPastePhrase => 'Paste phrase';

  @override
  String get onboardingImportHint => 'Paste your 24-word seed phrase here...';

  @override
  String get onboardingImportButton => 'Import';

  @override
  String onboardingImportErrorWordCount(int count) {
    return 'Seed phrase must be exactly 24 words (got $count)';
  }

  @override
  String get onboardingImportErrorFillAll => 'Please fill in all 24 words';

  @override
  String get onboardingImportErrorInvalid => 'Invalid seed phrase';

  @override
  String get onboardingImportPrivateKey => 'Private key';

  @override
  String get onboardingImportPrivateKeyHint =>
      'Paste your private key (64 hex characters)';

  @override
  String get onboardingImportPrivateKeyErrorInvalid =>
      'Invalid private key. Expected 64 hex characters.';

  @override
  String get onboardingNameTitle => 'Name Your Wallet';

  @override
  String get onboardingNameHeading => 'Give your wallet a name';

  @override
  String get onboardingNameSubtext => 'This is just for your reference.';

  @override
  String get onboardingNameLabel => 'Wallet Name';

  @override
  String get onboardingNameValidationEmpty => 'Please enter a name';

  @override
  String get onboardingNameDefault => 'My Wallet';

  @override
  String get onboardingNameContinue => 'Continue';

  @override
  String get onboardingPinTitle => 'Set PIN';

  @override
  String get onboardingPinCreateHeading => 'Create a 6-digit PIN';

  @override
  String get onboardingPinConfirmHeading => 'Confirm your PIN';

  @override
  String get onboardingPinMismatch => 'PINs do not match. Try again.';

  @override
  String get onboardingPinBiometricTitle => 'Enable Biometrics?';

  @override
  String get onboardingPinBiometricBody =>
      'Use Face ID / fingerprint to unlock your wallet?';

  @override
  String get onboardingPinBiometricSkip => 'Skip';

  @override
  String get onboardingPinBiometricEnable => 'Enable';

  @override
  String get authEnterPin => 'Enter PIN';

  @override
  String get authEnterCurrentPin => 'Enter Current PIN';

  @override
  String get authEnterNewPin => 'Enter New PIN';

  @override
  String authWrongPin(int remaining) {
    return 'Wrong PIN. $remaining attempts remaining.';
  }

  @override
  String authCooldown(int seconds) {
    return 'Too many attempts. Wait ${seconds}s.';
  }

  @override
  String get homeTitle => 'Gonka Wallet';

  @override
  String get homeEmpty => 'No wallets yet';

  @override
  String get homeCreateWallet => 'Create Wallet';

  @override
  String get homeAddWallet => 'Add Wallet';

  @override
  String get walletDetailTitle => 'Wallet';

  @override
  String get walletDetailNotFound => 'Wallet not found';

  @override
  String get walletDetailShowSeed => 'Show Seed Phrase';

  @override
  String get walletDetailExportPk => 'Export Private Key';

  @override
  String get walletDetailExportPkDialogTitle => 'Private Key';

  @override
  String get walletDetailExportPkWarning =>
      'Anyone with this key can access your funds. Never share it.';

  @override
  String get walletDetailExportPkCopied => 'Private key copied';

  @override
  String get walletDetailRename => 'Rename Wallet';

  @override
  String get walletDetailDelete => 'Delete Wallet';

  @override
  String get walletDetailSend => 'Send';

  @override
  String get walletDetailReceive => 'Receive';

  @override
  String get walletDetailHostTools => 'Host Tools';

  @override
  String get walletDetailTxHistory => 'Transaction History';

  @override
  String get walletDetailNoTx => 'No transactions yet';

  @override
  String get walletDetailTxError => 'Failed to load history';

  @override
  String walletDetailBalanceError(String error) {
    return 'Failed to load balance: $error';
  }

  @override
  String get walletDetailSeedDialogTitle => 'Seed Phrase';

  @override
  String get walletDetailRenameDialogTitle => 'Rename Wallet';

  @override
  String get walletDetailRenameLabel => 'Name';

  @override
  String walletDetailDeleteDialogBody(String name) {
    return 'Are you sure you want to delete \"$name\"?\n\nThis will remove the wallet and its seed phrase from this device. Make sure you have backed up your seed phrase!';
  }

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonDone => 'Done';

  @override
  String get commonClose => 'Close';

  @override
  String get commonCopy => 'Copy';

  @override
  String get commonFrom => 'From';

  @override
  String get commonTo => 'To';

  @override
  String get commonAmount => 'Amount';

  @override
  String get commonFee => 'Fee';

  @override
  String get commonFeeZero => '0 GNK';

  @override
  String get commonAddress => 'Address';

  @override
  String get commonAction => 'Action';

  @override
  String get commonStatus => 'Status';

  @override
  String get commonType => 'Type';

  @override
  String get commonHash => 'Hash';

  @override
  String get commonHeight => 'Height';

  @override
  String get commonTime => 'Time';

  @override
  String get commonMemo => 'Memo';

  @override
  String get commonSuccess => 'Success';

  @override
  String get commonFailed => 'Failed';

  @override
  String get commonContract => 'Contract';

  @override
  String get commonValidator => 'Validator';

  @override
  String get commonGranter => 'Granter';

  @override
  String get commonGrantee => 'Grantee';

  @override
  String get commonProposal => 'Proposal';

  @override
  String get commonOption => 'Option';

  @override
  String get commonEpoch => 'Epoch';

  @override
  String get balanceTotal => 'Total Balance';

  @override
  String get balanceAvailable => 'Available';

  @override
  String get balanceVesting => 'Vesting';

  @override
  String get authBiometricReason => 'Authenticate to access your wallet';

  @override
  String get errorNoActiveNode => 'No active node';

  @override
  String get errorMnemonicNotFound => 'Mnemonic not found';

  @override
  String get errorInvalidMnemonic => 'Invalid mnemonic';

  @override
  String get errorGeneric => 'Something went wrong';

  @override
  String get txTypeReceived => 'Received';

  @override
  String get txTypeSent => 'Sent';

  @override
  String get txTypeContract => 'Contract';

  @override
  String get txTypeContractDeposit => 'Deposit';

  @override
  String get txTypeContractWithdraw => 'Withdraw';

  @override
  String get txTypeUnjail => 'Unjail';

  @override
  String get txTypeGrant => 'Grant Permissions';

  @override
  String get txTypeCollateralDeposit => 'Collateral Deposit';

  @override
  String get txTypeCollateralWithdraw => 'Collateral Withdraw';

  @override
  String get txTypeVestingReward => 'Vesting Reward';

  @override
  String txTypeEpochReward(int epoch) {
    return 'Epoch $epoch Reward';
  }

  @override
  String txTypeVote(String option) {
    return 'Vote: $option';
  }

  @override
  String get txTimeJustNow => 'Just now';

  @override
  String txTimeMinutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String txTimeHoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String txTimeDaysAgo(int days) {
    return '${days}d ago';
  }

  @override
  String get sendTitle => 'Send';

  @override
  String get sendRecipientLabel => 'Recipient Address';

  @override
  String get sendAmountLabel => 'Amount';

  @override
  String get sendMaxButton => 'MAX';

  @override
  String get sendUnitGnk => 'GNK';

  @override
  String get sendUnitNgonka => 'ngonka';

  @override
  String get sendContinue => 'Continue';

  @override
  String get sendErrorEnterAddress => 'Enter recipient address';

  @override
  String get sendErrorInvalidAddress => 'Invalid Gonka address';

  @override
  String get sendErrorSelfSend => 'Cannot send to yourself';

  @override
  String get sendErrorEnterAmount => 'Enter amount';

  @override
  String get sendErrorAmountPositive => 'Amount must be positive';

  @override
  String get sendErrorInsufficient => 'Insufficient balance';

  @override
  String get sendErrorInvalidAmount => 'Invalid amount';

  @override
  String get sendScanQr => 'Scan QR Code';

  @override
  String get confirmSendTitle => 'Confirm Send';

  @override
  String get confirmSendButton => 'Confirm & Send';

  @override
  String get confirmSendAuthenticating => 'Authenticating...';

  @override
  String get sendResultSuccess => 'Transaction Sent!';

  @override
  String get sendResultFailed => 'Transaction Failed';

  @override
  String get receiveTitle => 'Receive';

  @override
  String get receiveNoWallet => 'No wallet';

  @override
  String get receiveTapToCopy => 'Tap address to copy';

  @override
  String get minersTitle => 'Host Tools';

  @override
  String get minersPubKey => 'My PubKey';

  @override
  String get minersPubKeySubtitle => 'View and copy your public key';

  @override
  String get minersPubKeyCopied => 'Public key copied';

  @override
  String get minersCollateral => 'Collateral';

  @override
  String get minersCollateralSubtitle => 'Manage your mining collateral';

  @override
  String get minersGrant => 'Grant Permissions';

  @override
  String get minersGrantSubtitle => 'Grant permissions to ML operational key';

  @override
  String get minersUnjail => 'Unjail';

  @override
  String get minersUnjailSubtitle => 'Unjail your validator';

  @override
  String get minersGovernance => 'Governance';

  @override
  String get minersGovernanceSubtitle => 'Vote on proposals';

  @override
  String get minersTracker => 'Tracker';

  @override
  String get minersTrackerSubtitle => 'Professional Dashboard';

  @override
  String get collateralTitle => 'Collateral';

  @override
  String get collateralCurrent => 'Current Collateral';

  @override
  String get collateralDeposit => 'Deposit';

  @override
  String get collateralWithdraw => 'Withdraw';

  @override
  String get collateralUnbonding => 'Unbonding';

  @override
  String collateralCompletionEpoch(int epoch) {
    return 'Completion epoch: $epoch';
  }

  @override
  String get collateralEmpty => 'No collateral yet';

  @override
  String get collateralDepositTitle => 'Deposit Collateral';

  @override
  String get collateralWithdrawTitle => 'Withdraw Collateral';

  @override
  String collateralCurrentInfo(String amount) {
    return 'Current collateral: $amount GNK';
  }

  @override
  String get collateralErrorExceeds => 'Exceeds current collateral';

  @override
  String get collateralConfirmDeposit => 'Confirm Deposit';

  @override
  String get collateralConfirmWithdraw => 'Confirm Withdraw';

  @override
  String get collateralConfirmDepositButton => 'Confirm & Deposit';

  @override
  String get collateralConfirmWithdrawButton => 'Confirm & Withdraw';

  @override
  String get collateralResultDepositSuccess => 'Deposit Successful!';

  @override
  String get collateralResultWithdrawSuccess => 'Withdrawal Successful!';

  @override
  String get collateralResultDepositFailed => 'Deposit Failed';

  @override
  String get collateralResultWithdrawFailed => 'Withdrawal Failed';

  @override
  String get grantTitle => 'Grant Permissions';

  @override
  String get grantInfo =>
      'Grant your ML operational key permission to perform inference, training, and other ML operations on your behalf. This does not grant access to your funds.';

  @override
  String get grantOpKeyLabel => 'Operational Key Address';

  @override
  String get grantOpKeyHint => 'gonka1...';

  @override
  String get grantErrorEnterAddress => 'Enter operational key address';

  @override
  String get grantErrorInvalidAddress => 'Invalid Gonka address';

  @override
  String get grantErrorSelf => 'Cannot grant permissions to yourself';

  @override
  String get grantContinue => 'Continue';

  @override
  String get grantScanQr => 'Scan QR Code';

  @override
  String get grantConfirmTitle => 'Confirm Grant';

  @override
  String get grantConfirmAction => 'Grant ML Permissions';

  @override
  String get grantConfirmExpiration => 'Expiration';

  @override
  String get grantConfirmExpirationValue => '2 years';

  @override
  String get grantConfirmPermissions => 'Permissions';

  @override
  String get grantConfirmPermissionsValue => '27 ML operations';

  @override
  String get grantConfirmButton => 'Confirm & Grant';

  @override
  String get grantResultSuccess => 'Permissions Granted!';

  @override
  String get grantResultFailed => 'Grant Failed';

  @override
  String get unjailTitle => 'Unjail Validator';

  @override
  String get unjailWarningJailed =>
      'Your validator is jailed. Send an unjail transaction to resume operations.';

  @override
  String get unjailInfoNotJailed =>
      'Your validator is not jailed. No action needed.';

  @override
  String get unjailInfoNotFound =>
      'Validator not found on chain. Make sure your validator has been created.';

  @override
  String get unjailAction => 'Unjail Validator';

  @override
  String get unjailValidatorAddress => 'Validator Address';

  @override
  String get unjailConfirmButton => 'Confirm & Unjail';

  @override
  String get unjailResultSuccess => 'Unjail Successful';

  @override
  String get unjailResultFailed => 'Unjail Failed';

  @override
  String get governanceTitle => 'Governance';

  @override
  String get governanceTabAll => 'All';

  @override
  String get governanceTabActive => 'Active';

  @override
  String get governanceTabClosed => 'Closed';

  @override
  String governanceErrorLoad(String error) {
    return 'Failed to load proposals: $error';
  }

  @override
  String get governanceEmptyAll => 'No proposals found';

  @override
  String get governanceEmptyActive => 'No active proposals';

  @override
  String get governanceEmptyClosed => 'No closed proposals';

  @override
  String get governanceStatusActive => 'Active';

  @override
  String get governanceStatusPassed => 'Passed';

  @override
  String get governanceStatusRejected => 'Rejected';

  @override
  String get governanceEndingSoon => 'Ending soon';

  @override
  String governanceEndsInDays(int days, int hours) {
    return 'Ends in ${days}d ${hours}h';
  }

  @override
  String governanceEndsInHours(int hours, int minutes) {
    return 'Ends in ${hours}h ${minutes}m';
  }

  @override
  String governanceEndsInMinutes(int minutes) {
    return 'Ends in ${minutes}m';
  }

  @override
  String governanceEndedDaysAgo(int days) {
    return 'Ended ${days}d ago';
  }

  @override
  String governanceEndedOn(String date) {
    return 'Ended $date';
  }

  @override
  String proposalDetailTitle(int id) {
    return 'Proposal #$id';
  }

  @override
  String proposalDetailErrorLoad(String error) {
    return 'Failed to load proposal: $error';
  }

  @override
  String get proposalDetailNotFound => 'Proposal not found';

  @override
  String get proposalDetailSummary => 'Summary';

  @override
  String get proposalDetailProposer => 'Proposer';

  @override
  String get proposalDetailVotingPeriod => 'Voting Period';

  @override
  String get proposalDetailTally => 'Tally Results';

  @override
  String get proposalVoteYes => 'Yes';

  @override
  String get proposalVoteAbstain => 'Abstain';

  @override
  String get proposalVoteNo => 'No';

  @override
  String get proposalVoteNoWithVeto => 'No with Veto';

  @override
  String get proposalCastYourVote => 'Cast Your Vote';

  @override
  String get proposalSubmitVote => 'Submit Vote';

  @override
  String get proposalVotingEnded => 'Voting has ended for this proposal.';

  @override
  String get proposalVoteSubmitted => 'Vote Submitted';

  @override
  String get proposalVoteFailed => 'Vote Failed';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsNodeSettings => 'Node Settings';

  @override
  String get settingsSecurity => 'Security';

  @override
  String get settingsSecuritySubtitle => 'PIN & biometrics';

  @override
  String get settingsTerms => 'Terms of Use';

  @override
  String get settingsPrivacy => 'Privacy Policy';

  @override
  String get securityTitle => 'Security';

  @override
  String get securityChangePin => 'Change PIN';

  @override
  String get securityBiometric => 'Biometric Authentication';

  @override
  String get securityWipe => 'Erase wallets after failed PIN';

  @override
  String securityWipeSubtitle(int max) {
    return 'Delete all wallets after $max wrong attempts';
  }

  @override
  String get securityPinChanged => 'PIN changed';

  @override
  String get securityPinNotChanged => 'PIN not changed';

  @override
  String get nodeSettingsTitle => 'Node Settings';

  @override
  String get nodeSettingsRefresh => 'Refresh Nodes';

  @override
  String get nodeStatusChecking => 'Checking...';

  @override
  String get nodeStatusSyncing => 'Syncing...';

  @override
  String get nodeStatusNotSynced => 'Not synced';

  @override
  String get nodeStatusOffline => 'Offline';

  @override
  String nodeStatusLatency(int ms) {
    return '${ms}ms';
  }

  @override
  String get nodeActive => 'Active';

  @override
  String get nodeAdd => 'Add Node';

  @override
  String get nodeUrlLabel => 'Node URL';

  @override
  String get nodeUrlHint => 'https://node.example.com:8000';

  @override
  String get nodeLabelLabel => 'Label';

  @override
  String get nodeProxyMode => 'Proxy Mode';

  @override
  String get nodeProxyModeSubtitle => '/chain-api/ + /chain-rpc/';

  @override
  String get nodeDefaultLabel => 'Custom Node';

  @override
  String get nodeAddButton => 'Add';

  @override
  String get securityWarningTitle => 'Security Warning';

  @override
  String get securityWarningBody =>
      'This device appears to be rooted or jailbroken. Running a wallet app on a compromised device puts your funds at risk.';

  @override
  String get securityWarningAck => 'I understand the risks';

  @override
  String get widgetHashCopied => 'Hash copied';

  @override
  String get widgetAddressCopied => 'Address copied';

  @override
  String get widgetTxHash => 'Transaction Hash';
}
