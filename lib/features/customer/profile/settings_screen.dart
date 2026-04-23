import 'package:flutter/material.dart';
import 'package:water_delivery_app/core/constants/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _darkMode = false;
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'TZS';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Preferences
            _buildSection('Preferences', [
              _buildSwitchTile(
                'Dark Mode',
                'Switch to dark theme',
                _darkMode,
                (value) {
                  setState(() {
                    _darkMode = value;
                  });
                },
                Icons.dark_mode,
              ),
              _buildDropdownTile(
                'Language',
                'Select your preferred language',
                _selectedLanguage,
                ['English', 'Swahili', 'French'],
                (value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                },
                Icons.language,
              ),
              _buildDropdownTile(
                'Currency',
                'Select your currency',
                _selectedCurrency,
                ['TZS', 'USD', 'EUR'],
                (value) {
                  setState(() {
                    _selectedCurrency = value!;
                  });
                },
                Icons.attach_money,
              ),
            ]),
            
            // Notifications
            _buildSection('Notifications', [
              _buildSwitchTile(
                'Push Notifications',
                'Receive order updates and offers',
                _notificationsEnabled,
                (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
                Icons.notifications_active,
              ),
              _buildSwitchTile(
                'Email Notifications',
                'Receive email updates',
                _emailNotifications,
                (value) {
                  setState(() {
                    _emailNotifications = value;
                  });
                },
                Icons.email,
              ),
              _buildSwitchTile(
                'SMS Notifications',
                'Receive SMS updates',
                _smsNotifications,
                (value) {
                  setState(() {
                    _smsNotifications = value;
                  });
                },
                Icons.sms,
              ),
            ]),
            
            // Account
            _buildSection('Account', [
              _buildMenuItem(
                'Change Password',
                Icons.lock_outline,
                () {},
              ),
              _buildMenuItem(
                'Manage Payment Methods',
                Icons.credit_card,
                () {},
              ),
              _buildMenuItem(
                'Delete Account',
                Icons.delete_forever,
                () {
                  _showDeleteAccountDialog();
                },
                color: Colors.red,
              ),
            ]),
            
            // About
            _buildSection('About', [
              _buildMenuItem(
                'App Version',
                Icons.info_outline,
                () {},
                trailing: '1.0.0',
              ),
              _buildMenuItem(
                'Privacy Policy',
                Icons.privacy_tip_outlined,
                () {},
              ),
              _buildMenuItem(
                'Terms of Service',
                Icons.description_outlined,
                () {},
              ),
            ]),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.grey,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    IconData icon,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.grey)),
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.primary,
      secondary: Icon(icon, color: AppColors.primary),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    String value,
    List<String> items,
    Function(String?) onChanged,
    IconData icon,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.grey)),
      leading: Icon(icon, color: AppColors.primary),
      trailing: DropdownButton<String>(
        value: value,
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        underline: const SizedBox(),
      ),
    );
  }

  Widget _buildMenuItem(
    String title,
    IconData icon,
    VoidCallback onTap, {
    String? trailing,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.primary),
      title: Text(title, style: color != null ? TextStyle(color: color) : null),
      trailing: trailing != null
          ? Text(trailing, style: const TextStyle(color: AppColors.grey))
          : const Icon(Icons.chevron_right, color: AppColors.grey),
      onTap: onTap,
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion request sent'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
