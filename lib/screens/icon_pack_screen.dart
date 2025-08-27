import 'package:flutter/material.dart';
import '../models/icon_pack.dart';
import '../services/icon_pack_service.dart';
import '../utils/theme.dart';

class IconPackScreen extends StatefulWidget {
  const IconPackScreen({super.key});

  @override
  State<IconPackScreen> createState() => _IconPackScreenState();
}

class _IconPackScreenState extends State<IconPackScreen> {
  late IconPackService _iconPackService;
  IconPack? _currentIconPack;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _iconPackService = IconPackService.instance;
    _loadCurrentIconPack();
  }

  Future<void> _loadCurrentIconPack() async {
    setState(() => _isLoading = true);
    try {
      _currentIconPack = await _iconPackService.getCurrentIconPack();
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectIconPack(IconPack iconPack) async {
    try {
      await _iconPackService.setCurrentIconPack(iconPack.id);
      setState(() {
        _currentIconPack = iconPack;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${iconPack.name} icon pack applied!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to apply icon pack: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Icon Packs',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadCurrentIconPack,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCurrentIconPackSection(),
                  const SizedBox(height: 24),
                  _buildAvailableIconPacksSection(),
                  const SizedBox(height: 24),
                  _buildActionsSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildCurrentIconPackSection() {
    if (_currentIconPack == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Icon Pack',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: const Color(0xFF212121),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getIconPackColor(_currentIconPack!.id),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _getIconPackIcon(_currentIconPack!.id),
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentIconPack!.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currentIconPack!.description,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'by ${_currentIconPack!.author}',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Active',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailableIconPacksSection() {
    final availablePacks = _iconPackService.getAllIconPacks();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Icon Packs',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ...availablePacks.map((pack) => _buildIconPackTile(pack)),
      ],
    );
  }

  Widget _buildIconPackTile(IconPack iconPack) {
    final isCurrent = _currentIconPack?.id == iconPack.id;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF212121),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getIconPackColor(iconPack.id),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getIconPackIcon(iconPack.id),
            color: Colors.white,
            size: 25,
          ),
        ),
        title: Text(
          iconPack.name,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              iconPack.description,
              style: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 12),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'by ${iconPack.author}',
                  style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 11),
                ),
                const SizedBox(width: 8),
                Text(
                  'v${iconPack.version}',
                  style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        trailing: isCurrent
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Active',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : TextButton(
                onPressed: () => _selectIconPack(iconPack),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Apply'),
              ),
        onTap: isCurrent ? null : () => _selectIconPack(iconPack),
      ),
    );
  }

  Widget _buildActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        _buildActionTile(
          'Export Icon Pack Settings',
          'Save your current icon pack configuration',
          Icons.download,
          () => _exportSettings(),
        ),
        _buildActionTile(
          'Import Custom Icon Pack',
          'Add your own custom icon pack',
          Icons.upload,
          () => _importCustomPack(),
        ),
        _buildActionTile(
          'Reset to Default',
          'Restore Material Design icons',
          Icons.restore,
          () => _resetToDefault(),
        ),
      ],
    );
  }

  Widget _buildActionTile(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF212121),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 12),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
        onTap: onTap,
      ),
    );
  }

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

  Future<void> _exportSettings() async {
    try {
      await _iconPackService.exportIconPackSettings();
      // In a real app, you'd save this to a file or share it
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Icon pack settings exported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _importCustomPack() async {
    // Show dialog for custom icon pack import
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF212121),
        title: const Text(
          'Import Custom Icon Pack',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Custom icon pack import feature is coming soon! You can currently use the built-in icon packs.',
          style: TextStyle(color: Color(0xFFBDBDBD)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetToDefault() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF212121),
        title: const Text(
          'Reset to Default',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to reset to Material Design icons?',
          style: TextStyle(color: Color(0xFFBDBDBD)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _iconPackService.resetToDefault();
        await _loadCurrentIconPack();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reset to Material Design icons'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to reset: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
