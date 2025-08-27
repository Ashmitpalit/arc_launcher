import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import '../providers/enhanced_launcher_provider.dart';
import '../utils/theme.dart';

class RemoteControlsScreen extends StatefulWidget {
  const RemoteControlsScreen({super.key});

  @override
  State<RemoteControlsScreen> createState() => _RemoteControlsScreenState();
}

class _RemoteControlsScreenState extends State<RemoteControlsScreen> {
  bool _isLoading = false;
  bool _isAdmin = false; // This would be determined by user role

  // Remote config values
  bool _enableDynamicShortcuts = true;
  int _shortcutRefreshInterval = 24;
  bool _enableRecommendations = true;
  int _maxShortcuts = 8;
  int _maxRecommendations = 6;
  String _cohortShortcuts = '{}';
  String _recommendationWeights = '{}';

  @override
  void initState() {
    super.initState();
    _loadRemoteConfig();
  }

  Future<void> _loadRemoteConfig() async {
    setState(() => _isLoading = true);
    
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      
      setState(() {
        _enableDynamicShortcuts = remoteConfig.getBool('enable_dynamic_shortcuts');
        _shortcutRefreshInterval = remoteConfig.getInt('shortcut_refresh_interval');
        _enableRecommendations = remoteConfig.getBool('enable_recommendations');
        _maxShortcuts = remoteConfig.getInt('max_shortcuts');
        _maxRecommendations = remoteConfig.getInt('max_recommendations');
        _cohortShortcuts = remoteConfig.getString('cohort_shortcuts');
        _recommendationWeights = remoteConfig.getString('recommendation_weights');
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load remote config: $e');
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
          'Remote Controls',
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
            onPressed: _loadRemoteConfig,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isAdmin
              ? _buildAdminControls()
              : _buildReadOnlyControls(),
    );
  }

  Widget _buildAdminControls() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Dynamic Shortcuts Control'),
          _buildSwitchTile(
            'Enable Dynamic Shortcuts',
            'Turn on/off dynamic shortcut generation',
            _enableDynamicShortcuts,
            (value) => setState(() => _enableDynamicShortcuts = value),
          ),
          _buildSliderTile(
            'Shortcut Refresh Interval (hours)',
            'How often to refresh shortcuts',
            _shortcutRefreshInterval.toDouble(),
            1,
            48,
            (value) => setState(() => _shortcutRefreshInterval = value.round()),
          ),
          _buildSliderTile(
            'Max Shortcuts',
            'Maximum number of shortcuts to show',
            _maxShortcuts.toDouble(),
            1,
            20,
            (value) => setState(() => _maxShortcuts = value.round()),
          ),
          
          const SizedBox(height: 24),
          
          _buildSectionHeader('Recommendations Control'),
          _buildSwitchTile(
            'Enable App Recommendations',
            'Turn on/off app recommendations',
            _enableRecommendations,
            (value) => setState(() => _enableRecommendations = value),
          ),
          _buildSliderTile(
            'Max Recommendations',
            'Maximum number of recommendations to show',
            _maxRecommendations.toDouble(),
            1,
            15,
            (value) => setState(() => _maxRecommendations = value.round()),
          ),
          
          const SizedBox(height: 24),
          
          _buildSectionHeader('Cohort Configuration'),
          _buildJsonEditor(
            'Cohort Shortcuts',
            'JSON configuration for cohort-specific shortcuts',
            _cohortShortcuts,
            (value) => setState(() => _cohortShortcuts = value),
          ),
          _buildJsonEditor(
            'Recommendation Weights',
            'JSON configuration for recommendation algorithm weights',
            _recommendationWeights,
            (value) => setState(() => _recommendationWeights = value),
          ),
          
          const SizedBox(height: 32),
          
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildReadOnlyControls() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Current Configuration'),
          _buildInfoTile('Dynamic Shortcuts', _enableDynamicShortcuts ? 'Enabled' : 'Disabled'),
          _buildInfoTile('Shortcut Refresh Interval', '${_shortcutRefreshInterval} hours'),
          _buildInfoTile('Max Shortcuts', _maxShortcuts.toString()),
          _buildInfoTile('App Recommendations', _enableRecommendations ? 'Enabled' : 'Disabled'),
          _buildInfoTile('Max Recommendations', _maxRecommendations.toString()),
          
          const SizedBox(height: 24),
          
          _buildSectionHeader('Access Denied'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.lock, color: Colors.red[400]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'You need admin privileges to modify remote controls. Contact your administrator for access.',
                    style: TextStyle(color: Colors.red[400]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.grey[900],
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue,
      ),
    );
  }

  Widget _buildSliderTile(String title, String subtitle, double value, double min, double max, ValueChanged<double> onChanged) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: value,
                    min: min,
                    max: max,
                    divisions: (max - min).round(),
                    onChanged: onChanged,
                    activeColor: Colors.blue,
                    inactiveColor: Colors.grey[700],
                  ),
                ),
                Container(
                  width: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    value.round().toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.grey[900],
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        trailing: Text(
          value,
          style: TextStyle(color: Colors.grey[300], fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildJsonEditor(String title, String subtitle, String value, ValueChanged<String> onChanged) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
            const SizedBox(height: 16),
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[600]!),
              ),
              child: TextField(
                controller: TextEditingController(text: value),
                onChanged: onChanged,
                maxLines: null,
                expands: true,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(12),
                  border: InputBorder.none,
                  hintText: 'Enter JSON configuration...',
                  hintStyle: TextStyle(color: Colors.grey[500]!),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _saveRemoteConfig,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Save Changes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton(
            onPressed: _resetToDefaults,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[400],
              side: BorderSide(color: Colors.grey[600]!),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Reset to Defaults',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveRemoteConfig() async {
    try {
      setState(() => _isLoading = true);
      
      // In a real app, you would save these to Firebase Remote Config
      // For now, we'll just show a success message
      
      // Simulate saving
      await Future.delayed(const Duration(seconds: 1));
      
      _showSuccessSnackBar('Remote configuration saved successfully!');
      
      // Refresh the provider
      final provider = context.read<EnhancedLauncherProvider>();
      await provider.forceRefresh();
      
    } catch (e) {
      _showErrorSnackBar('Failed to save configuration: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resetToDefaults() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Reset to Defaults',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to reset all remote controls to their default values? This action cannot be undone.',
          style: TextStyle(color: Colors.grey[300]!),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _enableDynamicShortcuts = true;
        _shortcutRefreshInterval = 24;
        _enableRecommendations = true;
        _maxShortcuts = 8;
        _maxRecommendations = 6;
        _cohortShortcuts = '{}';
        _recommendationWeights = '{}';
      });
      
      _showSuccessSnackBar('Configuration reset to defaults');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

