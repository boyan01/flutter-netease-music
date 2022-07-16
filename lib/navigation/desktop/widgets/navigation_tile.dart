import 'package:flutter/material.dart';
import '../../../component.dart';

class NavigationTile extends StatelessWidget {
  const NavigationTile({
    super.key,
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

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
            children: [
              const SizedBox(width: 8),
              IconTheme.merge(
                data: const IconThemeData(size: 16),
                child: icon,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DefaultTextStyle.merge(
                  style: context.theme.textTheme.bodyMedium?.copyWith(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
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
  const NavigationTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 20, top: 12, bottom: 8),
      child: Text(title, style: context.theme.textTheme.caption),
    );
  }
}
