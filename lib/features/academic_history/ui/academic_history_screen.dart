import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/services/connectivity_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/states/app_async_content.dart';
import '../api/academic_history_repository.dart';
import 'widgets/history_body.dart';

class AcademicHistoryScreen extends StatefulWidget {
  const AcademicHistoryScreen({
    super.key,
    this.repository,
    this.connectivity,
    this.entryId,
    this.expectedUid,
  });
  final AcademicHistoryRepository? repository;
  final ConnectivityService? connectivity;
  final String? entryId;
  final String? expectedUid;
  @override
  State<AcademicHistoryScreen> createState() => _AcademicHistoryScreenState();
}

class _AcademicHistoryScreenState extends State<AcademicHistoryScreen> {
  late final AcademicHistoryRepository _repository;
  late final Stream<User?> _session;
  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? AcademicHistoryRepository();
    _session = _repository.sessionChanges;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: CupertinoNavigationBar(
      backgroundColor: AppColors.background,
      middle: Text(widget.entryId == null ? 'Mi historial' : 'Resultado'),
      previousPageTitle: widget.entryId == null ? 'Progreso' : 'Historial',
    ),
    body: SafeArea(
      child: StreamBuilder<User?>(
        stream: _session,
        initialData: _repository.currentUser,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const AppErrorState(
              message: 'No se pudo verificar tu sesión.',
            );
          }
          final user = snapshot.data;
          if (user == null ||
              (widget.expectedUid != null && user.uid != widget.expectedUid)) {
            return const AppErrorState(
              message: 'Inicia sesión para acceder a este historial.',
            );
          }
          return HistoryBody(
            key: ValueKey(user.uid),
            uid: user.uid,
            repository: _repository,
            connectivity: widget.connectivity,
            entryId: widget.entryId,
          );
        },
      ),
    ),
  );
}
