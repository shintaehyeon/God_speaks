import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

    final navigator = Navigator.of(context);
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
        navigator.pushReplacementNamed('/navigation');
      }
    } else {
      setState(() {
        _errorMessage = _isSignUp 
            ? "가입에 실패했습니다. 이미 사용 중인 이메일이거나 네트워크를 확인해 주세요."
            : "이메일 또는 비밀번호가 올바르지 않습니다. 다시 시도해 주세요.";
      });
    }
  }

  void _showGoogleSafeModeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.shield_rounded, color: Color(0xFF2F69F8)),
            SizedBox(width: 8),
            Text(
              "시뮬레이터 안전 모드",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          "iOS 시뮬레이터 환경의 안정성을 위해 소셜 로그인 API 대신 이메일 가입/로그인을 사용해 주십시오.\n\n이메일 가입 시 이름에 'guest'를 포함하여 가입하면 무료 계정, 그 외 성함을 입력하시면 👑 프리미엄 계정이 즉시 생성됩니다!",
          style: TextStyle(height: 1.5, fontSize: 14, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "확인",
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2F69F8), fontSize: 15),
            ),
          ),
        ],
      ),
    );
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
                    decoration: const BoxDecoration(
                      color: Color(0xFFEBF2FF),
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
                const SizedBox(height: 32),

                // Form card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Custom Premium Segment Switcher (Tab Controller style)
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _isSignUp = false;
                                        _errorMessage = null;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: !_isSignUp ? Colors.white : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: !_isSignUp ? [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          )
                                        ] : null,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '이메일 로그인',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: !_isSignUp ? const Color(0xFF2F69F8) : const Color(0xFF64748B),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _isSignUp = true;
                                        _errorMessage = null;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: _isSignUp ? Colors.white : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: _isSignUp ? [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          )
                                        ] : null,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '간편 이메일 가입',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: _isSignUp ? const Color(0xFF2F69F8) : const Color(0xFF64748B),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          if (_isSignUp) ...[
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: '사용자 이름 (Name)',
                                hintText: '홍길동 (또는 guest 포함 입력)',
                                prefixIcon: const Icon(Icons.person_outline_rounded),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              validator: (val) => val == null || val.trim().isEmpty ? '이름을 입력해 주세요.' : null,
                            ),
                            const SizedBox(height: 16),
                          ],

                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: '이메일 주소 (Email)',
                              hintText: 'alex@example.com',
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return '이메일을 입력해 주세요.';
                              if (!val.contains('@')) return '올바른 이메일 형식이 아닙니다.';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: '비밀번호 (Password)',
                              hintText: '6자 이상 입력',
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            validator: (val) => val == null || val.length < 6 ? '비밀번호는 최소 6자 이상이어야 합니다.' : null,
                          ),
                          
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w600),
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
                                        elevation: 1,
                                      ),
                                      child: Text(
                                        _isSignUp ? '무료/프리미엄 즉시 가입 및 로그인' : '로그인 완료하기',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    // Beautiful simulation safe warning guide card
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: const [
                                              Icon(Icons.lightbulb_outline_rounded, size: 16, color: Color(0xFFF59E0B)),
                                              SizedBox(width: 6),
                                              Text(
                                                "💡 빠른 시연 및 계정 설정 팁",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                  color: Color(0xFF1E293B),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          const Text(
                                            "• 가입 시 이름에 'guest'가 포함되면 [무료 게스트 등급]으로 지정됩니다.",
                                            style: TextStyle(fontSize: 11, color: Color(0xFF64748B), height: 1.4),
                                          ),
                                          const Text(
                                            "• 그 외의 실명을 입력하면 [👑 프리미엄 등급]으로 지정됩니다.",
                                            style: TextStyle(fontSize: 11, color: Color(0xFF64748B), height: 1.4),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Divider
                Row(
                  children: const [
                    Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('OR', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                  ],
                ),
                const SizedBox(height: 16),

                // Anonymous Guest Sign-in Option
                OutlinedButton.icon(
                  onPressed: () async {
                    setState(() { _errorMessage = null; });
                    final navigator = Navigator.of(context);
                    final sermonProvider = Provider.of<SermonProvider>(context, listen: false);
                    bool success = await sermonProvider.signUp(
                      "guest_${DateTime.now().millisecondsSinceEpoch}@sermon.com",
                      "guest12345",
                      "Guest User",
                    );
                    if (success && mounted) {
                      navigator.pushReplacementNamed('/navigation');
                    } else {
                      setState(() { _errorMessage = "게스트 로그인 실패. 인터넷 연결을 확인해 주세요."; });
                    }
                  },
                  icon: const Icon(Icons.flash_on_rounded, color: Color(0xFF2F69F8), size: 18),
                  label: const Text('비밀번호 없이 즉시 게스트 체험하기', style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    backgroundColor: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Safe Google Login placeholder
                ElevatedButton.icon(
                  onPressed: _showGoogleSafeModeDialog,
                  icon: const FaIcon(
                    FontAwesomeIcons.google,
                    color: Color(0xFFEA4335),
                    size: 16,
                  ),
                  label: const Text('구글 계정으로 시작 (안전 가이드)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F5F9),
                    foregroundColor: const Color(0xFF475569),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
                    ),
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
