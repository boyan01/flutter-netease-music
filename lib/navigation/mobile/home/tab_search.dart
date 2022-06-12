import 'package:flutter/cupertino.dart';
import '../../../extension.dart';

class HomeTabSearch extends StatelessWidget {
  const HomeTabSearch({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        SizedBox(
          height: 50,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              debugPrint('Search');
            },
            child: CupertinoSearchTextField(
              placeholder: context.strings.search,
              enabled: false,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: CupertinoColors.inactiveGray,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
