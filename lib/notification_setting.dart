import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

class NotificationSetting extends StatefulWidget {
  @override
  _NotificationSettingState createState() => _NotificationSettingState();
}

class _NotificationSettingState extends State<NotificationSetting> {
  int selectedNotificationTime = 60; // 기본 알림 시간 설정

  @override
  void initState() {
    super.initState();
    _loadNotificationInterval();
  }

  // SharedPreferences에서 저장된 알림 간격을 불러오는 메서드
  void _loadNotificationInterval() async {
    final prefs = await SharedPreferences.getInstance();
    int savedInterval = prefs.getInt('notification_interval') ?? 60; // 기본값 60초
    setState(() {
      selectedNotificationTime = savedInterval;
    });
  }

  String getNotificationTimeText() {
    if (selectedNotificationTime == 0) {
      return '알림 없음';
    }
    return '${selectedNotificationTime}초';
  }

  @override
  Widget build(BuildContext context) {
    Color containerColor = Theme.of(context).brightness == Brightness.dark ? Colors.black26 : Colors.grey;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.all(30.0),
              decoration: BoxDecoration(
                color: containerColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                title: Text(
                  '알림 간격',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text(getNotificationTimeText()),
                trailing: Icon(Icons.keyboard_arrow_down),
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return SizedBox(
                        height: 200,
                        child: ListWheelScrollView.useDelegate(
                          itemExtent: 48,
                          physics: FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) async {
                            setState(() {
                              selectedNotificationTime = index; // 초 단위로 설정
                            });
                            await prefs.setInt('notification_interval', selectedNotificationTime);
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            builder: (BuildContext context, int index) {
                              return Center(child: Text('${index}초'));
                            },
                            childCount: 61, // 0초부터 60초까지
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              child: Text("Apply", style: TextStyle(fontSize: 16)).tr(),
              style: ElevatedButton.styleFrom(
                primary: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                minimumSize: Size(130, 45),
              ),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setInt('notification_interval', selectedNotificationTime);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
