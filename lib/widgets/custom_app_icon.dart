import 'package:flutter/material.dart';
import '../models/app_shortcut.dart';
import '../services/icon_pack_service.dart';

class CustomAppIcon extends StatefulWidget {
  final AppShortcut app;
  final double size;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showLabel;
  final TextStyle? labelStyle;

  const CustomAppIcon({
    super.key,
    required this.app,
    this.size = 56.0,
    this.onTap,
    this.onLongPress,
    this.showLabel = true,
    this.labelStyle,
  });

  @override
  State<CustomAppIcon> createState() => _CustomAppIconState();
}

class _CustomAppIconState extends State<CustomAppIcon> {
  late IconPackService _iconPackService;
  Widget? _customIcon;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _iconPackService = IconPackService.instance;
    _loadCustomIcon();
  }

  Future<void> _loadCustomIcon() async {
    try {
      final icon = await _iconPackService.getAppIcon(
        widget.app.packageName,
        size: widget.size,
      );
      if (mounted) {
        setState(() {
          _customIcon = icon;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIconContainer(),
          if (widget.showLabel) ...[
            const SizedBox(height: 8),
            _buildAppLabel(),
          ],
        ],
      ),
    );
  }

  Widget _buildIconContainer() {
    if (_isLoading) {
      return Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: const Color(0xFF757575),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    if (_customIcon != null) {
      return _customIcon!;
    }

    // Fallback to default icon
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: widget.app.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: widget.app.color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        widget.app.icon,
        color: Colors.white,
        size: widget.size * 0.5,
      ),
    );
  }

  Widget _buildAppLabel() {
    return Text(
      widget.app.name,
      style: widget.labelStyle ?? const TextStyle(
        fontSize: 11,
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  void didUpdateWidget(CustomAppIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.app.iconPackId != widget.app.iconPackId) {
      _loadCustomIcon();
    }
  }
}
