import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:lord_bible/src/pages/bible.dart';
import 'package:lord_bible/src/pages/home.dart';
import 'package:lord_bible/src/pages/setting.dart';
import './controller/bottom_nav_controller.dart';

class App extends GetView<BottomNavController> {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      body: _getBody(controller.pageIndex.value),
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: controller.pageIndex.value,
          elevation: 0,
          onTap: controller.changeBottomNav,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: tr('Home')
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.book_outlined),
                activeIcon: Icon(Icons.book),
                label: tr('Bible')
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.search_outlined),
                activeIcon: Icon(Icons.search),
                label: tr('Search')
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings),
                label: tr('Setting')
            )
          ]
      ),
    ));
  }

  Widget _getBody(int pageIndex) {
    switch (pageIndex) {
      case 0:
        return const Home();
      case 1:
      // Bible 페이지에 고유 Key를 부여하여 새로 생성되도록 설정
        return Bible(key: UniqueKey());
      case 2:
        return Container(
          child: Center(child: Text(tr("Search"))),
        );
      case 3:
        return const Setting();
      default:
        return const Home();
    }
  }
}
