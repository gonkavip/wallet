# Gonka Wallet

Secure, self-custody wallet for the Gonka blockchain. Built with Flutter for iOS, Android, macOS, and Windows.

<p align="center">
  <a href="https://wallet.gonka.vip/">
    <img src="https://img.shields.io/badge/Website-wallet.gonka.vip-3b82f6?style=for-the-badge&logo=google-chrome&logoColor=white" alt="Website">
  </a>
</p>

<p align="center">
  <a href="https://apps.apple.com/us/app/gonka-wallet/id6760277065"><img src="https://img.shields.io/badge/App_Store-0D96F6?style=for-the-badge&logo=app-store&logoColor=white" alt="App Store"></a>&nbsp;&nbsp;&nbsp;<a href="https://play.google.com/store/apps/details?id=com.dutiap.gonkawallet"><img src="https://img.shields.io/badge/Google_Play-414141?style=for-the-badge&logo=google-play&logoColor=white" alt="Google Play"></a>&nbsp;&nbsp;&nbsp;<a href="https://wallet.gonka.vip/download/GonkaWallet.dmg"><img src="https://img.shields.io/badge/macOS-000000?style=for-the-badge&logo=apple&logoColor=white" alt="macOS"></a>&nbsp;&nbsp;&nbsp;<a href="https://wallet.gonka.vip/download/GonkaWallet.exe"><img src="https://img.shields.io/badge/Windows-0078D4?style=for-the-badge&logo=data:image/svg%2Bxml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCI+PHBhdGggZmlsbD0id2hpdGUiIGQ9Ik0wIDMuNDQ5TDkuNzUgMi4xdjkuNDUxSDBtMTAuOTQ5LTkuNjAyTDI0IDB2MTEuNEgxMC45NDlNMCAxMi42aDkuNzV2OS40NTFMMCAyMC42OTlNMTAuOTQ5IDEyLjZIMjRWMjRsLTEyLjktMS44MDEiLz48L3N2Zz4%3D&logoColor=white" alt="Windows"></a>
</p>

## Features

### Wallet Management
- Create new wallets with 24-word BIP39 mnemonic generation
- Import existing wallets from seed phrase (word-by-word or paste full phrase)
- Import wallets from raw private key (hex, with or without 0x prefix)
- Export private key from wallet detail (biometric/PIN gated, secure screen enabled)
- Export public key (base64) from miners menu
- Multiple wallets support with switching between them
- Rename and delete wallets
- Backup seed phrase display with screenshot protection (hidden for private-key-only wallets)

### Send & Receive
- Send GNK tokens to any gonka1... address
- QR code scanner for recipient address input (clipboard paste on desktop)
- QR code generation for receiving tokens
- Amount input in GNK or ngonka with denomination toggle
- Thousands separator formatting for all amounts
- Smart GNK display: 2 decimal digits for whole amounts, variable precision for fractional
- Automatic comma-to-dot conversion for decimal separator (ru/es/pt keyboards)
- Transaction confirmation screen with full details
- Transaction history with all types: send, receive, vesting rewards, collateral, grants, unjail, votes, smart contract interactions
- Copy-to-clipboard for transaction hashes

### Smart Contract Support
- Automatic detection of MsgExecuteContract transactions
- Contract deposit and withdraw history tracking
- Detailed contract interaction view with action type, contract address, and amounts

### Host Operations
- **Collateral** — deposit and withdraw collateral for node operators
- **Grant Permissions** — grant 27 ML operation permissions to an operational key (authz MsgGrant)
- **Unjail** — unjail a validator with jail status detection
- **Governance** — view proposals, tally results, and cast votes (Yes / No / Abstain / No with Veto)
- **Tracker** — link to professional dashboard at tracker.gonka.vip

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
- Root/jailbreak detection (mobile)
- Screenshot and screen recording prevention for sensitive screens (mobile)
- Clipboard auto-clear after 60 seconds
- Private key zeroing after use

### Desktop Support
- Native macOS and Windows builds
- Responsive layout with max-width constraint for wide displays
- Desktop-adapted PIN entry with text field input
- Clipboard paste instead of QR scanner on desktop
- Platform-aware lifecycle management
- macOS Keychain integration for secure storage

### Localization
- 5 languages: English, Русский, Español, Português, 中文 (简体)
- Runtime language switching with persisted selection
- Priority: saved preference → system locale → English fallback
- Per-app language support on Android 13+ (locales_config.xml)
- Native platform name localization (iOS/macOS CFBundleDisplayName)

### Design System
- Unified Material 3 dark theme built on design tokens
- Centralized color palette, gradients, radii, and shadows (GonkaColors / GonkaGradients)
- Reusable branded widgets: GlassCard, GlowBackground, GradientText, StatusPill,
  ResultIcon, TxHashDisplay, InfoBanner
- PIN lock implemented as overlay Stack (preserves navigation history on resume)

### Legal
- Terms of Use and Privacy Policy links on onboarding and settings screens

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
  config/         Constants, formatting, design tokens, theme, input formatters
  core/
    crypto/       BIP39, BIP32, secp256k1, bech32, private key utilities
    network/      Node client, node manager, API endpoints
    transaction/  Protobuf encoding, tx builder, message types
    platform_util Platform detection (desktop vs mobile)
  data/
    models/       Wallet, balance, node, tx history models
    repositories/ Wallet, node, and settings persistence (Hive)
    services/     Secure storage, auth, device security
  state/
    providers/    Riverpod state management (wallet, tx, locale, ...)
  l10n/           ARB files for en/ru/es/pt/zh-Hans + generated AppLocalizations
  presentation/
    error_l10n    Technical exception → localized message mapping
    screens/      All UI screens
    widgets/      Reusable widgets (gonka_widgets, responsive_center, ...)
```

## Build

```bash
flutter pub get
flutter run
```

### Platform-specific builds

```bash
# iOS
flutter build ios

# Android
flutter build apk

# macOS
flutter build macos

# Windows
flutter build windows
```

### Run tests

```bash
flutter test
```

## Requirements

- Flutter SDK ^3.8.1
- Dart SDK ^3.8.1
- Android SDK / Xcode / Visual Studio for platform builds

## License

MIT License. See [LICENSE](LICENSE) for details.
