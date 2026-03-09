class BalanceModel {
  final BigInt spendable;
  final BigInt vesting;

  BalanceModel({
    required this.spendable,
    required this.vesting,
  });

  BigInt get total => spendable + vesting;

  factory BalanceModel.zero() => BalanceModel(
        spendable: BigInt.zero,
        vesting: BigInt.zero,
      );
}
