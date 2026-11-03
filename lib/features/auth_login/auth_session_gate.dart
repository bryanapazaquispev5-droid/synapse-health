import 'package:flutter/material.dart';

import '../../core/auth/app_auth.dart';
import '../../core/api/own_profile_repository.dart';
import '../../core/api/aws_data_source.dart';
import '../navigation/ui/main_navigation_wrapper.dart';
import 'ui/complete_profile_screen.dart';
import 'model/registration_flow_status.dart';

/// A new Cognito identity completes its own AWS profile before entering the app.
class AuthSessionGate extends StatefulWidget {
  const AuthSessionGate({super.key, required this.user});
  final AppUser user;
  @override
  State<AuthSessionGate> createState() => _AuthSessionGateState();
}

class _AuthSessionGateState extends State<AuthSessionGate> {
  late Stream<ProfileRecord> _profile;
  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _profile = OwnProfileRepository().watch(widget.user.uid);
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
    valueListenable: RegistrationFlowStatus.isSavingProfile,
    builder: (context, isSavingProfile, _) {
      if (isSavingProfile) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return StreamBuilder<ProfileRecord>(
        stream: _profile,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Could not load your profile. Check your connection.',
                    ),
                    TextButton(
                      onPressed: () => AwsDataSource.instance.refreshAll(),
                      child: const Text('Try again'),
                    ),
                    TextButton(
                      onPressed: () => AppAuth.instance.signOut(),
                      child: const Text('Sign out'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final data = snapshot.data!.data();
          if ((data?['career'] as String? ?? '').trim().isEmpty) {
            return CompleteProfileScreen(user: widget.user);
          }
          return MainNavigationWrapper(user: widget.user);
        },
      );
    },
  );
}
