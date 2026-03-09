// ignore_for_file: implementation_imports
import 'package:bip39/bip39.dart' as bip39;
import 'package:bip39/src/wordlists/english.dart' as english;

class MnemonicService {
  static String generate() {
    return bip39.generateMnemonic(strength: 256);
  }

  static bool validate(String mnemonic) {
    return bip39.validateMnemonic(mnemonic);
  }

  static List<int> toSeed(String mnemonic, {String passphrase = ''}) {
    return bip39.mnemonicToSeed(mnemonic, passphrase: passphrase);
  }

  static List<String> get wordList => english.WORDLIST;
}
