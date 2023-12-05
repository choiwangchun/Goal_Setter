import 'package:flutter/material.dart';
import 'package:goal_setter/notification.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewScreen extends StatefulWidget {
  final String text;

  NewScreen({required this.text});

  @override
  _NewScreenState createState() => _NewScreenState();
}

class _NewScreenState extends State<NewScreen> {
  double fontSize = 18; // 기본 폰트 크기
  TextAlign textAlign = TextAlign.center; // 기본 텍스트 정렬

  @override
  void initState() {
    super.initState();
    loadSettings();
    sendNotification(widget.text);
  }

  void sendNotification(String text) async {
    final notificationService = NotificationService();
    await notificationService.showNotification(0, text); // 수정된 부분
  }

  void loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      fontSize = prefs.getDouble('fontSize') ?? 18;
      textAlign = TextAlign.values[prefs.getInt('textAlignment') ?? 0];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          widget.text, // 텍스트 내용
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
          textAlign: textAlign,
        ),
      ),
    );
  }
}