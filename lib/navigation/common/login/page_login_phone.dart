import 'dart:convert';
import 'dart:ui';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:overlay_support/overlay_support.dart';

import '../../../component.dart';
import '../../../material/dialogs.dart';
import '../../../model/region_flag.dart';
import '../../../providers/navigator_provider.dart';
import '../../../repository.dart';
import '../buttons.dart';
import 'login_sub_navigation.dart';
import 'page_dia_code_selection.dart';

/// Read emoji flags from assets.
Future<List<RegionFlag>> _getRegions() async {
  final jsonStr =
      await rootBundle.loadString('assets/emoji-flags.json', cache: false);
  final flags = json.decode(jsonStr) as List;
  final result =
      flags.cast<Map>().map(RegionFlag.fromMap).where((flag) {
    return flag.dialCode != null && flag.dialCode!.trim().isNotEmpty;
  }).toList();
  return result;
}

class PageLoginWithPhone extends HookConsumerWidget {
  const PageLoginWithPhone({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final regions = useFuture(useMemoized(_getRegions));
    final platform = ref.watch(debugNavigatorPlatformProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.strings.loginWithPhone),
        leading: platform == NavigationPlatform.mobile
            ? IconButton(
                icon: const BackButtonIcon(),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).maybePop();
                },
              )
            : null,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AppIconButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).maybePop();
              },
              icon: FluentIcons.dismiss_20_regular,
            ),
          ),
        ],
      ),
      body: regions.hasData
          ? _PhoneInputLayout(regions: regions.requireData)
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

class _PhoneInputLayout extends HookConsumerWidget {
  const _PhoneInputLayout({
    super.key,
    required this.regions,
  });

  final List<RegionFlag> regions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inputController = useTextEditingController();

    final selectedRegion = useState<RegionFlag>(useMemoized(() {
      // initial to select system default region.
      final countryCode = window.locale.countryCode;
      return regions.firstWhere((region) => region.code == countryCode,
          orElse: () => regions[0],);
    }),);

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
      await Navigator.pushNamed(context, pageLoginPassword,
          arguments: {'phone': text},);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 30),
          Text(
            context.strings.tipsAutoRegisterIfUserNotExist,
            style: Theme.of(context).textTheme.caption,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: _PhoneInput(
              controller: inputController,
              selectedRegion: selectedRegion.value,
              onPrefixTap: () async {
                final region = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return RegionSelectionPage(regions: regions);
                  },),
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
      return context.theme.disabledColor;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final style = context.textTheme.bodyText2!.copyWith(
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
        prefixIconConstraints: const BoxConstraints(
          
        ),
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
        primary: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: Theme.of(context).primaryTextTheme.bodyText2,
        padding: const EdgeInsets.symmetric(vertical: 18),
      ),
      onPressed: onTap,
      child: Text(context.strings.nextStep),
    );
  }
}
