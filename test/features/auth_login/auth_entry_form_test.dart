import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/features/auth_login/ui/widgets/auth_login_form.dart';
import 'package:synapse_health/features/auth_login/ui/widgets/auth_register_form.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('login form exposes a user-controlled remember-email switch', (
    tester,
  ) async {
    final email = TextEditingController();
    final password = TextEditingController();
    var rememberEmail = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AuthLoginForm(
            emailController: email,
            passwordController: password,
            onForgotPassword: () {},
            rememberEmail: rememberEmail,
            onRememberEmailChanged: (value) => rememberEmail = value,
            onEmailChanged: (_) {},
          ),
        ),
      ),
    );
    expect(find.text('Remember email'), findsOneWidget);
    await tester.tap(find.byType(CupertinoSwitch));
    expect(rememberEmail, isTrue);
    email.dispose();
    password.dispose();
  });

  testWidgets('registration selects a degree from the existing options', (
    tester,
  ) async {
    final controllers = List.generate(5, (_) => TextEditingController());
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: AuthRegisterForm(
              nameController: controllers[0],
              emailController: controllers[1],
              careerController: controllers[2],
              passwordController: controllers[3],
              confirmPasswordController: controllers[4],
              selectedGender: 'Hombre',
              onGenderChanged: (_) {},
              requireCaptcha: false,
              isCaptchaVerified: false,
              onCaptchaVerified: (_) {},
              onStateUpdate: () {},
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nursing'));
    expect(controllers[2].text, 'Nursing');
    for (final controller in controllers) {
      controller.dispose();
    }
  });
}
