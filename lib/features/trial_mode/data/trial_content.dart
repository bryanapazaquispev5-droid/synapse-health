import '../../cheatsheets/model/cheatsheet_model.dart';
import '../../cheatsheets/model/medical_area_model.dart';
import '../../cheatsheets/model/topic_model.dart';
import '../../quizzes/model/quiz_model.dart';

/// Small anatomy demo stored in the app bundle; it is never loaded from AWS.
class TrialContent {
  TrialContent._();

  static final area = MedicalAreaModel(
    id: 'trial-anatomy',
    name: 'Human Anatomy',
    code: 'TRIAL-ANATOMY',
    order: 0,
    topicsCount: 1,
    cheatsheetsCount: 2,
    quizzesCount: 1,
  );

  static const topic = TopicModel(
    id: 'trial-anatomical-basics',
    areaId: 'trial-anatomy',
    title: 'Anatomical Basics',
    description: 'A short introduction to anatomical position and body planes.',
    order: 0,
    cheatsheetsCount: 2,
    quizzesCount: 1,
  );

  static const notes = <CheatsheetModel>[
    CheatsheetModel(
      id: 'trial-anatomical-position',
      areaId: 'trial-anatomy',
      topicId: 'trial-anatomical-basics',
      title: 'Anatomical Position',
      summary: 'The standard reference posture used to describe the body.',
      contentMarkdown:
          'A person is standing upright, facing forward, with the '
          'head level and eyes forward. The feet are flat and directed forward. '
          'The arms rest at the sides, and the palms face forward with the '
          'thumbs pointing away from the body.\n\n'
          'This shared reference makes descriptions such as anterior, '
          'posterior, medial, and lateral consistent, even when the person '
          'being described is lying down or moving.',
      keyPoints: [
        'Upright posture and forward gaze.',
        'Arms at the sides; palms face forward.',
        'Directional terms refer to this position.',
      ],
      readDurationInMinutes: 2,
      isPremium: false,
      sourceBook: 'None',
    ),
    CheatsheetModel(
      id: 'trial-body-planes',
      areaId: 'trial-anatomy',
      topicId: 'trial-anatomical-basics',
      title: 'Body Planes and Sections',
      summary: 'Imaginary planes help describe how the body is divided.',
      contentMarkdown:
          'The **sagittal plane** divides the body into right and '
          'left portions. The midsagittal plane passes through the midline; '
          'a parasagittal plane is offset from it.\n\n'
          'The **frontal (coronal) plane** separates anterior and posterior '
          'portions. The **transverse (horizontal) plane** separates superior '
          'and inferior portions. A section is the cut or image made along a '
          'plane, so naming the plane clarifies the view being discussed.',
      keyPoints: [
        'Sagittal: right and left.',
        'Frontal: anterior and posterior.',
        'Transverse: superior and inferior.',
      ],
      readDurationInMinutes: 2,
      isPremium: false,
      sourceBook: 'None',
    ),
  ];

  static const quizLevelOne = <QuizModel>[
    QuizModel(
      id: 'trial-level-one-question-one',
      areaId: 'trial-anatomy',
      topicId: 'trial-anatomical-basics',
      question: 'In anatomical position, which direction do the palms face?',
      options: ['Posteriorly', 'Anteriorly', 'Medially', 'Inferiorly'],
      correctIndex: 1,
      rationale: 'The palms face anteriorly while the arms rest at the sides.',
      sourceBook: 'None',
      orderIndex: 1,
    ),
  ];
}
