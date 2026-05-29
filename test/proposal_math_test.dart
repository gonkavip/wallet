import 'package:flutter_test/flutter_test.dart';
import 'package:gonka_wallet/config/constants.dart';
import 'package:gonka_wallet/core/governance/proposal_math.dart';
import 'package:gonka_wallet/core/network/node_client.dart';

TallyResult tally({int yes = 0, int no = 0, int abstain = 0, int veto = 0}) =>
    TallyResult(
      yesCount: BigInt.from(yes),
      abstainCount: BigInt.from(abstain),
      noCount: BigInt.from(no),
      noWithVetoCount: BigInt.from(veto),
    );

void main() {
  final params = GovTallyParams.defaults();

  group('computeTallyOutcome', () {
    test('active proposal: turnout and quorum computed against total bonded', () {

      final o = computeTallyOutcome(
        tally: tally(yes: 50000, no: 10000),
        params: params,
        totalBonded: BigInt.from(200000),
      );
      expect(o.hasBonded, true);
      expect(o.turnoutPct, closeTo(30.0, 0.001));
      expect(o.quorumPct, closeTo(25.0, 0.001));
      expect(o.quorumPassed, true);
    });

    test('turnout below quorum -> quorumPassed false', () {

      final o = computeTallyOutcome(
        tally: tally(yes: 20000),
        params: params,
        totalBonded: BigInt.from(200000),
      );
      expect(o.quorumPassed, false);
    });

    test('no bonded (closed proposal) -> turnout hidden, no div-by-zero', () {
      final o = computeTallyOutcome(
        tally: tally(yes: 31851, no: 9566, veto: 12961),
        params: params,
        totalBonded: BigInt.zero,
      );
      expect(o.hasBonded, false);
      expect(o.turnoutPct, 0.0);
      expect(o.quorumPassed, false);

      expect(o.yesFraction, greaterThan(0));
    });

    test('per-option fractions sum to ~1 when there are votes', () {
      final o = computeTallyOutcome(
        tally: tally(yes: 25, no: 25, abstain: 25, veto: 25),
        params: params,
        totalBonded: BigInt.from(1000),
      );
      expect(
        o.yesFraction + o.abstainFraction + o.noFraction + o.vetoFraction,
        closeTo(1.0, 0.0001),
      );
    });

    test('zero tally does not crash', () {
      final o = computeTallyOutcome(
        tally: tally(),
        params: params,
        totalBonded: BigInt.from(100000),
      );
      expect(o.totalVotes, BigInt.zero);
      expect(o.yesFraction, 0.0);
    });
  });

  group('formatWeightShort', () {
    test('millions', () {
      expect(formatWeightShort(BigInt.from(1200000)), '1.20M');
    });
    test('thousands', () {
      expect(formatWeightShort(BigInt.from(133104)), '133.1K');
    });
    test('small values use commas', () {
      expect(formatWeightShort(BigInt.from(842)), '842');
    });
  });
}
