import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final double? width;
  final Color? color;
  final Widget child;
  final EdgeInsets? padding;
  final void Function()? onTap;

  Button({
    Key? key,
    this.width,
    this.color,
    this.padding,
    this.onTap,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {
          onTap?.call();
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: width,
          padding: padding,
          child: Center(child: child),
        ),
      ),
    );
  }
}
