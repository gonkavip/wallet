import '../../core/walletconnect/sign_direct_decoder.dart';
import '../../core/walletconnect/tx_body_decoder.dart';

class WcSignRequestView {
  final int requestId;
  final String topic;
  final String dappName;
  final String? dappIcon;
  final String walletId;
  final String signerAddress;
  final SignDirectPayload payload;
  final TxBodyDecoded txBody;

  const WcSignRequestView({
    required this.requestId,
    required this.topic,
    required this.dappName,
    required this.walletId,
    required this.signerAddress,
    required this.payload,
    required this.txBody,
    this.dappIcon,
  });

  bool get hasUnknownMessages => txBody.hasUnknownMessages;
}
