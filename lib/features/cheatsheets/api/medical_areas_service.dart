import '../../../core/api/aws_data_source.dart';
import '../model/medical_area_model.dart';
import '../model/topic_model.dart';
import '../model/cheatsheet_model.dart';

/// AWS catalogue data remains in memory for the lifetime of its subscriptions.
class MedicalAreasService {
  MedicalAreasService({AwsDataSource? source})
    : source = source ?? AwsDataSource.instance;
  final AwsDataSource source;

  Stream<List<MedicalAreaModel>> getAreasStream() =>
      source.watch('api/v1/areas').map((data) {
        final areas = AwsDataSource.items(data)
            .map((item) => MedicalAreaModel.fromMap(item, item['id'] as String))
            .toList();
        areas.sort(
          (a, b) => a.order != b.order
              ? a.order.compareTo(b.order)
              : a.name.compareTo(b.name),
        );
        return areas;
      });

  Stream<List<TopicModel>> getTopicsStream(String areaId) =>
      source.watch('api/v1/areas/$areaId/topics').map((data) {
        final topics = AwsDataSource.items(data)
            .map((item) => TopicModel.fromMap(item, item['id'] as String))
            .toList();
        topics.sort((a, b) => a.order.compareTo(b.order));
        return topics;
      });

  Stream<List<CheatsheetModel>> getTopicCheatsheetsStream(
    String areaId,
    String topicId,
  ) => source
      .watch('api/v1/areas/$areaId/topics/$topicId/study-notes')
      .map(
        (data) => AwsDataSource.items(data)
            .map((item) => CheatsheetModel.fromMap(item, item['id'] as String))
            .toList(),
      );
}
