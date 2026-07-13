import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/app_state.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController(text: 'chanda.m@pamodzi.com');
  final _passCtrl = TextEditingController(text: 'rent2026');
  final _authService = AuthService();
  bool _loading = false;
  bool _showError = false;
  bool _obscurePass = true;
  String _errorMessage = '';

  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  Future<void> _doLogin() async {
    setState(() { 
      _showError = false;
      _errorMessage = '';
    });

    if (_emailCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) {
      setState(() { 
        _showError = true;
        _errorMessage = 'Please fill in all fields';
      });
      _shakeCtrl.forward(from: 0);
      return;
    }

    setState(() { _loading = true; });

    final result = await _authService.login(
      _emailCtrl.text.trim(),
      _passCtrl.text,
    );

    setState(() { _loading = false; });

    if (!mounted) return;

    if (result.success) {
      context.read<AppState>().login();
    } else {
      setState(() { 
        _showError = true;
        _errorMessage = result.message;
      });
      _shakeCtrl.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? PamodziColors.bgDark : PamodziColors.bg;
    final textColor = isDark ? PamodziColors.textDark : PamodziColors.text;
    final text2Color = isDark ? PamodziColors.text2Dark : PamodziColors.text2;
    final mutedColor = isDark ? PamodziColors.mutedDark : PamodziColors.muted;
    final greenColor = isDark ? PamodziColors.greenDark2 : PamodziColors.green;
    final greenGlColor = isDark ? PamodziColors.greenGl : PamodziColors.greenGl2;
    final borderColor = isDark ? PamodziColors.borderDark : PamodziColors.border;
    final surfaceColor = isDark ? PamodziColors.surfaceDark : PamodziColors.surface;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // Brand mark
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [greenColor, PamodziColors.greenDark],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: greenColor.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 8)),
                  ],
                ),
                child: const Icon(Icons.apartment_rounded, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 14),
              Text('PAMODZI',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: textColor)),
              Text('Tenant Portal',
                  style: TextStyle(fontSize: 12, color: mutedColor, fontWeight: FontWeight.w500)),

              const SizedBox(height: 40),

              // Form card
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sign in',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textColor)),
                    const SizedBox(height: 4),
                    Text('Access your rent, receipts & requests',
                        style: TextStyle(fontSize: 13, color: text2Color)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Error
              AnimatedBuilder(
                animation: _shakeAnim,
                builder: (context, child) => Transform.translate(
                  offset: Offset(_showError ? 5 * (_shakeAnim.value % 2 == 0 ? 1 : -1) : 0, 0),
                  child: child,
                ),
                child: AnimatedOpacity(
                  opacity: _showError ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                    decoration: BoxDecoration(
                      color: PamodziColors.redGl,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: PamodziColors.red.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: PamodziColors.red, size: 16),
                        const SizedBox(width: 8),
                        Text(_errorMessage,
                            style: const TextStyle(color: PamodziColors.red, fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              ),

              // Email
              _FieldLabel(label: 'Email address'),
              const SizedBox(height: 6),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(fontSize: 14, color: textColor),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.mail_outline, color: mutedColor, size: 18),
                  hintText: 'your@email.com',
                  hintStyle: TextStyle(color: mutedColor),
                  filled: true,
                  fillColor: surfaceColor,
                ),
              ),
              const SizedBox(height: 14),

              // Password
              _FieldLabel(label: 'Password'),
              const SizedBox(height: 6),
              TextField(
                controller: _passCtrl,
                obscureText: _obscurePass,
                style: TextStyle(fontSize: 14, color: textColor),
                onSubmitted: (_) => _doLogin(),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock_outline, color: mutedColor, size: 18),
                  hintText: '••••••••',
                  hintStyle: TextStyle(color: mutedColor),
                  filled: true,
                  fillColor: surfaceColor,
                  suffixIcon: GestureDetector(
                    onTap: () => setState(() => _obscurePass = !_obscurePass),
                    child: Icon(
                      _obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: mutedColor,
                      size: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Login button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _doLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: greenColor,
                    disabledBackgroundColor: greenColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 4,
                    shadowColor: greenColor.withOpacity(0.35),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Text('Sign in to Pamodzi',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),

              const SizedBox(height: 14),

              // Demo hint
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: greenGlColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor),
                ),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 12, color: text2Color),
                    children: [
                      const TextSpan(text: 'Demo: '),
                      TextSpan(
                        text: 'chanda.m@pamodzi.com',
                        style: TextStyle(color: greenColor, fontWeight: FontWeight.w700),
                      ),
                      const TextSpan(text: ' / '),
                      TextSpan(
                        text: 'rent2026',
                        style: TextStyle(color: greenColor, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
