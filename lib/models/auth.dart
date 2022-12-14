import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/exceptions/auth_exception.dart';
import 'package:shop/utils/constants.dart';

import '../data/store.dart';

class Auth with ChangeNotifier {
  String? _token;
  String? _email;
  String? _userId;
  DateTime? _expiryDate;
  Timer? _logoutTimer;

  bool get isAuth {
    final isValid = _expiryDate?.isAfter(DateTime.now()) ?? false;
    return (_token != null) && (isValid);
  }

  String? get token {
    return isAuth ? _token : null;
  }

  String? get email {
    return isAuth ? _email : null;
  }

  String? get userId {
    return isAuth ? _userId : null;
  }

  Future<void> _executeSign(String email, String password, String url) async {
    final response = await http.post(
      Uri.parse(url),
      body: jsonEncode(
        {
          'email': email,
          'password': password,
          'returnSecureToken': true,
        },
      ),
    );

    final body = jsonDecode(response.body);

    if (body['error'] != null) {
      throw AuthException(key: body['error']['message']);
    }

    _token = body['idToken'];
    _email = body['email'];
    _userId = body['localId'];
    _expiryDate = DateTime.now().add(
      Duration(seconds: int.parse(body['expiresIn'])),
    );

    Store.saveMap('userData', {
      'token': _token,
      'email': _email,
      'userId': _userId,
      'expiryDate': _expiryDate!.toIso8601String(),
    });

    _autoLogout(int.parse(body['expiresIn']));
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    return _executeSign(email, password, Constants.signInBaseUrl);
  }

  Future<void> signup(String email, String password) async {
    return _executeSign(email, password, Constants.signUpBaseUrl);
  }

  Future<void> tryAutoLogin() async {
    if (isAuth) return;

    final userData = await Store.getMap('userData');
    if (userData.isEmpty) return;

    final expiryDate = DateTime.parse(userData['expiryDate']);
    if (expiryDate.isBefore(DateTime.now())) return;

    _token = userData['token'];
    _email = userData['email'];
    _userId = userData['userId'];
    _expiryDate = expiryDate;

    _autoLogout(expiryDate.difference(DateTime.now()).inSeconds);
    notifyListeners();
  }

  void logout() {
    _token = null;
    _email = null;
    _userId = null;
    _expiryDate = null;

    Store.remove('userData');
    _clearAutoLogoutTimer();
    notifyListeners();
  }

  void _clearAutoLogoutTimer() {
    _logoutTimer?.cancel();
    _logoutTimer = null;
  }

  void _autoLogout(int duration) {
    _clearAutoLogoutTimer();
    _logoutTimer = Timer(Duration(seconds: duration), logout);
  }
}
