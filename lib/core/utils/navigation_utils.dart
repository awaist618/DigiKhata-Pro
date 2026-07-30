import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class NavigationUtils {
  static Route<T> createRoute<T>(Widget screen) {
    if (Platform.isIOS) {
      return CupertinoPageRoute<T>(builder: (_) => screen);
    } else {
      return MaterialPageRoute<T>(builder: (_) => screen);
    }
  }

  static void push<T>(BuildContext context, Widget screen) {
    Navigator.of(context).push(createRoute<T>(screen));
  }

  static void pushReplacement<T, TO>(BuildContext context, Widget screen) {
    Navigator.of(context).pushReplacement(createRoute<T>(screen));
  }
}
