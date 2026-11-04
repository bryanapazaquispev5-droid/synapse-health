import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/features/auth_login/utils/auth_validators.dart';
import 'package:synapse_health/features/quizzes/model/quiz_model.dart';
import 'package:synapse_health/features/quizzes/utils/quiz_scoring_helper.dart';

QuizModel quiz({
  String type = 'single_choice',
  List<MatchingPair> pairs = const [],
  List<String> orderingItems = const [],
}) => QuizModel(
  id: 'quiz-1',
  areaId: 'anatomy',
  topicId: 'heart',
  type: type,
  question: 'Sample question',
  options: const ['A', 'B'],
  correctIndex: 0,
  rationale: 'Sample rationale',
  sourceBook: 'Test source',
  matchingPairs: pairs,
  orderingItems: orderingItems,
);
void main() {
  // PRUEBAS UNITARIAS — APP (25)


  // Prueba 1: El campo de correo recibe una dirección Gmail completa. La validación reconoce
  // que tiene el formato esperado y la acepta.
  test(
    'UNIT-APP-01 | email format case 01',
    () => expect(AuthValidators.isValidEmail('ana@gmail.com'), isTrue),
  );


  // Prueba 2: Se escribe un correo de universidad, no de Gmail. La app permite otros
  // proveedores y debe aceptarlo si el formato es válido.
  test(
    'UNIT-APP-02 | email format case 02',
    () => expect(AuthValidators.isValidEmail('ana@universidad.edu.pe'), isTrue),
  );


  // Prueba 3: El correo llega con mayúsculas y espacios al inicio y al final. La app los
  // normaliza y acepta la dirección.
  test(
    'UNIT-APP-03 | email format case 03',
    () => expect(AuthValidators.isValidEmail('  ANA@GMAIL.COM  '), isTrue),
  );


  // Prueba 4: Se escribe un texto sin el símbolo @ en el correo. La app debe marcarlo como
  // inválido y detener el inicio de sesión.
  test(
    'UNIT-APP-04 | email format case 04',
    () => expect(AuthValidators.isValidEmail('anagmail.com'), isFalse),
  );


  // Prueba 5: El correo no tiene nombre antes de @. La app debe rechazarlo porque falta una
  // parte obligatoria.
  test(
    'UNIT-APP-05 | email format case 05',
    () => expect(AuthValidators.isValidEmail('@gmail.com'), isFalse),
  );


  // Prueba 6: El correo termina justo después de @, sin dominio. La app debe rechazarlo por
  // estar incompleto.
  test(
    'UNIT-APP-06 | email format case 06',
    () => expect(AuthValidators.isValidEmail('ana@'), isFalse),
  );


  // Prueba 7: El correo tiene dominio, pero no una extensión como .com. La app debe marcarlo
  // como inválido.
  test(
    'UNIT-APP-07 | email format case 07',
    () => expect(AuthValidators.isValidEmail('ana@gmail'), isFalse),
  );


  // Prueba 8: El correo contiene un espacio entre sus letras. La app debe rechazarlo porque un
  // correo no puede tener ese espacio.
  test(
    'UNIT-APP-08 | email format case 08',
    () => expect(AuthValidators.isValidEmail('a na@gmail.com'), isFalse),
  );


  // Prueba 9: La contraseña contiene letras mayúsculas y minúsculas, números y un símbolo,
  // además de la longitud requerida. Debe cumplir las reglas.
  test(
    'UNIT-APP-09 | password policy case 09',
    () => expect(AuthValidators.meetsCognitoPasswordPolicy('SaludSegura2026!'), isTrue),
  );


  // Prueba 10: Se prueba una contraseña de exactamente 12 caracteres con los requisitos
  // necesarios. Debe aceptarse en el límite mínimo.
  test(
    'UNIT-APP-10 | password policy case 10',
    () => expect(AuthValidators.meetsCognitoPasswordPolicy('Abcdefgh123!'), isTrue),
  );


  // Prueba 11: La contraseña tiene solo 11 caracteres. Aunque incluya otros requisitos, debe
  // rechazarse por no llegar al mínimo.
  test(
    'UNIT-APP-11 | password policy case 11',
    () => expect(AuthValidators.meetsCognitoPasswordPolicy('Abcdefg12!x'), isFalse),
  );


  // Prueba 12: La contraseña no contiene letras minúsculas. La validación debe rechazarla
  // porque falta ese tipo de carácter.
  test(
    'UNIT-APP-12 | password policy case 12',
    () => expect(AuthValidators.meetsCognitoPasswordPolicy('PASSWORD123!'), isFalse),
  );


  // Prueba 13: La contraseña no contiene letras mayúsculas. La validación debe rechazarla
  // porque falta ese tipo de carácter.
  test(
    'UNIT-APP-13 | password policy case 13',
    () => expect(AuthValidators.meetsCognitoPasswordPolicy('password123!'), isFalse),
  );


  // Prueba 14: La contraseña no tiene ningún número. La validación debe rechazarla aunque tenga
  // letras y un símbolo.
  test(
    'UNIT-APP-14 | password policy case 14',
    () => expect(AuthValidators.meetsCognitoPasswordPolicy('PasswordSegura!'), isFalse),
  );


  // Prueba 15: La contraseña no incluye símbolos. La app debe marcarla como inválida aunque
  // tenga letras y números.
  test(
    'UNIT-APP-15 | password policy case 15',
    () => expect(AuthValidators.meetsCognitoPasswordPolicy('Password12345'), isFalse),
  );


  // Prueba 16: Se usa el correo completo como contraseña. La app detecta que son iguales y
  // marca la clave como insegura.
  test(
    'UNIT-APP-16 | password comparison case 16',
    () => expect(
      AuthValidators.isPasswordEqualToEmail('ana@gmail.com', 'ana@gmail.com'),
      isTrue,
    ),
  );


  // Prueba 17: Se usa como contraseña el nombre que aparece antes de @ en el correo. La app
  // reconoce la coincidencia y la marca como insegura.
  test(
    'UNIT-APP-17 | password comparison case 17',
    () => expect(AuthValidators.isPasswordEqualToEmail('ana', 'ana@gmail.com'), isTrue),
  );


  // Prueba 18: Correo y contraseña tienen mayúsculas y espacios distintos, pero representan el
  // mismo texto. Al normalizarlos, la app detecta que coinciden.
  test(
    'UNIT-APP-18 | password comparison case 18',
    () =>
        expect(AuthValidators.isPasswordEqualToEmail(' ANA ', 'ana@gmail.com'), isTrue),
  );


  // Prueba 19: Se ingresa una contraseña diferente del correo y del nombre de usuario. La app
  // no debe marcarla como repetida.
  test(
    'UNIT-APP-19 | password comparison case 19',
    () => expect(
      AuthValidators.isPasswordEqualToEmail('ClaveSegura2026!', 'ana@gmail.com'),
      isFalse,
    ),
  );


  // Prueba 20: El nombre del correo tiene solo dos letras y la contraseña es distinta. La app
  // no debe confundirlas ni bloquear el acceso.
  test(
    'UNIT-APP-20 | password comparison case 20',
    () => expect(AuthValidators.isPasswordEqualToEmail('ab', 'ab@gmail.com'), isFalse),
  );


  // Prueba 21: El cronómetro recibe 0 segundos. Debe mostrar 0s y no un valor negativo ni
  // vacío.
  test(
    'UNIT-APP-21 | quiz helper case 21',
    () => expect(QuizScoringHelper.formatDuration(0), '0s'),
  );


  // Prueba 22: El cronómetro recibe 59 segundos, justo antes de un minuto. Debe mostrar 59s.
  test(
    'UNIT-APP-22 | quiz helper case 22',
    () => expect(QuizScoringHelper.formatDuration(59), '59s'),
  );


  // Prueba 23: El cronómetro recibe 60 segundos. Debe convertirlos y mostrar 1m 0s.
  test(
    'UNIT-APP-23 | quiz helper case 23',
    () => expect(QuizScoringHelper.formatDuration(60), '1m 0s'),
  );


  // Prueba 24: El cronómetro recibe 125 segundos. Debe mostrar 2m 5s, separando minutos y
  // segundos.
  test(
    'UNIT-APP-24 | quiz helper case 24',
    () => expect(QuizScoringHelper.formatDuration(125), '2m 5s'),
  );


  // Prueba 25: Se combinan una pregunta simple, dos parejas para relacionar y dos pasos para
  // ordenar. El máximo esperado es de cinco estrellas.
  test('UNIT-APP-25 | quiz helper case 25', () {
    final quizzes = [
      quiz(),
      quiz(
        type: 'matching',
        pairs: const [
          MatchingPair(left: 'A', right: '1'),
          MatchingPair(left: 'B', right: '2'),
        ],
      ),
      quiz(type: 'ordering', orderingItems: const ['A', 'B']),
    ];
    expect(QuizScoringHelper.calculateTotalMaxStars(quizzes), 5);
  });

  // PRUEBAS MASIVAS — APP (25)


  // Prueba masiva 1: El correo recibe tres direcciones válidas, entre ellas una de Gmail. La
  // app debe aceptar las tres.
  test('MASS-APP-01 | email batch case 01', () {
    for (final email in ['maria@gmail.com', 'luis@med.org', 'sol@campus.edu']) {
      expect(AuthValidators.isValidEmail(email), isTrue, reason: email);
    }
  });


  // Prueba masiva 2: Se ingresa un correo universitario válido que no es Gmail. La app debe
  // aceptarlo porque no limita el proveedor.
  test(
    'MASS-APP-02 | email batch case 02',
    () => expect(AuthValidators.isValidEmail('alumno@uni.edu.pe'), isTrue),
  );


  // Prueba masiva 3: Se prueban dos direcciones válidas de distintos dominios. Ambas deben
  // pasar la revisión de formato.
  test('MASS-APP-03 | email batch case 03', () {
    for (final email in ['ana@mail.facultad.edu', 'bob@salud.example.org']) {
      expect(AuthValidators.isValidEmail(email), isTrue, reason: email);
    }
  });


  // Prueba masiva 4: El campo recibe valores vacíos o una dirección incompleta. Cada uno debe
  // rechazarse antes de intentar iniciar sesión.
  test('MASS-APP-04 | email batch case 04', () {
    for (final email in ['', '   ', '  @gmail.com  ']) {
      expect(AuthValidators.isValidEmail(email), isFalse, reason: email);
    }
  });


  // Prueba masiva 5: Se envían correos sin nombre, sin dominio o sin texto después de @. La app
  // debe rechazar todos por incompletos.
  test('MASS-APP-05 | email batch case 05', () {
    for (final email in ['usuario.gmail.com', '@uni.edu', 'usuario@']) {
      expect(AuthValidators.isValidEmail(email), isFalse, reason: email);
    }
  });


  // Prueba masiva 6: Se prueban correos con espacios internos, dos @ o texto sobrante. Ninguno
  // tiene formato válido y todos deben rechazarse.
  test('MASS-APP-06 | email batch case 06', () {
    for (final email in [
      'hola ana@gmail.com',
      'ana@@gmail.com',
      'ana@gmail.com basura',
    ]) {
      expect(AuthValidators.isValidEmail(email), isFalse, reason: email);
    }
  });


  // Prueba masiva 7: Las direcciones tienen dominios o terminaciones incompletas. La app debe
  // marcarlas como inválidas.
  test('MASS-APP-07 | email batch case 07', () {
    for (final email in ['ana@.com', 'ana@gmail.c', 'ana@mail.']) {
      expect(AuthValidators.isValidEmail(email), isFalse, reason: email);
    }
  });


  // Prueba masiva 8: Se ingresan dos correos válidos con mayúsculas y espacios alrededor. La
  // app debe limpiarlos y aceptar ambos.
  test('MASS-APP-08 | email batch case 08', () {
    for (final email in [' ANA@GMAIL.COM ', ' LUIS@UNI.EDU.PE ']) {
      expect(AuthValidators.isValidEmail(email), isTrue, reason: email);
    }
  });


  // Prueba masiva 9: Se revisan tres contraseñas con longitud y combinación de caracteres
  // correctas. Las tres deben cumplir las reglas.
  test('MASS-APP-09 | password batch case 09', () {
    for (final password in ['Anatomia2026#', 'ClaveFuerte88!', 'BioMedicina7\$']) {
      expect(AuthValidators.meetsCognitoPasswordPolicy(password), isTrue);
    }
  });


  // Prueba masiva 10: Una contraseña válida tiene 12 caracteres y otra tiene 11. La primera
  // debe pasar y la segunda fallar por longitud.
  test('MASS-APP-10 | password batch case 10', () {
    expect(AuthValidators.meetsCognitoPasswordPolicy('Abcdefgh12!x'), isTrue);
    expect(AuthValidators.meetsCognitoPasswordPolicy('Abcdefg12!x'), isFalse);
  });


  // Prueba masiva 11: Las claves de esta lista incumplen distintos requisitos: mayúsculas,
  // minúsculas, números o símbolos. Todas deben rechazarse.
  test('MASS-APP-11 | password batch case 11', () {
    for (final password in [
      'lowercase123!',
      'UPPERCASE123!',
      'NoDigitsHere!!',
      'NoSymbol12345',
    ]) {
      expect(
        AuthValidators.meetsCognitoPasswordPolicy(password),
        isFalse,
        reason: password,
      );
    }
  });


  // Prueba masiva 12: La contraseña es larga, pero no tiene números. La app debe rechazarla
  // porque le falta ese requisito.
  test(
    'MASS-APP-12 | password batch case 12',
    () => expect(AuthValidators.meetsCognitoPasswordPolicy('PasswordAbcde!'), isFalse),
  );


  // Prueba masiva 13: Una clave no tiene minúsculas y otra no tiene mayúsculas. La app debe
  // rechazar ambas.
  test('MASS-APP-13 | password batch case 13', () {
    expect(AuthValidators.meetsCognitoPasswordPolicy('PASSWORD12345!'), isFalse);
    expect(AuthValidators.meetsCognitoPasswordPolicy('password12345!'), isFalse);
  });


  // Prueba masiva 14: Se compara la clave con el correo completo y con el nombre anterior a @.
  // La app debe detectar las dos coincidencias.
  test('MASS-APP-14 | password comparison batch case 14', () {
    expect(
      AuthValidators.isPasswordEqualToEmail('maria@uni.edu', 'maria@uni.edu'),
      isTrue,
    );
    expect(AuthValidators.isPasswordEqualToEmail('maria', 'maria@uni.edu'), isTrue);
  });


  // Prueba masiva 15: La contraseña es distinta del correo y de su nombre de usuario. La app
  // debe permitirla como clave no repetida.
  test(
    'MASS-APP-15 | password comparison batch case 15',
    () => expect(
      AuthValidators.isPasswordEqualToEmail('maria2026!', 'maria@uni.edu'),
      isFalse,
    ),
  );


  // Prueba masiva 16: Se comparan correos y claves con diferencias de mayúsculas o espacios
  // exteriores. La app debe normalizarlos y reconocer las coincidencias.
  test('MASS-APP-16 | password comparison batch case 16', () {
    expect(
      AuthValidators.isPasswordEqualToEmail(' MARIA@UNI.EDU ', 'maria@uni.edu'),
      isTrue,
    );
    expect(AuthValidators.isPasswordEqualToEmail(' Maria ', 'maria@uni.edu'), isTrue);
  });


  // Prueba masiva 17: El cronómetro recibe 0, 1, 17 y 59 segundos. Debe mostrar esos valores en
  // segundos.
  test('MASS-APP-17 | quiz batch case 17', () {
    for (final seconds in [0, 1, 17, 59]) {
      expect(QuizScoringHelper.formatDuration(seconds), '${seconds}s');
    }
  });


  // Prueba masiva 18: El cronómetro recibe 61, 119 y 3605 segundos. Debe convertirlos a minutos
  // y mostrar también los segundos restantes.
  test('MASS-APP-18 | quiz batch case 18', () {
    expect(QuizScoringHelper.formatDuration(61), '1m 1s');
    expect(QuizScoringHelper.formatDuration(119), '1m 59s');
    expect(QuizScoringHelper.formatDuration(3605), '60m 5s');
  });


  // Prueba masiva 19: Tres cuestionarios simples aportan una estrella máxima cada uno. El total
  // esperado es tres.
  test('MASS-APP-19 | quiz batch case 19', () {
    expect(QuizScoringHelper.calculateTotalMaxStars([quiz(), quiz(), quiz()]), 3);
  });


  // Prueba masiva 20: Una pregunta tiene cuatro parejas para relacionar. El máximo debe ser
  // cuatro estrellas, una por pareja.
  test('MASS-APP-20 | quiz batch case 20', () {
    final pairs = List.generate(
      4,
      (index) => MatchingPair(left: 'L$index', right: 'R$index'),
    );
    expect(
      QuizScoringHelper.calculateTotalMaxStars([quiz(type: 'matching', pairs: pairs)]),
      4,
    );
  });


  // Prueba masiva 21: Una pregunta tiene cinco pasos para ordenar. El máximo debe ser cinco
  // estrellas, una por paso.
  test(
    'MASS-APP-21 | quiz batch case 21',
    () => expect(
      QuizScoringHelper.calculateTotalMaxStars([
        quiz(type: 'ordering', orderingItems: const ['A', 'B', 'C', 'D', 'E']),
      ]),
      5,
    ),
  );


  // Prueba masiva 22: Se suman una pregunta simple, tres parejas y cuatro pasos. El máximo
  // total esperado es ocho estrellas.
  test('MASS-APP-22 | quiz batch case 22', () {
    final matching = List.generate(
      3,
      (index) => MatchingPair(left: 'L$index', right: 'R$index'),
    );
    expect(
      QuizScoringHelper.calculateTotalMaxStars([
        quiz(),
        quiz(type: 'matching', pairs: matching),
        quiz(type: 'ordering', orderingItems: const ['A', 'B', 'C', 'D']),
      ]),
      8,
    );
  });


  // Prueba masiva 23: Una lista vacía no contiene cuestionarios. El máximo de estrellas debe
  // ser cero.
  test(
    'MASS-APP-23 | quiz batch case 23',
    () => expect(QuizScoringHelper.calculateTotalMaxStars(const []), 0),
  );


  // Prueba masiva 24: El cronómetro recibe 2 y 120 segundos. Debe mostrar 2s y 2m 0s,
  // respectivamente.
  test('MASS-APP-24 | quiz batch case 24', () {
    expect(QuizScoringHelper.formatDuration(2), '2s');
    expect(QuizScoringHelper.formatDuration(120), '2m 0s');
  });


  // Prueba masiva 25: Se ingresa un correo válido de Outlook. La app debe aceptarlo igual que
  // otros proveedores válidos.
  test(
    'MASS-APP-25 | quiz batch case 25',
    () => expect(AuthValidators.isValidEmail('estudiante@outlook.com'), isTrue),
  );
}
