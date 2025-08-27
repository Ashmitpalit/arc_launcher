import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/icon_pack.dart';

class IconPackService {
  static const String _currentIconPackKey = 'current_icon_pack_id';
  
  // Built-in icon packs
  static final List<IconPack> _builtInIconPacks = [
    IconPack(
      id: 'material',
      name: 'Material Design',
      description: 'Google\'s Material Design icon style',
      author: 'Google',
      version: '1.0.0',
      previewImagePath: 'assets/images/icon_packs/material_preview.png',
      isBuiltIn: true,
      isEnabled: true,
      appIconMappings: {},
      supportedApps: [],
      lastUpdated: DateTime.now(),
    ),
    IconPack(
      id: 'ios_style',
      name: 'iOS Style',
      description: 'Apple\'s iOS icon aesthetic',
      author: 'Apple',
      version: '1.0.0',
      previewImagePath: 'assets/images/icon_packs/ios_preview.png',
      isBuiltIn: true,
      isEnabled: false,
      appIconMappings: {},
      supportedApps: [],
      lastUpdated: DateTime.now(),
    ),
    IconPack(
      id: 'rounded',
      name: 'Rounded',
      description: 'Soft, rounded icon corners',
      author: 'Arc Launcher',
      version: '1.0.0',
      previewImagePath: 'assets/images/icon_packs/rounded_preview.png',
      isBuiltIn: true,
      isEnabled: false,
      appIconMappings: {},
      supportedApps: [],
      lastUpdated: DateTime.now(),
    ),
    IconPack(
      id: 'square',
      name: 'Square',
      description: 'Sharp, geometric icon design',
      author: 'Arc Launcher',
      version: '1.0.0',
      previewImagePath: 'assets/images/icon_packs/square_preview.png',
      isBuiltIn: true,
      isEnabled: false,
      appIconMappings: {},
      supportedApps: [],
      lastUpdated: DateTime.now(),
    ),
  ];

  static IconPackService? _instance;
  static IconPackService get instance => _instance ??= IconPackService._();

  IconPackService._();

  // Get all available icon packs
  List<IconPack> getAllIconPacks() {
    return List.from(_builtInIconPacks);
  }

  // Get currently active icon pack
  Future<IconPack?> getCurrentIconPack() async {
    final prefs = await SharedPreferences.getInstance();
    final currentId = prefs.getString(_currentIconPackKey);
    
    if (currentId == null) {
      // Return Material Design as default
      return _builtInIconPacks.firstWhere((pack) => pack.id == 'material');
    }
    
    return _builtInIconPacks.firstWhere(
      (pack) => pack.id == currentId,
      orElse: () => _builtInIconPacks.first,
    );
  }

  // Set current icon pack
  Future<void> setCurrentIconPack(String iconPackId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentIconPackKey, iconPackId);
    
    // Update enabled status
    for (var pack in _builtInIconPacks) {
      if (pack.id == iconPackId) {
        pack = pack.copyWith(isEnabled: true);
      } else {
        pack = pack.copyWith(isEnabled: false);
      }
    }
  }

  // Get icon for specific app from current icon pack
  Future<Widget> getAppIcon(String packageName, {double size = 56.0}) async {
    final currentPack = await getCurrentIconPack();
    
    if (currentPack == null || currentPack.id == 'material') {
      // Return default Material icon
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.android,
          color: Colors.white,
          size: 28,
        ),
      );
    }
    
    // For other icon packs, return styled icon
    return _getStyledIcon(currentPack, packageName, size);
  }

  // Get styled icon based on icon pack
  Widget _getStyledIcon(IconPack pack, String packageName, double size) {
    Color iconColor = Colors.white;
    BorderRadius borderRadius;
    
    switch (pack.id) {
      case 'ios_style':
        borderRadius = BorderRadius.circular(size * 0.2);
        break;
      case 'rounded':
        borderRadius = BorderRadius.circular(size * 0.15);
        break;
      case 'square':
        borderRadius = BorderRadius.circular(8);
        break;
      default:
        borderRadius = BorderRadius.circular(16);
    }
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getIconPackColor(pack.id),
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: _getIconPackColor(pack.id).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        _getIconPackIcon(pack.id),
        color: iconColor,
        size: size * 0.5,
      ),
    );
  }

  // Get color scheme for icon pack
  Color _getIconPackColor(String packId) {
    switch (packId) {
      case 'ios_style':
        return const Color(0xFF424242);
      case 'rounded':
        return Colors.green;
      case 'square':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  // Get icon for icon pack
  IconData _getIconPackIcon(String packId) {
    switch (packId) {
      case 'ios_style':
        return Icons.phone_iphone;
      case 'rounded':
        return Icons.circle;
      case 'square':
        return Icons.square;
      default:
        return Icons.android;
    }
  }

  // Import custom icon pack
  Future<bool> importIconPack(File iconPackFile) async {
    try {
      // This would implement custom icon pack import logic
      // For now, return false as it's not fully implemented
      return false;
    } catch (e) {
      return false;
    }
  }

  // Export current icon pack settings
  Future<String> exportIconPackSettings() async {
    final currentPack = await getCurrentIconPack();
    final data = {
      'currentIconPack': currentPack?.toMap(),
      'exportDate': DateTime.now().toIso8601String(),
    };
    return jsonEncode(data);
  }

  // Reset to default icon pack
  Future<void> resetToDefault() async {
    await setCurrentIconPack('material');
  }
}
