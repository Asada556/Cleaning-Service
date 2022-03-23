import 'package:cleaning_service/constants/colors.dart';
import 'package:flutter/material.dart';

class Input extends StatefulWidget {
  final String? labelText;
  final TextEditingController? controller;
  final String? initialValue;
  final bool enable;
  final Color? backgroundColor;
  final TextInputType? keyboardType;
  final int? minLines;
  final int? maxLines;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? hintText;
  final void Function(String)? onChange;
  final String? Function(String?)? validator;

  Input({
    Key? key,
    this.labelText,
    this.controller,
    this.initialValue,
    this.enable = true,
    this.backgroundColor,
    this.keyboardType,
    this.minLines,
    this.maxLines,
    this.prefixIcon,
    this.suffixIcon,
    this.hintText,
    this.onChange,
    this.validator,
  }) : super(key: key);

  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> {
  TextEditingController _controller() {
    if (widget.controller != null) {
      if (widget.initialValue != null) {
        setState(() {
          widget.controller!.text = widget.initialValue!;
        });
      }
      return widget.controller!;
    }

    return TextEditingController(text: widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        Container(
          // height: 48,
          child: TextFormField(
            controller: _controller(),
            keyboardType: widget.keyboardType,
            minLines: widget.minLines,
            maxLines: widget.maxLines,
            onChanged: widget.onChange,
            decoration: InputDecoration(
              hintText: widget.hintText,
              suffixIcon: widget.suffixIcon,
              prefix: widget.prefixIcon,
              enabled: widget.enable,
              fillColor: widget.enable
                  ? widget.backgroundColor != null
                      ? widget.backgroundColor
                      : kLightBlue
                  : Colors.grey[300],
              filled: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: BorderSide(
                  width: 0,
                  style: BorderStyle.none,
                ),
              ),
            ),
            validator: widget.validator,
          ),
        ),
      ],
    );
  }
}
