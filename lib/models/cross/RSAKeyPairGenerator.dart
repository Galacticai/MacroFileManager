import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/key_generators/api.dart';
import 'package:pointycastle/key_generators/rsa_key_generator.dart';

mixin RSAKeyPairGenerator {
  static AsymmetricKeyPair<PublicKey, PrivateKey> generateKeyPair(int bitStrength) {
    // Generate RSA key pair
    final keyGen = RSAKeyGenerator()..init(ParametersWithRandom(RSAKeyGeneratorParameters(BigInt.parse('65537'), bitStrength, 64), SecureRandom()));

    final keyPair = keyGen.generateKeyPair();
    final publicKey = keyPair.publicKey as RSAPublicKey;
    final privateKey = keyPair.privateKey as RSAPrivateKey;

    return AsymmetricKeyPair<PublicKey, PrivateKey>(publicKey, privateKey);
  }
}
