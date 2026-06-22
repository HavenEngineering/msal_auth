import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:msal_auth/msal_auth.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<MethodCall> log;
  late dynamic Function(MethodCall) handler;

  setUp(() {
    log = [];
    handler = (_) => null;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(kMethodChannel, (call) async {
      log.add(call);
      return handler(call);
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(kMethodChannel, null);
  });

  Future<SingleAccountPca> createPca() async {
    handler = (call) {
      switch (call.method) {
        case 'createSingleAccountPca':
          return true;
        case 'clearPersistedAccount':
          return true;
        case 'signOut':
          return true;
        case 'currentAccount':
          return <String, dynamic>{
            'id': 'test-id',
            'username': 'user@example.com',
            'name': 'Test User',
          };
        default:
          return null;
      }
    };

    return SingleAccountPca.create(
      clientId: 'test-client-id',
      appleConfig:
          AppleConfig(authority: 'https://login.microsoftonline.com/common'),
    );
  }

  test(
      'Given a persisted account exists, '
      'When clearPersistedAccount is called, '
      'Then it invokes the method channel and returns true', () async {
    final pca = await createPca();

    final result = await pca.clearPersistedAccount();

    expect(result, true);
    expect(log.any((c) => c.method == 'clearPersistedAccount'), true);
  });

  test(
      'Given the native side returns null, '
      'When clearPersistedAccount is called, '
      'Then it returns false', () async {
    final pca = await createPca();

    handler = (call) {
      if (call.method == 'clearPersistedAccount') {
        return null;
      }
      return true;
    };

    final result = await pca.clearPersistedAccount();

    expect(result, false);
  });

  test(
      'Given the native side throws, '
      'When clearPersistedAccount is called, '
      'Then it throws MsalException', () async {
    final pca = await createPca();

    handler = (call) {
      if (call.method == 'clearPersistedAccount') {
        throw PlatformException(
          code: 'CLEAR_ACCOUNT_ERROR',
          message: 'Failed to clear persisted account: test error',
        );
      }
      return true;
    };

    await expectLater(
      pca.clearPersistedAccount(),
      throwsA(isA<MsalException>()),
    );
  });

  test(
      'Given a signed-in account, '
      'When signOut is called, '
      'Then it invokes the method channel and returns true', () async {
    final pca = await createPca();

    final result = await pca.signOut();

    expect(result, true);
    expect(log.any((c) => c.method == 'signOut'), true);
  });

  test(
      'Given a cached account, '
      'When currentAccount is accessed, '
      'Then it returns the deserialized Account', () async {
    final pca = await createPca();

    final account = await pca.currentAccount;

    expect(account.id, 'test-id');
    expect(account.username, 'user@example.com');
    expect(log.any((c) => c.method == 'currentAccount'), true);
  });
}
