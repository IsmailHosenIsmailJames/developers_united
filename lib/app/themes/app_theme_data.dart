import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import 'const_theme_data.dart';

class AppThemeData extends GetxController {
  RxString themeModeName = 'system'.obs;
  Rx<IconData> themeIcon = Icons.brightness_6.obs;
  Rx<Color> drawerAppBarColor = ConstantThemeData().drawerAppBarLightColor.obs;
  Rx<Color> navbarColor = ConstantThemeData().navbarColorLight.obs;
  Rx<Color> containerBackGroundColor = Colors.grey.shade200.obs;
  Rx<Color> iconColors = Colors.grey.shade100.obs;

  void initTheme() {
    var box = Hive.box('tpi_programming_club');
    var userTheme = box.get('theme_preference', defaultValue: false);
    if (userTheme != false) {
      if (userTheme == 'light') {
        Get.changeThemeMode(ThemeMode.light);
        themeModeName.value = 'light';
        themeIcon.value = Icons.sunny;
        drawerAppBarColor.value = ConstantThemeData().drawerAppBarLightColor;
        navbarColor.value = ConstantThemeData().navbarColorLight;
        containerBackGroundColor.value = Colors.grey.shade200;
        iconColors.value = Colors.grey.shade800;
      } else if (userTheme == 'dark') {
        Get.changeThemeMode(ThemeMode.dark);
        themeModeName.value = 'dark';
        themeIcon.value = Icons.brightness_2;
        drawerAppBarColor.value = ConstantThemeData().drawerAppBarDarkColor;
        navbarColor.value = ConstantThemeData().navbarColorDark;
        containerBackGroundColor.value = Colors.grey.shade800;
        iconColors.value = Colors.grey.shade100;
      } else if (userTheme == 'system') {
        Get.changeThemeMode(ThemeMode.system);
        themeModeName.value = 'system';
        themeIcon.value = Icons.brightness_6;
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark
            ? {
                drawerAppBarColor.value =
                    ConstantThemeData().drawerAppBarDarkColor,
                navbarColor.value = ConstantThemeData().navbarColorDark,
                containerBackGroundColor.value = Colors.grey.shade800,
                iconColors.value = Colors.grey.shade100,
              }
            : {
                drawerAppBarColor.value =
                    ConstantThemeData().drawerAppBarLightColor,
                navbarColor.value = ConstantThemeData().navbarColorLight,
                containerBackGroundColor.value = Colors.grey.shade200,
                iconColors.value = Colors.grey.shade800,
              };
      }
    } else {
      box.put('theme_preference', 'system');
      initTheme();
    }
  }

  void setTheme(String themeToChange) {
    var box = Hive.box('tpi_programming_club');
    if (themeToChange == 'light') {
      Get.changeThemeMode(ThemeMode.light);
      box.put('theme_preference', 'light');
      themeModeName.value = 'light';
      themeIcon.value = Icons.sunny;
      drawerAppBarColor.value = ConstantThemeData().drawerAppBarLightColor;
      navbarColor.value = ConstantThemeData().navbarColorLight;
      containerBackGroundColor.value = Colors.grey.shade200;
      iconColors.value = Colors.grey.shade800;
    } else if (themeToChange == 'dark') {
      Get.changeThemeMode(ThemeMode.dark);
      box.put('theme_preference', 'dark');
      themeModeName.value = 'dark';
      themeIcon.value = Icons.brightness_2;
      drawerAppBarColor.value = ConstantThemeData().drawerAppBarDarkColor;
      navbarColor.value = ConstantThemeData().navbarColorDark;
      containerBackGroundColor.value = Colors.grey.shade800;
      iconColors.value = Colors.grey.shade100;
    } else if (themeToChange == 'system') {
      Get.changeThemeMode(ThemeMode.system);
      box.put('theme_preference', 'system');
      themeModeName.value = 'system';
      themeIcon.value = Icons.brightness_6;
      WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark
          ? {
              drawerAppBarColor.value =
                  ConstantThemeData().drawerAppBarDarkColor,
              navbarColor.value = ConstantThemeData().navbarColorDark,
              containerBackGroundColor.value = Colors.grey.shade800,
              iconColors.value = Colors.grey.shade100,
            }
          : {
              drawerAppBarColor.value =
                  ConstantThemeData().drawerAppBarLightColor,
              navbarColor.value = ConstantThemeData().navbarColorLight,
              containerBackGroundColor.value = Colors.grey.shade200,
              iconColors.value = Colors.grey.shade800,
            };
    }
  }
}
