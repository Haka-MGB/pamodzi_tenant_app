import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../services/auth_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _authService = AuthService();
  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  
  bool _isLoading = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    // Validate inputs
    if (_currentPasswordCtrl.text.isEmpty) {
      showToast('Please enter your current password');
      return;
    }

    if (_newPasswordCtrl.text.isEmpty) {
      showToast('Please enter a new password');
      return;
    }

    if (_newPasswordCtrl.text.length < 6) {
      showToast('New password must be at least 6 characters');
      return;
    }

    if (_newPasswordCtrl.text != _confirmPasswordCtrl.text) {
      showToast('Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _authService.changePassword(
        currentPassword: _currentPasswordCtrl.text,
        newPassword: _newPasswordCtrl.text,
      );

      setState(() => _isLoading = false);

      if (!mounted) return;

      if (result.success) {
        showToast(result.message);
        Navigator.pop(context);
      } else {
        showToast(result.message);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        showToast('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? PamodziColors.bgDark : PamodziColors.bg;
    final surfaceColor = isDark ? PamodziColors.surfaceDark : PamodziColors.surface;
    final borderColor = isDark ? PamodziColors.borderDark : PamodziColors.border;
    final textColor = isDark ? PamodziColors.textDark : PamodziColors.text;
    final mutedColor = isDark ? PamodziColors.mutedDark : PamodziColors.muted;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            SubHeader(title: 'Change Password'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel(label: 'Current Password'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _currentPasswordCtrl,
                        obscureText: _obscureCurrent,
                        style: TextStyle(fontSize: 14, color: textColor),
                        decoration: InputDecoration(
                          hintText: 'Enter current password',
                          hintStyle: TextStyle(color: mutedColor),
                          filled: true,
                          fillColor: bgColor,
                          suffixIcon: GestureDetector(
                            onTap: () => setState(() => _obscureCurrent = !_obscureCurrent),
                            child: Icon(
                              _obscureCurrent ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: mutedColor,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _FieldLabel(label: 'New Password'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _newPasswordCtrl,
                        obscureText: _obscureNew,
                        style: TextStyle(fontSize: 14, color: textColor),
                        decoration: InputDecoration(
                          hintText: 'Enter new password (min 6 characters)',
                          hintStyle: TextStyle(color: mutedColor),
                          filled: true,
                          fillColor: bgColor,
                          suffixIcon: GestureDetector(
                            onTap: () => setState(() => _obscureNew = !_obscureNew),
                            child: Icon(
                              _obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: mutedColor,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _FieldLabel(label: 'Confirm New Password'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _confirmPasswordCtrl,
                        obscureText: _obscureConfirm,
                        style: TextStyle(fontSize: 14, color: textColor),
                        decoration: InputDecoration(
                          hintText: 'Re-enter new password',
                          hintStyle: TextStyle(color: mutedColor),
                          filled: true,
                          fillColor: bgColor,
                          suffixIcon: GestureDetector(
                            onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
                            child: Icon(
                              _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: mutedColor,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      PamodziButton(
                        label: 'Change Password',
                        icon: Icons.lock_outline,
                        isLoading: _isLoading,
                        onTap: _changePassword,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? PamodziColors.mutedDark : PamodziColors.muted;
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
        color: mutedColor,
        letterSpacing: 0.8,
      ),
    );
  }
}
