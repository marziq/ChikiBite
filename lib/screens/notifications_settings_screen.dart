import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../services/profile_service.dart';
import '../models/user.dart' as app_user;

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  app_user.User? _currentUser;
  bool _isLoading = true;

  // Default notification settings
  Map<String, bool> _settings = {
    'orderUpdates': true,
    'promotions': true,
    'newItems': false,
    'newsletter': false,
  };

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final user = await profileService.getUserProfileOnce(uid);
      if (mounted) {
        setState(() {
          _currentUser = user;
          if (user?.notificationSettings != null) {
            _settings = {..._settings, ...user!.notificationSettings!};
          }
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateSetting(String key, bool value) async {
    setState(() {
      _settings[key] = value;
    });

    final uid = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        await profileService.updateNotificationSettings(uid, _settings);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
          // Revert the change
          setState(() {
            _settings[key] = !value;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header Card
                Card(
                  color: Colors.orange[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.notifications_active,
                          color: Colors.orange[700],
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Stay Updated',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[900],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Manage your notification preferences',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Order Updates Section
                Text(
                  'Order Notifications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),
                _buildSettingTile(
                  title: 'Order Updates',
                  subtitle: 'Get notified about your order status',
                  icon: Icons.shopping_bag_outlined,
                  value: _settings['orderUpdates'] ?? true,
                  onChanged: (value) => _updateSetting('orderUpdates', value),
                ),
                const SizedBox(height: 24),

                // Marketing Section
                Text(
                  'Marketing & Promotions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),
                _buildSettingTile(
                  title: 'Promotions & Offers',
                  subtitle: 'Receive special deals and discounts',
                  icon: Icons.local_offer_outlined,
                  value: _settings['promotions'] ?? true,
                  onChanged: (value) => _updateSetting('promotions', value),
                ),
                const SizedBox(height: 8),
                _buildSettingTile(
                  title: 'New Menu Items',
                  subtitle: 'Be the first to know about new dishes',
                  icon: Icons.restaurant_menu_outlined,
                  value: _settings['newItems'] ?? false,
                  onChanged: (value) => _updateSetting('newItems', value),
                ),
                const SizedBox(height: 8),
                _buildSettingTile(
                  title: 'Newsletter',
                  subtitle: 'Weekly updates and food recommendations',
                  icon: Icons.mail_outline,
                  value: _settings['newsletter'] ?? false,
                  onChanged: (value) => _updateSetting('newsletter', value),
                ),
                const SizedBox(height: 24),

                // Info Card
                Card(
                  color: Colors.blue[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue[700],
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'You can change these settings anytime. Some notifications may still be sent for important account activities.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue[900],
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        secondary: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.orange[800]),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ),
        value: value,
        activeColor: Colors.orange[700],
        onChanged: onChanged,
      ),
    );
  }
}
