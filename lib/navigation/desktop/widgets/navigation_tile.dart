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
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: isSelected
                ? context.colorScheme.onSurface.withOpacity(0.1)
                : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SizedBox(
              height: 56,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 12),
                  IconTheme.merge(
                    data: const IconThemeData(size: 20),
                    child: icon,
                  ),
                  const SizedBox(width: 12),
                  DefaultTextStyle(
                    style: context.theme.textTheme.bodyText2!,
                    child: title,
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
