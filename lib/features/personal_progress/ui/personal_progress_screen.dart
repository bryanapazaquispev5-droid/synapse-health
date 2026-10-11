import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/services/connectivity_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/states/app_async_content.dart';
import 'progress_ranking_screen.dart';
import '../api/personal_progress_repository.dart';
import 'widgets/personal_progress_body.dart';
import 'widgets/progress_header.dart';

class PersonalProgressScreen extends StatefulWidget {
  const PersonalProgressScreen({
    super.key,
    this.repository,
    this.connectivity,
    this.rankingBuilder,
  });
  final PersonalProgressRepository? repository;
  final ConnectivityService? connectivity;
  final Widget Function(User)? rankingBuilder;
  @override
  State<PersonalProgressScreen> createState() => _PersonalProgressScreenState();
}

class _PersonalProgressScreenState extends State<PersonalProgressScreen>
    with AutomaticKeepAliveClientMixin {
  late final PersonalProgressRepository _repository;
  late final Stream<User?> _session;
  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? PersonalProgressRepository();
    _session = _repository.sessionChanges;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<User?>(
          stream: _session,
          initialData: _repository.currentUser,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const AppErrorState(
                message:
                    'No se pudo verificar tu sesión. Vuelve a iniciar sesión.',
              );
            }
            final user = snapshot.data;
            if (user == null) {
              return const AppErrorState(
                message: 'Inicia sesión para ver tu progreso personal.',
              );
            }
            return PersonalProgressBody(
              key: ValueKey(user.uid),
              uid: user.uid,
              repository: _repository,
              connectivity: widget.connectivity,
              header: ProgressHeader(
                onRanking: () {
                  if (_repository.currentUser?.uid != user.uid) return;
                  Navigator.push(
                    context,
                    AppPageRoute(
                      child: ProgressRankingScreen(
                        user: user,
                        child: widget.rankingBuilder?.call(user),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
