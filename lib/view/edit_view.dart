import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keygen/constants/app_colors.dart';
import 'package:keygen/database/database_connection.dart';
import 'package:keygen/model/keygen_model.dart';

class EditView extends StatefulWidget {
  final int id;
  late String password;
  final Function refreshCallback;
  EditView({
    Key? key,
    required this.id,
    required this.password,
    required this.refreshCallback,
  }) : super(key: key);

  @override
  State<EditView> createState() => _EditViewState();
}

class _EditViewState extends State<EditView> {
  bool _isVisible = true;
  bool _isCopied = false;
  bool _isAuthenticated = false;

  void _toggleCopy() {
    setState(() {
      _isCopied = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isCopied = false;
      });
    });
  }

  void _toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  void _handleIsAuthenticatedChanged() {
    setState(() {
      _isAuthenticated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    String newPassword = widget.password;

    return AlertDialog(
      title: Text(
        'Edit Password',
        style: TextStyle(color: primaryColor),
      ),
      content: SizedBox(
        width: 300.0,
        height: 100.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Password',
              style: TextStyle(fontSize: 20.0, color: tertiaryColorVariant),
            ),
            TextFormField(
              initialValue: widget.password,
              obscureText: _isVisible,
              obscuringCharacter: '•',
              onChanged: (value) => newPassword = value,
              style: const TextStyle(
                fontSize: 18.0,
              ),
              decoration: InputDecoration(
                  suffixIcon: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      if (_isAuthenticated) {
                        _toggleVisibility();
                      } else {
                        KeyGenModel.instance.showAuthenticationDialog(
                            context, _handleIsAuthenticatedChanged);
                      }
                    },
                    icon: Icon(_isVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                  ),
                  IconButton(
                    onPressed: () {
                      if (_isAuthenticated) {
                        if (newPassword.isNotEmpty) {
                          final data = ClipboardData(text: newPassword);
                          Clipboard.setData(data);
                          _toggleCopy();
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
                            desc: 'Cannot copy cause there is no text to do so',
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
                      } else {
                        KeyGenModel.instance.showAuthenticationDialog(
                            context, _handleIsAuthenticatedChanged);
                      }
                    },
                    icon: _isCopied
                        ? const Icon(Icons.check_outlined)
                        : const Icon(Icons.content_copy_outlined),
                    iconSize: 23.0,
                  ),
                ],
              )),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text(
            'Cancel',
            style: TextStyle(
              fontSize: 19.0,
              color: Colors.red,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: const Text('Save',
              style: TextStyle(
                fontSize: 19.0,
                color: Colors.blue,
              )),
          onPressed: () async {
            await DatabaseConnection.instance.updatePassword(
                widget.id, newPassword, DateTime.now().millisecondsSinceEpoch);
            widget.refreshCallback();
            Navigator.pop(context);
            if (kDebugMode) {
              print('Edited row with id: ${widget.id}');
            }
          },
        ),
      ],
    );
  }
}
