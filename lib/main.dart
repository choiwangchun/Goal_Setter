import 'package:flutter/material.dart';
import 'package:goal_setter/goal_screen.dart';
import 'package:goal_setter/notification.dart';
import 'package:goal_setter/setting.dart';
import 'package:goal_setter/test.dart';
import 'dart:async';
import 'dart:io';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
// ca-app-pub-3940256099942544/6300978111

void main() async {
  final notificationService = NotificationService();
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await notificationService.init();
  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('ko'), Locale('zh'), Locale('ja')],
      path: 'assets/translations', // JSON 파일 경로
      fallbackLocale: Locale('en'),
      child: MyApp(),
    ),
  );
}



class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false; // 테마 상태를 저장하는 변수
  bool _isFeatureEnabled = false;
  Timer? notificationTimer;

  @override
  void initState() {
    super.initState();
    _loadDarkMode();
    _loadFeatureStatus();
    _startNotificationTimer();
  }

  void _startNotificationTimer() async {
    final prefs = await SharedPreferences.getInstance();
    int interval = prefs.getInt('notification_interval') ?? 8; // 기본값을 1시간으로 설정

    // 시간 단위를 초 단위로 변환합니다.
    int intervalInSeconds = interval * 60;

    notificationTimer?.cancel(); // 이전 타이머가 있다면 취소합니다.
    notificationTimer = Timer.periodic(Duration(seconds: intervalInSeconds), (timer) async {
      String userGoal = prefs.getString('enter_goal') ?? "새로운 목표를 설정해 주세요";
      NotificationService().regular_showNotification(0, userGoal);
    });
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
  void dispose() {
    notificationTimer?.cancel(); // 타이머 정리
    super.dispose();
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



  Future<void> _saveGoal(String goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('enter_goal', goal);
  }

  Future<String> _loadGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('enter_goal') ?? '기본 목표';
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
        return TextAlign.center;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color textColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;
    Color iconColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;
    Color buttonTextColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;
    Color buttonBorderColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;
    Color fillColor = Theme.of(context).brightness == Brightness.dark ? Colors.black26 : Colors.black26;

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
              padding: const EdgeInsets.all(38.0),
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
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: "enter_goal".tr(),
                      prefixIcon: Icon(Icons.flag, color: iconColor),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.done, color: iconColor),
                        onPressed: () {
                          _saveGoal(controller.text);
                          focusNode.unfocus();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => NewScreen(
                                text: controller.text,
                              ),
                            ),
                          );
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: fillColor,
                    ),
                    onSubmitted: (String text) {
                      if (text.isNotEmpty) {
                        _saveGoal(text);
                        focusNode.unfocus();
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