import 'package:flutter/material.dart';
import 'package:phone_book/views/contact-list.dart';
import 'package:phone_book/views/login_screen.dart';
import 'package:phone_book/views/register_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String authLogin = '/auth-login';
  static const String authRegister = '/auth-register';
  static const String contactList = '/contact-list';

  static Map<String, WidgetBuilder> define() {
    return{
      authLogin: (context) => Login(),
      authRegister: (context) => Register(),

      contactList: (context) => ContactList(),
    };
  }
}