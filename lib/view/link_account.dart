import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:keygen/constants/app_colors.dart';
import '../database/database_connection.dart';
import '../model/keygen_model.dart';

class LinkAccount extends StatefulWidget {
  final int id;
  final String site;
  final String username;
  final String password;
  final Function refreshCallback;
  const LinkAccount(
      {Key? key,
      required this.id,
      required this.site,
      required this.username,
      required this.password,
      required this.refreshCallback})
      : super(key: key);

  @override
  State<LinkAccount> createState() => _LinkAccountState();
}

class _LinkAccountState extends State<LinkAccount> {
  bool _isVisible = true;
  bool _isSiteCopied = false;
  bool _isUsernameCopied = false;
  bool _isPasswordCopied = false;
  bool _isAuthenticated = false;

  void _toggleCopySite() {
    setState(() {
      _isSiteCopied = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isSiteCopied = false;
      });
    });
  }

  void _toggleCopyUsername() {
    setState(() {
      _isUsernameCopied = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isUsernameCopied = false;
      });
    });
  }

  void _toggleCopyPassword() {
    setState(() {
      _isPasswordCopied = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isPasswordCopied = false;
      });
    });
  }

  void _toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  void _handleIsAuthenticatedUsernameChanged() {
    setState(() {
      _isAuthenticated = true;
    });
  }

  void _handleIsAuthenticatedPasswordChanged() {
    setState(() {
      _isAuthenticated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    String newSite = widget.site;
    String newUsername = widget.username;
    String newPassword = widget.password;

    return AlertDialog(
      title: Text(
        'Link An Account',
        style: TextStyle(color: primaryColor),
      ),
      content: SizedBox(
        width: 300.0,
        height: 300.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Text(
                  'Site',
                  style: TextStyle(fontSize: 20.0, color: tertiaryColorVariant),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.info_outline),
                  iconSize: 20.0,
                  color: tertiaryColorVariant,
                  tooltip: 'Specify http/https prefix',
                ),
              ],
            ),
            TextFormField(
              initialValue: widget.site,
              onChanged: (value) => newSite = value,
              style: TextStyle(fontSize: 18.0, color: primaryColor),
              decoration: InputDecoration(
                hintText: 'Enter a website link',
                suffixIcon: IconButton(
                  onPressed: () {
                    if (newSite.isNotEmpty) {
                      final data = ClipboardData(text: newSite);
                      Clipboard.setData(data);
                      _toggleCopySite();
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
                  },
                  icon: _isSiteCopied
                      ? const Icon(Icons.check_outlined)
                      : const Icon(Icons.content_copy_outlined),
                  iconSize: 23.0,
                ),
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            Text(
              'Username',
              style: TextStyle(fontSize: 20.0, color: tertiaryColorVariant),
            ),
            TextFormField(
              initialValue: widget.username,
              onChanged: (value) => newUsername = value,
              style: TextStyle(fontSize: 18.0, color: primaryColor),
              decoration: InputDecoration(
                hintText: 'Enter an email address',
                suffixIcon: IconButton(
                  onPressed: () {
                    if (_isAuthenticated) {
                      if (newUsername.isNotEmpty) {
                        final data = ClipboardData(text: newUsername);
                        Clipboard.setData(data);
                        _toggleCopyUsername();
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
                          context, _handleIsAuthenticatedUsernameChanged);
                    }
                  },
                  icon: _isUsernameCopied
                      ? const Icon(Icons.check_outlined)
                      : const Icon(Icons.content_copy_outlined),
                  iconSize: 23.0,
                ),
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            Text(
              'Password',
              style: TextStyle(fontSize: 20.0, color: tertiaryColorVariant),
            ),
            TextFormField(
              initialValue: widget.password,
              obscureText: _isVisible,
              obscuringCharacter: '•',
              onChanged: (value) => newPassword = value,
              style: TextStyle(fontSize: 18.0, color: primaryColor),
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
                              context, _handleIsAuthenticatedPasswordChanged);
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
                            _toggleCopyPassword();
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
                        } else {
                          KeyGenModel.instance.showAuthenticationDialog(
                              context, _handleIsAuthenticatedPasswordChanged);
                        }
                      },
                      icon: _isPasswordCopied
                          ? const Icon(Icons.check_outlined)
                          : const Icon(Icons.content_copy_outlined),
                      iconSize: 23.0,
                    ),
                  ],
                ),
              ),
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
          child: const Text(
            'Save',
            style: TextStyle(
              fontSize: 19.0,
              color: Colors.blue,
            ),
          ),
          onPressed: () async {
            await DatabaseConnection.instance.update(
                widget.id,
                newSite,
                newUsername,
                newPassword,
                DateTime.now().millisecondsSinceEpoch);
            widget.refreshCallback();
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
