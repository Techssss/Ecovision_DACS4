import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/services/auth_service.dart';
import '../../data/models/auth_models.dart';

/// Modern Login Screen for EcoVision
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Autofocus on email field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _emailFocusNode.requestFocus();
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

                // Back button (optional, top-left)
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, size: 24),
                    color: const Color(0xFF1A1A1A),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                const SizedBox(height: 8),

                // App Icon/Logo - Eco-friendly (48px)
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '🌿',
                      style: TextStyle(fontSize: 28),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Title: "Chào mừng trở lại!"
                Text(
                  'Chào mừng trở lại!',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A1A),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // Subtitle: "Đăng nhập để tiếp tục"
                Text(
                  'Đăng nhập để tiếp tục',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: const Color(0xFF666666),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Email Input Field
                _buildEmailField(),

                const SizedBox(height: 16),

                // Password Input Field
                _buildPasswordField(),

                const SizedBox(height: 12),

                // Forgot Password Link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/forgot-password');
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Quên mật khẩu?',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Login Button
                _buildLoginButton(),

                const SizedBox(height: 32),

                // Divider with "HOẶC"
                _buildDivider(),

                const SizedBox(height: 24),

                // Social Login Buttons
                _buildSocialButton(
                  icon: Icons.facebook,
                  label: 'Tiếp tục với Facebook',
                  color: const Color(0xFF1877F2),
                  onTap: () {
                    // TODO: OAuth Facebook
                  },
                ),

                const SizedBox(height: 12),

                _buildSocialButton(
                  icon: Icons.g_mobiledata,
                  label: 'Tiếp tục với Google',
                  color: const Color(0xFFDB4437),
                  onTap: () {
                    // TODO: OAuth Google
                  },
                ),

                const SizedBox(height: 24),

                // Sign-up Redirect
                _buildSignUpRedirect(),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
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
            color: const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        // Input Field
        TextFormField(
          controller: _emailController,
          focusNode: _emailFocusNode,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofocus: true,
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
            if (!value.contains('@')) {
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
            color: const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        // Input Field
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _handleLogin(),
          decoration: InputDecoration(
            hintText: '••••••••',
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
          style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFF1A1A1A)),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập mật khẩu';
            }
            if (value.length < 6) {
              return 'Mật khẩu phải có ít nhất 6 ký tự';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
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
        onPressed: _isLoading ? null : _handleLogin,
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
                'Đăng nhập',
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
            const SizedBox(width: 24),
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpRedirect() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Chưa có tài khoản? ',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF666666),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/register');
          },
          child: Text(
            'Đăng ký ngay',
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

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final loginRequest = LoginRequest(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final authResponse = await _authService.login(loginRequest);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Navigate to home on success
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đăng nhập thất bại: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }
}
