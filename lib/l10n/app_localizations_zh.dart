// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Gonka Wallet';

  @override
  String get splashLoading => '加载中...';

  @override
  String get splashCheckingNodes => '正在检查节点...';

  @override
  String get onboardingCreateTitle => 'Gonka Wallet';

  @override
  String get onboardingCreateSubtitle => 'Gonka 区块链的安全钱包';

  @override
  String get onboardingCreateNewWallet => '创建新钱包';

  @override
  String get onboardingCreateImportWallet => '导入现有钱包';

  @override
  String get onboardingCreateTerms => '使用条款';

  @override
  String get onboardingCreatePrivacy => '隐私政策';

  @override
  String get onboardingBackupTitle => '备份助记词';

  @override
  String get onboardingBackupWarning =>
      '请按顺序写下这 24 个单词。切勿与任何人分享。掌握这组助记词的人可以访问您的资金。';

  @override
  String get onboardingBackupCheckbox => '我已抄写助记词';

  @override
  String get onboardingBackupContinue => '继续';

  @override
  String get onboardingBackupVerifyTitle => '验证备份';

  @override
  String onboardingBackupVerifyPrompt(int index) {
    return '第 $index 个单词是什么?';
  }

  @override
  String onboardingBackupVerifyHint(int index) {
    return '请输入第 $index 个单词';
  }

  @override
  String get onboardingBackupVerifyButton => '验证';

  @override
  String get onboardingBackupVerifyError => '单词错误,请重试。';

  @override
  String get onboardingImportTitle => '导入钱包';

  @override
  String get onboardingImportWordByWord => '逐词输入';

  @override
  String get onboardingImportPastePhrase => '粘贴助记词';

  @override
  String get onboardingImportHint => '在此粘贴您的 24 个单词助记词...';

  @override
  String get onboardingImportButton => '导入';

  @override
  String onboardingImportErrorWordCount(int count) {
    return '助记词必须恰好为 24 个单词(当前 $count 个)';
  }

  @override
  String get onboardingImportErrorFillAll => '请填写全部 24 个单词';

  @override
  String get onboardingImportErrorInvalid => '无效的助记词';

  @override
  String get onboardingImportPrivateKey => '私钥';

  @override
  String get onboardingImportPrivateKeyHint => '粘贴您的私钥(64 位十六进制字符)';

  @override
  String get onboardingImportPrivateKeyErrorInvalid => '无效的私钥。应为 64 位十六进制字符。';

  @override
  String get onboardingNameTitle => '为钱包命名';

  @override
  String get onboardingNameHeading => '给您的钱包起个名字';

  @override
  String get onboardingNameSubtext => '仅供您参考。';

  @override
  String get onboardingNameLabel => '钱包名称';

  @override
  String get onboardingNameValidationEmpty => '请输入名称';

  @override
  String get onboardingNameDefault => '我的钱包';

  @override
  String get onboardingNameContinue => '继续';

  @override
  String get onboardingPinTitle => '设置 PIN 码';

  @override
  String get onboardingPinCreateHeading => '创建 6 位 PIN 码';

  @override
  String get onboardingPinConfirmHeading => '确认 PIN 码';

  @override
  String get onboardingPinMismatch => 'PIN 码不一致,请重试。';

  @override
  String get onboardingPinBiometricTitle => '启用生物识别?';

  @override
  String get onboardingPinBiometricBody => '使用 Face ID / 指纹解锁您的钱包?';

  @override
  String get onboardingPinBiometricSkip => '跳过';

  @override
  String get onboardingPinBiometricEnable => '启用';

  @override
  String get authEnterPin => '输入 PIN 码';

  @override
  String get authEnterCurrentPin => '输入当前 PIN 码';

  @override
  String get authEnterNewPin => '输入新 PIN 码';

  @override
  String authWrongPin(int remaining) {
    return 'PIN 码错误。剩余 $remaining 次尝试。';
  }

  @override
  String authCooldown(int seconds) {
    return '尝试次数过多。请等待 $seconds 秒。';
  }

  @override
  String get homeTitle => 'Gonka Wallet';

  @override
  String get homeEmpty => '暂无钱包';

  @override
  String get homeCreateWallet => '创建钱包';

  @override
  String get homeAddWallet => '添加钱包';

  @override
  String get walletDetailTitle => '钱包';

  @override
  String get walletDetailNotFound => '未找到钱包';

  @override
  String get walletDetailShowSeed => '显示助记词';

  @override
  String get walletDetailExportPk => '导出私钥';

  @override
  String get walletDetailExportPkDialogTitle => '私钥';

  @override
  String get walletDetailExportPkWarning => '任何掌握此私钥的人都可以访问您的资金。切勿分享。';

  @override
  String get walletDetailExportPkCopied => '私钥已复制';

  @override
  String get walletDetailRename => '重命名钱包';

  @override
  String get walletDetailDelete => '删除钱包';

  @override
  String get walletDetailSend => '发送';

  @override
  String get walletDetailReceive => '接收';

  @override
  String get walletDetailHostTools => '主机工具';

  @override
  String get walletDetailTxHistory => '交易记录';

  @override
  String get walletDetailNoTx => '暂无交易';

  @override
  String get walletDetailTxError => '加载记录失败';

  @override
  String walletDetailBalanceError(String error) {
    return '加载余额失败: $error';
  }

  @override
  String get walletDetailSeedDialogTitle => '助记词';

  @override
  String get walletDetailRenameDialogTitle => '重命名钱包';

  @override
  String get walletDetailRenameLabel => '名称';

  @override
  String walletDetailDeleteDialogBody(String name) {
    return '确定要删除「$name」吗?\n\n这将从本设备中移除该钱包及其助记词。请确保您已备份助记词!';
  }

  @override
  String get commonCancel => '取消';

  @override
  String get commonSave => '保存';

  @override
  String get commonDelete => '删除';

  @override
  String get commonRetry => '重试';

  @override
  String get commonDone => '完成';

  @override
  String get commonClose => '关闭';

  @override
  String get commonCopy => '复制';

  @override
  String get commonFrom => '从';

  @override
  String get commonTo => '至';

  @override
  String get commonAmount => '金额';

  @override
  String get commonFee => '手续费';

  @override
  String get commonFeeZero => '0 GNK';

  @override
  String get commonAddress => '地址';

  @override
  String get commonAction => '操作';

  @override
  String get commonStatus => '状态';

  @override
  String get commonType => '类型';

  @override
  String get commonHash => '哈希';

  @override
  String get commonHeight => '区块高度';

  @override
  String get commonTime => '时间';

  @override
  String get commonMemo => '备注';

  @override
  String get commonSuccess => '成功';

  @override
  String get commonFailed => '失败';

  @override
  String get commonContract => '合约';

  @override
  String get commonValidator => '验证者';

  @override
  String get commonGranter => '授权方';

  @override
  String get commonGrantee => '被授权方';

  @override
  String get commonProposal => '提案';

  @override
  String get commonOption => '选项';

  @override
  String get commonEpoch => '纪元';

  @override
  String get balanceTotal => '总余额';

  @override
  String get balanceAvailable => '可用';

  @override
  String get balanceVesting => '锁仓中';

  @override
  String get authBiometricReason => '请验证身份以访问您的钱包';

  @override
  String get errorNoActiveNode => '没有活动节点';

  @override
  String get errorMnemonicNotFound => '未找到助记词';

  @override
  String get errorInvalidMnemonic => '无效的助记词';

  @override
  String get errorGeneric => '发生错误';

  @override
  String get txTypeReceived => '已接收';

  @override
  String get txTypeSent => '已发送';

  @override
  String get txTypeContract => '合约';

  @override
  String get txTypeContractDeposit => '存入';

  @override
  String get txTypeContractWithdraw => '提取';

  @override
  String get txTypeUnjail => '解禁';

  @override
  String get txTypeGrant => '授予权限';

  @override
  String get txTypeCollateralDeposit => '质押存入';

  @override
  String get txTypeCollateralWithdraw => '质押提取';

  @override
  String get txTypeVestingReward => '锁仓奖励';

  @override
  String txTypeEpochReward(int epoch) {
    return '第 $epoch 纪元奖励';
  }

  @override
  String txTypeVote(String option) {
    return '投票: $option';
  }

  @override
  String get txTimeJustNow => '刚刚';

  @override
  String txTimeMinutesAgo(int minutes) {
    return '$minutes 分钟前';
  }

  @override
  String txTimeHoursAgo(int hours) {
    return '$hours 小时前';
  }

  @override
  String txTimeDaysAgo(int days) {
    return '$days 天前';
  }

  @override
  String get sendTitle => '发送';

  @override
  String get sendRecipientLabel => '收款地址';

  @override
  String get sendAmountLabel => '金额';

  @override
  String get sendMaxButton => '最大';

  @override
  String get sendUnitGnk => 'GNK';

  @override
  String get sendUnitNgonka => 'ngonka';

  @override
  String get sendContinue => '继续';

  @override
  String get sendErrorEnterAddress => '请输入收款地址';

  @override
  String get sendErrorInvalidAddress => '无效的 Gonka 地址';

  @override
  String get sendErrorSelfSend => '不能发送给自己';

  @override
  String get sendErrorEnterAmount => '请输入金额';

  @override
  String get sendErrorAmountPositive => '金额必须大于零';

  @override
  String get sendErrorInsufficient => '余额不足';

  @override
  String get sendErrorInvalidAmount => '无效的金额';

  @override
  String get sendScanQr => '扫描二维码';

  @override
  String get confirmSendTitle => '确认发送';

  @override
  String get confirmSendButton => '确认并发送';

  @override
  String get confirmSendAuthenticating => '正在验证...';

  @override
  String get sendResultSuccess => '交易已发送!';

  @override
  String get sendResultFailed => '交易失败';

  @override
  String get receiveTitle => '接收';

  @override
  String get receiveNoWallet => '无钱包';

  @override
  String get receiveTapToCopy => '点击地址复制';

  @override
  String get minersTitle => '主机工具';

  @override
  String get minersPubKey => '我的公钥';

  @override
  String get minersPubKeySubtitle => '查看并复制您的公钥';

  @override
  String get minersPubKeyCopied => '公钥已复制';

  @override
  String get minersCollateral => '质押';

  @override
  String get minersCollateralSubtitle => '管理您的挖矿质押';

  @override
  String get minersGrant => '授予权限';

  @override
  String get minersGrantSubtitle => '向 ML 操作密钥授予权限';

  @override
  String get minersUnjail => '解禁';

  @override
  String get minersUnjailSubtitle => '解禁您的验证者';

  @override
  String get minersGovernance => '治理';

  @override
  String get minersGovernanceSubtitle => '对提案进行投票';

  @override
  String get minersTracker => '监控面板';

  @override
  String get minersTrackerSubtitle => '专业仪表板';

  @override
  String get collateralTitle => '质押';

  @override
  String get collateralCurrent => '当前质押';

  @override
  String get collateralDeposit => '存入';

  @override
  String get collateralWithdraw => '提取';

  @override
  String get collateralUnbonding => '解绑中';

  @override
  String collateralCompletionEpoch(int epoch) {
    return '完成纪元: $epoch';
  }

  @override
  String get collateralEmpty => '暂无质押';

  @override
  String get collateralDepositTitle => '存入质押';

  @override
  String get collateralWithdrawTitle => '提取质押';

  @override
  String collateralCurrentInfo(String amount) {
    return '当前质押: $amount GNK';
  }

  @override
  String get collateralErrorExceeds => '超过当前质押数量';

  @override
  String get collateralConfirmDeposit => '确认存入';

  @override
  String get collateralConfirmWithdraw => '确认提取';

  @override
  String get collateralConfirmDepositButton => '确认并存入';

  @override
  String get collateralConfirmWithdrawButton => '确认并提取';

  @override
  String get collateralResultDepositSuccess => '存入成功!';

  @override
  String get collateralResultWithdrawSuccess => '提取成功!';

  @override
  String get collateralResultDepositFailed => '存入失败';

  @override
  String get collateralResultWithdrawFailed => '提取失败';

  @override
  String get grantTitle => '授予权限';

  @override
  String get grantInfo => '授予您的 ML 操作密钥代表您执行推理、训练及其他 ML 操作的权限。此授权不会提供对资金的访问权限。';

  @override
  String get grantOpKeyLabel => '操作密钥地址';

  @override
  String get grantOpKeyHint => 'gonka1...';

  @override
  String get grantErrorEnterAddress => '请输入操作密钥地址';

  @override
  String get grantErrorInvalidAddress => '无效的 Gonka 地址';

  @override
  String get grantErrorSelf => '不能向自己授予权限';

  @override
  String get grantContinue => '继续';

  @override
  String get grantScanQr => '扫描二维码';

  @override
  String get grantConfirmTitle => '确认授权';

  @override
  String get grantConfirmAction => '授予 ML 权限';

  @override
  String get grantConfirmExpiration => '到期时间';

  @override
  String get grantConfirmExpirationValue => '2 年';

  @override
  String get grantConfirmPermissions => '权限';

  @override
  String get grantConfirmPermissionsValue => '27 项 ML 操作';

  @override
  String get grantConfirmButton => '确认并授予';

  @override
  String get grantResultSuccess => '权限已授予!';

  @override
  String get grantResultFailed => '授权失败';

  @override
  String get unjailTitle => '解禁验证者';

  @override
  String get unjailWarningJailed => '您的验证者已被封禁。请发送解禁交易以恢复运行。';

  @override
  String get unjailInfoNotJailed => '您的验证者未被封禁,无需操作。';

  @override
  String get unjailInfoNotFound => '链上未找到验证者。请确认您的验证者已创建。';

  @override
  String get unjailAction => '解禁验证者';

  @override
  String get unjailValidatorAddress => '验证者地址';

  @override
  String get unjailConfirmButton => '确认并解禁';

  @override
  String get unjailResultSuccess => '解禁成功';

  @override
  String get unjailResultFailed => '解禁失败';

  @override
  String get governanceTitle => '治理';

  @override
  String get governanceTabAll => '全部';

  @override
  String get governanceTabActive => '进行中';

  @override
  String get governanceTabClosed => '已结束';

  @override
  String governanceErrorLoad(String error) {
    return '加载提案失败: $error';
  }

  @override
  String get governanceEmptyAll => '未找到提案';

  @override
  String get governanceEmptyActive => '没有进行中的提案';

  @override
  String get governanceEmptyClosed => '没有已结束的提案';

  @override
  String get governanceStatusActive => '进行中';

  @override
  String get governanceStatusPassed => '已通过';

  @override
  String get governanceStatusRejected => '已拒绝';

  @override
  String get governanceEndingSoon => '即将结束';

  @override
  String governanceEndsInDays(int days, int hours) {
    return '$days 天 $hours 小时后结束';
  }

  @override
  String governanceEndsInHours(int hours, int minutes) {
    return '$hours 小时 $minutes 分钟后结束';
  }

  @override
  String governanceEndsInMinutes(int minutes) {
    return '$minutes 分钟后结束';
  }

  @override
  String governanceEndedDaysAgo(int days) {
    return '$days 天前结束';
  }

  @override
  String governanceEndedOn(String date) {
    return '$date 结束';
  }

  @override
  String proposalDetailTitle(int id) {
    return '提案 #$id';
  }

  @override
  String proposalDetailErrorLoad(String error) {
    return '加载提案失败: $error';
  }

  @override
  String get proposalDetailNotFound => '未找到提案';

  @override
  String get proposalDetailSummary => '摘要';

  @override
  String get proposalDetailProposer => '提案人';

  @override
  String get proposalDetailVotingPeriod => '投票期';

  @override
  String get proposalDetailTally => '投票结果';

  @override
  String get proposalVoteYes => '赞成';

  @override
  String get proposalVoteAbstain => '弃权';

  @override
  String get proposalVoteNo => '反对';

  @override
  String get proposalVoteNoWithVeto => '反对并否决';

  @override
  String get proposalCastYourVote => '投出您的票';

  @override
  String get proposalSubmitVote => '提交投票';

  @override
  String get proposalVotingEnded => '此提案的投票已结束。';

  @override
  String get proposalVoteSubmitted => '投票已提交';

  @override
  String get proposalVoteFailed => '投票失败';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsNodeSettings => '节点设置';

  @override
  String get settingsSecurity => '安全';

  @override
  String get settingsSecuritySubtitle => 'PIN 码与生物识别';

  @override
  String get settingsTerms => '使用条款';

  @override
  String get settingsPrivacy => '隐私政策';

  @override
  String get securityTitle => '安全';

  @override
  String get securityChangePin => '修改 PIN 码';

  @override
  String get securityBiometric => '生物识别认证';

  @override
  String get securityWipe => 'PIN 错误后清除钱包';

  @override
  String securityWipeSubtitle(int max) {
    return '在 $max 次错误尝试后删除所有钱包';
  }

  @override
  String get securityPinChanged => 'PIN 码已修改';

  @override
  String get securityPinNotChanged => 'PIN 码未修改';

  @override
  String get nodeSettingsTitle => '节点设置';

  @override
  String get nodeSettingsRefresh => '刷新节点';

  @override
  String get nodeStatusChecking => '检查中...';

  @override
  String get nodeStatusSyncing => '同步中...';

  @override
  String get nodeStatusNotSynced => '未同步';

  @override
  String get nodeStatusOffline => '离线';

  @override
  String nodeStatusLatency(int ms) {
    return '$ms 毫秒';
  }

  @override
  String get nodeActive => '活动';

  @override
  String get nodeAdd => '添加节点';

  @override
  String get nodeUrlLabel => '节点 URL';

  @override
  String get nodeUrlHint => 'https://node.example.com:8000';

  @override
  String get nodeLabelLabel => '标签';

  @override
  String get nodeProxyMode => '代理模式';

  @override
  String get nodeProxyModeSubtitle => '/chain-api/ + /chain-rpc/';

  @override
  String get nodeDefaultLabel => '自定义节点';

  @override
  String get nodeAddButton => '添加';

  @override
  String get securityWarningTitle => '安全警告';

  @override
  String get securityWarningBody => '此设备似乎已被 Root 或越狱。在受损设备上运行钱包应用会使您的资金面临风险。';

  @override
  String get securityWarningAck => '我了解风险';

  @override
  String get widgetHashCopied => '哈希已复制';

  @override
  String get widgetAddressCopied => '地址已复制';

  @override
  String get widgetTxHash => '交易哈希';
}
