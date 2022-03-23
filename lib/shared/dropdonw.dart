import 'package:cleaning_service/constants/colors.dart';
import 'package:flutter/material.dart';

class DropdownOption {
  final String title;
  final String value;

  DropdownOption({
    required this.title,
    required this.value,
  });
}

class Dropdown extends StatefulWidget {
  final void Function(String?)? onChange;
  final List<DropdownOption> options;
  final String? labelText;
  final String? selectValue;

  Dropdown({
    Key? key,
    required this.options,
    this.onChange,
    this.labelText,
    this.selectValue,
  }) : super(key: key);

  @override
  _DropdownState createState() => _DropdownState();
}

class _DropdownState extends State<Dropdown> {
  String? _value;

  List<DropdownMenuItem<String>> _items() {
    return widget.options.map((e) {
      return DropdownMenuItem(
        value: e.value,
        child: Text(e.title),
      );
    }).toList();
  }

  @override
  void initState() {
    if (widget.selectValue != null) {
      setState(() {
        _value = widget.selectValue;
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        widget.labelText != null
            ? Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  widget.labelText!,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              )
            : SizedBox(),
        DecoratedBox(
          decoration: BoxDecoration(
            color: kLightBlue,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButton(
              value: _value,
              onChanged: (String? newValue) {
                setState(() {
                  _value = newValue;
                  widget.onChange?.call(_value);
                });
              },
              isExpanded: true,
              items: _items(),
              underline: SizedBox(),
            ),
          ),
        ),
      ],
    );
  }
}
