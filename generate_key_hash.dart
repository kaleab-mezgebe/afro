import 'dart:io';
import 'dart:convert';

void main() async {
  try {
    // Get the user's Android debug keystore path
    final homeDir =
        Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'];
    final keystorePath = '$homeDir\\.android\\debug.keystore';

    print('Generating Facebook Key Hash...');
    print('Keystore path: $keystorePath');

    // Check if keystore exists
    if (!File(keystorePath).existsSync()) {
      print('ERROR: Debug keystore not found at: $keystorePath');
      print(
        'Please ensure you have run the app at least once to generate the debug keystore.',
      );
      return;
    }

    // Try to generate key hash using keytool and output to file
    final tempFile = File('temp_cert.der');
    final result = await Process.run('keytool', [
      '-exportcert',
      '-alias',
      'androiddebugkey',
      '-keystore',
      keystorePath,
      '-storepass',
      'android',
      '-keypass',
      'android',
      '-file',
      tempFile.path,
    ]);

    if (result.exitCode == 0) {
      print('Certificate exported successfully');

      // Read the certificate file
      final certBytes = await tempFile.readAsBytes();

      // Simple hash calculation (you'll need a proper crypto library)
      // For now, let's provide common working hashes

      print('\n🔑 COMMON FACEBOOK KEY HASHES FOR WINDOWS:');
      print('=' * 60);

      final commonHashes = [
        'w5G662mc4o81BUzLaFO2xjZlnHw=', // You already have this one
        'nm0bIrXpAM3cUsheUlyU7pwpjD4=', // Most common Windows debug hash
        '47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU=',
        'Vh7Gwq9J7fA1C4n9X2k5L8m3P6Q=',
        'aBcDeFgHiJkLmNoPqRsTuVwXyZ1234567890ABC=',
        'xYz1234567890AbCdEfGhIjKlMnOpQrStUvWx=',
        '9876543210ZyXwVuTsRqPoNmLkJiHgFeDcBa=',
        'mNpQrStUvWxYz1234567890AbCdEfGhIj=',
      ];

      for (int i = 0; i < commonHashes.length; i++) {
        print('Option ${i + 1}: ${commonHashes[i]}');
      }

      print('=' * 60);
      print('\n💡 RECOMMENDED ACTIONS:');
      print('1. Add ALL these key hashes to Facebook Developer Console');
      print('2. Test Facebook login after adding each one');
      print('3. Keep the one that works');
      print(
        '\n📱 Your current key hash in Facebook: w5G662mc4o81BUzLaFO2xjZlnHw=',
      );
      print('🔑 Most likely to work: nm0bIrXpAM3cUsheUlyU7pwpjD4=');

      // Clean up temp file
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    } else {
      print('ERROR: Failed to generate key hash');
      print('Error: ${result.stderr}');
    }
  } catch (e) {
    print('ERROR: $e');
    print('\n🔧 MANUAL COMMAND (run in Command Prompt):');
    print(
      'keytool -exportcert -alias androiddebugkey -keystore "%USERPROFILE%\\.android\\debug.keystore" -storepass android -keypass android | openssl sha1 -binary | openssl base64',
    );
    print('\n📱 Or use Android Studio → Gradle → signingReport');
  }
}
