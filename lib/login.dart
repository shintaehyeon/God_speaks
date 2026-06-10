import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_login/flutter_login.dart';
import 'state/sermon_provider.dart';
import 'theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Future<String?> _authUser(LoginData data) async {
    final sermonProvider = Provider.of<SermonProvider>(context, listen: false);
    bool success = await sermonProvider.signIn(
      data.name.trim(),
      data.password.trim(),
    );
    if (success) {
      return null;
    } else {
      return '이메일 또는 비밀번호가 올바르지 않습니다.';
    }
  }

  Future<String?> _signupUser(SignupData data) async {
    final sermonProvider = Provider.of<SermonProvider>(context, listen: false);
    final name = data.additionalSignupData?['name'] ?? 'User';
    bool success = await sermonProvider.signUp(
      data.name!.trim(),
      data.password!.trim(),
      name.trim(),
    );
    if (success) {
      return null;
    } else {
      return '가입에 실패했습니다. 사용 중인 이메일이거나 네트워크를 확인하세요.';
    }
  }

  Future<String?> _recoverPassword(String name) async {
    return '비밀번호 재설정은 현재 이메일 안전 통합 모드로 인해 지원되지 않습니다.';
  }

  void _showGoogleSafeModeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.shield_rounded, color: HISpeakTheme.purpleMain),
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
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: HISpeakTheme.purpleMain,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          HISpeakTheme.buildIridescentBg(context),
          FlutterLogin(
            title: 'HISpeak',
            logo: const AssetImage('assets/hispeak_clean_logo.png'),
            onLogin: _authUser,
            onSignup: _signupUser,
            onRecoverPassword: _recoverPassword,
            onSubmitAnimationCompleted: () {
              Navigator.of(context).pushReplacementNamed('/navigation');
            },
            additionalSignupFields: [
              UserFormField(
                keyName: 'name',
                displayName: '이름 (guest 포함:무료 / 실명:👑프리미엄)',
                icon: const Icon(Icons.person_outline_rounded),
                defaultValue: '',
              ),
            ],
            loginProviders: [
              LoginProvider(
                icon: FontAwesomeIcons.google,
                label: '구글 계정',
                callback: () async {
                  _showGoogleSafeModeDialog();
                  return '시뮬레이터 안전 모드 (이메일로 가입해 주세요)';
                },
              ),
              LoginProvider(
                icon: FontAwesomeIcons.bolt,
                label: '게스트 원터치 시작',
                callback: () async {
                  final sermonProvider = Provider.of<SermonProvider>(
                    context,
                    listen: false,
                  );
                  bool success = await sermonProvider.signUp(
                    "guest_${DateTime.now().millisecondsSinceEpoch}@sermon.com",
                    "guest12345",
                    "Guest User",
                  );
                  if (success) {
                    return null;
                  } else {
                    return '게스트 체험 로그인 실패';
                  }
                },
              ),
            ],
            messages: LoginMessages(
              userHint: '이메일 주소 (Email)',
              passwordHint: '비밀번호 (Password)',
              confirmPasswordHint: '비밀번호 확인',
              loginButton: '이메일 로그인',
              signupButton: '간편 이메일 가입',
              forgotPasswordButton: '비밀번호를 잊으셨나요?',
              recoverPasswordButton: '임시 비밀번호 전송',
              recoverPasswordIntro: '이메일을 입력하시면 비밀번호 복구 가이드를 보냅니다.',
              goBackButton: '뒤로가기',
              confirmPasswordError: '비밀번호가 일치하지 않습니다.',
              additionalSignUpSubmitButton: '무료/프리미엄 즉시 가입',
            ),
            theme: LoginTheme(
              primaryColor: HISpeakTheme.purpleMain,
              accentColor: HISpeakTheme.purpleMain,
              pageColorLight: Colors.transparent,
              pageColorDark: Colors.transparent,
              titleStyle: TextStyle(
                fontWeight: FontWeight.w900,
                color: isDark ? const Color(0xFFF1F5F9) : HISpeakTheme.purpleMain,
                fontSize: 28,
                letterSpacing: 2.0,
              ),
              buttonTheme: const LoginButtonTheme(
                splashColor: HISpeakTheme.lightPurple,
                backgroundColor: HISpeakTheme.purpleMain,
              ),
              cardTheme: CardTheme(
                color: isDark
                    ? const Color(0xFF1E293B).withOpacity(0.85)
                    : const Color(0xFFFDFBFF).withOpacity(0.92), // Slightly richer lavender-tinted card background
                elevation: 10, // Premium elevated shadow
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: isDark
                        ? Colors.white.withOpacity(0.15)
                        : HISpeakTheme.purpleMain.withOpacity(0.25), // Elegant border outline
                    width: 1.5,
                  ),
                ),
              ),
              inputTheme: InputDecorationTheme(
                filled: true,
                fillColor: isDark
                    ? const Color(0xFF0F172A)
                    : const Color(0xFFF8FAFC), // Cleaner contrast color
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white.withOpacity(0.12) : const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: HISpeakTheme.purpleMain,
                    width: 1.8,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.redAccent,
                    width: 1.2,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.redAccent,
                    width: 1.8,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
