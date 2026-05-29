import '../network/node_client.dart';

class GovTallyOutcome {
  final BigInt totalVotes;

  final bool hasBonded;
  final double turnoutPct;
  final double quorumPct;
  final bool quorumPassed;

  final double yesFraction;
  final double abstainFraction;
  final double noFraction;
  final double vetoFraction;

  GovTallyOutcome({
    required this.totalVotes,
    required this.hasBonded,
    required this.turnoutPct,
    required this.quorumPct,
    required this.quorumPassed,
    required this.yesFraction,
    required this.abstainFraction,
    required this.noFraction,
    required this.vetoFraction,
  });
}

GovTallyOutcome computeTallyOutcome({
  required TallyResult tally,
  required GovTallyParams params,
  required BigInt totalBonded,
}) {
  final total = tally.totalVotes.toDouble();
  final bonded = totalBonded.toDouble();

  final hasBonded = totalBonded > BigInt.zero;
  final turnoutPct = hasBonded ? total / bonded * 100 : 0.0;
  final quorumPct = params.quorum * 100;
  final quorumPassed = hasBonded && turnoutPct >= quorumPct;

  double frac(BigInt n) => total > 0 ? n.toDouble() / total : 0.0;

  return GovTallyOutcome(
    totalVotes: tally.totalVotes,
    hasBonded: hasBonded,
    turnoutPct: turnoutPct,
    quorumPct: quorumPct,
    quorumPassed: quorumPassed,
    yesFraction: frac(tally.yesCount),
    abstainFraction: frac(tally.abstainCount),
    noFraction: frac(tally.noCount),
    vetoFraction: frac(tally.noWithVetoCount),
  );
}
