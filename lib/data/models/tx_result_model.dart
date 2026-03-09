class TxResultModel {
  final String txhash;
  final int code;
  final String rawLog;

  TxResultModel({
    required this.txhash,
    required this.code,
    required this.rawLog,
  });

  bool get isSuccess => code == 0;
}
