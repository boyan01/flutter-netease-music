part of 'settings.dart';

//网易红调色板
const _swatchNeteaseRed = const MaterialColor(0xFFdd4237, {
  900: const Color(0xFFae2a20),
  800: const Color(0xFFbe332a),
  700: const Color(0xFFcb3931),
  600: const Color(0xFFdd4237),
  500: const Color(0xFFec4b38),
  400: const Color(0xFFe85951),
  300: const Color(0xFFdf7674),
  200: const Color(0xFFea9c9a),
  100: const Color(0xFFfcced2),
  50: const Color(0xFFfeebee),
});

//app主题
final quietThemes = [
  _buildTheme(_swatchNeteaseRed),
  _buildTheme(Colors.blue),
  _buildTheme(Colors.green),
  _buildTheme(Colors.amber),
  _buildTheme(Colors.teal),
];

final quietDarkTheme = ThemeData.dark().copyWith(
  backgroundColor: Colors.white12,
);

ThemeData _buildTheme(Color primaryColor) {
  return ThemeData(
      primaryColor: primaryColor,
      dividerColor: Color(0xfff5f5f5),
      iconTheme: IconThemeData(color: Color(0xFFb3b3b3)),
      primaryColorLight: primaryColor,
      backgroundColor: Colors.white);
}
