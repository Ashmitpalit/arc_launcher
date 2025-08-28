import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/web_app_shortcut.dart';
import '../services/web_app_service.dart';
import '../utils/theme.dart';

class WebAppsScreen extends StatefulWidget {
  const WebAppsScreen({super.key});

  @override
  State<WebAppsScreen> createState() => _WebAppsScreenState();
}

class _WebAppsScreenState extends State<WebAppsScreen> {
  final WebAppService _webAppService = WebAppService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebApps();
  }

  Future<void> _initializeWebApps() async {
    setState(() => _isLoading = true);
    try {
      await _webAppService.initialize();
    } catch (e) {
      print('Error initializing web apps: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Web Apps',
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
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _showAddWebAppDialog,
            tooltip: 'Add Web App',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildWebAppsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddWebAppDialog,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildWebAppsList() {
    final webApps = _webAppService.webApps;
    
    if (webApps.isEmpty) {
      return _buildEmptyState();
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: webApps.length,
      itemBuilder: (context, index) {
        final webApp = webApps[index];
        return _buildWebAppCard(webApp);
      },
    );
  }

  Widget _buildWebAppCard(WebAppShortcut webApp) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withOpacity(0.2),
          child: Icon(Icons.language, color: Colors.blue),
        ),
        title: Text(
          webApp.title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              webApp.url,
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    webApp.category,
                    style: TextStyle(color: Colors.blue[300], fontSize: 10),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    webApp.cohort.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(color: Colors.green[300], fontSize: 10),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.launch, color: Colors.blue),
          onPressed: () => _launchWebApp(webApp),
          tooltip: 'Launch',
        ),
        onTap: () => _launchWebApp(webApp),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.language_outlined,
            size: 64,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'No web apps yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first web app to get started',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddWebAppDialog() {
    final urlController = TextEditingController();
    final titleController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Add Web App',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: urlController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'URL',
                labelStyle: TextStyle(color: Colors.grey[400]),
                hintText: 'https://example.com',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Colors.grey[400]),
                hintText: 'App Name',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => _addWebApp(urlController.text, titleController.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _addWebApp(String url, String title) async {
    if (url.isEmpty || title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('URL and title are required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    Navigator.pop(context);
    
    final success = await _webAppService.addWebApp(
      url: url.trim(),
      title: title.trim(),
      category: 'General',
      cohort: 'new_user',
    );
    
    if (success) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added web app: $title'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add web app'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _launchWebApp(WebAppShortcut webApp) async {
    try {
      await _webAppService.updateWebAppUsage(webApp.id);
      setState(() {});
      
      final url = Uri.parse(webApp.url);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error launching web app: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
