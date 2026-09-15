// Quizzes Clínicos de Anatomía Humana - Rouvière Tomo 3 (Miembros: Miembro Superior)
// 3 Temas x 20 Quizzes = 60 Quizzes
import { uploadQuizzesBatch } from './seed_quizzes_common.mjs';

const tomo3Part1Quizzes = [
  // =========================================================================
  // TEMA 1: cintura_escapular_hombro (20 QUIZZES)
  // =========================================================================
  {
    id: 'quiz_t3_hom_01',
    topicId: 'cintura_escapular_hombro',
    type: 'single_choice',
    question: '¿Qué músculo del manguito rotador se inserta en el tubérculo menor (troquín) del húmero realizando rotación medial?',
    options: ['Músculo subescapular', 'Músculo supraespinoso', 'Músculo infraespinoso'],
    correctIndex: 0,
    rationale: 'El músculo subescapular es el único músculo del manguito rotador que se fija en el tubérculo menor (troquín) del húmero; todos los demás van al tubérculo mayor (troquíter).',
    sourceBook: 'Rouvière - Delmas: Tomo 3 (Miembros), Músculos del Hombro',
    order: 1
  },
  {
    id: 'quiz_t3_hom_02',
    topicId: 'cintura_escapular_hombro',
    type: 'single_choice',
    question: 'El tendón del músculo supraespinoso se inserta en:',
    options: ['La faceta superior del tubérculo mayor (troquíter) del húmero', 'El tubérculo menor', 'La corredera bicipital'],
    correctIndex: 0,
    rationale: 'El supraespinoso se inserta en la carilla superior del tubérculo mayor humeral y es el músculo que más comúnmente se desgarra en el síndrome subacromial.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Manguito de los Rotadores',
    order: 2
  },
  {
    id: 'quiz_t3_hom_03',
    topicId: 'cintura_escapular_hombro',
    type: 'single_choice',
    question: 'Paciente de 24 años sufre caída sobre el hombro sufriendo luxación anterior de hombro (glenohumeral). Tras la reducción, presenta anestesia en la cara lateral del muñón del hombro e incapacidad para abducir el brazo. ¿Qué nervio fue traccionado?',
    options: ['Nervio axilar (circunflejo)', 'Nervio musculocutáneo', 'Nervio radial'],
    correctIndex: 0,
    rationale: 'El nervio axilar contornea el cuello quirúrgico del húmero inmediatamente inferior a la articulación glenohumeral; inerva el músculo deltoides y la piel suprayacente.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Nervio Axilar y Luxación Glenohumeral',
    order: 3
  },
  {
    id: 'quiz_t3_hom_04',
    topicId: 'cintura_escapular_hombro',
    type: 'single_choice',
    question: 'El espacio cuadrangular (cuadrilátero humerotricipital de Velpeau) da paso al nervio axilar y a:',
    options: ['La arteria circunfleja humeral posterior', 'La arteria braquial profunda', 'La arteria supraescapular'],
    correctIndex: 0,
    rationale: 'El cuadrilátero de Velpeau está delimitado por el redondo menor, redondo mayor, tríceps y húmero; transmite el nervio axilar y los vasos circunflejos humerales posteriores.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Espacios Intermusculares Escapulares',
    order: 4
  },
  {
    id: 'quiz_t3_hom_05',
    topicId: 'cintura_escapular_hombro',
    type: 'matching',
    question: 'Relaciona cada músculo del manguito rotador con su función biomecánica primaria:',
    matchingPairs: [
      { left: 'Músculo supraespinoso', right: 'Iniciador de la abducción del brazo (primeros 15 grados)' },
      { left: 'Músculo infraespinoso y redondo menor', right: 'Rotación lateral (externa) del brazo' },
      { left: 'Músculo subescapular', right: 'Rotación medial (interna) y aducción del brazo' }
    ],
    options: ['Acciones del manguito de los rotadores'],
    correctIndex: 0,
    rationale: 'Supraespinoso: abducción inicial; infraespinoso y redondo menor: rotadores externos; subescapular: rotador interno.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Biomecánica del Hombro',
    order: 5
  },
  {
    id: 'quiz_t3_hom_06',
    topicId: 'cintura_escapular_hombro',
    type: 'ordering',
    question: 'Ordena de medial a lateral las tres porciones de la arteria axilar en relación con el músculo pectoral menor:',
    orderingItems: [
      'Primera porción (medial al músculo pectoral menor)',
      'Segunda porción (posterior al músculo pectoral menor)',
      'Tercera porción (lateral al músculo pectoral menor hasta el borde de redondo mayor)'
    ],
    options: ['Porciones de la arteria axilar'],
    correctIndex: 0,
    rationale: 'El músculo pectoral menor es el punto de referencia que divide la arteria axilar en sus 3 porciones clásicas.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Arteria Axilar',
    order: 6
  },
  {
    id: 'quiz_t3_hom_07',
    topicId: 'cintura_escapular_hombro',
    type: 'single_choice',
    question: '¿Qué nervio inerva al músculo serrato anterior, cuya parálisis origina la deformidad de "escápula alada"?',
    options: ['Nervio torácico largo (de Charles Bell)', 'Nervio toracodorsal', 'Nervio supraescapular'],
    correctIndex: 0,
    rationale: 'El nervio torácico largo (raíces C5, C6, C7) desciende sobre la cara superficial del serrato anterior; su lesión causa el despegamiento escapular (escápula alada).',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Nervio Torácico Largo',
    order: 7
  },
  {
    id: 'quiz_t3_hom_08',
    topicId: 'cintura_escapular_hombro',
    type: 'single_choice',
    question: 'El triángulo clavipectoral (espacio de Mohrenheim) está atravesado por:',
    options: ['Vena cefálica, arteria toracoacromial y nervio pectoral lateral', 'Nervio mediano', 'Arteria braquial'],
    correctIndex: 0,
    rationale: 'La fascia clavipectoral es perforada por la vena cefálica (que drena en la axilar), la arteria toracoacromial y el nervio pectoral lateral.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Fosa Axilar y Fascia Clavipectoral',
    order: 8
  },
  {
    id: 'quiz_t3_hom_09',
    topicId: 'cintura_escapular_hombro',
    type: 'single_choice',
    question: 'Un paciente presenta dolor en la fosa supraespinosa e infraespinosa con atrofia muscular por atrapamiento del nervio supraescapular en la escotadura coracoidea. ¿Qué ligamento comprime el nervio?',
    options: ['Ligamento transverso superior de la escápula (ligamento coracoideo)', 'Ligamento coracoacromial', 'Ligamento acromioclavicular'],
    correctIndex: 0,
    rationale: 'El nervio supraescapular pasa por debajo del ligamento transverso de la escápula (a través de la escotadura), mientras que la arteria supraescapular pasa por encima.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Escotadura de la Escápula',
    order: 9
  },
  {
    id: 'quiz_t3_hom_10',
    topicId: 'cintura_escapular_hombro',
    type: 'single_choice',
    question: 'La articulación esternoclavicular se clasifica funcionalmente como sinovial de tipo:',
    options: ['En silla de montar (encaje recíproco)', 'Esferoidea pura', 'Trocoide'],
    correctIndex: 0,
    rationale: 'La articulación esternoclavicular es una articulación por encaje recíproco (silla de montar) dotada de un fibrocartílago interarticular completo.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Articulaciones de la Cintura Escapular',
    order: 10
  },
  {
    id: 'quiz_t3_hom_11',
    topicId: 'cintura_escapular_hombro',
    type: 'single_choice',
    question: '¿Cuáles ligamentos son los principales estabilizadores verticales de la articulación acromioclavicular?',
    options: ['Ligamentos coracoclaviculares (conoide y trapezoide)', 'Ligamento coracohumeral', 'Ligamento glenohumeral superior'],
    correctIndex: 0,
    rationale: 'Los ligamentos coracoclaviculares (trapezoide lateral y conoide medial) anclan la clavícula a la apófisis coracoides; su ruptura causa el "signo de la tecla de piano".',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Articulación Acromioclavicular',
    order: 11
  },
  {
    id: 'quiz_t3_hom_12',
    topicId: 'cintura_escapular_hombro',
    type: 'single_choice',
    question: 'El rodete glenoideo (labrum) cumple la función primordial de:',
    options: ['Profundizar y ampliar la cavidad glenoidea para mejorar la congruencia con la cabeza humeral', 'Nutrir la cápsula articular', 'Secretar líquido sinovial'],
    correctIndex: 0,
    rationale: 'La cavidad glenoidea es pequeña y plana; el labrum fibrocartilaginoso periférico aumenta su superficie y profundidad para la cabeza del húmero.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Articulación Glenohumeral',
    order: 12
  },
  {
    id: 'quiz_t3_hom_13',
    topicId: 'cintura_escapular_hombro',
    type: 'matching',
    question: 'Empareja los espacios axilares con sus límites musculares:',
    matchingPairs: [
      { left: 'Espacio axilar medial (triángulo omotricipital)', right: 'Redondo menor, redondo mayor y cabeza larga del tríceps' },
      { left: 'Espacio axilar lateral (cuadrilátero humerotricipital)', right: 'Redondos menor y mayor, húmero y cabeza larga del tríceps' },
      { left: 'Intervalo triangular (hendidura humerotricipital)', right: 'Redondo mayor, húmero y cabeza larga del tríceps' }
    ],
    options: ['Espacios topográficos escapulohumerales'],
    correctIndex: 0,
    rationale: 'Triángulo omotricipital transmite vasos circunflejos escapulares; cuadrilátero transmite axilar y circunfleja humeral post; hendidura transmite radial y braquial profunda.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Espacios Topográficos del Hombro',
    order: 13
  },
  {
    id: 'quiz_t3_hom_14',
    topicId: 'cintura_escapular_hombro',
    type: 'ordering',
    question: 'Ordena de medial a lateral las inserciones en la corredera bicipital (surco intertubercular) del húmero ("un dorsal entre dos mayores"):',
    orderingItems: [
      'Músculo redondo mayor (labio medial)',
      'Músculo dorsal ancho (en el fondo del surco)',
      'Músculo pectoral mayor (labio lateral)'
    ],
    options: ['Inserciones de la corredera bicipital'],
    correctIndex: 0,
    rationale: 'Mnemotecnia clásica "un dorsal entre dos mayores": labio medial = redondo mayor; fondo = dorsal ancho; labio lateral = pectoral mayor.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Húmero Proximal',
    order: 14
  },
  {
    id: 'quiz_t3_hom_15',
    topicId: 'cintura_escapular_hombro',
    type: 'single_choice',
    question: '¿Qué tendón intraarticular cruza por dentro de la cápsula de la articulación glenohumeral antes de salir por la corredera bicipital?',
    options: ['Tendón de la cabeza larga del músculo bíceps braquial', 'Tendón del músculo coracobraquial', 'Tendón del músculo tríceps'],
    correctIndex: 0,
    rationale: 'El tendón de la porción larga del bíceps se origina en el tubérculo supraglenoideo, recorre intracapsularmente la cavidad sinovial y desciende por el surco intertubercular.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Músculo Bíceps Braquial',
    order: 15
  },
  {
    id: 'quiz_t3_hom_16',
    topicId: 'cintura_escapular_hombro',
    type: 'single_choice',
    question: 'La arteria subescapular (escapular inferior) es la rama colateral más voluminosa de la arteria axilar y se bifurca en:',
    options: ['Arteria toracodorsal y arteria circunfleja de la escápula', 'Arteria toracoacromial y torácica lateral', 'Arterias circunflejas humerales'],
    correctIndex: 0,
    rationale: 'La subescapular da la rama toracodorsal para el músculo dorsal ancho y la circunfleja escapular que penetra por el triángulo omotricipital.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Ramas Colaterales de la Axilar',
    order: 16
  },
  {
    id: 'quiz_t3_hom_17',
    topicId: 'cintura_escapular_hombro',
    type: 'single_choice',
    question: 'Una mujer operada de mastectomía radical con vaciamiento ganglionar axilar presenta dificultad para trepar y extender el brazo medialmente. ¿Qué nervio fue lesionado en la pared posterior de la fosa axilar?',
    options: ['Nervio toracodorsal (inerva al dorsal ancho)', 'Nervio torácico largo', 'Nervio cutáneo medial del brazo'],
    correctIndex: 0,
    rationale: 'El nervio toracodorsal desciende por la pared posterior de la axila para inervar al músculo dorsal ancho; su lesión debilita la extensión y rotación medial del brazo.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Inervación del Dorsal Ancho',
    order: 17
  },
  {
    id: 'quiz_t3_hom_18',
    topicId: 'cintura_escapular_hombro',
    type: 'single_choice',
    question: '¿Qué músculo se inserta en el tubérculo infraglenoideo de la escápula?',
    options: ['Cabeza larga del músculo tríceps braquial', 'Cabeza larga del bíceps', 'Músculo coracobraquial'],
    correctIndex: 0,
    rationale: 'La cabeza larga del tríceps se origina en el tubérculo infraglenoideo escapular y separa los espacios axilares medial y lateral.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Escápula y Tríceps Braquial',
    order: 18
  },
  {
    id: 'quiz_t3_hom_19',
    topicId: 'cintura_escapular_hombro',
    type: 'single_choice',
    question: 'El ligamento coracoacromial forma un arco osteofibroso por encima de la cabeza del húmero denominado:',
    options: ['Bóveda acromiocoracoidea', 'Foramen de Weitbrecht', 'Ligamento transverso humeral'],
    correctIndex: 0,
    rationale: 'El acromion y la apófisis coracoides unidos por el ligamento coracoacromial constituyen el arco o techo acromiocoracoideo que previene la luxación superior del húmero.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Bóveda Acromiocoracoidea',
    order: 19
  },
  {
    id: 'quiz_t3_hom_20',
    topicId: 'cintura_escapular_hombro',
    type: 'single_choice',
    question: 'La base de la fosa axilar (suelo de la axila) está formada por piel, tejido subcutáneo y:',
    options: ['Fascia axilar (ligamento suspensorio de la axila de Gerdy)', 'Músculo pectoral menor', 'Músculo subescapular'],
    correctIndex: 0,
    rationale: 'La base de la axila está cerrada por la fascia axilar cribiforme, suspendida por el ligamento suspensorio de Gerdy procedente de la fascia clavipectoral.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Fosa Axilar',
    order: 20
  },

  // =========================================================================
  // TEMA 2: brazo_codo_antebrazo (20 QUIZZES)
  // =========================================================================
  {
    id: 'quiz_t3_bra_01',
    topicId: 'brazo_codo_antebrazo',
    type: 'single_choice',
    question: '¿Qué nervio del plexo braquial perfora el músculo coracobraquial (de Casserius) e inerva el compartimento anterior del brazo?',
    options: ['Nervio musculocutáneo', 'Nervio mediano', 'Nervio radial'],
    correctIndex: 0,
    rationale: 'El nervio musculocutáneo (fascículo lateral) perfora el coracobraquial y luego desciende entre el bíceps y el braquial inervando a los tres flexores del brazo.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Nervio Musculocutáneo',
    order: 1
  },
  {
    id: 'quiz_t3_bra_02',
    topicId: 'brazo_codo_antebrazo',
    type: 'single_choice',
    question: 'El surco del nervio radial (canal de torsión) se localiza en la cara posterior de qué hueso:',
    options: ['Diáfisis del húmero', 'Cúbito', 'Radio'],
    correctIndex: 0,
    rationale: 'El nervio radial y los vasos braquiales profundos recorren oblicuamente el surco espiral en la cara posterior de la diáfisis humeral entre las cabezas lateral y medial del tríceps.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Diáfisis Humeral y Nervio Radial',
    order: 2
  },
  {
    id: 'quiz_t3_bra_03',
    topicId: 'brazo_codo_antebrazo',
    type: 'single_choice',
    question: 'Un paciente sufre fractura del tercio medio de la diáfisis humeral presentando incapacidad para extender la muñeca y los dedos ("mano caída" o péndula). ¿Qué nervio se lesionó?',
    options: ['Nervio radial', 'Nervio cubital', 'Nervio mediano'],
    correctIndex: 0,
    rationale: 'La fractura diafisaria del húmero lesiona típicamente al nervio radial en su canal de torsión, perdiéndose la inervación de los extensores de muñeca y dedos.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Lesiones del Nervio Radial',
    order: 3
  },
  {
    id: 'quiz_t3_bra_04',
    topicId: 'brazo_codo_antebrazo',
    type: 'single_choice',
    question: 'El canal bicipital medial (fosa del codo) contiene de medial a lateral:',
    options: ['Nervio mediano, arteria braquial con sus venas satélites y tendón del bíceps', 'Nervio radial y arteria recurrente', 'Nervio cubital exclusivamente'],
    correctIndex: 0,
    rationale: 'En el surco bicipital medial se ubican de medial a lateral: el nervio mediano, la arteria braquial (humeral) y el tendón distal del bíceps braquial.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Fosa del Codo (Pliegue del Codo)',
    order: 4
  },
  {
    id: 'quiz_t3_bra_05',
    topicId: 'brazo_codo_antebrazo',
    type: 'matching',
    question: 'Relaciona cada raíz del plexo braquial con su principal reflejo osteotendinoso explorado en la clínica:',
    matchingPairs: [
      { left: 'Reflejo bicipital', right: 'Raíz C5 - C6 (nervio musculocutáneo)' },
      { left: 'Reflejo braquiorradial (estilorradial)', right: 'Raíz C6 (nervio radial)' },
      { left: 'Reflejo tricipital', right: 'Raíz C7 (nervio radial)' }
    ],
    options: ['Reflejos del miembro superior'],
    correctIndex: 0,
    rationale: 'Bicipital evalúa C5-C6; estilorradial evalúa C6; tricipital evalúa C7.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Exploración Clínica del Miembro Superior',
    order: 5
  },
  {
    id: 'quiz_t3_bra_06',
    topicId: 'brazo_codo_antebrazo',
    type: 'ordering',
    question: 'Ordena de lateral a medial los músculos epicondíleos mediales (epitrocleares) del antebrazo:',
    orderingItems: [
      'Músculo pronador redondo',
      'Músculo flexor radial del carpo (palmar mayor)',
      'Músculo palmar largo (palmar menor)',
      'Músculo flexor cubital del carpo (cubital anterior)'
    ],
    options: ['Músculos epitrocleares'],
    correctIndex: 0,
    rationale: 'Mnemotecnia clásica de lateral a medial: PR-FRC-PL-FCC ("Pronador, Palmar mayor, Palmar menor y Cubital anterior").',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Músculos del Antebrazo',
    order: 6
  },
  {
    id: 'quiz_t3_bra_07',
    topicId: 'brazo_codo_antebrazo',
    type: 'single_choice',
    question: 'El nervio cubital (ulnar) pasa por detrás del codo a través de:',
    options: ['El canal epitrocleoolecraneano (surco para el nervio cubital)', 'La fosa del codo anterior', 'El túnel del carpo'],
    correctIndex: 0,
    rationale: 'El nervio cubital transcurre por el canal osteofibroso delimitado entre el epicóndilo medial (epitróclea) y el olécranon del cúbito.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Nervio Cubital en el Codo',
    order: 7
  },
  {
    id: 'quiz_t3_bra_08',
    topicId: 'brazo_codo_antebrazo',
    type: 'single_choice',
    question: '¿Qué músculo es el flexor más potente y puro de la articulación del codo en cualquier posición de prono-supinación?',
    options: ['Músculo braquial (braquial anterior)', 'Músculo bíceps braquial', 'Músculo pronador cuadrado'],
    correctIndex: 0,
    rationale: 'El músculo braquial se inserta en la tuberosidad del cúbito; al no insertar en el radio, es el flexor puro del codo independientemente de la pronación o supinación.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Músculo Braquial',
    order: 8
  },
  {
    id: 'quiz_t3_bra_09',
    topicId: 'brazo_codo_antebrazo',
    type: 'single_choice',
    question: 'Un paciente presenta dolor agudo en el epicóndilo lateral del codo que empeora al extender la muñeca contra resistencia ("codo de tenista" o epicondilitis lateral). ¿Qué tendón común se encuentra inflamado?',
    options: ['Tendón común de los músculos extensores del antebrazo', 'Tendón de los flexores epitrocleares', 'Tendón del tríceps'],
    correctIndex: 0,
    rationale: 'La epicondilitis lateral compromete el origen común de los extensores de muñeca (especialmente el extensor radial corto del carpo) en el epicóndilo lateral.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Epicóndilo Lateral y Músculos Extensores',
    order: 9
  },
  {
    id: 'quiz_t3_bra_10',
    topicId: 'brazo_codo_antebrazo',
    type: 'single_choice',
    question: 'La articulación radiocubital proximal se clasifica funcionalmente como:',
    options: ['Trocoide (pivote cilíndrico)', 'Gínglimo (bisagra)', 'Sinovial plana'],
    correctIndex: 0,
    rationale: 'La cabeza del radio gira dentro del anillo osteofibroso formado por la escotadura radial del cúbito y el ligamento anular, constituyendo un trocoide.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Articulación Radiocubital Proximal',
    order: 10
  },
  {
    id: 'quiz_t3_bra_11',
    topicId: 'brazo_codo_antebrazo',
    type: 'single_choice',
    question: 'El ligamento anular del radio rodea la circunferencia articular de la cabeza radial insertándose en:',
    options: ['Los bordes anterior y posterior de la escotadura radial del cúbito', 'El epicóndilo lateral', 'La tróclea humeral'],
    correctIndex: 0,
    rationale: 'El ligamento anular abraza la cabeza del radio fijándose a ambos extremos de la escotadura radial de la ulna manteniendo la cabeza en su sitio.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Ligamento Anular del Radio',
    order: 11
  },
  {
    id: 'quiz_t3_bra_12',
    topicId: 'brazo_codo_antebrazo',
    type: 'single_choice',
    question: '¿Qué nervio atraviesa los dos fascículos del músculo supinador (arcada de Frohse) para inervar el compartimento posterior del antebrazo?',
    options: ['Ramo profundo del nervio radial (nervio interóseo posterior)', 'Nervio interóseo anterior', 'Nervio musculocutáneo'],
    correctIndex: 0,
    rationale: 'El ramo motor profundo del nervio radial atraviesa la arcada de Frohse en el supinador pasando al plano extensor posterior del antebrazo.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Arcada de Frohse y Nervio Radial',
    order: 12
  },
  {
    id: 'quiz_t3_bra_13',
    topicId: 'brazo_codo_antebrazo',
    type: 'matching',
    question: 'Empareja los nervios terminales del plexo braquial con su fascículo de origen:',
    matchingPairs: [
      { left: 'Fascículo lateral', right: 'Nervio musculocutáneo y raíz lateral del mediano' },
      { left: 'Fascículo medial', right: 'Nervio cubital y raíz medial del mediano' },
      { left: 'Fascículo posterior', right: 'Nervio radial y nervio axilar' }
    ],
    options: ['Fascículos del plexo braquial'],
    correctIndex: 0,
    rationale: 'Lateral da musculocutáneo y raíz lateral del mediano; Medial da cubital y raíz medial del mediano; Posterior da radial y axilar.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Fascículos del Plexo Braquial',
    order: 13
  },
  {
    id: 'quiz_t3_bra_14',
    topicId: 'brazo_codo_antebrazo',
    type: 'ordering',
    question: 'Ordena de superficial a profundo los planos musculares de la cara anterior del antebrazo:',
    orderingItems: [
      'Primer plano: Músculos epitrocleares superficiales (pronador redondo, palmares, cubital anterior)',
      'Segundo plano: Músculo flexor superficial de los dedos',
      'Tercer plano: Músculo flexor profundo de los dedos y flexor largo del pulgar',
      'Cuarto plano: Músculo pronador cuadrado'
    ],
    options: ['Planos del compartimento anterior del antebrazo'],
    correctIndex: 0,
    rationale: 'Los 8 músculos anteriores se ordenan en 4 capas estrictas de superficial a profundo hasta el pronador cuadrado.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Músculos Anteriores del Antebrazo',
    order: 14
  },
  {
    id: 'quiz_t3_bra_15',
    topicId: 'brazo_codo_antebrazo',
    type: 'single_choice',
    question: 'La arteria braquial se bifurca en sus dos ramas terminales (arteria radial y cubital) a la altura de:',
    options: ['4 cm por debajo de la interlínea articular del codo (cuello del radio)', 'El tercio medio del brazo', 'La muñeca'],
    correctIndex: 0,
    rationale: 'La arteria humeral se divide en arteria radial y arteria cubital en la parte inferior de la fosa del codo, frente al cuello del radio.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Bifurcación de la Arteria Braquial',
    order: 15
  },
  {
    id: 'quiz_t3_bra_16',
    topicId: 'brazo_codo_antebrazo',
    type: 'single_choice',
    question: '¿Qué músculo del antebrazo está inervado doblemente (mitad medial por el nervio cubital y mitad lateral por el nervio interóseo anterior de mediano)?',
    options: ['Músculo flexor profundo de los dedos', 'Músculo flexor superficial de los dedos', 'Músculo pronador redondo'],
    correctIndex: 0,
    rationale: 'El flexor profundo de los dedos tiene doble inervación: los tendones para los dedos 2 y 3 los inerva el mediano; para los dedos 4 y 5 los inerva el cubital.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Flexor Profundo de los Dedos',
    order: 16
  },
  {
    id: 'quiz_t3_bra_17',
    topicId: 'brazo_codo_antebrazo',
    type: 'single_choice',
    question: 'Niño de 2 años es alzado bruscamente de la mano y queda con el codo en pronación dolorosa sin mover el brazo ("codo de niñera"). ¿Qué estructura anatómica se subluxó a través del ligamento anular?',
    options: ['Cabeza del radio', 'Olécranon', 'Epicóndilo medial'],
    correctIndex: 0,
    rationale: 'La subluxación de la cabeza del radio (pronación dolorosa infantil) ocurre cuando la cabeza radial pequeña resbala parcialmente debajo del ligamento anular laxo.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Cabeza Radial y Codo de Niñera',
    order: 17
  },
  {
    id: 'quiz_t3_bra_18',
    topicId: 'brazo_codo_antebrazo',
    type: 'single_choice',
    question: 'El músculo braquiorradial (supinador largo) pertenece al grupo lateral del antebrazo y está inervado por:',
    options: ['Nervio radial', 'Nervio musculocutáneo', 'Nervio mediano'],
    correctIndex: 0,
    rationale: 'A pesar de ser flexor del codo, el braquiorradial está inervado directamente por el nervio radial antes de su bifurcación.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Músculo Braquiorradial',
    order: 18
  },
  {
    id: 'quiz_t3_bra_19',
    topicId: 'brazo_codo_antebrazo',
    type: 'single_choice',
    question: 'La membrana interósea del antebrazo une los bordes interóseos del radio y cúbito transmitiendo las fuerzas de compresión desde:',
    options: ['El radio hacia el cúbito en dirección proximal', 'El cúbito hacia el húmero directamente', 'La mano al hombro'],
    correctIndex: 0,
    rationale: 'Las fibras de la membrana interósea se orientan oblicuamente hacia abajo y adentro para desviar las fuerzas mecánicas desde el radio distal hacia la ulna proximal.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Membrana Interósea del Antebrazo',
    order: 19
  },
  {
    id: 'quiz_t3_bra_20',
    topicId: 'brazo_codo_antebrazo',
    type: 'single_choice',
    question: 'El músculo ancóneo refuerza la extensión del codo y se sitúa en:',
    options: ['La cara posterior del codo, lateral al olécranon', 'La fosa bicipital anterior', 'El túnel del carpo'],
    correctIndex: 0,
    rationale: 'El ancóneo es un músculo triangular pequeño en la cara posterior del codo que estabiliza la articulación durante la pronosupinación.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Músculo Ancóneo',
    order: 20
  },

  // =========================================================================
  // TEMA 3: muneca_mano_tunel_carpiano (20 QUIZZES)
  // =========================================================================
  {
    id: 'quiz_t3_man_01',
    topicId: 'muneca_mano_tunel_carpiano',
    type: 'single_choice',
    question: '¿Qué hueso del carpo es el que se fractura con mayor frecuencia tras una caída sobre la palma de la mano en hiperextensión?',
    options: ['Hueso escafoides', 'Hueso semilunar', 'Hueso piramidal'],
    correctIndex: 0,
    rationale: 'El escafoides concentra el 70% de todas las fracturas del carpo; su irrigación retrógrada distal a proximal lo predispone a necrosis avascular del polo proximal.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Huesos del Carpo y Escafoides',
    order: 1
  },
  {
    id: 'quiz_t3_man_02',
    topicId: 'muneca_mano_tunel_carpiano',
    type: 'single_choice',
    question: 'El túnel carpiano está formado por el arco de los huesos del carpo cerrado anteriormente por:',
    options: ['El retináculo flexor (ligamento anular anterior del carpo)', 'La aponeurosis palmar superficial', 'El retináculo extensor'],
    correctIndex: 0,
    rationale: 'El retináculo flexor se extiende desde el tubérculo del escafoides y trapecio hasta el pisiforme y gancho del ganchoso, convirtiendo la corredera carpiana en un túnel.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Túnel Carpiano',
    order: 2
  },
  {
    id: 'quiz_t3_man_03',
    topicId: 'muneca_mano_tunel_carpiano',
    type: 'single_choice',
    question: 'Paciente femenina presenta parestesias nocturnas en los dedos pulgar, índice, medio y mitad lateral del anular con atrofia de la eminencia tenar (signos de Tinel y Phalen positivos). ¿Qué elemento del túnel carpiano está comprimido?',
    options: ['Nervio mediano', 'Nervio cubital', 'Arteria radial'],
    correctIndex: 0,
    rationale: 'El síndrome del túnel carpiano es la neuropatía por atrapamiento del nervio mediano dentro del túnel carpiano acompañado por 9 tendones flexores.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Nervio Mediano y Síndrome del Túnel Carpiano',
    order: 3
  },
  {
    id: 'quiz_t3_man_04',
    topicId: 'muneca_mano_tunel_carpiano',
    type: 'single_choice',
    question: '¿Cuántos tendones atraviesan el túnel del carpo junto con el nervio mediano?',
    options: ['9 tendones (4 del flexor superficial, 4 del flexor profundo y 1 del flexor largo del pulgar)', '5 tendones', '12 tendones'],
    correctIndex: 0,
    rationale: 'El contenido exacto del túnel carpiano son 10 estructuras: el nervio mediano y 9 tendones flexores rodeados por sus vainas sinoviales.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Contenido del Túnel Carpiano',
    order: 4
  },
  {
    id: 'quiz_t3_man_05',
    topicId: 'muneca_mano_tunel_carpiano',
    type: 'matching',
    question: 'Relaciona las eminencias de la palma de la mano con los grupos musculares que alojan:',
    matchingPairs: [
      { left: 'Eminencia tenar (lado radial)', right: 'Músculos intrínsecos del pulgar (abductor corto, flexor corto, oponente, aductor)' },
      { left: 'Eminencia hipotenar (lado cubital)', right: 'Músculos del meñique (palmar corto, abductor, flexor corto, oponente)' },
      { left: 'Hueco palmar medio', right: 'Músculos lumbricales e interóseos con los tendones flexores' }
    ],
    options: ['Topografía muscular de la mano'],
    correctIndex: 0,
    rationale: 'Tenar para el pulgar; hipotenar para el meñique; región media para lumbricales e interóseos.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Músculos de la Palma de la Mano',
    order: 5
  },
  {
    id: 'quiz_t3_man_06',
    topicId: 'muneca_mano_tunel_carpiano',
    type: 'ordering',
    question: 'Ordena de lateral a medial los 4 huesos de la fila proximal del carpo:',
    orderingItems: [
      'Escafoides',
      'Semilunar (lunatum)',
      'Piramidal (triquetrum)',
      'Pisiforme (hueso sesamoideo sobre el piramidal)'
    ],
    options: ['Fila proximal del carpo'],
    correctIndex: 0,
    rationale: 'Mnemotecnia clásica de lateral a medial: "E-Se-Pi-Pi" (Escafoides, Semilunar, Piramidal y Pisiforme).',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Huesos del Carpo',
    order: 6
  },
  {
    id: 'quiz_t3_man_07',
    topicId: 'muneca_mano_tunel_carpiano',
    type: 'single_choice',
    question: 'El canal de Guyon (canal cubital de la muñeca) transmite:',
    options: ['El nervio cubital y la arteria cubital', 'El nervio mediano', 'El tendón del palmar mayor'],
    correctIndex: 0,
    rationale: 'El canal de Guyon se sitúa superficial al retináculo flexor entre el pisiforme y el gancho del ganchoso, dando paso al paquete vasculonervioso cubital.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Canal de Guyon',
    order: 7
  },
  {
    id: 'quiz_t3_man_08',
    topicId: 'muneca_mano_tunel_carpiano',
    type: 'single_choice',
    question: 'Los límites anatómicos de la tabaquera anatómica en el dorso de la muñeca son:',
    options: ['Abductor largo y extensor corto del pulgar (medial/anterior) y extensor largo del pulgar (lateral/posterior)', 'Extensor de los dedos y palmar mayor', 'Músculos lumbricales'],
    correctIndex: 0,
    rationale: 'La tabaquera anatómica está limitada por el abductor largo y extensor corto del pulgar a un lado, y el extensor largo del pulgar al otro; en su piso discurre la arteria radial.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Tabaquera Anatómica',
    order: 8
  },
  {
    id: 'quiz_t3_man_09',
    topicId: 'muneca_mano_tunel_carpiano',
    type: 'single_choice',
    question: 'Un paciente presenta una herida lacerante profunda en la base de la palma con lesión del nervio cubital. Al examinarlo, presenta la típica deformidad de "mano en garra" (garra cubital). ¿Por qué se produce esta postura?',
    options: ['Por parálisis de los músculos interóseos y 3.er y 4.° lumbricales (hiperextensión MCF y flexión IF)', 'Por contractura del tendón del bíceps', 'Por parálisis del nervio radial'],
    correctIndex: 0,
    rationale: 'El nervio cubital inerva todos los interóseos y los dos lumbricales mediales. Su parálisis causa extensión metacarpofalángica y flexión interfalángica en 4.° y 5.° dedo.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Mano en Garra Cubital',
    order: 9
  },
  {
    id: 'quiz_t3_man_10',
    topicId: 'muneca_mano_tunel_carpiano',
    type: 'single_choice',
    question: 'La articulación trapeciometacarpiana del pulgar es una articulación sinovial de tipo:',
    options: ['En silla de montar (encaje recíproco)', 'Esferoidea', 'Gínglimo'],
    correctIndex: 0,
    rationale: 'La articulación del trapecio con el primer metacarpiano es una articulación en silla de montar que permite el movimiento fundamental de oposición del pulgar.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Articulación Trapeciometacarpiana',
    order: 10
  },
  {
    id: 'quiz_t3_man_11',
    topicId: 'muneca_mano_tunel_carpiano',
    type: 'single_choice',
    question: 'El arco palmar superficial se forma predominantemente por la terminación de:',
    options: ['La arteria cubital anastomosada con la rama palmar superficial de la arteria radial', 'La arteria interósea', 'La arteria braquial'],
    correctIndex: 0,
    rationale: 'El arco palmar superficial lo constituye principalmente la arteria cubital completada lateralmente por la arteria radiopalmar (palmar superficial de la radial).',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Arcos Palmares de la Mano',
    order: 11
  },
  {
    id: 'quiz_t3_man_12',
    topicId: 'muneca_mano_tunel_carpiano',
    type: 'single_choice',
    question: '¿Cuántos músculos interóseos palmares y dorsales existen en la mano humana y cuál es su acción?',
    options: ['3 palmares (aducen dedos hacia el eje) y 4 dorsales (abducen o separan dedos)', '5 palmares y 5 dorsales', '4 palmares extensores'],
    correctIndex: 0,
    rationale: 'Mnemotecnia PAD y DAB: Palmares ADucen (PAD) hacia el 3.er dedo; Dorsales ABducen (DAB) separando los dedos del eje de la mano.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Músculos Interóseos de la Mano',
    order: 12
  },
  {
    id: 'quiz_t3_man_13',
    topicId: 'muneca_mano_tunel_carpiano',
    type: 'matching',
    question: 'Asocia cada prueba semiológica de la mano con su objetivo diagnóstico:',
    matchingPairs: [
      { left: 'Signo de Phalen', right: 'Flexión forzada de muñecas a 90° durante 60 s para despertar parestesias en túnel carpiano' },
      { left: 'Prueba de Allen', right: 'Comprueba la permeabilidad y suficiencia de las arterias radial y cubital y los arcos palmares' },
      { left: 'Signo de Froment', right: 'Flexión compensatoria de la interfalángica del pulgar por parálisis del aductor (nervio cubital)' }
    ],
    options: ['Maniobras clínicas de muñeca y mano'],
    correctIndex: 0,
    rationale: 'Phalen evalúa mediano; Allen evalúa vascularización palmar; Froment evalúa debilidad del nervio cubital.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Semiología Quirúrgica de la Mano',
    order: 13
  },
  {
    id: 'quiz_t3_man_14',
    topicId: 'muneca_mano_tunel_carpiano',
    type: 'ordering',
    question: 'Ordena de lateral a medial los huesos de la fila distal del carpo:',
    orderingItems: [
      'Trapecio',
      'Trapezoide',
      'Hueso grande (capitatum)',
      'Hueso ganchoso (hamatum)'
    ],
    options: ['Fila distal del carpo'],
    correctIndex: 0,
    rationale: 'Mnemotecnia de lateral a medial: Trapecio -> Trapezoide -> Grande -> Ganchoso.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Huesos del Carpo Fila Distal',
    order: 14
  },
  {
    id: 'quiz_t3_man_15',
    topicId: 'muneca_mano_tunel_carpiano',
    type: 'single_choice',
    question: 'El fibrocartílago triangular (complejo del fibrocartílago triangular) separa la cabeza del cúbito de:',
    options: ['Los huesos semilunar y piramidal del carpo', 'El hueso escafoides', 'El primer metacarpiano'],
    correctIndex: 0,
    rationale: 'El disco articular o fibrocartílago triangular impide que el cúbito articule directamente con el carpo en la articulación radiocarpiana.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Articulación Radiocarpiana',
    order: 15
  },
  {
    id: 'quiz_t3_man_16',
    topicId: 'muneca_mano_tunel_carpiano',
    type: 'single_choice',
    question: 'Los tendones del flexor superficial de los dedos se bifurcan a nivel de la falange proximal permitiendo el paso de:',
    options: ['Los tendones del flexor profundo de los dedos (tendón perforante)', 'Los tendones extensores', 'Los lumbricales'],
    correctIndex: 0,
    rationale: 'El flexor superficial es el tendón "perforado" (quiasma de Camper) que da paso al tendón "perforante" del flexor profundo hacia la falange distal.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Quiasma Tendinoso de Camper',
    order: 16
  },
  {
    id: 'quiz_t3_man_17',
    topicId: 'muneca_mano_tunel_carpiano',
    type: 'single_choice',
    question: 'Un paciente presenta tenosinovitis estenosante de De Quervain con dolor severo en el borde radial de la muñeca (maniobra de Finkelstein positiva). ¿Qué corredera osteofibrosa dorsal de la muñeca está afectada?',
    options: ['Primera corredera dorsal (abductor largo y extensor corto del pulgar)', 'Segunda corredera dorsal', 'Tercera corredera dorsal'],
    correctIndex: 0,
    rationale: 'La tenosinovitis de De Quervain inflama la 1.ª corredera dorsal por donde discurren los tendones del abductor largo y extensor corto del pulgar.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Correderas Tendinosas Dorsales',
    order: 17
  },
  {
    id: 'quiz_t3_man_18',
    topicId: 'muneca_mano_tunel_carpiano',
    type: 'single_choice',
    question: '¿Qué músculo de la eminencia tenar es el único inervado por el nervio cubital y no por el nervio mediano?',
    options: ['Músculo aductor del pulgar (y fascículo profundo del flexor corto)', 'Músculo oponente del pulgar', 'Músculo abductor corto del pulgar'],
    correctIndex: 0,
    rationale: 'El músculo aductor del pulgar y el fascículo profundo del flexor corto están inervados por el ramo profundo del nervio cubital.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Inervación de la Mano',
    order: 18
  },
  {
    id: 'quiz_t3_man_19',
    topicId: 'muneca_mano_tunel_carpiano',
    type: 'single_choice',
    question: 'La fascia o aponeurosis palmar media se continúa proximalmente con el tendón del músculo:',
    options: ['Músculo palmar largo (palmar menor)', 'Músculo flexor radial del carpo', 'Músculo pronador redondo'],
    correctIndex: 0,
    rationale: 'El tendón del palmar largo se expande distalmente en abanico fibroso sobre la palma de la mano formando la aponeurosis palmar superficial.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Aponeurosis Palmar',
    order: 19
  },
  {
    id: 'quiz_t3_man_20',
    topicId: 'muneca_mano_tunel_carpiano',
    type: 'single_choice',
    question: 'La arteria radial ingresa a la palma profunda pasando entre las dos cabezas de qué músculo:',
    options: ['Primer músculo interóseo dorsal', 'Músculo aductor del meñique', 'Músculo pronador cuadrado'],
    correctIndex: 0,
    rationale: 'La arteria radial penetra desde el dorso al plano palmar profundo cruzando entre los dos fascículos del primer interóseo dorsal para formar el arco palmar profundo.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Arteria Radial en la Mano',
    order: 20
  }
];

export async function run() {
  await uploadQuizzesBatch(tomo3Part1Quizzes, 'Rouvière Tomo 3 (Bloque A: Temas 1 a 3)');
}
