import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../extension.dart';
import '../../providers/navigator_provider.dart';

class AppIconButton extends StatelessWidget {
  AppIconButton({
    super.key,
    required IconData icon,
    this.size = 24,
    this.onPressed,
    this.enable = true,
    this.color,
    this.disabledColor,
    this.tooltip,
    this.padding = const EdgeInsets.all(8),
  }) : icon = Icon(icon);

  const AppIconButton.widget({
    super.key,
    required this.icon,
    this.size = 24,
    this.onPressed,
    this.enable = true,
    this.color,
    this.disabledColor,
    this.tooltip,
    this.padding = const EdgeInsets.all(8),
  });

  final Widget icon;
  final double size;
  final VoidCallback? onPressed;
  final bool enable;
  final Color? color;
  final Color? disabledColor;

  final String? tooltip;

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => IconButton(
        onPressed: enable ? (onPressed ?? () {}) : null,
        icon: icon,
        iconSize: size,
        color: color ?? IconTheme.of(context).color,
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
    super.key,
    required this.icon,
    required this.text,
    this.onTap,
  });

  final Widget icon;
  final Widget text;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
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
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              child: icon,
            ),
            const SizedBox(width: 8),
            DefaultTextStyle.merge(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyLarge,
              child: text,
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}

class AppBackButton extends ConsumerWidget {
  const AppBackButton({
    super.key,
    this.size = 24,
    this.color,
  });

  final double size;

  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final IconData icon;
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      icon = FluentIcons.ios_arrow_ltr_24_regular;
    } else {
      icon = FluentIcons.arrow_left_24_regular;
    }
    return AppIconButton(
      icon: icon,
      size: size,
      color: color,
      onPressed: () {
        ref.read(navigatorProvider.notifier).back();
      },
    );
  }
}
