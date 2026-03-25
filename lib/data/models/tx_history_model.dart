enum TxType { send, receive, vestingReward, collateralDeposit, collateralWithdraw, grantPermissions, unjail, vote, contractDeposit, contractWithdraw }

class TxHistoryItem {
  final String txhash;
  final String fromAddress;
  final String toAddress;
  final BigInt amountNgonka;
  final String denom;
  final DateTime timestamp;
  final int height;
  final bool success;
  final String memo;
  final TxType type;
  final int? epochIndex;

  TxHistoryItem({
    required this.txhash,
    required this.fromAddress,
    required this.toAddress,
    required this.amountNgonka,
    this.denom = 'ngonka',
    required this.timestamp,
    required this.height,
    required this.success,
    this.memo = '',
    this.type = TxType.send,
    this.epochIndex,
  });

  bool get isCollateral =>
      type == TxType.collateralDeposit || type == TxType.collateralWithdraw;

  bool get isGrant => type == TxType.grantPermissions;

  bool get isUnjail => type == TxType.unjail;

  bool get isVote => type == TxType.vote;

  bool get isContract => type == TxType.contractDeposit || type == TxType.contractWithdraw;

  bool isReceive(String myAddress) =>
      type == TxType.vestingReward || toAddress == myAddress;

  factory TxHistoryItem.fromTxResponse(
      Map<String, dynamic> tx, Map<String, dynamic> txResponse) {
    try {
      final messages = tx['body']?['messages'] as List? ?? [];
      if (messages.isNotEmpty) {
        final typeUrl = messages[0]['@type']?.toString() ?? '';
        if (typeUrl.contains('MsgExecuteContract')) {
          return TxHistoryItem.fromContractTx(tx, txResponse);
        }
      }
    } catch (_) {}

    final txhash = txResponse['txhash']?.toString() ?? '';
    final code = txResponse['code'] ?? 0;
    final height = int.tryParse(txResponse['height']?.toString() ?? '0') ?? 0;
    final timestampStr = txResponse['timestamp']?.toString() ?? '';
    final timestamp = DateTime.tryParse(timestampStr) ?? DateTime.now();

    String from = '';
    String to = '';
    BigInt amount = BigInt.zero;
    String denom = 'ngonka';
    String memo = '';

    try {
      final body = tx['body'];
      if (body != null) {
        memo = body['memo']?.toString() ?? '';
        final messages = body['messages'] as List? ?? [];
        for (final msg in messages) {
          final typeUrl = msg['@type']?.toString() ?? '';
          if (typeUrl.contains('MsgSend')) {
            from = msg['from_address']?.toString() ?? '';
            to = msg['to_address']?.toString() ?? '';
            final amounts = msg['amount'] as List? ?? [];
            if (amounts.isNotEmpty) {
              amount =
                  BigInt.tryParse(amounts[0]['amount']?.toString() ?? '0') ??
                      BigInt.zero;
              denom = amounts[0]['denom']?.toString() ?? 'ngonka';
            }
            break;
          }
        }
      }
    } catch (_) {}

    return TxHistoryItem(
      txhash: txhash,
      fromAddress: from,
      toAddress: to,
      amountNgonka: amount,
      denom: denom,
      timestamp: timestamp,
      height: height,
      success: code == 0,
      memo: memo,
      type: TxType.send,
    );
  }

  factory TxHistoryItem.fromVestingReward(
      Map<String, dynamic> tx,
      Map<String, dynamic> txResponse,
      String myAddress) {
    final txhash = txResponse['txhash']?.toString() ?? '';
    final code = txResponse['code'] ?? 0;
    final height = int.tryParse(txResponse['height']?.toString() ?? '0') ?? 0;
    final timestampStr = txResponse['timestamp']?.toString() ?? '';
    final timestamp = DateTime.tryParse(timestampStr) ?? DateTime.now();

    int? epochIndex;
    BigInt amount = BigInt.zero;

    try {
      final messages = tx['body']?['messages'] as List? ?? [];
      for (final msg in messages) {
        final typeUrl = msg['@type']?.toString() ?? '';
        if (typeUrl.contains('MsgExec')) {
          final innerMsgs = msg['msgs'] as List? ?? [];
          for (final im in innerMsgs) {
            if (im['@type']?.toString().contains('MsgClaimRewards') == true &&
                im['creator'] == myAddress) {
              epochIndex = int.tryParse(im['epoch_index']?.toString() ?? '');
            }
          }
        } else if (typeUrl.contains('MsgClaimRewards') &&
            msg['creator'] == myAddress) {
          epochIndex = int.tryParse(msg['epoch_index']?.toString() ?? '');
        }
      }
    } catch (_) {}

    try {
      final events = txResponse['events'] as List? ?? [];
      for (final event in events) {
        if (event['type'] == 'vest_reward') {
          final attrs = <String, String>{};
          for (final a in event['attributes'] as List? ?? []) {
            attrs[a['key'].toString()] = a['value'].toString();
          }
          if (attrs['participant'] == myAddress) {
            final amountStr = attrs['amount'] ?? '0';
            final numStr = amountStr.replaceAll(RegExp(r'[^0-9]'), '');
            final parsed = BigInt.tryParse(numStr) ?? BigInt.zero;
            if (parsed > amount) amount = parsed;
          }
        }
      }
    } catch (_) {}

    return TxHistoryItem(
      txhash: txhash,
      fromAddress: 'Epoch Reward',
      toAddress: myAddress,
      amountNgonka: amount,
      timestamp: timestamp,
      height: height,
      success: code == 0,
      type: TxType.vestingReward,
      epochIndex: epochIndex,
    );
  }

  factory TxHistoryItem.fromCollateralTx(
      Map<String, dynamic> tx, Map<String, dynamic> txResponse) {
    final txhash = txResponse['txhash']?.toString() ?? '';
    final code = txResponse['code'] ?? 0;
    final height =
        int.tryParse(txResponse['height']?.toString() ?? '0') ?? 0;
    final timestampStr = txResponse['timestamp']?.toString() ?? '';
    final timestamp = DateTime.tryParse(timestampStr) ?? DateTime.now();

    String participant = '';
    BigInt amount = BigInt.zero;
    TxType type = TxType.collateralDeposit;

    try {
      final body = tx['body'];
      if (body != null) {
        final messages = body['messages'] as List? ?? [];
        for (final msg in messages) {
          final typeUrl = msg['@type']?.toString() ?? '';
          if (typeUrl.contains('MsgDepositCollateral')) {
            type = TxType.collateralDeposit;
          } else if (typeUrl.contains('MsgWithdrawCollateral')) {
            type = TxType.collateralWithdraw;
          } else {
            continue;
          }
          participant = msg['participant']?.toString() ?? '';
          final coin = msg['amount'];
          if (coin is Map) {
            amount =
                BigInt.tryParse(coin['amount']?.toString() ?? '0') ??
                    BigInt.zero;
          }
          break;
        }
      }
    } catch (_) {}

    return TxHistoryItem(
      txhash: txhash,
      fromAddress: participant,
      toAddress: participant,
      amountNgonka: amount,
      timestamp: timestamp,
      height: height,
      success: code == 0,
      type: type,
    );
  }

  factory TxHistoryItem.fromUnjailTx(
      Map<String, dynamic> tx, Map<String, dynamic> txResponse) {
    final txhash = txResponse['txhash']?.toString() ?? '';
    final code = txResponse['code'] ?? 0;
    final height =
        int.tryParse(txResponse['height']?.toString() ?? '0') ?? 0;
    final timestampStr = txResponse['timestamp']?.toString() ?? '';
    final timestamp = DateTime.tryParse(timestampStr) ?? DateTime.now();

    String validatorAddress = '';

    try {
      final body = tx['body'];
      if (body != null) {
        final messages = body['messages'] as List? ?? [];
        if (messages.isNotEmpty) {
          validatorAddress =
              messages[0]['validator_address']?.toString() ?? '';
        }
      }
    } catch (_) {}

    return TxHistoryItem(
      txhash: txhash,
      fromAddress: validatorAddress,
      toAddress: '',
      amountNgonka: BigInt.zero,
      timestamp: timestamp,
      height: height,
      success: code == 0,
      type: TxType.unjail,
    );
  }

  factory TxHistoryItem.fromGrantTx(
      Map<String, dynamic> tx, Map<String, dynamic> txResponse) {
    final txhash = txResponse['txhash']?.toString() ?? '';
    final code = txResponse['code'] ?? 0;
    final height =
        int.tryParse(txResponse['height']?.toString() ?? '0') ?? 0;
    final timestampStr = txResponse['timestamp']?.toString() ?? '';
    final timestamp = DateTime.tryParse(timestampStr) ?? DateTime.now();

    String granter = '';
    String grantee = '';

    try {
      final body = tx['body'];
      if (body != null) {
        final messages = body['messages'] as List? ?? [];
        if (messages.isNotEmpty) {
          final msg = messages[0];
          granter = msg['granter']?.toString() ?? '';
          grantee = msg['grantee']?.toString() ?? '';
        }
      }
    } catch (_) {}

    return TxHistoryItem(
      txhash: txhash,
      fromAddress: granter,
      toAddress: grantee,
      amountNgonka: BigInt.zero,
      timestamp: timestamp,
      height: height,
      success: code == 0,
      type: TxType.grantPermissions,
    );
  }

  factory TxHistoryItem.fromVoteTx(
      Map<String, dynamic> tx, Map<String, dynamic> txResponse) {
    final txhash = txResponse['txhash']?.toString() ?? '';
    final code = txResponse['code'] ?? 0;
    final height =
        int.tryParse(txResponse['height']?.toString() ?? '0') ?? 0;
    final timestampStr = txResponse['timestamp']?.toString() ?? '';
    final timestamp = DateTime.tryParse(timestampStr) ?? DateTime.now();

    String voter = '';
    String proposalId = '';
    String option = '';

    try {
      final body = tx['body'];
      if (body != null) {
        final messages = body['messages'] as List? ?? [];
        if (messages.isNotEmpty) {
          final msg = messages[0];
          voter = msg['voter']?.toString() ?? '';
          proposalId = msg['proposal_id']?.toString() ?? '';
          option = msg['option']?.toString() ?? '';
        }
      }
    } catch (_) {}

    return TxHistoryItem(
      txhash: txhash,
      fromAddress: voter,
      toAddress: 'Proposal #$proposalId',
      amountNgonka: BigInt.zero,
      timestamp: timestamp,
      height: height,
      success: code == 0,
      memo: option,
      type: TxType.vote,
    );
  }

  factory TxHistoryItem.fromContractTx(
      Map<String, dynamic> tx, Map<String, dynamic> txResponse) {
    final txhash = txResponse['txhash']?.toString() ?? '';
    final code = txResponse['code'] ?? 0;
    final height =
        int.tryParse(txResponse['height']?.toString() ?? '0') ?? 0;
    final timestampStr = txResponse['timestamp']?.toString() ?? '';
    final timestamp = DateTime.tryParse(timestampStr) ?? DateTime.now();

    String sender = '';
    String contract = '';
    BigInt amount = BigInt.zero;
    String action = '';

    try {
      final body = tx['body'];
      if (body != null) {
        final messages = body['messages'] as List? ?? [];
        if (messages.isNotEmpty) {
          final msg = messages[0];
          sender = msg['sender']?.toString() ?? '';
          contract = msg['contract']?.toString() ?? '';
          final funds = msg['funds'] as List? ?? [];
          if (funds.isNotEmpty) {
            amount =
                BigInt.tryParse(funds[0]['amount']?.toString() ?? '0') ??
                    BigInt.zero;
          }
          final msgBody = msg['msg'];
          if (msgBody is Map) {
            action = msgBody.keys.first.toString();
            if (amount == BigInt.zero) {
              final actionBody = msgBody[action];
              if (actionBody is Map) {
                final innerAmount = actionBody['amount']?.toString();
                if (innerAmount != null) {
                  amount = BigInt.tryParse(innerAmount) ?? BigInt.zero;
                }
              }
            }
          }
        }
      }
    } catch (_) {}

    return TxHistoryItem(
      txhash: txhash,
      fromAddress: sender,
      toAddress: contract,
      amountNgonka: amount,
      timestamp: timestamp,
      height: height,
      success: code == 0,
      memo: action,
      type: action == 'withdraw' ? TxType.contractWithdraw : TxType.contractDeposit,
    );
  }
}
