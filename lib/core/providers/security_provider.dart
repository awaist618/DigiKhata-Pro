import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class SecurityState {
  final bool isPinEnabled;
  final bool isBiometricEnabled;
  final bool isAutoLogoutEnabled;

  SecurityState({
    this.isPinEnabled = false,
    this.isBiometricEnabled = false,
    this.isAutoLogoutEnabled = true,
  });

  SecurityState copyWith({
    bool? isPinEnabled,
    bool? isBiometricEnabled,
    bool? isAutoLogoutEnabled,
  }) {
    return SecurityState(
      isPinEnabled: isPinEnabled ?? this.isPinEnabled,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      isAutoLogoutEnabled: isAutoLogoutEnabled ?? this.isAutoLogoutEnabled,
    );
  }
}

class SecurityNotifier extends StateNotifier<SecurityState> {
  final _storage = const FlutterSecureStorage();
  final _auth = LocalAuthentication();

  SecurityNotifier() : super(SecurityState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final pin = await _storage.read(key: 'user_pin');
    final bio = await _storage.read(key: 'biometric_enabled');
    final autoLogout = await _storage.read(key: 'auto_logout_enabled');
    state = state.copyWith(
      isPinEnabled: pin != null,
      isBiometricEnabled: bio == 'true',
      isAutoLogoutEnabled: autoLogout != 'false', // Default to true
    );
  }

  Future<void> toggleAutoLogout(bool enable) async {
    await _storage.write(key: 'auto_logout_enabled', value: enable.toString());
    state = state.copyWith(isAutoLogoutEnabled: enable);
  }

  Future<void> setPin(String pin) async {
    await _storage.write(key: 'user_pin', value: pin);
    state = state.copyWith(isPinEnabled: true);
  }

  Future<void> disablePin() async {
    await _storage.delete(key: 'user_pin');
    state = state.copyWith(isPinEnabled: false);
  }

  Future<bool> toggleBiometric(bool enable) async {
    if (enable) {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      
      if (!canAuthenticate) return false;

      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Please authenticate to enable biometric login',
      );

      if (didAuthenticate) {
        await _storage.write(key: 'biometric_enabled', value: 'true');
        state = state.copyWith(isBiometricEnabled: true);
        return true;
      }
      return false;
    } else {
      await _storage.write(key: 'biometric_enabled', value: 'false');
      await _storage.delete(key: 'user_email');
      await _storage.delete(key: 'user_password');
      state = state.copyWith(isBiometricEnabled: false);
      return true;
    }
  }

  Future<void> saveCredentials(String email, String password) async {
    await _storage.write(key: 'user_email', value: email);
    await _storage.write(key: 'user_password', value: password);
  }

  Future<Map<String, String>?> getStoredCredentials() async {
    final email = await _storage.read(key: 'user_email');
    final password = await _storage.read(key: 'user_password');
    if (email != null && password != null) {
      return {'email': email, 'password': password};
    }
    return null;
  }

  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Login to DigiKhata Pro using biometrics',
      );
    } catch (e) {
      return false;
    }
  }
}

final securityProvider = StateNotifierProvider<SecurityNotifier, SecurityState>((ref) {
  return SecurityNotifier();
});
