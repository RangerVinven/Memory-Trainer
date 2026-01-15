import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  
  User? _user;
  bool _isLoading = true;
  bool _isSaving = false;

  late TextEditingController _emailController;
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _loadUser();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final user = await _authService.getCurrentUser();
    if (mounted) {
      setState(() {
        _user = user;
        if (user != null) {
          _emailController.text = user.email;
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final success = await _authService.updateProfile(
      email: _emailController.text,
      currentPassword: _currentPasswordController.text,
      password: _newPasswordController.text,
      passwordConfirmation: _confirmPasswordController.text,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile. Check your current password.')),
        );
      }
    }
  }

  void _signOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3B82F6),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'ACCOUNT DETAILS',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 1.0),
                    ),
                    const SizedBox(height: 16),
                    _buildInputGroup('Email', _emailController, isRequired: true),
                    
                    const SizedBox(height: 32),
                    const Text(
                      'CHANGE PASSWORD',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 1.0),
                    ),
                    const SizedBox(height: 16),
                    _buildInputGroup('Current Password', _currentPasswordController, isPassword: true, isRequired: true, hint: 'Required to save changes'),
                    const SizedBox(height: 16),
                    _buildInputGroup('New Password', _newPasswordController, isPassword: true),
                    const SizedBox(height: 16),
                    _buildInputGroup('Confirm New Password', _confirmPasswordController, isPassword: true, validator: (val) {
                      if (_newPasswordController.text.isNotEmpty && val != _newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    }),

                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSaving
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),

                    const SizedBox(height: 40),
                    OutlinedButton(
                      onPressed: _signOut,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Sign Out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInputGroup(String label, TextEditingController controller, {bool isPassword = false, bool isRequired = false, String? hint, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            ),
            validator: validator ?? (isRequired ? (val) => val == null || val.isEmpty ? '$label is required' : null : null),
          ),
        ),
      ],
    );
  }
}