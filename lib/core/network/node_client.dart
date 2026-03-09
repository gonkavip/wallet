import 'package:dio/dio.dart';
import 'api_endpoints.dart';

class NodeClient {
  final Dio _dio;
  final String _baseUrl;
  final String _restBase;
  final String _rpcBase;

  NodeClient({
    required String nodeUrl,
    bool proxyMode = true,
  })  : _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        )),
        _baseUrl = nodeUrl,
        _restBase = proxyMode
            ? '$nodeUrl${ApiEndpoints.proxyRestPrefix}'
            : nodeUrl,
        _rpcBase = proxyMode
            ? '$nodeUrl${ApiEndpoints.proxyRpcPrefix}'
            : nodeUrl;

  Future<BigInt> getBalance(String address) async {
    final response = await _dio.get(
      '$_restBase${ApiEndpoints.balances(address)}',
    );
    final balances = response.data['balances'] as List;
    for (final b in balances) {
      if (b['denom'] == 'ngonka') {
        return BigInt.parse(b['amount']);
      }
    }
    return BigInt.zero;
  }

  Future<BigInt> getSpendableBalance(String address) async {
    final response = await _dio.get(
      '$_restBase${ApiEndpoints.spendableBalances(address)}',
    );
    final balances = response.data['balances'] as List;
    for (final b in balances) {
      if (b['denom'] == 'ngonka') {
        return BigInt.parse(b['amount']);
      }
    }
    return BigInt.zero;
  }

  Future<BigInt> getVesting(String address) async {
    try {
      final response = await _dio.get(
        '$_restBase${ApiEndpoints.totalVesting(address)}',
      );
      final totalAmount = response.data['total_amount'] as List? ?? [];
      for (final item in totalAmount) {
        if (item['denom'] == 'ngonka') {
          return BigInt.parse(item['amount'].toString());
        }
      }
      return BigInt.zero;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return BigInt.zero;
      rethrow;
    }
  }

  Future<List<TxSearchItem>> getVestingRewards(String address,
      {int limit = 50}) async {
    try {
      final url =
          '$_restBase${ApiEndpoints.txSearch}'
          '?query=vest_reward.participant%3D%27$address%27'
          '&order_by=ORDER_BY_DESC'
          '&pagination.limit=$limit';
      final response = await _dio.get(url);
      return _parseTxSearchResponse(response.data);
    } catch (_) {
      return [];
    }
  }

  Future<BigInt> getCollateral(String address) async {
    try {
      final response = await _dio.get(
        '$_restBase${ApiEndpoints.collateral(address)}',
      );
      final amount = response.data['amount'];
      if (amount != null && amount['amount'] != null) {
        return BigInt.parse(amount['amount'].toString());
      }
      return BigInt.zero;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return BigInt.zero;
      rethrow;
    }
  }

  Future<List<UnbondingEntry>> getUnbondingCollateral(String address) async {
    try {
      final response = await _dio.get(
        '$_restBase${ApiEndpoints.unbondingCollateral(address)}',
      );
      final unbondings = response.data['unbondings'] as List? ?? [];
      return unbondings.map((u) {
        final amount = u['amount'];
        final ngonka = amount != null && amount['amount'] != null
            ? BigInt.parse(amount['amount'].toString())
            : BigInt.zero;
        final epoch = int.tryParse(u['completion_epoch']?.toString() ?? '0') ?? 0;
        return UnbondingEntry(amount: ngonka, completionEpoch: epoch);
      }).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      rethrow;
    }
  }

  Future<ValidatorInfo?> getValidatorInfo(String valoperAddress) async {
    try {
      final response = await _dio.get(
        '$_restBase${ApiEndpoints.validator(valoperAddress)}',
      );
      final data = response.data;
      if (data is Map && data['code'] != null && data['code'] != 0) {
        return null;
      }
      final validator = data['validator'];
      if (validator == null) return null;
      return ValidatorInfo(
        operatorAddress: validator['operator_address']?.toString() ?? '',
        jailed: validator['jailed'] == true,
        status: validator['status']?.toString() ?? '',
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 || e.response?.statusCode == 400) {
        return null;
      }
      rethrow;
    } catch (_) {
      return null;
    }
  }

  Future<BroadcastResult?> getTxByHash(String txhash) async {
    try {
      final response = await _dio.get(
        '$_restBase${ApiEndpoints.txSearch}/$txhash',
      );
      final txResponse = response.data['tx_response'];
      if (txResponse == null) return null;
      return BroadcastResult(
        code: txResponse['code'] ?? 0,
        txhash: txResponse['txhash']?.toString() ?? txhash,
        rawLog: txResponse['raw_log']?.toString() ?? '',
      );
    } catch (_) {
      return null;
    }
  }

  Future<AccountInfo> getAccountInfo(String address) async {
    final response = await _dio.get(
      '$_restBase${ApiEndpoints.account(address)}',
    );
    final account = response.data['account'];
    final baseAccount = account['base_account'] ?? account;
    return AccountInfo(
      accountNumber: int.parse(baseAccount['account_number']?.toString() ?? '0'),
      sequence: int.parse(baseAccount['sequence']?.toString() ?? '0'),
    );
  }

  Future<NodeStatus> getNodeStatus() async {
    final stopwatch = Stopwatch()..start();
    final response = await _dio.get(
      '$_rpcBase${ApiEndpoints.rpcStatus}',
    );
    stopwatch.stop();

    final result = response.data['result'] ?? response.data;
    final syncInfo = result['sync_info'] ?? {};
    final nodeInfo = result['node_info'] ?? {};

    final blockTimeStr = syncInfo['latest_block_time']?.toString() ?? '';
    final blockTime = DateTime.tryParse(blockTimeStr);

    return NodeStatus(
      chainId: nodeInfo['network']?.toString() ?? '',
      latestHeight: int.tryParse(syncInfo['latest_block_height']?.toString() ?? '0') ?? 0,
      catchingUp: syncInfo['catching_up'] == true,
      latencyMs: stopwatch.elapsedMilliseconds,
      latestBlockTime: blockTime,
    );
  }

  Future<EpochStatus> getEpochStatus() async {
    final stopwatch = Stopwatch()..start();
    final response = await _dio.get(
      '$_baseUrl${ApiEndpoints.epochsLatest}',
    );
    stopwatch.stop();

    final data = response.data;
    return EpochStatus(
      blockHeight: int.tryParse(data['block_height']?.toString() ?? '0') ?? 0,
      epochIndex: data['latest_epoch']?['index'] ?? 0,
      phase: data['phase']?.toString() ?? '',
      latencyMs: stopwatch.elapsedMilliseconds,
    );
  }

  Future<List<String>> fetchParticipantHosts() async {
    try {
      final response = await _dio.get(
        '$_baseUrl${ApiEndpoints.participants}',
      );
      final participants =
          response.data['active_participants']?['participants'] as List? ?? [];
      final hosts = <String>{};
      for (final p in participants) {
        final url = p['inference_url']?.toString() ?? '';
        if (url.isEmpty) continue;
        try {
          final parsed = Uri.parse(url);
          final host = parsed.host;
          if (host.isNotEmpty) hosts.add(host);
        } catch (_) {}
      }
      return hosts.toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<ProposalItem>> getProposals({int? status}) async {
    try {
      final response = await _dio.get(
        '$_restBase${ApiEndpoints.proposals(status: status)}',
      );
      final proposals = response.data['proposals'] as List? ?? [];
      return proposals.map((p) => ProposalItem.fromJson(p as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<ProposalItem?> getProposal(String proposalId) async {
    try {
      final response = await _dio.get(
        '$_restBase${ApiEndpoints.proposal(proposalId)}',
      );
      final proposal = response.data['proposal'] as Map<String, dynamic>?;
      if (proposal == null) return null;
      return ProposalItem.fromJson(proposal);
    } catch (_) {
      return null;
    }
  }

  Future<List<TxSearchItem>> getVoteTxHistory(String address,
      {int limit = 50}) async {
    try {
      final url =
          '$_restBase${ApiEndpoints.txSearch}'
          '?query=message.action%3D%27/cosmos.gov.v1.MsgVote%27%20AND%20message.sender%3D%27$address%27'
          '&order_by=ORDER_BY_DESC'
          '&pagination.limit=$limit';
      final response = await _dio.get(url);
      return _parseTxSearchResponse(response.data);
    } catch (_) {
      return [];
    }
  }

  Future<List<TxSearchItem>> getGrantTxHistory(String address,
      {int limit = 50}) async {
    try {
      final url =
          '$_restBase${ApiEndpoints.txSearch}'
          '?query=message.action%3D%27/cosmos.authz.v1beta1.MsgGrant%27%20AND%20message.sender%3D%27$address%27'
          '&order_by=ORDER_BY_DESC'
          '&pagination.limit=$limit';
      final response = await _dio.get(url);
      return _parseTxSearchResponse(response.data);
    } catch (_) {
      return [];
    }
  }

  Future<List<TxSearchItem>> getUnjailTxHistory(String address,
      {int limit = 50}) async {
    try {
      final url =
          '$_restBase${ApiEndpoints.txSearch}'
          '?query=message.action%3D%27/cosmos.slashing.v1beta1.MsgUnjail%27%20AND%20message.sender%3D%27$address%27'
          '&order_by=ORDER_BY_DESC'
          '&pagination.limit=$limit';
      final response = await _dio.get(url);
      return _parseTxSearchResponse(response.data);
    } catch (_) {
      return [];
    }
  }

  Future<List<TxSearchItem>> getCollateralTxHistory(String address,
      {int limit = 50}) async {
    final results = <TxSearchItem>[];

    try {
      final url =
          '$_restBase${ApiEndpoints.txSearch}'
          '?query=message.action%3D%27/inference.collateral.MsgDepositCollateral%27%20AND%20message.sender%3D%27$address%27'
          '&order_by=ORDER_BY_DESC'
          '&pagination.limit=$limit';
      final response = await _dio.get(url);
      results.addAll(_parseTxSearchResponse(response.data));
    } catch (_) {}

    try {
      final url =
          '$_restBase${ApiEndpoints.txSearch}'
          '?query=message.action%3D%27/inference.collateral.MsgWithdrawCollateral%27%20AND%20message.sender%3D%27$address%27'
          '&order_by=ORDER_BY_DESC'
          '&pagination.limit=$limit';
      final response = await _dio.get(url);
      results.addAll(_parseTxSearchResponse(response.data));
    } catch (_) {}

    final seen = <String>{};
    final unique = <TxSearchItem>[];
    for (final item in results) {
      if (seen.add(item.txhash)) {
        unique.add(item);
      }
    }
    unique.sort((a, b) => b.height.compareTo(a.height));
    return unique;
  }

  Future<List<TxSearchItem>> getTxHistory(String address,
      {int limit = 50}) async {
    final results = <TxSearchItem>[];

    try {
      final sentUrl =
          '$_restBase${ApiEndpoints.txSearch}'
          '?query=message.action%3D%27/cosmos.bank.v1beta1.MsgSend%27%20AND%20message.sender%3D%27$address%27'
          '&order_by=ORDER_BY_DESC'
          '&pagination.limit=$limit';
      final sentResponse = await _dio.get(sentUrl);
      results.addAll(_parseTxSearchResponse(sentResponse.data));
    } catch (_) {}

    try {
      final recvUrl =
          '$_restBase${ApiEndpoints.txSearch}'
          '?query=transfer.recipient%3D%27$address%27'
          '&order_by=ORDER_BY_DESC'
          '&pagination.limit=$limit';
      final recvResponse = await _dio.get(recvUrl);
      results.addAll(_parseTxSearchResponse(recvResponse.data));
    } catch (_) {}

    final seen = <String>{};
    final unique = <TxSearchItem>[];
    for (final item in results) {
      if (seen.add(item.txhash)) {
        unique.add(item);
      }
    }
    unique.sort((a, b) => b.height.compareTo(a.height));
    return unique;
  }

  List<TxSearchItem> _parseTxSearchResponse(dynamic data) {
    final items = <TxSearchItem>[];
    if (data is! Map<String, dynamic>) return items;
    final txResponses = data['tx_responses'] as List? ?? [];
    final txs = data['txs'] as List? ?? [];
    for (var i = 0; i < txResponses.length; i++) {
      final txResponse = txResponses[i] as Map<String, dynamic>;
      final tx = i < txs.length ? txs[i] as Map<String, dynamic> : <String, dynamic>{};
      items.add(TxSearchItem(
        tx: tx,
        txResponse: txResponse,
      ));
    }
    return items;
  }

  Future<BroadcastResult> broadcastTx(String base64TxBytes) async {
    final response = await _dio.post(
      '$_restBase${ApiEndpoints.broadcastTx}',
      data: {
        'tx_bytes': base64TxBytes,
        'mode': 'BROADCAST_MODE_SYNC',
      },
    );
    final txResponse = response.data['tx_response'];
    return BroadcastResult(
      code: txResponse['code'] ?? 0,
      txhash: txResponse['txhash'] ?? '',
      rawLog: txResponse['raw_log'] ?? '',
    );
  }

  void dispose() {
    _dio.close();
  }
}

class AccountInfo {
  final int accountNumber;
  final int sequence;
  AccountInfo({required this.accountNumber, required this.sequence});
}

class NodeStatus {
  final String chainId;
  final int latestHeight;
  final bool catchingUp;
  final int latencyMs;
  final DateTime? latestBlockTime;
  NodeStatus({
    required this.chainId,
    required this.latestHeight,
    required this.catchingUp,
    required this.latencyMs,
    this.latestBlockTime,
  });

  bool get isHealthy => !catchingUp;
}

class EpochStatus {
  final int blockHeight;
  final int epochIndex;
  final String phase;
  final int latencyMs;
  EpochStatus({
    required this.blockHeight,
    required this.epochIndex,
    required this.phase,
    required this.latencyMs,
  });
}

class BroadcastResult {
  final int code;
  final String txhash;
  final String rawLog;
  BroadcastResult({required this.code, required this.txhash, required this.rawLog});

  bool get isSuccess => code == 0;
}

class UnbondingEntry {
  final BigInt amount;
  final int completionEpoch;
  UnbondingEntry({required this.amount, required this.completionEpoch});
}

class ValidatorInfo {
  final String operatorAddress;
  final bool jailed;
  final String status;
  ValidatorInfo({
    required this.operatorAddress,
    required this.jailed,
    required this.status,
  });
}

class TxSearchItem {
  final Map<String, dynamic> tx;
  final Map<String, dynamic> txResponse;

  TxSearchItem({required this.tx, required this.txResponse});

  String get txhash => txResponse['txhash']?.toString() ?? '';
  int get height =>
      int.tryParse(txResponse['height']?.toString() ?? '0') ?? 0;
}

class TallyResult {
  final BigInt yesCount;
  final BigInt abstainCount;
  final BigInt noCount;
  final BigInt noWithVetoCount;

  TallyResult({
    required this.yesCount,
    required this.abstainCount,
    required this.noCount,
    required this.noWithVetoCount,
  });

  BigInt get totalVotes => yesCount + abstainCount + noCount + noWithVetoCount;

  factory TallyResult.fromJson(Map<String, dynamic> json) {
    return TallyResult(
      yesCount: BigInt.tryParse(json['yes_count']?.toString() ?? '0') ?? BigInt.zero,
      abstainCount: BigInt.tryParse(json['abstain_count']?.toString() ?? '0') ?? BigInt.zero,
      noCount: BigInt.tryParse(json['no_count']?.toString() ?? '0') ?? BigInt.zero,
      noWithVetoCount: BigInt.tryParse(json['no_with_veto_count']?.toString() ?? '0') ?? BigInt.zero,
    );
  }

  factory TallyResult.zero() => TallyResult(
        yesCount: BigInt.zero,
        abstainCount: BigInt.zero,
        noCount: BigInt.zero,
        noWithVetoCount: BigInt.zero,
      );
}

class ProposalItem {
  final String id;
  final String title;
  final String summary;
  final String status;
  final String proposer;
  final DateTime? submitTime;
  final DateTime? votingStartTime;
  final DateTime? votingEndTime;
  final TallyResult tally;
  final String metadata;
  final String messageType;

  ProposalItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.status,
    required this.proposer,
    this.submitTime,
    this.votingStartTime,
    this.votingEndTime,
    required this.tally,
    this.metadata = '',
    this.messageType = '',
  });

  bool get isVotingPeriod => status == 'PROPOSAL_STATUS_VOTING_PERIOD';
  bool get isPassed => status == 'PROPOSAL_STATUS_PASSED';
  bool get isRejected => status == 'PROPOSAL_STATUS_REJECTED';

  factory ProposalItem.fromJson(Map<String, dynamic> json) {
    final messages = json['messages'] as List? ?? [];
    final messageType = messages.isNotEmpty
        ? (messages[0]['@type']?.toString() ?? '')
        : '';

    final tallyJson = json['final_tally_result'] as Map<String, dynamic>? ?? {};

    return ProposalItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      proposer: json['proposer']?.toString() ?? '',
      submitTime: DateTime.tryParse(json['submit_time']?.toString() ?? ''),
      votingStartTime: DateTime.tryParse(json['voting_start_time']?.toString() ?? ''),
      votingEndTime: DateTime.tryParse(json['voting_end_time']?.toString() ?? ''),
      tally: TallyResult.fromJson(tallyJson),
      metadata: json['metadata']?.toString() ?? '',
      messageType: messageType,
    );
  }
}
