import 'package:flutter/widgets.dart';
import '../../generated/l10n.dart';

export 'package:quiet/generated/l10n.dart';

extension AppStringResourceExtension on BuildContext {
  S get strings {
    return S.of(this);
  }
}
