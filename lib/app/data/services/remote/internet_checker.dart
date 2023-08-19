import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

/// A class to check the availability of an Internet connection.
class InternetChecker {
  
  /// Checks if an active Internet connection is available.
  ///
  /// Returns [true] if there is an Internet connection, [false] otherwise.
  /// If an error occurs during the check, it also returns [false].
  Future<bool> hasInternet() async {
    try {
      if (kIsWeb) {
        // If we are on a web platform, make a request to a trusted website to verify the connection.
        final response = await get(Uri.parse('www.google.com'));
        return response.statusCode == 200;
      } else {
        // If we are not on a web platform, attempt to look up the IP address of a trusted website.
        final list = await InternetAddress.lookup('google.com');
        return list.isNotEmpty && list.first.rawAddress.isNotEmpty;
      }
    } catch (e) {
      // If an error occurs during the check, assume there is no Internet connection.
      return false;
    }
  }
}
