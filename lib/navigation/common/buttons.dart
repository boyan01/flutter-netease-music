import 'package:flutter/material.dart';
import '../../component.dart';

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

class PlaylistIconTextButton extends StatelessWidget {
  const PlaylistIconTextButton({
    Key? key,
    required this.icon,
    required this.text,
    this.onTap,
  }) : super(key: key);

  final Widget icon;
  final Widget text;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor, width: 1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        mouseCursor:
            onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 12),
            IconTheme.merge(
              data: IconThemeData(
                size: 16,
                color: Theme.of(context).textTheme.bodyText1?.color,
              ),
              child: icon,
            ),
            const SizedBox(width: 8),
            DefaultTextStyle.merge(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyText1,
              child: text,
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
