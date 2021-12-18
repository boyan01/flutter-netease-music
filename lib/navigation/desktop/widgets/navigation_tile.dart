import 'package:flutter/material.dart';
import 'package:quiet/component.dart';

class NavigationTile extends StatelessWidget {
  const NavigationTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  final Widget icon;

  final Widget title;

  final bool isSelected;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: isSelected
                ? context.colorScheme.onSurface.withOpacity(0.1)
                : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 8),
              IconTheme.merge(
                data: const IconThemeData(size: 16),
                child: icon,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DefaultTextStyle(
                  style: context.theme.textTheme.bodyMedium!,
                  maxLines: 1,
                  child: title,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavigationTitle extends StatelessWidget {
  const NavigationTitle({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 20, top: 10, bottom: 4),
      child: Text(title, style: context.theme.textTheme.subtitle1.bold),
    );
  }
}
