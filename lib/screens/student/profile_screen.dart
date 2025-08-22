import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _departmentController;
  late TextEditingController _semesterController;
  late TextEditingController _batchController;
  late TextEditingController _contactController;

  @override
  void initState() {
    super.initState();
    final userProfile = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).userProfile;

    _nameController = TextEditingController(text: userProfile?.name ?? '');
    _emailController = TextEditingController(text: userProfile?.email ?? '');
    _departmentController = TextEditingController(
      text: userProfile?.department ?? '',
    );
    _semesterController = TextEditingController(
      text: userProfile?.semester ?? '',
    );
    _batchController = TextEditingController(text: userProfile?.batch ?? '');
    _contactController = TextEditingController(
      text: userProfile?.contactNumber ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _departmentController.dispose();
    _semesterController.dispose();
    _batchController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/dashboard'),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to Dashboard',
        ),
        title: const Text('Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isEditing) ...[
            TextButton(
              onPressed: () => setState(() => _isEditing = false),
              child: const Text('Cancel'),
            ),
            TextButton(onPressed: _saveProfile, child: const Text('Save')),
          ],
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final userProfile = authProvider.userProfile;

          if (userProfile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Profile Picture Section
                  const SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[200],
                        child: const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey,
                        ),
                      ),
                      if (_isEditing)
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () {
                              // TODO: Implement image picker
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Image picker will be implemented',
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // User Info Cards
                  _buildInfoCard(
                    title: 'Personal Information',
                    children: [
                      _buildFormField(
                        controller: _nameController,
                        label: 'Full Name',
                        icon: Icons.person,
                        enabled: _isEditing,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Name is required';
                          }
                          return null;
                        },
                      ),
                      _buildFormField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email,
                        enabled: false, // Email should not be editable
                      ),
                      if (userProfile.studentId != null)
                        _buildFormField(
                          controller: TextEditingController(
                            text: userProfile.studentId,
                          ),
                          label: 'Student ID',
                          icon: Icons.badge,
                          enabled: false, // Student ID should not be editable
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _buildInfoCard(
                    title: 'Academic Information',
                    children: [
                      _buildFormField(
                        controller: _departmentController,
                        label: 'Department',
                        icon: Icons.school,
                        enabled: _isEditing,
                      ),
                      if (userProfile.semester != null)
                        _buildFormField(
                          controller: _semesterController,
                          label: 'Semester',
                          icon: Icons.calendar_today,
                          enabled: _isEditing,
                        ),
                      if (userProfile.batch != null)
                        _buildFormField(
                          controller: _batchController,
                          label: 'Batch',
                          icon: Icons.group,
                          enabled: _isEditing,
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _buildInfoCard(
                    title: 'Contact Information',
                    children: [
                      _buildFormField(
                        controller: _contactController,
                        label: 'Contact Number',
                        icon: Icons.phone,
                        enabled: _isEditing,
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Settings Section
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.brightness_6),
                          title: const Text('Theme'),
                          trailing: Consumer<ThemeProvider>(
                            builder: (context, themeProvider, child) {
                              return Switch(
                                value: themeProvider.isDarkMode,
                                onChanged: (value) =>
                                    themeProvider.toggleTheme(),
                              );
                            },
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.logout, color: Colors.red),
                          title: const Text(
                            'Logout',
                            style: TextStyle(color: Colors.red),
                          ),
                          onTap: _showLogoutDialog,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        validator: validator,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
          filled: !enabled,
          fillColor: enabled ? null : Colors.grey[100],
        ),
      ),
    );
  }

  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement profile update in Supabase
      setState(() => _isEditing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await Provider.of<AuthProvider>(context, listen: false).signOut();
              if (mounted) context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
