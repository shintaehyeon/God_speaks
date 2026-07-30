import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_login/flutter_login.dart';
import 'state/sermon_provider.dart';
import 'theme.dart';
import 'l10n/hispeak_localizations.dart';

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
      return context.l10n.t('emailInvalid');
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
      return context.l10n.t('signupFailed');
    }
  }

  Future<String?> _recoverPassword(String name) async {
    return context.l10n.t('recoverUnavailable');
  }

  void _showGoogleSafeModeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.shield_rounded, color: HISpeakTheme.purpleMain),
            const SizedBox(width: 8),
            Text(
              context.l10n.t('simulatorSafeModeTitle'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          context.l10n.t('simulatorSafeModeDesc'),
          style: const TextStyle(
            height: 1.5,
            fontSize: 14,
            color: Color(0xFF475569),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              context.l10n.t('ok'),
              style: const TextStyle(
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
                displayName: context.l10n.t('nameField'),
                icon: const Icon(Icons.person_outline_rounded),
                defaultValue: '',
              ),
            ],
            loginProviders: [
              LoginProvider(
                icon: FontAwesomeIcons.google,
                label: context.l10n.t('googleAccount'),
                callback: () async {
                  final sermonProvider = Provider.of<SermonProvider>(
                    context,
                    listen: false,
                  );
                  bool success = await sermonProvider.signInWithGoogle();
                  if (success) {
                    return null;
                  } else {
                    return context.l10n.t('googleFailed');
                  }
                },
              ),
              LoginProvider(
                icon: FontAwesomeIcons.bolt,
                label: context.l10n.t('guestStart'),
                callback: () async {
                  final sermonProvider = Provider.of<SermonProvider>(
                    context,
                    listen: false,
                  );
                  bool success = await sermonProvider.fastGuestSignIn();
                  if (success) {
                    return null;
                  } else {
                    return context.l10n.t('guestFailed');
                  }
                },
              ),
            ],
            messages: LoginMessages(
              userHint: context.l10n.t('emailHint'),
              passwordHint: context.l10n.t('passwordHint'),
              confirmPasswordHint: context.l10n.t('confirmPasswordHint'),
              loginButton: context.l10n.t('emailLogin'),
              signupButton: context.l10n.t('emailSignup'),
              forgotPasswordButton: context.l10n.t('forgotPassword'),
              recoverPasswordButton: context.l10n.t('sendTempPassword'),
              recoverPasswordIntro: context.l10n.t('recoverIntro'),
              goBackButton: context.l10n.t('goBack'),
              confirmPasswordError: context.l10n.t('passwordMismatch'),
              additionalSignUpSubmitButton: context.l10n.t('finishSignup'),
            ),
            theme: LoginTheme(
              primaryColor: HISpeakTheme.purpleMain,
              accentColor: HISpeakTheme.purpleMain,
              pageColorLight: Colors.transparent,
              pageColorDark: Colors.transparent,
              titleStyle: TextStyle(
                fontWeight: FontWeight.w900,
                color: isDark
                    ? const Color(0xFFF1F5F9)
                    : HISpeakTheme.purpleMain,
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
                    : const Color(0xFFFDFBFF).withOpacity(
                        0.92,
                      ), // Slightly richer lavender-tinted card background
                elevation: 10, // Premium elevated shadow
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: isDark
                        ? Colors.white.withOpacity(0.15)
                        : HISpeakTheme.purpleMain.withOpacity(
                            0.25,
                          ), // Elegant border outline
                    width: 1.5,
                  ),
                ),
              ),
              inputTheme: InputDecorationTheme(
                filled: true,
                fillColor: isDark
                    ? const Color(0xFF0F172A)
                    : const Color(0xFFF8FAFC), // Cleaner contrast color
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark
                        ? Colors.white.withOpacity(0.12)
                        : const Color(0xFFE2E8F0),
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
