import 'dart:async';
import 'package:flutter/material.dart';
import 'package:goal_setter/notification.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotifivarionScreen extends StatefulWidget {
  final String userText;

  const NotifivarionScreen({super.key, required this.userText});

  @override
  NotifivarionScreenState createState() => NotifivarionScreenState();
}

class NotifivarionScreenState extends State<NotifivarionScreen> {
  int _counter = 0; // _counter 변수를 0으로 초기화
  int _targetNumber = 10; // _targetNumber 변수를 10으로 초기화
  Timer? _timer; // 타이머를 선언

  @override
  void initState() {
    super.initState();
    _requestNotificationPermissions(); // 알림 권한 요청
  }


  Future<String> _loadSavedGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('enter_goal') ?? '기본 목표';
  }

  void _requestNotificationPermissions() async {
    //알림 권한 요청
    final status = await NotificationService().requestNotificationPermissions();
    if (status.isDenied && context.mounted) {
      showDialog(
        // 알림 권한이 거부되었을 경우 다이얼로그 출력
        context: context,
        builder: (context) => AlertDialog(
          title: Text('알림 권한이 거부되었습니다.'),
          content: Text('알림을 받으려면 앱 설정에서 권한을 허용해야 합니다.'),
          actions: <Widget>[
            TextButton(
              child: Text('설정'), //다이얼로그 버튼의 죄측 텍스트
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings(); //설정 클릭시 권한설정 화면으로 이동
              },
            ),
            TextButton(
              child: Text('취소'), //다이얼로그 버튼의 우측 텍스트
              onPressed: () => Navigator.of(context).pop(), //다이얼로그 닫기
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    //화면 구성
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('타이머: $_counter'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('알림 시간 입력(초) : '),
                SizedBox(
                  width: 60,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _targetNumber = int.parse(value);
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _resetCounter,
                  child: const Text('초기화'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _toggleTimer,
                  child: Text(_timer?.isActive == true ? '정지' : '시작'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _resetCounter() {
    setState(() {
      _counter = 0; // _counter 변수를 0으로 초기화
    });
  }

  void _toggleTimer() {
    // 타이머 시작/정지 기능
    if (_timer?.isActive == true) {
      _stopTimer();
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      setState(() async {
        _counter++;
        if (_counter == _targetNumber) {
          String savedGoal = await _loadSavedGoal(); // 저장된 텍스트 로드
          NotificationService().showNotification(_targetNumber, savedGoal); // 알림에 저장된 텍스트 사용
          _stopTimer();
        }
      });
    });
  }

  void _stopTimer() {
    //타이머 정지
    _timer?.cancel();
  }
}