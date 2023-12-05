import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:goal_setter/goal_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';


enum TextAlignment { left, right, center }

class FontSettingsScreen extends StatefulWidget {
  final Function(double, TextAlignment) onSettingsChanged;

  FontSettingsScreen({required this.onSettingsChanged});


  @override
  _FontSettingsScreenState createState() => _FontSettingsScreenState();
}

class _FontSettingsScreenState extends State<FontSettingsScreen> {
  final FocusNode focusNode = FocusNode();
  double currentFontSize = 18;
  TextAlignment currentAlignment = TextAlignment.center;
  String sampleText = 'Sample\nText';
  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadSettings();
    textController.text = sampleText; // 컨트롤러 초기값 설정
  }

  @override
  void dispose() {
    textController.dispose(); // 컨트롤러 해제
    super.dispose();
  }

  void loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentFontSize = prefs.getDouble('fontSize') ?? 18;

      // 정렬 값 불러오기
      int alignmentIndex = prefs.getInt('textAlignment') ?? 2; // 기본값은 center
      if (alignmentIndex >= 0 && alignmentIndex < TextAlignment.values.length) {
        currentAlignment = TextAlignment.values[alignmentIndex];
      } else {
        currentAlignment = TextAlignment.center;
      }
    });
  }

  void saveSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', currentFontSize);
    await prefs.setInt('textAlignment', currentAlignment.index);
  }



  TextAlign getTextAlign(TextAlignment alignment) {
    switch (alignment) {
      case TextAlignment.left:
        return TextAlign.left;
      case TextAlignment.center:
        return TextAlign.center;
      case TextAlignment.right:
        return TextAlign.right;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color iconColor = Theme
        .of(context)
        .brightness == Brightness.dark ? Colors.white : Colors.black;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 60),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text("Font_size", style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)).tr(),
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
                          activeColor: Theme
                              .of(context)
                              .brightness == Brightness.dark
                              ? Colors.teal
                              : Colors.black,
                          inactiveColor: Theme
                              .of(context)
                              .brightness == Brightness.dark
                              ? Colors.teal[300]
                              : Colors.black12,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text('${currentFontSize.round()} px', style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text("Aligning_text", style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)).tr(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.format_align_left),
                      onPressed: () =>
                          setState(() => currentAlignment = TextAlignment.left),
                      color: currentAlignment == TextAlignment.left
                          ? (Theme
                          .of(context)
                          .brightness == Brightness.dark
                          ? Colors.teal
                          : iconColor)
                          : Colors.grey[500],
                    ),
                    SizedBox(width: 50),
                    IconButton(
                      icon: Icon(Icons.format_align_center),
                      onPressed: () =>
                          setState(() =>
                          currentAlignment = TextAlignment.center),
                      color: currentAlignment == TextAlignment.center
                          ? (Theme
                          .of(context)
                          .brightness == Brightness.dark
                          ? Colors.teal
                          : iconColor)
                          : Colors.grey[500],
                    ),
                    SizedBox(width: 50),
                    IconButton(
                      icon: Icon(Icons.format_align_right),
                      onPressed: () =>
                          setState(() =>
                          currentAlignment = TextAlignment.right),
                      color: currentAlignment == TextAlignment.right
                          ? (Theme
                          .of(context)
                          .brightness == Brightness.dark
                          ? Colors.teal
                          : iconColor)
                          : Colors.grey[500],
                    ),
                  ],
                ),
                SizedBox(height: 60),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(
                    child: Text(
                      sampleText,
                      style: TextStyle(fontSize: currentFontSize,
                          fontWeight: FontWeight.bold),
                      textAlign: getTextAlign(currentAlignment),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  child: TextField(
                    controller: textController,
                    keyboardType: TextInputType.multiline, // 다중 줄 입력 활성화
                    maxLines: null, // 최대 줄 수 제한 없음
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Enter_Text".tr(), // 텍스트 필드 레이블
                      labelStyle: TextStyle(color: Colors.white),
                      focusedBorder: OutlineInputBorder( // 포커스 상태일 때의 테두리 스타일
                        borderSide: BorderSide(color: Colors.teal, width: 1.0),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.done, color: iconColor),
                        onPressed: () {
                          setState(() {
                            sampleText = textController.text; // 현재 텍스트를 업데이트
                            focusNode.unfocus(); // 키보드 숨기기
                          });
                        },
                      ),
                    ),
                    onSubmitted: (String newText) {
                      setState(() {
                        sampleText = newText; // 키보드 확인 버튼을 누를 때 텍스트 업데이트
                      });
                    },
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  child: Text(
                    "Apply",
                    style: TextStyle(fontSize: 16), // 텍스트의 크기를 조정합니다.
                  ).tr(),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    // 버튼 배경을 검정색으로 설정
                    padding: EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                    // 버튼 내부의 패딩을 설정
                    minimumSize: Size(130, 45), // 버튼의 최소 크기를 설정
                  ),
                  onPressed: () {
                    saveSettings();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}