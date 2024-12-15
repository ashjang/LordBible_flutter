import 'package:get/get.dart';
import 'package:lord_bible/src/controller/bottom_nav_controller.dart';

// Binding: 앱이 실행될 때 필요한 컨트롤러나 서비스를 미리 메모리에 등록
class InitBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(BottomNavController(), permanent: true);
  }
}