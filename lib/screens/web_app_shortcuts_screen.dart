import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/theme.dart';

class WebAppShortcut {
  final String id;
  final String name;
  final String url;
  final String iconUrl;
  final DateTime addedDate;
  final String category;
  final bool isPinned;
  final int usageCount;

  WebAppShortcut({
    required this.id,
    required this.name,
    required this.url,
    required this.iconUrl,
    required this.addedDate,
    required this.category,
    this.isPinned = false,
    this.usageCount = 0,
  });
}

class WebAppShortcutsScreen extends StatefulWidget {
  const WebAppShortcutsScreen({super.key});

  @override
  State<WebAppShortcutsScreen> createState() => _WebAppShortcutsScreenState();
}

class _WebAppShortcutsScreenState extends State<WebAppShortcutsScreen> {
  final List<WebAppShortcut> _shortcuts = [
    WebAppShortcut(
      id: '1',
      name: 'Gmail',
      url: 'https://mail.google.com',
      iconUrl: 'https://via.placeholder.com/64x64/EA4335/FFFFFF?text=G',
      addedDate: DateTime.now().subtract(const Duration(days: 5)),
      category: 'Productivity',
      usageCount: 15,
    ),
    WebAppShortcut(
      id: '2',
      name: 'Google Drive',
      url: 'https://drive.google.com',
      iconUrl: 'https://via.placeholder.com/64x64/4285F4/FFFFFF?text=D',
      addedDate: DateTime.now().subtract(const Duration(days: 3)),
      category: 'Productivity',
      usageCount: 8,
    ),
    WebAppShortcut(
      id: '3',
      name: 'YouTube',
      url: 'https://youtube.com',
      iconUrl: 'https://via.placeholder.com/64x64/FF0000/FFFFFF?text=Y',
      addedDate: DateTime.now().subtract(const Duration(days: 1)),
      category: 'Entertainment',
      usageCount: 25,
    ),
    WebAppShortcut(
      id: '4',
      name: 'Spotify',
      url: 'https://open.spotify.com',
      iconUrl: 'https://via.placeholder.com/64x64/1DB954/FFFFFF?text=S',
      addedDate: DateTime.now().subtract(const Duration(hours: 12)),
      category: 'Entertainment',
      usageCount: 12,
    ),
  ];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _showAddShortcutDialog() {
    _nameController.clear();
    _urlController.clear();
    _categoryController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
        title: const Text(
          'Add Web App Shortcut',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'App Name',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.primaryColor),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'URL',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.primaryColor),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Category',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.primaryColor),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.isNotEmpty && _urlController.text.isNotEmpty) {
                final newShortcut = WebAppShortcut(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: _nameController.text,
                  url: _urlController.text,
                  iconUrl: 'https://via.placeholder.com/64x64/666666/FFFFFF?text=${_nameController.text[0].toUpperCase()}',
                  addedDate: DateTime.now(),
                  category: _categoryController.text.isNotEmpty ? _categoryController.text : 'Other',
                );
                
                setState(() {
                  _shortcuts.add(newShortcut);
                });
                
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  void _removeShortcut(String id) {
    setState(() {
      _shortcuts.removeWhere((shortcut) => shortcut.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Web App Shortcuts',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _showAddShortcutDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header info
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  '${_shortcuts.length} Web Apps',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Quick access to your favorite web apps',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          // Shortcuts grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: _shortcuts.length,
              itemBuilder: (context, index) {
                final shortcut = _shortcuts[index];
                return _buildShortcutCard(shortcut);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutCard(WebAppShortcut shortcut) {
    return GestureDetector(
      onTap: () => _launchUrl(shortcut.url),
      onLongPress: () => _showShortcutOptions(shortcut),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: shortcut.isPinned ? AppTheme.primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: shortcut.iconUrl.startsWith('http')
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        shortcut.iconUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Text(
                              shortcut.name[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Center(
                      child: Text(
                        shortcut.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
            
            const SizedBox(height: 12),
            
            // App name
            Text(
              shortcut.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 4),
            
            // Category
            Text(
              shortcut.category,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
            
            if (shortcut.isPinned) ...[
              const SizedBox(height: 4),
              const Icon(
                Icons.push_pin,
                color: AppTheme.primaryColor,
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showShortcutOptions(WebAppShortcut shortcut) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.open_in_new, color: Colors.white),
              title: const Text('Open', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.of(context).pop();
                _launchUrl(shortcut.url);
              },
            ),
            ListTile(
              leading: Icon(
                shortcut.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                color: Colors.white,
              ),
              title: Text(
                shortcut.isPinned ? 'Unpin' : 'Pin',
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.of(context).pop();
                setState(() {
                  final index = _shortcuts.indexWhere((s) => s.id == shortcut.id);
                  if (index != -1) {
                    _shortcuts[index] = WebAppShortcut(
                      id: shortcut.id,
                      name: shortcut.name,
                      url: shortcut.url,
                      iconUrl: shortcut.iconUrl,
                      addedDate: shortcut.addedDate,
                      category: shortcut.category,
                      isPinned: !shortcut.isPinned,
                      usageCount: shortcut.usageCount,
                    );
                  }
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.white),
              title: const Text('Edit', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.of(context).pop();
                _showEditShortcutDialog(shortcut);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Remove', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.of(context).pop();
                _removeShortcut(shortcut.id);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showEditShortcutDialog(WebAppShortcut shortcut) {
    _nameController.text = shortcut.name;
    _urlController.text = shortcut.url;
    _categoryController.text = shortcut.category;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
        title: const Text(
          'Edit Web App Shortcut',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'App Name',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.primaryColor),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'URL',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.primaryColor),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Category',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.primaryColor),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.isNotEmpty && _urlController.text.isNotEmpty) {
                setState(() {
                  final index = _shortcuts.indexWhere((s) => s.id == shortcut.id);
                  if (index != -1) {
                    _shortcuts[index] = WebAppShortcut(
                      id: shortcut.id,
                      name: _nameController.text,
                      url: _urlController.text,
                      iconUrl: shortcut.iconUrl,
                      addedDate: shortcut.addedDate,
                      category: _categoryController.text.isNotEmpty ? _categoryController.text : 'Other',
                      isPinned: shortcut.isPinned,
                      usageCount: shortcut.usageCount,
                    );
                  }
                });
                
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

