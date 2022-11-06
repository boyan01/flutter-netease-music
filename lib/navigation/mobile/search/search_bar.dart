import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../extension.dart';
import '../../common/buttons.dart';

class SearchBar extends HookWidget implements PreferredSizeWidget {
  const SearchBar({
    super.key,
    required this.enable,
    this.controller,
    this.focusNode,
    this.onSearchBarTap,
    this.placeholder,
  });

  final bool enable;

  final TextEditingController? controller;

  final FocusNode? focusNode;

  final VoidCallback? onSearchBarTap;

  final String? placeholder;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            const SizedBox(width: 8),
            const AppBackButton(),
            Expanded(
              child: GestureDetector(
                onTap: onSearchBarTap,
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  height: 40,
                  child: CupertinoSearchTextField(
                    focusNode: focusNode,
                    controller: controller,
                    placeholder: placeholder ?? context.strings.search,
                    enabled: enable,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemColor: context.colorScheme.textPrimary,
                    placeholderStyle: TextStyle(
                      color: context.colorScheme.textPrimary,
                    ),
                    style: TextStyle(
                      color: context.colorScheme.textPrimary,
                    ),
                    prefixIcon: const Icon(FluentIcons.search_24_regular),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: context.colorScheme.divider,
                      ),
                      color: context.colorScheme.surface,
                    ),
                    prefixInsets:
                        const EdgeInsetsDirectional.fromSTEB(16, 0, 0, 0),
                    suffixInsets:
                        const EdgeInsetsDirectional.fromSTEB(0, 0, 16, 0),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
