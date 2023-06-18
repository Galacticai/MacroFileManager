import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/api.dart' show AsymmetricKeyPair, PrivateKey, PublicKey;
import 'package:rsa_encrypt/rsa_encrypt.dart' show RsaKeyHelper;

import 'SimplePair.dart';

class Key {
  /// Generate new RSA [AsymmetricKeyPair]
  static Future<AsymmetricKeyPair<PublicKey, PrivateKey>> generate() {
    var helper = RsaKeyHelper();
    return helper.computeRSAKeyPair(helper.getSecureRandom());
  }

  /// Stores the keys in the secure storage
  ///
  /// ⚠️ This overwrites the existing keys
  static Future<void> store(String privateKey, String publicKey) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: "privateKey", value: privateKey);
    await storage.write(key: "publicKey", value: publicKey);
  }

  /// Stores the keys in the secure storage
  ///
  /// ⚠️ This overwrites the existing keys
  static Future<void> storeSimplePair(SimplePair pair) async {
    await store(pair.privateKey, pair.publicKey);
  }

  /// Get the private key from the secure storage or null if it doesn't exist
  static Future<String?> getPrivate({FlutterSecureStorage? storageInstance}) async {
    return await (storageInstance ?? const FlutterSecureStorage()).read(key: "privateKey");
  }

  /// Get the public key from the secure storage or null if it doesn't exist
  static Future<String?> getPublic({FlutterSecureStorage? storageInstance}) async {
    return await (storageInstance ?? const FlutterSecureStorage()).read(key: "publicKey");
  }

  /// Gets the keys from the secure storage, otherwise returns an error if the keys were not found
  static Future<SimplePair> getSimplePair({bool generateIfMissing = false, FlutterSecureStorage? storageInstance}) async {
    const storage = FlutterSecureStorage();

    String? privateKey = await getPrivate(storageInstance: storage);
    if (privateKey == null && !generateIfMissing) throw StateError("Private key not found");

    String? publicKey = await getPublic(storageInstance: storage);
    if (publicKey == null && !generateIfMissing) throw StateError("Public key not found");

    if ((privateKey == null || publicKey == null) && generateIfMissing) {
      final pair = await generate();
      privateKey = pair.privateKey.toString();
      publicKey = pair.publicKey.toString();
      await store(privateKey, publicKey);
    }

    return SimplePair(privateKey!, publicKey!);
  }

  /// Gets the keys from the secure storage, otherwise returns an error if the keys were not found
  static Future<AsymmetricKeyPair<PublicKey, PrivateKey>> get({bool generateIfMissing = false}) async {
    const storage = FlutterSecureStorage();
    final SimplePair pair = await getSimplePair(generateIfMissing: generateIfMissing, storageInstance: storage);

    final helper = RsaKeyHelper();
    final PrivateKey privateKey = helper.parsePrivateKeyFromPem(pair.privateKey);
    final PublicKey publicKey = helper.parsePublicKeyFromPem(pair.publicKey);

    return AsymmetricKeyPair<PublicKey, PrivateKey>(publicKey, privateKey);
  }
}
