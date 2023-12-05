  import 'package:flutter/material.dart';
  import 'package:goal_setter/description.dart';
  import 'package:goal_setter/font_setting.dart';
  import 'package:goal_setter/main.dart';
  import 'package:goal_setter/notification_setting.dart';
  import 'dart:async';
  import 'dart:io';
  import 'package:toggle_switch/toggle_switch.dart';
  import 'package:url_launcher/url_launcher.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import 'package:flutter_localizations/flutter_localizations.dart';
  import 'package:easy_localization/easy_localization.dart';

  enum TextAlignment { left, center, right }

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
            SizedBox(height: 5),
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
            SizedBox(height: 5),
            Divider(color: Colors.grey, height: 1, thickness: 2),
            SizedBox(height: 5),
            ListTile(
              title: Text('Font_setting', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)).tr(),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => FontSettingsScreen(
                      onSettingsChanged: (newFontSize, newTextAlignment) {
                        setState(() {
                          currentFontSize = currentFontSize;
                          currentAlignment = currentAlignment;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 5),
            Divider(color: Colors.grey,height: 1, thickness: 2),
            ListTile(
              title: Text('알림설정', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => NotificationSetting(),
                  ),
                );
              },
            ),
            SizedBox(height: 5),
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
