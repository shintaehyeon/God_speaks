import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/sermon_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  
  bool _isSignUp = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _errorMessage = null;
    });

    final sermonProvider = Provider.of<SermonProvider>(context, listen: false);
    bool success = false;

    if (_isSignUp) {
      success = await sermonProvider.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim(),
      );
    } else {
      success = await sermonProvider.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }

    if (success) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/navigation');
      }
    } else {
      setState(() {
        _errorMessage = _isSignUp 
            ? "Failed to sign up. Check connection or try another email."
            : "Invalid credentials. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final sermonProvider = Provider.of<SermonProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Premium Brand Header
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBF2FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.translate_rounded,
                      size: 44,
                      color: Color(0xFF2F69F8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '솔로몬 AI',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1E293B),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '지혜롭고 영감 있는 실시간 예배 번역기',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),

                // Form card
                Card(
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _isSignUp ? 'Create an Account' : 'Welcome Back',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          if (_isSignUp) ...[
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Full Name',
                                hintText: 'Alex Johnson',
                                prefixIcon: const Icon(Icons.person_outline_rounded),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your name' : null,
                            ),
                            const SizedBox(height: 16),
                          ],

                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              hintText: 'alex@example.com',
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'Please enter your email';
                              if (!val.contains('@')) return 'Please enter a valid email';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: '••••••••',
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            validator: (val) => val == null || val.length < 6 ? 'Password must be at least 6 characters' : null,
                          ),
                          
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ],

                          const SizedBox(height: 24),
                          
                          sermonProvider.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    ElevatedButton(
                                      onPressed: _submit,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF2F69F8),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Text(
                                        _isSignUp ? '가입하고 로그인' : '이메일 로그인',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        setState(() { _errorMessage = null; });
                                        // Standard guest fallback simulation in provider
                                        bool success = await sermonProvider.signUp(
                                          "guest_${DateTime.now().millisecondsSinceEpoch}@sermon.com",
                                          "guest12345",
                                          "Alex Johnson",
                                        );
                                        if (success && mounted) {
                                          Navigator.pushReplacementNamed(context, '/navigation');
                                        } else {
                                          setState(() { _errorMessage = "게스트 로그인 실패. 연결 상태를 확인하세요."; });
                                        }
                                      },
                                      icon: const Icon(Icons.flash_on_rounded, size: 16),
                                      label: const Text('비밀번호 없이 게스트 둘러보기'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFEBF2FF),
                                        foregroundColor: const Color(0xFF2F69F8),
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          side: const BorderSide(color: Color(0xFFC7D9FF), width: 1.5),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Switch Sign In / Sign Up Mode
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isSignUp ? 'Already have an account? ' : "Don't have an account? ",
                      style: const TextStyle(color: Color(0xFF64748B)),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isSignUp = !_isSignUp;
                          _errorMessage = null;
                        });
                      },
                      child: Text(
                        _isSignUp ? 'Log In' : 'Sign Up',
                        style: const TextStyle(color: Color(0xFF2F69F8), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Divider
                Row(
                  children: const [
                    Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('OR CONTINUE WITH', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                  ],
                ),
                const SizedBox(height: 20),

                // Anonymous Guest Sign-in Option
                OutlinedButton.icon(
                  onPressed: () async {
                    setState(() { _errorMessage = null; });
                    final sermonProvider = Provider.of<SermonProvider>(context, listen: false);
                    // Standard guest fallback simulation in provider
                    bool success = await sermonProvider.signUp(
                      "guest_${DateTime.now().millisecondsSinceEpoch}@sermon.com",
                      "guest12345",
                      "Alex Johnson",
                    );
                    if (success && mounted) {
                      Navigator.pushReplacementNamed(context, '/navigation');
                    } else {
                      setState(() { _errorMessage = "Guest sign-in failed. Try again."; });
                    }
                  },
                  icon: const Icon(Icons.person_pin_rounded, color: Color(0xFF64748B)),
                  label: const Text('Sign in as Guest', style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
