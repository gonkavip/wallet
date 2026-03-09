class ApiEndpoints {
  static const String proxyRestPrefix = '/chain-api';
  static const String proxyRpcPrefix = '/chain-rpc';

  static const int directRestPort = 1317;
  static const int directRpcPort = 26657;
  static const int defaultNodePort = 8000;

  static String balances(String address) =>
      '/cosmos/bank/v1beta1/balances/$address';
  static String spendableBalances(String address) =>
      '/cosmos/bank/v1beta1/spendable_balances/$address';

  static String totalVesting(String address) =>
      '/productscience/inference/streamvesting/total_vesting/$address';
  static String vestingSchedule(String address) =>
      '/productscience/inference/streamvesting/vesting_schedule/$address';

  static String collateral(String address) =>
      '/productscience/inference/collateral/collateral/$address';
  static String unbondingCollateral(String address) =>
      '/productscience/inference/collateral/unbonding/$address';
  static const String collateralParams =
      '/productscience/inference/collateral/params';

  static String validator(String valoperAddress) =>
      '/cosmos/staking/v1beta1/validators/$valoperAddress';

  static String account(String address) =>
      '/cosmos/auth/v1beta1/accounts/$address';

  static const String broadcastTx = '/cosmos/tx/v1beta1/txs';
  static const String txSearch = '/cosmos/tx/v1beta1/txs';

  static const String rpcStatus = '/status';

  static String proposals({int? status}) =>
      '/cosmos/gov/v1/proposals${status != null ? '?proposal_status=$status&pagination.limit=50&pagination.reverse=true' : '?pagination.limit=50&pagination.reverse=true'}';
  static String proposal(String id) => '/cosmos/gov/v1/proposals/$id';
  static String proposalTally(String id) => '/cosmos/gov/v1/proposals/$id/tally';

  static const String participants = '/v1/epochs/current/participants';
  static const String epochsLatest = '/v1/epochs/latest';
}
