import 'package:flutter/material.dart';

class AppShortcut {
  final String name;
  final String packageName;
  final IconData icon;
  final Color color;
  final String? category;
  final DateTime? installDate;
  final int? usageCount;

  AppShortcut({
    required this.name,
    required this.packageName,
    required this.icon,
    required this.color,
    this.category,
    this.installDate,
    this.usageCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'packageName': packageName,
      'icon': icon.codePoint,
      'color': color.value,
      'category': category,
      'installDate': installDate?.millisecondsSinceEpoch,
      'usageCount': usageCount,
    };
  }

  factory AppShortcut.fromMap(Map<String, dynamic> map) {
    return AppShortcut(
      name: map['name'] as String,
      packageName: map['packageName'] as String,
      icon: IconData(map['icon'] as int, fontFamily: 'MaterialIcons'),
      color: Color(map['color'] as int),
      category: map['category'] as String?,
      installDate: map['installDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['installDate'] as int)
          : null,
      usageCount: map['usageCount'] as int?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppShortcut && other.packageName == packageName;
  }

  @override
  int get hashCode => packageName.hashCode;

  @override
  String toString() {
    return 'AppShortcut(name: $name, packageName: $packageName)';
  }
}









