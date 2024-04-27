import 'package:flutter/material.dart';
import 'package:keygen/constants/app_colors.dart';

class CheckBox extends StatefulWidget {
  final String title;
  final bool isChecked;
  final ValueChanged<bool?> onChanged;
  const CheckBox(
      {Key? key,
      required this.title,
      required this.isChecked,
      required this.onChanged})
      : super(key: key);

  @override
  State<CheckBox> createState() => _CheckBoxState();
}

class _CheckBoxState extends State<CheckBox> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: widget.isChecked,
          onChanged: widget.onChanged,
        ),
        const SizedBox(
          width: 10.0,
        ),
        Text(
          widget.title,
          style: TextStyle(
            fontSize: 20.0,
            color: tertiaryColorVariant,
          ),
        ),
      ],
    );
  }
}
