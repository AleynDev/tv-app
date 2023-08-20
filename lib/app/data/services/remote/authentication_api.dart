import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

import '../../../domain/either.dart';
import '../../../domain/enums.dart';

class AuthenticationAPI {
  final Client _client;
  final _apiKey = '5956a6e4478e6b1d4a8a65c0f6d6721e';
  final _baseUrl = 'https://api.themoviedb.org/3';

  AuthenticationAPI(this._client);

  Future<String?> createResquetToken() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/authentication/token/new?api_key=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = Map<String, dynamic>.from(
          jsonDecode(response.body),
        );

        return jsonResponse['request_token'];
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Either<SignInFailure, String>> createSessionWihtLogin({
    required String username,
    required String password,
    required String requestToken,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse(
            '$_baseUrl/authentication/token/validate_with_login?api_key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
          'request_token': requestToken,
        }),
      );

      switch (response.statusCode) {
        case 200:
          final jsonResponse = Map<String, dynamic>.from(
            jsonDecode(response.body),
          );
          final newRequestToken = jsonResponse['request_token'];
          return Either.right(newRequestToken);

        case 401:
          return Either.left(SignInFailure.unauthorized);

        case 400:
          return Either.left(SignInFailure.notFound);

        default:
          return Either.left(SignInFailure.unknown);
      }
    } catch (e) {
      if (e is SocketException) {
        return Either.left(SignInFailure.network);
      }

      return Either.left(SignInFailure.unknown);
    }
  }

  Future<Either<SignInFailure, String>> createSession({
    required String requestTokenWihtLogin,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/authentication/session/new?api_key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'request_token': requestTokenWihtLogin,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = Map<String, dynamic>.of(
          jsonDecode(response.body),
        );

        return Either.right(jsonResponse['session_id']);
      }

      return Either.left(SignInFailure.unknown);
    } catch (e) {
      if (e is SocketException) {
        return Either.left(SignInFailure.network);
      }

      return Either.left(SignInFailure.unknown);
    }
  }
}
