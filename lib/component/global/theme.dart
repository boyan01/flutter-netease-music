part of 'settings.dart';

//网易红调色板
const _swatchNeteaseRed = MaterialColor(0xFFdd4237, {
  900: Color(0xFFae2a20),
  800: Color(0xFFbe332a),
  700: Color(0xFFcb3931),
  600: Color(0xFFdd4237),
  500: Color(0xFFec4b38),
  400: Color(0xFFe85951),
  300: Color(0xFFdf7674),
  200: Color(0xFFea9c9a),
  100: Color(0xFFfcced2),
  50: Color(0xFFfeebee),
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
      dividerColor: const Color(0xfff5f5f5),
      iconTheme: const IconThemeData(color: Color(0xFFb3b3b3)),
      primaryColorLight: primaryColor,
      backgroundColor: Colors.white);
}

extension QuietAppTheme on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => theme.textTheme;

  TextTheme get primaryTextTheme => theme.primaryTextTheme;

  ColorScheme get colorScheme => theme.colorScheme;
}

extension TextStyleExtesntion on TextStyle? {
  TextStyle? get bold => this?.copyWith(fontWeight: FontWeight.bold);
}
