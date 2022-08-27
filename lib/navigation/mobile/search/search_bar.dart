import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../extension.dart';
import '../../common/buttons.dart';

class SearchBar extends HookWidget implements PreferredSizeWidget {
  const SearchBar({
    super.key,
    required this.enable,
    required this.onDismissTapped,
    required this.controller,
    required this.focusNode,
  });

  final bool enable;

  final VoidCallback onDismissTapped;

  final TextEditingController controller;

  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: CupertinoSearchTextField(
              focusNode: focusNode,
              controller: controller,
              placeholder: context.strings.search,
              enabled: enable,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemColor: context.colorScheme.textPrimary,
              placeholderStyle: TextStyle(
                color: context.colorScheme.textPrimary,
              ),
              style: TextStyle(
                color: context.colorScheme.textPrimary,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: context.colorScheme.divider,
                ),
                color: context.colorScheme.surface,
              ),
              prefixInsets: const EdgeInsetsDirectional.fromSTEB(20, 0, 0, 4),
              suffixInsets: const EdgeInsetsDirectional.fromSTEB(0, 0, 20, 2),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: enable
              ? Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: AppIconButton(
                    icon: FluentIcons.dismiss_20_regular,
                    onPressed: onDismissTapped,
                  ),
                )
              : const SizedBox(),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50);
}
