part of 'public_client_application.dart';

/// This class is used to create public client application for single account
/// mode.
class SingleAccountPca extends PublicClientApplication {
  SingleAccountPca._create();

  /// Creates single account public client application.
  static Future<SingleAccountPca> create({
    /// Client id of the application.
    required String clientId,

    /// Android configuration, required for android platform.
    AndroidConfig? androidConfig,

    /// Apple configuration, required for iOS & MacOS platform.
    AppleConfig? appleConfig,
  }) async {
    try {
      final arguments = await Utils.createPcaArguments(
        clientId: clientId,
        androidConfig: androidConfig,
        appleConfig: appleConfig,
      );
      await kMethodChannel.invokeMethod('createSingleAccountPca', arguments);
      return SingleAccountPca._create();
    } on PlatformException catch (e) {
      throw e.convertToMsalException();
    }
  }

  /// Gets the current account from the cache. if no account is available, it
  /// will throw an exception.
  Future<Account> get currentAccount async {
    try {
      final result = await kMethodChannel.invokeMethod('currentAccount');
      return Account.fromJson(result.cast<String, dynamic>());
    } on PlatformException catch (e) {
      throw e.convertToMsalException();
    }
  }

  Future<bool> get isSharedDevice async {
    try {
      final result = await kMethodChannel.invokeMethod('isSharedDevice');
      return result;
    } on PlatformException catch (e) {
      throw e.convertToMsalException();
    }
  }

  /// Signs out the current account and credentials (tokens).
  /// NOTE: If a device is marked as a shared device within broker,
  /// sign out will be device wide.
  Future<bool> signOut() async {
    try {
      final result = await kMethodChannel.invokeMethod('signOut');
      return result;
    } on PlatformException catch (e) {
      throw e.convertToMsalException();
    }
  }

  /// Clears the persisted account from MSAL's local cache (Android only).
  ///
  /// Use this when the device enters a state where [signOut] fails because
  /// the broker no longer recognizes the cached account, and [acquireToken]
  /// throws a "current_account_mismatch" error. Calling this method removes
  /// the stale account entry from SharedPreferences, allowing a fresh
  /// interactive login.
  ///
  /// On iOS this is a no-op since the equivalent state does not occur.
  Future<bool> clearPersistedAccount() async {
    try {
      final result =
          await kMethodChannel.invokeMethod('clearPersistedAccount');
      return result ?? true;
    } on PlatformException catch (e) {
      throw e.convertToMsalException();
    }
  }
}
