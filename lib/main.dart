import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';
// ca-app-pub-3940256099942544/6300978111

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('ko'), Locale('zh'), Locale('ja')],
      path: 'assets/translations', // JSON 파일 경로
      fallbackLocale: Locale('en', 'US'),
      child: MyApp(),
    ),
  );
}


enum TextAlignment { left, center, right }

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false; // 테마 상태를 저장하는 변수
  bool _isFeatureEnabled = false;
  @override
  void initState() {
    super.initState();
    _loadDarkMode();
    _loadFeatureStatus();
  }

  void _loadFeatureStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFeatureEnabled = prefs.getBool('isFeatureEnabled') ?? false;
    });
  }

  void _loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
    });
  }
  void _saveDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
  }


  void toggleTheme(bool isOn) {
    setState(() {
      _isDarkMode = isOn;
    });
    _saveDarkMode(isOn);
  }
  void toggleFeature(bool isOn) {
    setState(() {
      _isFeatureEnabled = isOn;
    });
    _saveFeatureStatus(isOn);
  }
  void _saveFeatureStatus(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFeatureEnabled', value);
  }



  @override
  Widget build(BuildContext context) {
    ThemeData baseTheme = _isDarkMode ? ThemeData.dark() : ThemeData.light();

    return MaterialApp(
      localizationsDelegates: context.localizationDelegates + [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        // 다른 필요한 델리게이트들을 여기에 추가
      ],
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: baseTheme.copyWith(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: _isDarkMode ? Colors.white : Colors.black, // 다크 모드에 맞는 커서 색상
          selectionHandleColor: _isDarkMode ? Colors.white : Colors.black, // 다크 모드에 맞는 선택 핸들 색상
          selectionColor: _isDarkMode ? Colors.white38 : Colors.black12, // 다크 모드에 맞는 선택 색상
        ),
      ),
      home: HomeScreen(toggleTheme: toggleTheme, isDarkMode: _isDarkMode),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final Function(bool) toggleTheme;
  final bool isDarkMode;

  HomeScreen({required this.toggleTheme, required this.isDarkMode});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();
  double fontSize = 30; // 폰트 크기 상태를 저장하는 변수
  TextAlignment textAlignment = TextAlignment.center; // 기본 텍스트 정렬


  @override
  void initState() {
    super.initState();
    //myBanner = GoogleAdMob.loadBannerAd();
    //myBanner.load();
  }


  TextAlign getTextAlign(TextAlignment alignment) {
    switch (alignment) {
      case TextAlignment.left:
        return TextAlign.left;
      case TextAlignment.center:
        return TextAlign.center;
      case TextAlignment.right:
        return TextAlign.right;
      default:
        return TextAlign.left;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color textColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;
    Color iconColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;
    Color buttonTextColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;
    Color buttonBorderColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;
    Color fillColor = Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.black26;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 50.0,
            right: 30.0,
            child: IconButton(
              icon: Icon(Icons.settings),
              iconSize: 30,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(
                      fontSize: fontSize,
                      alignment: textAlignment,
                      onSettingsChanged: (newFontSize, newTextAlignment) {
                        setState(() {
                          fontSize = newFontSize;
                          textAlignment = newTextAlignment;
                        });
                      },
                      toggleTheme: widget.toggleTheme,
                      isDarkMode: widget.isDarkMode,// toggleTheme 파라미터 추가
                    ),
                  ),
                );
              },
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(55.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // GoogleAdMob.showBannerAd(myBanner),   <-- 나중에 추가
                  Text(
                    "title",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ).tr(),
                  SizedBox(height: 40),
                  TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      hintText: "enter_goal".tr(),
                      prefixIcon: Icon(Icons.flag, color: iconColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: fillColor,
                    ),
                    onSubmitted: (String text) {
                      if (text.isNotEmpty) {
                        focusNode.unfocus();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => NewScreen(
                              text: text,
                              fontSize: fontSize,
                              textAlign: getTextAlign(textAlignment),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NewScreen extends StatelessWidget {
  final String text;
  final double fontSize;
  final TextAlign textAlign;

  NewScreen({required this.text, required this.fontSize, required this.textAlign});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          text,
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
          textAlign: textAlign,
        ),
      ),
    );
  }
}

class description extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Screenshot_manual_1", textAlign: TextAlign.center, style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)).tr(),
            ),
            SizedBox(height: 10),
            _buildRoundedImage('assets/images/1.png'),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Screenshot_manual_2", style: TextStyle(fontSize: 20)).tr(),
            ),
            SizedBox(height: 30),
            _buildRoundedImage('assets/images/2.png'),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Screenshot_manual_3", style: TextStyle(fontSize: 20)).tr(),
            ),
            SizedBox(height: 30),
            _buildRoundedImage('assets/images/3.png'),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Screenshot_manual_4", style: TextStyle(fontSize: 20)).tr(),
            ),
            SizedBox(height: 30),
            _buildRoundedImage('assets/images/4.png'),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Screenshot_manual_5", style: TextStyle(fontSize: 20)).tr(),
            ),
            SizedBox(height: 30),
            _buildRoundedImage('assets/images/5.png'),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Screenshot_manual_6", style: TextStyle(fontSize: 20)).tr(),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
  Widget _buildRoundedImage(String imagePath) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0), // 좌우 여백
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0), // 라운드된 모서리
        child: Image.asset(imagePath),
      ),
    );
  }
}


class SettingsScreen extends StatefulWidget {
  final double fontSize;
  final TextAlignment alignment;
  final Function(double, TextAlignment) onSettingsChanged;
  final Function(bool) toggleTheme;
  final bool isDarkMode;

  SettingsScreen({required this.fontSize, required this.alignment, required this.onSettingsChanged, required this.toggleTheme, required this.isDarkMode});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late double currentFontSize;
  late TextAlignment currentAlignment;
  late bool isDarkMode;
  int _selectedLanguageIndex = 0; // 0: English, 1: Korean, 2: china, 3: japan


  @override
  void initState() {
    super.initState();
    currentFontSize = widget.fontSize;
    currentAlignment = widget.alignment;
    isDarkMode = widget.isDarkMode;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        final code = EasyLocalization.of(context)?.locale.languageCode;
        if (code == 'ko') {
          _selectedLanguageIndex = 1;
        } else if (code == 'zh') {
          _selectedLanguageIndex = 2;
        } else if (code == 'ja') {
          _selectedLanguageIndex = 3;
        } else {
          _selectedLanguageIndex = 0; // Default to English if no match found
        }
      });
    });
  }

  Future<void> _launchURL() async {
    const url = 'https://play.google.com/store/apps/details?id=com.goal_setter.goal_setter';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _buildLanguageToggle() {
    return Column(
      children: [
        Text(
          "Toggle_lang",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ).tr(),
        SizedBox(height: 20),
        ToggleSwitch(
          minWidth: 90.0,
          cornerRadius: 20.0,
          activeBgColors: [
            [Theme.of(context).brightness == Brightness.dark ? Colors.teal : Colors.black],
            [Theme.of(context).brightness == Brightness.dark ? Colors.teal : Colors.black],
            [Theme.of(context).brightness == Brightness.dark ? Colors.teal : Colors.black],
            [Theme.of(context).brightness == Brightness.dark ? Colors.teal : Colors.black]
          ],
          activeFgColor: Colors.white,
          inactiveBgColor: Colors.grey,
          inactiveFgColor: Colors.white,
          initialLabelIndex: _selectedLanguageIndex,
          totalSwitches: 4,
          labels: ["Toggle_lang_en".tr(), "Toggle_lang_ko".tr(), "Toggle_lang_zh".tr(), "Toggle_lang_ja".tr()],
          onToggle: (index) {
            setState(() {
              _selectedLanguageIndex = index!;
              Locale newLocale;
              switch (index) {
                case 0:
                  newLocale = Locale('en');
                  break;
                case 1:
                  newLocale = Locale('ko');
                  break;
                case 2:
                  newLocale = Locale('zh');
                  break;
                case 3:
                  newLocale = Locale('ja');
                  break;
                default:
                  newLocale = Locale('en');
              }
              context.setLocale(newLocale);
            });
          },
        ),
      ],
    );
  }



  @override
  Widget build(BuildContext context) {
    Color buttonTextColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;
    Color buttonBorderColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;
    Color textColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;
    Color iconColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;
    Color sliderActiveColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;
    Color sliderInactiveColor = Theme.of(context).brightness == Brightness.dark ? Colors.white30 : Colors.black26;

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ListTile(
            title: Text("Review", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)).tr(),
            onTap: _launchURL,
          ),
          Divider(color: Colors.grey,height: 1, thickness: 2),
          SizedBox(height: 10),
          SwitchListTile(
            title: Text("Dark_Mode", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)).tr(),
            value: isDarkMode,
            onChanged: (bool newValue) {
              setState(() {
                isDarkMode = newValue;
                widget.toggleTheme(newValue); // 상위 위젯에 변경 알림
              });
            },
          ),
          SizedBox(height: 10),
          Divider(color: Colors.grey,height: 1, thickness: 2),
          SizedBox(height: 20),
          _buildLanguageToggle(),
          SizedBox(height: 20),
          Divider(color: Colors.grey,height: 1, thickness: 2),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Screenshot_manual", textAlign: TextAlign.center, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)).tr(),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => description()),
              );
            },
            child: Text("Android", style: TextStyle(color: buttonTextColor)).tr(),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: buttonBorderColor),
            ),
          ),
          SizedBox(height: 20),
          Divider(color: Colors.grey,height: 1, thickness: 2),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Font_size", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)).tr(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: Slider(
                    value: currentFontSize,
                    min: 10,
                    max: 72,
                    divisions: 62,
                    label: currentFontSize.round().toString(),
                    onChanged: (newFontSize) {
                      setState(() {
                        currentFontSize = newFontSize;
                      });
                    },
                    activeColor: sliderActiveColor,
                    inactiveColor: sliderInactiveColor,
                  ),
                ),
                SizedBox(width: 10), // Slider와 Text 사이의 공간
                Text('${currentFontSize.round()} px', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
              ],
            ),
          ),
          SizedBox(height: 20),
          Divider(color: Colors.grey,height: 1, thickness: 2),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Aligning_text", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)).tr(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.format_align_left),
                onPressed: () => setState(() => currentAlignment = TextAlignment.left),
                color: currentAlignment == TextAlignment.left ? iconColor : Colors.grey[500],
              ),
              SizedBox(width: 50),
              IconButton(
                icon: Icon(Icons.format_align_center),
                onPressed: () => setState(() => currentAlignment = TextAlignment.center),
                color: currentAlignment == TextAlignment.center ? iconColor : Colors.grey[500],
              ),
              SizedBox(width: 50),
              IconButton(
                icon: Icon(Icons.format_align_right),
                onPressed: () => setState(() => currentAlignment = TextAlignment.right),
                color: currentAlignment == TextAlignment.right ? iconColor : Colors.grey[500],
              ),
            ],
          ),
          SizedBox(height: 20),
          Divider(color: Colors.grey,height: 1, thickness: 2),
          SizedBox(height: 20),
          ElevatedButton(
            child: Text(
              "Apply",
              style: TextStyle(fontSize: 16), // 텍스트의 크기를 조정합니다.
            ).tr(),
            style: ElevatedButton.styleFrom(
              primary: Colors.black, // 버튼 배경을 검정색으로 설정
              padding: EdgeInsets.symmetric(horizontal: 28, vertical: 10), // 버튼 내부의 패딩을 설정
              minimumSize: Size(130, 45), // 버튼의 최소 크기를 설정
            ),
            onPressed: () {
              widget.onSettingsChanged(currentFontSize, currentAlignment);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}