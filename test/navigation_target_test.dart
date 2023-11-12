import 'package:flutter_test/flutter_test.dart';
import 'package:quiet/navigation/common/navigation_target.dart';

void main() {
  test('navigation target is the same', () async {
    final target1 = NavigationTargetDiscover();
    final target2 = NavigationTargetDiscover();

    expect(target1.isTheSameTarget(target2), true);
    expect(target1 != target2, true);

    final target3 = NavigationTargetSettings();
    expect(target1.isTheSameTarget(target3), false);

    final target4 = NavigationTargetPlaylist(4);
    final target5 = NavigationTargetPlaylist(5);
    expect(target4.isTheSameTarget(target5), false);

    final target6 = NavigationTargetPlaylist(4);
    expect(target4.isTheSameTarget(target6), true);
  });
}
