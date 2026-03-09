import 'dart:typed_data';
import '../../config/constants.dart';
import 'protobuf_utils.dart';
import 'tx_message.dart';

enum VoteOption {
  yes(1),
  abstain(2),
  no(3),
  noWithVeto(4);

  final int value;
  const VoteOption(this.value);

  String get displayName => switch (this) {
        VoteOption.yes => 'Yes',
        VoteOption.abstain => 'Abstain',
        VoteOption.no => 'No',
        VoteOption.noWithVeto => 'No with Veto',
      };

  static VoteOption? fromString(String s) => switch (s) {
        'VOTE_OPTION_YES' => VoteOption.yes,
        'VOTE_OPTION_ABSTAIN' => VoteOption.abstain,
        'VOTE_OPTION_NO' => VoteOption.no,
        'VOTE_OPTION_NO_WITH_VETO' => VoteOption.noWithVeto,
        _ => null,
      };
}

class MsgVote implements TxMessage {
  final int proposalId;
  final String voter;
  final VoteOption option;

  MsgVote({
    required this.proposalId,
    required this.voter,
    required this.option,
  });

  @override
  String get typeUrl => GonkaConstants.msgVoteTypeUrl;

  @override
  Uint8List encode() {
    final writer = ProtobufWriter();
    writer.writeUint64(1, proposalId);
    writer.writeString(2, voter);
    writer.writeVarint(3, option.value);
    return writer.toBytes();
  }
}
