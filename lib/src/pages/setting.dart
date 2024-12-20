import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lord_bible/src/controller/scale_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  final TextScaleController textScaleController = Get.find();
  late bool isDarkMode;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? (CupertinoTheme.of(context).brightness == Brightness.dark);
    });
  }

  Future<void> _saveThemePreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    setState(() {
      isDarkMode = value;
    });
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        heroTag: 'setting_tag',
          transitionBetweenRoutes: false,
        middle: Text(tr('Setting'), style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
        backgroundColor: Colors.transparent,
        border: Border(bottom: BorderSide(color: Colors.transparent))
      ),
      body: SingleChildScrollView (
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row(),
              _textSize(),
              _themeMode(),
            ],
          ),
        )
      )
    );
  }

  Widget _textSize() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(tr('Adjust text size')),
          SizedBox(
            width: MediaQuery.of(context).size.width / 2.7,
            child: CupertinoSlider(
                value: textScaleController.textScale.value,
                min: 0.7,
                max: 1.7,
                divisions: 10,
                activeColor: isDarkMode ? Colors.white : Colors.black,
                onChanged: (value) {
                  textScaleController.updateTextScale(value);
                },
              ),
          )
        ],
      ),
    );
  }

  Widget _themeMode() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(tr('Dark mode')),
          CupertinoSwitch(
              value: isDarkMode,
              onChanged: (bool value) {
                _saveThemePreference(value);
              }
          )
        ],
      ),
    );
  }
}