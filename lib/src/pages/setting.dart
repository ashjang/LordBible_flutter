import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lord_bible/src/controller/scale_controller.dart';
import 'package:lord_bible/src/pages/bible.dart';
import 'package:lord_bible/src/pages/read_check.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  final TextScaleController textScaleController = Get.find();
  bool isDarkMode = false;
  final List<String> versions = ["KJV흠정역", "KJV", "개역개정", "NIV"];
  int selectedIndex = 0;
  String selectedVersion = "";


  @override
  void initState() {
    super.initState();
    _loadThemePreference();
    _getDefaultBibleVersion();
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

  Future<void> _getDefaultBibleVersion() async {
    final prefs = await SharedPreferences.getInstance();
    final defaultVersion = prefs.getString('defaultVersion') ?? versions[0];
    setState(() {
      selectedVersion = defaultVersion;
      selectedIndex = versions.indexOf(defaultVersion);
    });
  }

  // SharedPreferences에 선택된 값 저장
  Future<void> _saveSelectedVersion(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('defaultVersion', version);
    setState(() {
      selectedVersion = version;
    });
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: 300,
          child: CupertinoPicker(
            backgroundColor: Colors.transparent,
            itemExtent: 50.0,
            scrollController: FixedExtentScrollController(initialItem: selectedIndex),
            onSelectedItemChanged: (int index) {
              setState(() {
                selectedIndex = index;
                selectedVersion = versions[index];
              });
              _saveSelectedVersion(versions[index]);
            },
            children: versions.map((version) {
              return Center(
                child: Text(version,
                  textAlign: TextAlign.center,),
              );
            }).toList(),
          ),
        );
      },
    );
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
              _readCheck(),
              _bibleVersion(),
              _textSize(),
              _themeMode(),
            ],
          ),
        )
      )
    );
  }

  Widget _readCheck() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(tr('Read Check Page'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0)),
          CupertinoButton(
            onPressed: () {
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (context) => ReadCheck()),
              );
            },
            padding: EdgeInsets.zero,
            child: Icon(
              CupertinoIcons.arrow_right,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bibleVersion() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(tr('Bible version'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0)),
          CupertinoButton(
            onPressed: () => _showPicker(context),
            padding: EdgeInsets.zero,
            child: Text(selectedVersion!, style: TextStyle(fontSize: 14, color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textSize() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(tr('Adjust text size'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0)),
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
          Text(tr('Dark mode'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0)),
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