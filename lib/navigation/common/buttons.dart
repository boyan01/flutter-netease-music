import 'package:flutter/material.dart';

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    Key? key,
    required this.icon,
    this.size = 24,
    this.onPressed,
    this.enable = true,
    this.color,
    this.disabledColor,
    this.tooltip,
    this.padding = const EdgeInsets.all(8),
  }) : super(key: key);

  final IconData icon;
  final double size;
  final VoidCallback? onPressed;
  final bool enable;
  final Color? color;
  final Color? disabledColor;

  final String? tooltip;

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => IconButton(
        onPressed: enable ? (onPressed ?? () {}) : null,
        icon: Icon(icon),
        iconSize: size,
        color: color,
        disabledColor: disabledColor,
        splashRadius: size,
        tooltip: tooltip,
        mouseCursor:
            enable ? SystemMouseCursors.click : SystemMouseCursors.basic,
        padding: padding,
      );
}
