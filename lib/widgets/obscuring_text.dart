import 'package:flutter/material.dart';

class ObscuringText extends StatefulWidget {
  final String password;
  const ObscuringText({Key? key, required this.password}) : super(key: key);

  @override
  State<ObscuringText> createState() => _ObscuringTextState();
}

class _ObscuringTextState extends State<ObscuringText> {
  @override
  Widget build(BuildContext context) {
    String obscuredPassword = '•' * widget.password.length;

    return Text(
      obscuredPassword,
      style: const TextStyle(
        fontSize: 18.0,
      ),
    );
  }
}
