import 'package:reown_walletkit/reown_walletkit.dart';
import '../../data/models/wc_proposal_view.dart';
import 'wc_constants.dart';

class WcNamespaceBuilder {
  static WcValidationResult validateProposal(ProposalData proposal) {
    final required = proposal.requiredNamespaces;
    if (required.isEmpty) {
      return WcValidationResult.ok;
    }

    final cosmos = required[WcConstants.cosmosNamespace];
    if (cosmos == null) {
      return WcValidationResult.noRequiredNamespace;
    }

    final chains = cosmos.chains ?? const <String>[];
    for (final chain in chains) {
      if (chain != WcConstants.caipChainId) {
        return WcValidationResult.unsupportedChain;
      }
    }

    for (final method in cosmos.methods) {
      if (!WcConstants.supportedMethods.contains(method)) {
        return WcValidationResult.unsupportedMethod;
      }
    }

    return WcValidationResult.ok;
  }

  static Map<String, Namespace> buildApprovedNamespaces({
    required String walletAddress,
  }) {
    final account =
        '${WcConstants.caipChainId}:$walletAddress';
    return {
      WcConstants.cosmosNamespace: Namespace(
        accounts: [account],
        methods: WcConstants.supportedMethods,
        events: WcConstants.supportedEvents,
        chains: const [WcConstants.caipChainId],
      ),
    };
  }
}
