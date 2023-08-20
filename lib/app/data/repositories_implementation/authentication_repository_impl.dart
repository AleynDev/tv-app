import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/either.dart';
import '../../domain/enums.dart';
import '../../domain/models/user.dart';
import '../../domain/repositories/authentication_repository.dart';
import '../services/remote/authentication_api.dart';

const _key = 'sessionId';

class AuthenticationRepositoryImpl implements AuthenticationRepository {
  final FlutterSecureStorage _secureStorage;
  final AuthenticationAPI _authenticationAPI;

  AuthenticationRepositoryImpl(
    this._secureStorage,
    this._authenticationAPI,
  );

  @override
  Future<User?> getUserData() {
    return Future.value(
      User(),
    );
  }

  @override
  Future<bool> get isSignedIn async {
    final sessionId = await _secureStorage.read(key: _key);
    return sessionId != null;
  }

  @override
  Future<Either<SignInFailure, User>> signIn(
    String username,
    String password,
  ) async {
    final requestToken = await _authenticationAPI.createResquetToken();

    if (requestToken == null) {
      return Either.left(SignInFailure.unknown);
    }

    final loginResult = await _authenticationAPI.createSessionWihtLogin(
      username: username,
      password: password,
      requestToken: requestToken,
    );

    return loginResult.when(
      (failure) async => Either.left(failure),
      (newRequestToken) async {
        final sessionResult = await _authenticationAPI.createSession(
          requestTokenWihtLogin: newRequestToken,
        );

        return sessionResult.when(
          (failure) async => Either.left(failure),
          (sessionId) async {
            await _secureStorage.write(
              key: _key,
              value: sessionId,
            );

            return Either.right(
              User(),
            );
          },
        );
      },
    );
  }

  @override
  Future<void> signOut() async {
    await _secureStorage.delete(key: _key);
  }
}
