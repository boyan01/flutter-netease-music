import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:overlay_support/overlay_support.dart';

import '../../../extension.dart';
import '../../../model/region_flag.dart';
import '../../../repository.dart';
import '../material/dialogs.dart';
import 'page_dia_code_selection.dart';

/// Read emoji flags from assets.
Future<List<RegionFlag>> _getRegions() async {
  final jsonStr =
      await rootBundle.loadString('assets/emoji-flags.json', cache: false);
  final flags = json.decode(jsonStr) as List;
  final result = flags.cast<Map>().map(RegionFlag.fromMap).where((flag) {
    return flag.dialCode != null && flag.dialCode!.trim().isNotEmpty;
  }).toList();
  return result;
}

typedef PhoneNumberSubmitCallback = void Function(String phoneNumber);

class LoginPhoneNumberInputWidget extends HookWidget {
  const LoginPhoneNumberInputWidget({
    super.key,
    required this.onSubmit,
  });

  final PhoneNumberSubmitCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final regions = useFuture(useMemoized(_getRegions));
    return regions.hasData
        ? _PhoneInputLayout(
            regions: regions.requireData,
            onSubmit: onSubmit,
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}

class _PhoneInputLayout extends HookConsumerWidget {
  const _PhoneInputLayout({
    super.key,
    required this.regions,
    required this.onSubmit,
  });

  final List<RegionFlag> regions;
  final PhoneNumberSubmitCallback onSubmit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inputController = useTextEditingController();

    final countryCode = View.of(context).platformDispatcher.locale.countryCode;
    final selectedRegion = useState<RegionFlag>(
      useMemoized(() {
        // initial to select system default region.
        return regions.firstWhere(
          (region) => region.code == countryCode,
          orElse: () => regions[0],
        );
      }),
    );

    Future<void> onNextClick() async {
      final text = inputController.text;
      if (text.isEmpty) {
        toast('请输入手机号');
        return;
      }

      final result = await showLoaderOverlay(
        context,
        neteaseRepository!.checkPhoneExist(
          text,
          selectedRegion.value.dialCode!
              .replaceAll('+', '')
              .replaceAll(' ', ''),
        ),
      );
      if (result.isError) {
        toast(result.asError!.error.toString());
        return;
      }
      final value = result.asValue!.value;
      if (!value.isExist) {
        toast('注册流程开发未完成,欢迎贡献代码...');
        return;
      }
      if (!value.hasPassword!) {
        toast('无密码登录流程的开发未完成,欢迎提出PR贡献代码...');
        return;
      }
      onSubmit(text);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 30),
          Text(
            context.strings.tipsAutoRegisterIfUserNotExist,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: _PhoneInput(
              controller: inputController,
              selectedRegion: selectedRegion.value,
              onPrefixTap: () async {
                final region = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return RegionSelectionPage(regions: regions);
                    },
                  ),
                );
                if (region != null) {
                  selectedRegion.value = region;
                }
              },
              onDone: onNextClick,
            ),
          ),
          _ButtonNextStep(onTap: onNextClick),
        ],
      ),
    );
  }
}

class _PhoneInput extends HookWidget {
  const _PhoneInput({
    super.key,
    required this.controller,
    required this.selectedRegion,
    required this.onPrefixTap,
    required this.onDone,
  });

  final TextEditingController controller;

  final RegionFlag selectedRegion;

  final VoidCallback onPrefixTap;

  final VoidCallback onDone;

  Color? _textColor(BuildContext context) {
    if (controller.text.isEmpty) {
      return context.colorScheme.textDisabled;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final style = context.textTheme.bodyMedium!.copyWith(
      fontSize: 16,
      color: _textColor(context),
    );
    useListenable(controller);
    return TextField(
      autofocus: true,
      style: style,
      controller: controller,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      onSubmitted: (text) => onDone(),
      decoration: InputDecoration(
        prefixIcon: InkWell(
          onTap: onPrefixTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              '${selectedRegion.emoji} ${selectedRegion.dialCode!}',
              style: style,
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(),
      ),
    );
  }
}

class _ButtonNextStep extends StatelessWidget {
  const _ButtonNextStep({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: context.colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: Theme.of(context).primaryTextTheme.bodyMedium,
        padding: const EdgeInsets.symmetric(vertical: 18),
      ),
      onPressed: onTap,
      child: Text(context.strings.nextStep),
    );
  }
}
