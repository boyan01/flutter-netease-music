import 'package:quiet/component/netease/netease.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';
import 'package:mockito/mockito.dart';

class MockNeteaseRepository extends Mock implements NeteaseRepository {}

class MockNeteaseLocalData extends Mock implements LocalData {}

class MockLoginState extends Mock implements UserAccount {}

class MockLikedSongList extends Mock implements FavoriteMusicList {}

class MockCounter extends Mock implements Counter {}
