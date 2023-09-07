import 'package:flutter/material.dart';

class SettingsList {
  SettingsList({
    required this.titles,
    required this.subtitles,
    required this.icons,
  });
  final List<String> titles;
  final List<String> subtitles;
  final List<IconData> icons;
}
