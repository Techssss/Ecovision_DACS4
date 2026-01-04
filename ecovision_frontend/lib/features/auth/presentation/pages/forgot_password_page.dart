import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/data/services/auth_service.dart';

/// Modern Forgot Password Screen for EcoVision
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isEmailSent = false;

  @override
  void initState() {
    super.initState();
    // Autofocus on email field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _emailFocusNode.requestFocus();
    });
    // Listen to email changes to update button state
    _emailController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
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

                // Back button (top-left)
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, size: 24),
                    color: const Color(0xFF1A1A1A),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                const SizedBox(height: 8),

                // Key Icon (48px, centered)
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      '🔑',
                      style: TextStyle(fontSize: 28),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Title: "Khôi phục mật khẩu"
                Text(
                  'Khôi phục mật khẩu',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A1A),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // Subtitle: "Nhập email đã đăng ký"
                Text(
                  'Nhập email đã đăng ký',
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
                    // Very soft shadow
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
                      // Email Label
                      Text(
                        'Email',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Email Input Field
                      TextFormField(
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        autofocus: true,
                        onFieldSubmitted: (_) => _handleSendResetLink(),
                        decoration: InputDecoration(
                          hintText: 'example@email.com',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 16,
                            color: const Color(0xFF999999),
                          ),
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            size: 20,
                            color: Color(0xFF666666),
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập email';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'Email không hợp lệ';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Send Reset Link Button
                      _buildSendButton(),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Info Boxes
                _buildInfoBoxes(),

                const SizedBox(height: 24),

                // Footer: "Nhớ mật khẩu? Đăng nhập"
                _buildLoginRedirect(),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    final isValid = _emailController.text.isNotEmpty &&
        _emailController.text.contains('@') &&
        _emailController.text.contains('.');

    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        // Shadow: 0px 6px 14px rgba(0,217,163,0.12)
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryLight.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: (isValid && !_isLoading) ? _handleSendResetLink : null,
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
                'Gửi link khôi phục',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildInfoBoxes() {
    return Column(
      children: [
        // Info Box 1: Check Spam
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3).withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF2196F3).withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline,
                size: 20,
                color: Color(0xFF2196F3),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF666666),
                    ),
                    children: [
                      const TextSpan(text: 'Kiểm tra hộp thư '),
                      TextSpan(
                        text: 'Spam',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF666666),
                        ),
                      ),
                      const TextSpan(text: ' nếu không thấy email'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Info Box 2: Link validity
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFB300).withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFFFB300).withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 20,
                color: Color(0xFFFFB300),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF666666),
                    ),
                    children: [
                      const TextSpan(text: 'Link có hiệu lực trong '),
                      TextSpan(
                        text: '1 giờ',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoginRedirect() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Nhớ mật khẩu? ',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF666666),
          ),
        ),
        GestureDetector(
          onTap: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/login');
            }
          },
          child: Text(
            'Đăng nhập',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryLight,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSendResetLink() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      await authService.forgotPassword(_emailController.text.trim());

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isEmailSent = true;
        });

        // Show success alert
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show error dialog
        _showErrorDialog(e.toString());
      }
    }
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
                'Đã gửi!',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Vui lòng kiểm tra email của bạn để nhận link khôi phục mật khẩu.',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // In debug mode, check if token was returned and navigate to reset page
              final authService = AuthService();
              final token = await authService.getResetToken();
              
              if (token != null && context.mounted) {
                // Navigate to reset password page with token
                Navigator.pushNamed(
                  context,
                  '/reset-password',
                  arguments: {'token': token},
                );
              } else {
                // In production, just close the page
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
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
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }
}

