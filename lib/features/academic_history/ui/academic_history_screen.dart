import '../../../core/auth/app_auth.dart';

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
  late final Stream<AppUser?> _session;
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
      middle: Text(widget.entryId == null ? 'My History' : 'Result'),
      previousPageTitle: widget.entryId == null ? 'Progress' : 'History',
    ),
    body: SafeArea(
      child: StreamBuilder<AppUser?>(
        stream: _session,
        initialData: _repository.currentUser,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const AppErrorState(
              message: 'Could not verify your session.',
            );
          }
          final user = snapshot.data;
          if (user == null ||
              (widget.expectedUid != null && user.uid != widget.expectedUid)) {
            return const AppErrorState(
              message: 'Sign in to access this history.',
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
