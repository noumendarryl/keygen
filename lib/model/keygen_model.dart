import 'dart:io';
import 'dart:math';
import '../constants/app_colors.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

class KeyGenModel {
  KeyGenModel._privateConstructor();
  static final KeyGenModel instance = KeyGenModel._privateConstructor();

  String generatePassword(int keyLength, bool hasLowercase, bool hasUppercase, bool hasNumbers, bool hasSpecial) {
    var length = keyLength;
    const lettersLowercase = 'abcdefghijklmnopqrstuvwxz';
    const lettersUppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXZ';
    const numbers = '0123456789';
    const special = '@#=+!^\$%&?(){}*';

    String chars = '';
    if (hasUppercase) chars += lettersUppercase;
    if (hasLowercase) chars += lettersLowercase;
    if (hasNumbers) chars += numbers;
    if (hasSpecial) chars += special;

    return List.generate(length, (index) {
      final indexRandom = Random.secure().nextInt(chars.length);
      return chars[indexRandom];
    }).join('');
  }

  Color getComplexity(int keyLength, bool hasLowercase, bool hasUppercase, bool hasNumbers, bool hasSpecial) {
    if (keyLength < 8) {
      if (hasLowercase && hasUppercase && hasNumbers ||
          hasLowercase && hasUppercase && hasNumbers && hasSpecial) {
        return darkOrange;
      }
      if (hasLowercase ||
          hasUppercase ||
          hasNumbers ||
          hasLowercase && hasNumbers ||
          hasUppercase && hasNumbers) return darkRed;
    }
    if (8 <= keyLength && keyLength <= 12) {
      if (hasLowercase && hasUppercase && hasNumbers && hasSpecial) {
        return darkOrange;
      }
      if (hasLowercase ||
          hasUppercase ||
          hasNumbers ||
          hasSpecial ||
          hasLowercase && hasNumbers ||
          hasUppercase && hasNumbers ||
          hasLowercase && hasNumbers && hasSpecial ||
          hasUppercase && hasNumbers && hasSpecial ||
          hasLowercase && hasUppercase && hasSpecial) return darkRed;
    }
    if (keyLength > 12) {
      if (hasLowercase && hasUppercase && hasNumbers && hasSpecial) {
        return darkGreen;
      }
      if (hasLowercase && hasUppercase && hasNumbers ||
          hasLowercase && hasUppercase && hasSpecial ||
          hasLowercase && hasNumbers && hasSpecial ||
          hasUppercase && hasNumbers && hasSpecial) return darkOrange;
      if (hasLowercase ||
          hasUppercase ||
          hasNumbers ||
          hasSpecial ||
          hasLowercase && hasUppercase ||
          hasLowercase && hasNumbers ||
          hasUppercase && hasNumbers ||
          hasLowercase && hasSpecial ||
          hasUppercase && hasSpecial ||
          hasNumbers && hasSpecial) return darkRed;
    }
    return Colors.grey;
  }

  Future<void> showAuthenticationDialog(
      BuildContext context, Function onChanged) async {
    String command = '';
    if (Platform.isWindows) {
      command =
          'runas /user:Administrator cmd /c echo "Authenticate to see or copy your password"';
    } else if (Platform.isLinux) {
      command = 'pkexec echo "Authenticate to see or copy your password"';
    } else if (Platform.isMacOS) {
      command =
          'osascript -e \'do shell script "echo \\"Authenticate to see or copy your password\\"" with administrator privileges\'';
    } else {
      AwesomeDialog(
        context: context,
        width: 500.0,
        dialogType: DialogType.error,
        animType: AnimType.topSlide,
        showCloseIcon: true,
        title: 'Oops...',
        titleTextStyle: const TextStyle(
          fontSize: 23.0,
        ),
        desc: 'Unsupported platform detected',
        descTextStyle: const TextStyle(
          fontSize: 18.0,
        ),
        btnCancelOnPress: () {},
        btnOkOnPress: () {},
        buttonsTextStyle: const TextStyle(
          fontSize: 19.0,
          fontWeight: FontWeight.normal,
          color: Colors.white,
        ),
      ).show();
    }
    ProcessResult result = await Process.run('/bin/bash', ['-c', command]);
    if (result.exitCode == 0) {
      onChanged();
    } else {
      AwesomeDialog(
        context: context,
        width: 500.0,
        dialogType: DialogType.error,
        animType: AnimType.topSlide,
        showCloseIcon: true,
        title: 'Oops...',
        titleTextStyle: const TextStyle(
          fontSize: 23.0,
        ),
        desc: 'Authentication process failed. You then won\'t be able to see or copy password',
        descTextStyle: const TextStyle(
          fontSize: 18.0,
        ),
        btnCancelOnPress: () {},
        btnOkOnPress: () {},
        buttonsTextStyle: const TextStyle(
          fontSize: 19.0,
          fontWeight: FontWeight.normal,
          color: Colors.white,
        ),
      ).show();
    }
  }
}
