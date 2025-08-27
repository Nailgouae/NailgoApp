import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LocalizationChecker {
  static void changeLanguage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text('English'),
                onTap: () {
                  _setLanguage(context, Locale('en', 'US'));
                },
              ),
              ListTile(
                title: Text('Arabic'),
                onTap: () {
                  _setLanguage(context, Locale('ar', 'AE'));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static void _setLanguage(BuildContext context, Locale locale) {
    EasyLocalization.of(context)!.setLocale(locale);
    Navigator.pop(context); 
  }
}
