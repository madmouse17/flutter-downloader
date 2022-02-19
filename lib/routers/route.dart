import 'package:get/get.dart';
import 'package:medsos_downloader/routers/routeName.dart';
import 'package:medsos_downloader/view/home.dart';

class router {
  static final pages = [
    GetPage(name: routeName.home, page: () => const home()),
  ];
}
