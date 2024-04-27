import 'dart:core';
import 'dart:math';
import '../main.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keygen/widgets/checkbox.dart';
import 'package:keygen/widgets/radio_button.dart';
import 'package:keygen/database/database_connection.dart';
import 'package:keygen/widgets/saved_passwords.dart';
import 'package:keygen/security/password_encryption.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:keygen/model/keygen_model.dart';

import '../constants/app_colors.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final controller = TextEditingController();
  final List<Map<String, dynamic>> _rows = [];

  bool hasUppercase = false;
  bool hasLowercase = false;
  bool hasNumbers = false;
  bool hasSpecial = false;
  bool _isCopied = false;
  bool _isCleared = false;

  int keyLength = 0;
  int minLength = Random.secure().nextInt(6) + 4;
  int mediumLength = Random.secure().nextInt(10) + 10;
  int maxLength = Random.secure().nextInt(16) + 20;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _handleLowercaseCheckboxValueChanged(bool? value) {
    setState(() {
      hasLowercase = value!;
    });
  }

  void _handleUppercaseCheckboxValueChanged(bool? value) {
    setState(() {
      hasUppercase = value!;
    });
  }

  void _handleNumberCheckboxValueChanged(bool? value) {
    setState(() {
      hasNumbers = value!;
    });
  }

  void _handleSpecialCheckboxValueChanged(bool? value) {
    setState(() {
      hasSpecial = value!;
    });
  }

  void _handleRadioValueChanged(int? value) {
    setState(() {
      keyLength = value!;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(
            MyApp.title,
            style: TextStyle(
              fontSize: 23.0,
              fontWeight: FontWeight.normal,
              color: primaryColor,
            ),
          ),
          centerTitle: true,
        ),
        body: Container(
          padding: const EdgeInsets.only(
            left: 32.0,
            top: 32.0,
            right: 32.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                readOnly: true,
                enableInteractiveSelection: false,
                style: const TextStyle(fontSize: 17.0),
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: KeyGenModel.instance.getComplexity(keyLength,
                          hasLowercase, hasUppercase, hasNumbers, hasSpecial),
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: KeyGenModel.instance.getComplexity(keyLength,
                          hasLowercase, hasUppercase, hasNumbers, hasSpecial),
                    ),
                  ),
                  icon: IconButton(
                    onPressed: () async {
                      final row = {
                        DatabaseConnection.columnSite: '',
                        DatabaseConnection.columnUsername: '',
                        DatabaseConnection.columnPassword:
                            PasswordEncryption.encryptPassword(controller.text),
                        DatabaseConnection.columnCreatedAt:
                            DateTime.now().millisecondsSinceEpoch,
                      };
                      await DatabaseConnection.instance.insert(context, row);
                      setState(() {});
                    },
                    icon: const Icon(Icons.bookmark_add_outlined),
                  ),
                  hintText: 'Generate a secure password',
                  suffixIcon: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (!_isCleared) {
                            final password = KeyGenModel.instance.generatePassword(keyLength,
                                hasLowercase, hasUppercase, hasNumbers, hasSpecial);
                            controller.text = password;
                            setState(() {
                              _isCleared = true;
                            });
                          } else {
                            Future.delayed(const Duration(seconds: 1), () {
                              setState(() {
                                controller.clear();
                                _isCleared = false;
                              });
                            });
                          }
                        },
                        icon: _isCleared
                            ? const Icon(Icons.clear_outlined)
                            : const Icon(Icons.refresh_outlined),
                        iconSize: 28.0,
                      ),
                      IconButton(
                        icon: _isCopied
                            ? const Icon(Icons.check_outlined)
                            : const Icon(Icons.content_copy_outlined),
                        onPressed: () {
                          if (controller.text.isNotEmpty) {
                            final data = ClipboardData(text: controller.text);
                            Clipboard.setData(data);
                            setState(() {
                              _isCopied = true;
                            });
                            Future.delayed(const Duration(seconds: 2), () {
                              setState(() {
                                _isCopied = false;
                              });
                            });
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
                              desc:
                                  'Cannot copy cause there is no text to do so',
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
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 25.0,
              ),
              Row(
                children: [
                  CheckBox(
                    title: 'abc',
                    isChecked: hasLowercase,
                    onChanged: _handleLowercaseCheckboxValueChanged,
                  ),
                  const SizedBox(
                    width: 35.0,
                  ),
                  CheckBox(
                    title: 'ABC',
                    isChecked: hasUppercase,
                    onChanged: _handleUppercaseCheckboxValueChanged,
                  ),
                  const SizedBox(
                    width: 35.0,
                  ),
                  CheckBox(
                    title: '123',
                    isChecked: hasNumbers,
                    onChanged: _handleNumberCheckboxValueChanged,
                  ),
                  const SizedBox(
                    width: 35.0,
                  ),
                  CheckBox(
                    title: '@&\$',
                    isChecked: hasSpecial,
                    onChanged: _handleSpecialCheckboxValueChanged,
                  ),
                  const Spacer(),
                  RadioButton(
                    title: 'Min',
                    value: minLength,
                    groupValue: keyLength,
                    onChanged: _handleRadioValueChanged,
                  ),
                  const SizedBox(
                    width: 20.0,
                  ),
                  RadioButton(
                    title: 'Medium',
                    value: mediumLength,
                    groupValue: keyLength,
                    onChanged: _handleRadioValueChanged,
                  ),
                  const SizedBox(
                    width: 20.0,
                  ),
                  RadioButton(
                    title: 'Max',
                    value: maxLength,
                    groupValue: keyLength,
                    onChanged: _handleRadioValueChanged,
                  ),
                ],
              ),
              const SizedBox(
                height: 30.0,
              ),
              SavedPasswords(rows: _rows),
            ],
          ),
        ),
      );
}
