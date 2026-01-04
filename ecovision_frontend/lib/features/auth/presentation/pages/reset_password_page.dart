import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/data/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reset Password Screen
class ResetPasswordPage extends StatefulWidget {
  final String? token;

  const ResetPasswordPage({super.key, this.token});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _resetToken;

  @override
  void initState() {
    super.initState();
    _loadToken();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _passwordFocusNode.requestFocus();
    });
    _passwordController.addListener(() => setState(() {}));
    _confirmPasswordController.addListener(() => setState(() {}));
  }

  Future<void> _loadToken() async {
    // Get token from route parameter or stored token (for testing)
    String? token = widget.token;
    if (token == null) {
      final authService = AuthService();
      token = await authService.getResetToken();
    }
    setState(() {
      _resetToken = token;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_resetToken == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Token không hợp lệ',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Link khôi phục mật khẩu không hợp lệ hoặc đã hết hạn',
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Quay lại'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 32),

                // Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, size: 24),
                    color: const Color(0xFF1A1A1A),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                const SizedBox(height: 8),

                // Lock Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.lock_reset,
                      size: 28,
                      color: AppColors.primaryLight,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                Text(
                  'Đặt lại mật khẩu',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A1A),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Nhập mật khẩu mới của bạn',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: const Color(0xFF666666),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Form Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE0E0E0).withOpacity(0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Password Field
                      _buildPasswordField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        label: 'Mật khẩu mới',
                        hint: 'Nhập mật khẩu mới',
                        obscureText: _obscurePassword,
                        onToggleVisibility: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mật khẩu';
                          }
                          if (value.length < 8) {
                            return 'Mật khẩu phải có ít nhất 8 ký tự';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Confirm Password Field
                      _buildPasswordField(
                        controller: _confirmPasswordController,
                        focusNode: _confirmPasswordFocusNode,
                        label: 'Xác nhận mật khẩu',
                        hint: 'Nhập lại mật khẩu',
                        obscureText: _obscureConfirmPassword,
                        onToggleVisibility: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng xác nhận mật khẩu';
                          }
                          if (value != _passwordController.text) {
                            return 'Mật khẩu không khớp';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Reset Button
                      _buildResetButton(),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) {
            if (label.contains('Xác nhận')) {
              _handleResetPassword();
            } else {
              _confirmPasswordFocusNode.requestFocus();
            }
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 16,
              color: const Color(0xFF999999),
            ),
            prefixIcon: const Icon(
              Icons.lock_outline,
              size: 20,
              color: Color(0xFF666666),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 20,
                color: const Color(0xFF666666),
              ),
              onPressed: onToggleVisibility,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
          style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFF1A1A1A)),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildResetButton() {
    final isValid = _passwordController.text.isNotEmpty &&
        _passwordController.text.length >= 8 &&
        _confirmPasswordController.text.isNotEmpty &&
        _confirmPasswordController.text == _passwordController.text;

    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryLight.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: (isValid && !_isLoading) ? _handleResetPassword : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          disabledBackgroundColor: AppColors.primaryLight.withOpacity(0.6),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Đặt lại mật khẩu',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      await authService.resetPassword(_resetToken!, _passwordController.text.trim());

      // Clear stored token
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('reset_token');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show success dialog and navigate to login
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        _showErrorDialog(e.toString());
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.primaryLight,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Thành công!',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Mật khẩu đã được đặt lại thành công. Vui lòng đăng nhập lại.',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: Text(
              'Đăng nhập',
              style: GoogleFonts.inter(
                color: AppColors.primaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Lỗi',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Đóng',
              style: GoogleFonts.inter(
                color: AppColors.primaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }
}

