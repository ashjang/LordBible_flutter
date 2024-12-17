import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TextScaleController extends GetxController {
  // Slider 값 (0.5 ~ 2.0)
  RxDouble textScale = 1.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadTextScale(); // 앱 시작 시 저장된 값 불러오기
  }

  void updateTextScale(double value) async{
    textScale.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('textScale', value);
  }

  Future<void> loadTextScale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedScale = prefs.getDouble('textScale') ?? 1.0; // 저장된 값이 없으면 1.0
    textScale.value = savedScale;
  }
}
