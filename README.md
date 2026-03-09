# Gonka Wallet

Mobile wallet for the Gonka blockchain. Built with Flutter for Android and iOS.

## Features

### Wallet Management
- Create new wallets with 24-word BIP39 mnemonic generation
- Import existing wallets from seed phrase with autocomplete
- Multiple wallets support with switching between them
- Rename and delete wallets
- Backup seed phrase display with screenshot protection

### Send & Receive
- Send GNK tokens to any gonka1... address
- QR code scanner for recipient address input
- QR code generation for receiving tokens
- Amount input in GNK or ngonka with denomination toggle
- Transaction confirmation screen with full details
- Transaction history with all types (send, receive, vesting rewards, collateral, grants, unjail, votes)

### Host Operations
- **Collateral** — deposit and withdraw collateral for node operators
- **Grant Permissions** — grant 27 ML operation permissions to an operational key (authz MsgGrant)
- **Unjail** — unjail a validator with jail status detection
- **Governance** — view proposals, tally results, and cast votes (Yes / No / Abstain / No with Veto)

### Node Management
- Auto-discovery of network nodes from seed node participant lists
- Health checks with latency measurement
- Automatic failover to healthy nodes on consecutive errors
- Manual node addition and removal
- Full network scan on demand

### Security
- 6-digit PIN with PBKDF2 hashing (100,000 iterations)
- Biometric authentication (Face ID / fingerprint)
- Auto-wipe after 5 failed PIN attempts (configurable)
- Cooldown period on failed attempts
- Root/jailbreak detection
- Screenshot and screen recording prevention for sensitive screens
- Clipboard auto-clear after 60 seconds
- Private key zeroing after use

## Technical Details

- **Chain**: gonka-mainnet
- **HD Path**: m/44'/1200'/0'/0/0
- **Address format**: gonka1... (bech32)
- **Base denom**: ngonka (1 GNK = 10^9 ngonka)
- **Signing**: SIGN_MODE_DIRECT with secp256k1
- **Protobuf**: Manual encoding without code generation
- **Fees**: Zero-fee chain

## Architecture

```
lib/
  config/         Constants and formatting
  core/
    crypto/       BIP39, BIP32, secp256k1, bech32
    network/      Node client, node manager, API endpoints
    transaction/  Protobuf encoding, tx builder, message types
  data/
    models/       Wallet, balance, node, tx history models
    repositories/ Wallet and node persistence (Hive)
    services/     Secure storage, auth, device security
  state/
    providers/    Riverpod state management
  presentation/
    screens/      All UI screens
    widgets/      Reusable widgets
```

## Build

```bash
flutter pub get
flutter run
```

### Run tests

```bash
flutter test
```

## Requirements

- Flutter SDK ^3.8.1
- Dart SDK ^3.8.1
- Android SDK / Xcode for platform builds

## License

MIT License. See [LICENSE](LICENSE) for details.
