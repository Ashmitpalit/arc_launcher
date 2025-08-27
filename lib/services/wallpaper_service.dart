import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:typed_data';

class WallpaperService {
  static const MethodChannel _channel = MethodChannel('wallpaper_service');
  
  // Wallpaper types
  static const String _homeScreen = 'home';
  static const String _lockScreen = 'lock';
  static const String _both = 'both';
  
  // Current wallpaper info
  String? _currentWallpaperPath;
  String? _currentWallpaperType;
  bool _isLiveWallpaper = false;
  bool _isAnimatedWallpaper = false;
  
  // Wallpaper categories
  final List<WallpaperCategory> _categories = [
    WallpaperCategory(
      id: 'live',
      name: 'Live Wallpapers',
      description: 'Dynamic and interactive wallpapers',
      icon: Icons.animation,
      isLive: true,
    ),
    WallpaperCategory(
      id: 'animated',
      name: 'Animated Wallpapers',
      description: 'Moving and animated backgrounds',
      icon: Icons.movie,
      isAnimated: true,
    ),
    WallpaperCategory(
      id: 'static',
      name: 'Static Wallpapers',
      description: 'Beautiful high-resolution images',
      icon: Icons.image,
      isLive: false,
    ),
    WallpaperCategory(
      id: 'custom',
      name: 'Custom Wallpapers',
      description: 'Your own personal wallpapers',
      icon: Icons.person,
      isLive: false,
    ),
  ];

  // Get wallpaper categories
  List<WallpaperCategory> get categories => _categories;

  // Initialize the service
  Future<void> initialize() async {
    try {
      await _loadCurrentWallpaper();
    } catch (e) {
      print('Failed to initialize wallpaper service: $e');
    }
  }

  // Load current wallpaper info
  Future<void> _loadCurrentWallpaper() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentWallpaperPath = prefs.getString('current_wallpaper_path');
      _currentWallpaperType = prefs.getString('current_wallpaper_type');
      _isLiveWallpaper = prefs.getBool('is_live_wallpaper') ?? false;
      _isAnimatedWallpaper = prefs.getBool('is_animated_wallpaper') ?? false;
    } catch (e) {
      print('Failed to load current wallpaper: $e');
    }
  }

  // Set wallpaper from file path
  Future<bool> setWallpaperFromFile(String filePath, String wallpaperType) async {
    try {
      final result = await _channel.invokeMethod('setWallpaper', {
        'filePath': filePath,
        'wallpaperType': wallpaperType,
      });
      
      if (result == true) {
        await _saveWallpaperInfo(filePath, wallpaperType, false, false);
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to set wallpaper from file: $e');
      return false;
    }
  }

  // Set live wallpaper
  Future<bool> setLiveWallpaper(String packageName, String serviceName) async {
    try {
      final result = await _channel.invokeMethod('setLiveWallpaper', {
        'packageName': packageName,
        'serviceName': serviceName,
      });
      
      if (result == true) {
        await _saveWallpaperInfo('', 'live', true, false);
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to set live wallpaper: $e');
      return false;
    }
  }

  // Set animated wallpaper
  Future<bool> setAnimatedWallpaper(String filePath, String wallpaperType) async {
    try {
      final result = await _channel.invokeMethod('setAnimatedWallpaper', {
        'filePath': filePath,
        'wallpaperType': wallpaperType,
      });
      
      if (result == true) {
        await _saveWallpaperInfo(filePath, wallpaperType, false, true);
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to set animated wallpaper: $e');
      return false;
    }
  }

  // Save wallpaper information
  Future<void> _saveWallpaperInfo(String path, String type, bool isLive, bool isAnimated) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_wallpaper_path', path);
      await prefs.setString('current_wallpaper_type', type);
      await prefs.setBool('is_live_wallpaper', isLive);
      await prefs.setBool('is_animated_wallpaper', isAnimated);
      
      _currentWallpaperPath = path;
      _currentWallpaperType = type;
      _isLiveWallpaper = isLive;
      _isAnimatedWallpaper = isAnimated;
    } catch (e) {
      print('Failed to save wallpaper info: $e');
    }
  }

  // Get available live wallpapers
  Future<List<LiveWallpaper>> getAvailableLiveWallpapers() async {
    try {
      final result = await _channel.invokeMethod('getLiveWallpapers');
      if (result is List) {
        return result.map((item) => LiveWallpaper.fromMap(item)).toList();
      }
      return [];
    } catch (e) {
      print('Failed to get live wallpapers: $e');
      return [];
    }
  }

  // Get wallpaper preview
  Future<Uint8List?> getWallpaperPreview(String filePath) async {
    try {
      final result = await _channel.invokeMethod('getWallpaperPreview', {
        'filePath': filePath,
      });
      if (result is Uint8List) {
        return result;
      }
      return null;
    } catch (e) {
      print('Failed to get wallpaper preview: $e');
      return null;
    }
  }

  // Check if wallpaper is supported
  Future<bool> isWallpaperSupported(String filePath) async {
    try {
      final result = await _channel.invokeMethod('isWallpaperSupported', {
        'filePath': filePath,
      });
      return result == true;
    } catch (e) {
      print('Failed to check wallpaper support: $e');
      return false;
    }
  }

  // Get wallpaper info
  Future<WallpaperInfo?> getWallpaperInfo() async {
    try {
      final result = await _channel.invokeMethod('getWallpaperInfo');
      if (result is Map) {
        return WallpaperInfo.fromMap(Map<String, dynamic>.from(result));
      }
      return null;
    } catch (e) {
      print('Failed to get wallpaper info: $e');
      return null;
    }
  }

  // Reset to default wallpaper
  Future<bool> resetToDefault() async {
    try {
      final result = await _channel.invokeMethod('resetToDefault');
      if (result == true) {
        await _saveWallpaperInfo('', 'default', false, false);
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to reset wallpaper: $e');
      return false;
    }
  }

  // Get current wallpaper status
  Map<String, dynamic> getCurrentWallpaperStatus() {
    return {
      'path': _currentWallpaperPath,
      'type': _currentWallpaperType,
      'isLive': _isLiveWallpaper,
      'isAnimated': _isAnimatedWallpaper,
    };
  }

  // Check if current wallpaper is live
  bool get isCurrentWallpaperLive => _isLiveWallpaper;
  
  // Check if current wallpaper is animated
  bool get isCurrentWallpaperAnimated => _isAnimatedWallpaper;
  
  // Get current wallpaper path
  String? get currentWallpaperPath => _currentWallpaperPath;
  
  // Get current wallpaper type
  String? get currentWallpaperType => _currentWallpaperType;
}

// Wallpaper category model
class WallpaperCategory {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final bool isLive;
  final bool isAnimated;

  WallpaperCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.isLive = false,
    this.isAnimated = false,
  });
}

// Live wallpaper model
class LiveWallpaper {
  final String packageName;
  final String serviceName;
  final String displayName;
  final String description;
  final String previewImage;
  final bool isInstalled;
  final bool isActive;

  LiveWallpaper({
    required this.packageName,
    required this.serviceName,
    required this.displayName,
    required this.description,
    required this.previewImage,
    this.isInstalled = false,
    this.isActive = false,
  });

  factory LiveWallpaper.fromMap(Map<String, dynamic> map) {
    return LiveWallpaper(
      packageName: map['packageName'] ?? '',
      serviceName: map['serviceName'] ?? '',
      displayName: map['displayName'] ?? '',
      description: map['description'] ?? '',
      previewImage: map['previewImage'] ?? '',
      isInstalled: map['isInstalled'] ?? false,
      isActive: map['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'packageName': packageName,
      'serviceName': serviceName,
      'displayName': displayName,
      'description': description,
      'previewImage': previewImage,
      'isInstalled': isInstalled,
      'isActive': isActive,
    };
  }
}

// Wallpaper info model
class WallpaperInfo {
  final String path;
  final String type;
  final bool isLive;
  final bool isAnimated;
  final int width;
  final int height;
  final String mimeType;

  WallpaperInfo({
    required this.path,
    required this.type,
    required this.isLive,
    required this.isAnimated,
    required this.width,
    required this.height,
    required this.mimeType,
  });

  factory WallpaperInfo.fromMap(Map<String, dynamic> map) {
    return WallpaperInfo(
      path: map['path'] ?? '',
      type: map['type'] ?? '',
      isLive: map['isLive'] ?? false,
      isAnimated: map['isAnimated'] ?? false,
      width: map['width'] ?? 0,
      height: map['height'] ?? 0,
      mimeType: map['mimeType'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'path': path,
      'type': type,
      'isLive': isLive,
      'isAnimated': isAnimated,
      'width': width,
      'height': height,
      'mimeType': mimeType,
    };
  }
}

// Wallpaper item model
class WallpaperItem {
  final String id;
  final String name;
  final String description;
  final String imagePath;
  final String category;
  final bool isLive;
  final bool isAnimated;
  final bool isInstalled;
  final bool isActive;
  final double rating;
  final int downloadCount;

  WallpaperItem({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.category,
    this.isLive = false,
    this.isAnimated = false,
    this.isInstalled = false,
    this.isActive = false,
    this.rating = 0.0,
    this.downloadCount = 0,
  });

  factory WallpaperItem.fromMap(Map<String, dynamic> map) {
    return WallpaperItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imagePath: map['imagePath'] ?? '',
      category: map['category'] ?? '',
      isLive: map['isLive'] ?? false,
      isAnimated: map['isAnimated'] ?? false,
      isInstalled: map['isInstalled'] ?? false,
      isActive: map['isActive'] ?? false,
      rating: (map['rating'] ?? 0.0).toDouble(),
      downloadCount: map['downloadCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imagePath': imagePath,
      'category': category,
      'isLive': isLive,
      'isAnimated': isAnimated,
      'isInstalled': isInstalled,
      'isActive': isActive,
      'rating': rating,
      'downloadCount': downloadCount,
    };
  }
}
