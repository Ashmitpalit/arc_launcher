import 'package:flutter/material.dart';
import '../models/remote_config.dart';
import '../services/remote_controls_service.dart';
import '../utils/theme.dart';

class RemoteControlsScreen extends StatefulWidget {
  const RemoteControlsScreen({super.key});

  @override
  State<RemoteControlsScreen> createState() => _RemoteControlsScreenState();
}

class _RemoteControlsScreenState extends State<RemoteControlsScreen>
    with SingleTickerProviderStateMixin {
  final RemoteControlsService _remoteService = RemoteControlsService();
  late TabController _tabController;
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeRemoteControls();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeRemoteControls() async {
    setState(() => _isLoading = true);
    try {
      await _remoteService.initialize();
    } catch (e) {
      print('Error initializing Remote Controls: $e');
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
          '⚙️ Remote Controls',
          style: TextStyle(color: Colors.white, fontSize: 24),
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
            onPressed: _initializeRemoteControls,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(text: 'Dashboard'),
            Tab(text: 'Configs'),
            Tab(text: 'Cohorts'),
            Tab(text: 'Settings'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDashboardTab(),
                _buildConfigsTab(),
                _buildCohortsTab(),
                _buildSettingsTab(),
              ],
            ),
    );
  }

  Widget _buildDashboardTab() {
    final stats = _remoteService.getRemoteControlsStats();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('📊 Overview'),
          const SizedBox(height: 16),
          
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildStatCard('Total Configs', stats['totalConfigs'].toString(), Icons.settings, Colors.blue),
              _buildStatCard('Enabled', stats['enabledConfigs'].toString(), Icons.toggle_on, Colors.green),
              _buildStatCard('Critical', stats['criticalConfigs'].toString(), Icons.priority_high, Colors.red),
              _buildStatCard('A/B Tests', stats['abtestConfigs'].toString(), Icons.science, Colors.purple),
              _buildStatCard('Total Cohorts', stats['totalCohorts'].toString(), Icons.people, Colors.orange),
              _buildStatCard('Total Users', stats['totalUsers'].toString(), Icons.person, Colors.teal),
            ],
          ),
          
          const SizedBox(height: 24),
          
          _buildSectionHeader('👤 Current User Context'),
          const SizedBox(height: 16),
          _buildUserContextCard(stats['userContext']),
          
          const SizedBox(height: 24),
          
          _buildSectionHeader('🚨 Critical Configurations'),
          const SizedBox(height: 16),
          ..._remoteService.criticalConfigs.take(3).map((config) => _buildCriticalConfigCard(config)),
        ],
      ),
    );
  }

  Widget _buildConfigsTab() {
    return const Center(
      child: Text(
        'Configurations Tab - Coming Soon!',
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  Widget _buildCohortsTab() {
    return const Center(
      child: Text(
        'Cohorts Tab - Coming Soon!',
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  Widget _buildSettingsTab() {
    return const Center(
      child: Text(
        'Settings Tab - Coming Soon!',
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUserContextCard(Map<String, dynamic> userContext) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person,
                color: Colors.green,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'User Information',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          ...userContext.entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Text(
                  '${entry.key}: ',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  entry.value.toString(),
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildCriticalConfigCard(RemoteConfig config) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.priority_high,
                color: Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                config.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'CRITICAL',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            config.description,
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 14,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Updated: ${config.formattedLastUpdated} by ${config.updatedBy}',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

