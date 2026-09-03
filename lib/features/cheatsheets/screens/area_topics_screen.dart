import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/medical_area_model.dart';
import '../models/topic_model.dart';
import '../services/medical_areas_service.dart';

class AreaTopicsScreen extends StatelessWidget {
  final MedicalAreaModel area;

  const AreaTopicsScreen({super.key, required this.area});

  @override
  Widget build(BuildContext context) {
    final medicalService = MedicalAreasService();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Cabecera One UI
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          area.code,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.accent,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          area.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
                    ),
                    child: Center(
                      child: area.buildLogoWidget(
                        size: 24,
                        iconColor: AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: AppColors.border),

            // Lista de temas / subtemas en tiempo real desde Firestore
            Expanded(
              child: StreamBuilder<List<TopicModel>>(
                stream: medicalService.getTopicsStream(area.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    );
                  }

                  final topics = snapshot.data ?? [];

                  if (topics.isEmpty) {
                    return _buildEmptyTopicsState(context);
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 90),
                    itemCount: topics.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final topic = topics[index];
                      return _buildTopicCard(context, topic, index + 1);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicCard(BuildContext context, TopicModel topic, int number) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                if (topic.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    topic.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
        ],
      ),
    );
  }

  Widget _buildEmptyTopicsState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
              ),
              child: Center(
                child: area.buildLogoWidget(
                  size: 42,
                  iconColor: AppColors.accent,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Text(
                'Estructura de BD Lista',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Temas de ${area.name}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Esta área médica ya está registrada en Firestore. Los temas y chuletas clínicas se cargarán automáticamente en cuanto subas los PDFs de estudio.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
