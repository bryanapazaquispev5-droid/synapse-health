import 'package:flutter/material.dart';

import '../../../../core/services/connectivity_service.dart';
import '../../../../core/widgets/states/app_async_content.dart';
import '../../../cheatsheets/model/medical_area_model.dart';
import '../../api/personal_progress_repository.dart';
import '../../model/progress_summary.dart';
import 'progress_areas_section.dart';
import 'progress_evolution_section.dart';

class ProgressCatalogSections extends StatefulWidget {
  const ProgressCatalogSections({
    super.key,
    required this.uid,
    required this.repository,
    required this.summary,
    this.connectivity,
  });
  final String uid;
  final PersonalProgressRepository repository;
  final ProgressSummary summary;
  final ConnectivityService? connectivity;
  @override
  State<ProgressCatalogSections> createState() =>
      _ProgressCatalogSectionsState();
}

class _ProgressCatalogSectionsState extends State<ProgressCatalogSections> {
  late final Stream<List<MedicalAreaModel>> _areas;
  @override
  void initState() {
    super.initState();
    _areas = widget.repository.watchAreas(widget.uid);
  }

  @override
  Widget build(BuildContext context) =>
      AppAsyncStreamBuilder<List<MedicalAreaModel>>(
        stream: _areas,
        connectivity: widget.connectivity,
        onRetryStream: () => widget.repository.watchAreas(widget.uid),
        builder: (context, snapshot, retry) {
          if (!snapshot.hasData || snapshot.isAccessFailure) {
            return SizedBox(
              height: 340,
              child: AppAsyncStatus(
                snapshot: snapshot,
                isEmpty: false,
                onRetry: retry,
                emptyTitle: 'Áreas no disponibles',
                emptyMessage: 'No hay información de áreas.',
                errorMessage: 'No se pudieron cargar los nombres de las áreas.',
              ),
            );
          }
          final names = {for (final area in snapshot.data!) area.id: area.name};
          return Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
            child: Column(
              children: [
                AppAsyncNotice(snapshot: snapshot, onRetry: retry),
                ProgressAreasSection(
                  areas: widget.summary.areas,
                  areaNames: names,
                ),
                const SizedBox(height: 20),
                ProgressEvolutionSection(
                  series: widget.summary.evolution,
                  areaNames: names,
                  topicsStreamForArea: (id) =>
                      widget.repository.watchTopics(widget.uid, id),
                  connectivity: widget.connectivity,
                ),
              ],
            ),
          );
        },
      );
}
