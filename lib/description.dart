import 'package:flutter/material.dart';
import 'package:goal_setter/main.dart';
import 'dart:async';
import 'dart:io';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';


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