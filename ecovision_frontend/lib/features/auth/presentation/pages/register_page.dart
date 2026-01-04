import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/services/auth_service.dart';
import '../../data/models/auth_models.dart';

/// Modern Sign Up Screen for EcoVision
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _agreeToTerms = false;

  @override
  void initState() {
    super.initState();
    // Autofocus on name field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameFocusNode.requestFocus();
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
                    color: const Color(0xFF222222),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                const SizedBox(height: 8),

                // App Icon/Logo - Rocket (48px)
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      '🚀',
                      style: TextStyle(fontSize: 28),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Title: "Tạo tài khoản mới"
                Text(
                  'Tạo tài khoản mới',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF222222),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // Subtitle: "Tham gia EcoVision ngay"
                Text(
                  'Tham gia EcoVision ngay',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: const Color(0xFF666666),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Form Fields
                _buildNameField(),
                const SizedBox(height: 16),
                _buildEmailField(),
                const SizedBox(height: 16),
                _buildPasswordField(),

                const SizedBox(height: 16),

                // Terms and Privacy Checkbox
                _buildTermsCheckbox(),

                const SizedBox(height: 24),

                // Sign Up Button
                _buildSignUpButton(),

                const SizedBox(height: 24),

                // Divider with "HOẶC"
                _buildDivider(),

                const SizedBox(height: 24),

                // Social Sign Up Buttons
                _buildSocialButton(
                  icon: Icons.facebook,
                  label: 'Đăng ký với Facebook',
                  color: const Color(0xFF1877F3),
                  onTap: () {
                    // TODO: OAuth Facebook
                  },
                ),

                const SizedBox(height: 12),

                _buildSocialButton(
                  icon: Icons.g_mobiledata,
                  label: 'Đăng ký với Google',
                  color: const Color(0xFFEA4335),
                  onTap: () {
                    // TODO: OAuth Google
                  },
                ),

                const SizedBox(height: 24),

                // Footer: "Đã có tài khoản? Đăng nhập ngay"
                _buildLoginRedirect(),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          'Họ và tên',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF222222),
          ),
        ),
        const SizedBox(height: 8),
        // Input Field
        TextFormField(
          controller: _nameController,
          focusNode: _nameFocusNode,
          textInputAction: TextInputAction.next,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Nguyễn Văn A',
            hintStyle: GoogleFonts.inter(
              fontSize: 16,
              color: const Color(0xFF999999),
            ),
            prefixIcon: const Icon(
              Icons.person_outline,
              size: 20,
              color: Color(0xFFBDBDBD),
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
          style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFF222222)),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập họ và tên';
            }
            if (value.trim().length < 2) {
              return 'Họ và tên phải có ít nhất 2 ký tự';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          'Email',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF222222),
          ),
        ),
        const SizedBox(height: 8),
        // Input Field
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
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
          style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFF222222)),
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
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          'Mật khẩu',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF222222),
          ),
        ),
        const SizedBox(height: 8),
        // Input Field
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _handleSignUp(),
          decoration: InputDecoration(
            hintText: '********',
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
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
                color: const Color(0xFF666666),
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
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
          style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFF222222)),
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
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: Checkbox(
            value: _agreeToTerms,
            onChanged: (value) {
              setState(() {
                _agreeToTerms = value ?? false;
              });
            },
            activeColor: AppColors.primaryLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _agreeToTerms = !_agreeToTerms;
              });
            },
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF222222),
                ),
                children: [
                  const TextSpan(text: 'Tôi đồng ý với '),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () => _showTermsDialog(),
                      child: Text(
                        'Điều khoản dịch vụ',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.primaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const TextSpan(text: ' và '),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () => _showPrivacyDialog(),
                      child: Text(
                        'Chính sách bảo mật',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.primaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
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
        onPressed: (_agreeToTerms && !_isLoading) ? _handleSignUp : null,
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
                'Đăng ký',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.grey[300],
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'HOẶC',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF999999),
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.grey[300],
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF222222),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginRedirect() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Đã có tài khoản? ',
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
            'Đăng nhập ngay',
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

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đồng ý với Điều khoản dịch vụ và Chính sách bảo mật'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final registerRequest = RegisterRequest(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
      );

      final authResponse = await _authService.register(registerRequest);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng ký thành công! Vui lòng đăng nhập.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate back to login
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đăng ký thất bại: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Điều khoản dịch vụ',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Điều khoản dịch vụ của EcoVision...\n\n'
          'Bằng việc sử dụng ứng dụng EcoVision, bạn đồng ý với các điều khoản và điều kiện sử dụng.',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Đóng',
              style: GoogleFonts.inter(color: AppColors.primaryLight),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Chính sách bảo mật',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Chính sách bảo mật của EcoVision...\n\n'
          'Chúng tôi cam kết bảo vệ thông tin cá nhân của bạn và tuân thủ các quy định về bảo mật dữ liệu.',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Đóng',
              style: GoogleFonts.inter(color: AppColors.primaryLight),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }
}

