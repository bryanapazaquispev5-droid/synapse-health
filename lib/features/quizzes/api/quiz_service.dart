import '../../../core/api/aws_data_source.dart';
import '../model/quiz_model.dart';

class QuizService {
  QuizService({AwsDataSource? source})
    : source = source ?? AwsDataSource.instance;
  final AwsDataSource source;

  List<QuizModel> _parse(Map<String, dynamic> data) {
    final quizzes = AwsDataSource.items(data)
        .map((item) => QuizModel.fromMap(item, item['id'] as String))
        .toList();
    quizzes.sort((a, b) => a.order.compareTo(b.order));
    return quizzes;
  }

  Stream<List<QuizModel>> getQuizzesByAreaStream(String areaId) =>
      source.watch('api/v1/areas/$areaId/quizzes').map(_parse);

  Stream<List<QuizModel>> getQuizzesByTopicStream(
    String areaId,
    String topicId,
  ) => source.watch('api/v1/areas/$areaId/topics/$topicId/quizzes').asyncMap((
    data,
  ) async {
    final quizzes = _parse(data);
    if (quizzes.isNotEmpty) return quizzes;
    return _parse(
      await source.api.requestData(
        'GET',
        'api/v1/areas/$areaId/quizzes',
        query: {'topicId': topicId},
      ),
    );
  });
}
