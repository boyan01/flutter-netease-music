import 'package:flutter/widgets.dart';

class QuietLocalizationsDelegate extends LocalizationsDelegate<QuietLocalizations> {
  @override
  bool isSupported(Locale locale) {
    return ["en", "zh"].contains(locale.languageCode);
  }

  @override
  Future<QuietLocalizations> load(Locale locale) {
    return Future.value(QuietLocalizations(locale));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<QuietLocalizations> old) {
    return false;
  }
}

class QuietLocalizations {
  QuietLocalizations(this.locale);

  final Locale locale;

  static Map<String, Map<String, String>> _localizedValues = {
    "en": {
      "main_page_tab_title_my": "My",
      "main_page_tab_title_discover": "Discover",
    },
    "zh": {
      "main_page_tab_title_my": "我的",
      "main_page_tab_title_discover": "发现",
    },
  };

  // ignore: non_constant_identifier_names
  String get main_page_tab_title_my {
    return _localizedValues[locale.languageCode]["main_page_tab_title_my"];
  }

// ignore: non_constant_identifier_names
  String get main_page_tab_title_discover {
    return _localizedValues[locale.languageCode]["main_page_tab_title_discover"];
  }

}

extension QuietLocalizationsContext on BuildContext {
  QuietLocalizations get strings {
    return Localizations.of<QuietLocalizations>(this, QuietLocalizations);
  }
}
