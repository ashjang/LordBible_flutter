import 'package:get/get.dart';

class FavoriteController extends GetxController {
  var favoriteRefreshKey = 0.obs;

  void refreshFavorites() {
    favoriteRefreshKey.value++;
  }
}