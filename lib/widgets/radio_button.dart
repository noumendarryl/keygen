import 'package:flutter/material.dart';
import 'package:keygen/constants/app_colors.dart';

class RadioButton extends StatefulWidget {
  final String title;
  final int value;
  final int groupValue;
  final ValueChanged<int?> onChanged;
  const RadioButton(
      {Key? key,
      required this.title,
      required this.value,
      required this.groupValue,
      required this.onChanged})
      : super(key: key);

  @override
  State<RadioButton> createState() => _RadioButtonState();
}

class _RadioButtonState extends State<RadioButton> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Radio(
          value: widget.value,
          groupValue: widget.groupValue,
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
