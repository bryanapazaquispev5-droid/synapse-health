// Quizzes Clínicos de Anatomía Humana - Rouvière Tomo 2 (Parte 2: Temas 3 a 6)
// 4 Temas x 20 Quizzes = 80 Quizzes
import { uploadQuizzesBatch } from './seed_quizzes_common.mjs';

const tomo2Part2Quizzes = [
  // =========================================================================
  // TEMA 3: cardiovascular_corazon_pericardio (20 QUIZZES)
  // =========================================================================
  {
    id: 'quiz_t2_car_01',
    topicId: 'cardiovascular_corazon_pericardio',
    type: 'single_choice',
    question: 'El nódulo sinoauricular (marcapasos fisiológico de Keith y Flack) se ubica en:',
    options: ['La unión anterolateral de la vena cava superior con la aurícula derecha', 'El tabique interauricular cerca de la fosa oval', 'La punta del corazón'],
    correctIndex: 0,
    rationale: 'El nódulo SA se localiza en la pared posterolateral alta de la aurícula derecha, en la unión con la desembocadura de la vena cava superior (cresta terminal).',
    sourceBook: 'Rouvière - Delmas: Tomo 2 (Tronco), Sistema de Conducción Cardíaco',
    order: 1
  },
  {
    id: 'quiz_t2_car_02',
    topicId: 'cardiovascular_corazon_pericardio',
    type: 'single_choice',
    question: '¿Qué arteria coronaria da origen a la arteria descendente posterior (interventricular posterior) en el 85% de las personas (circulación con dominancia derecha)?',
    options: ['Arteria coronaria derecha', 'Arteria circunfleja', 'Arteria descendente anterior'],
    correctIndex: 0,
    rationale: 'En el patrón de dominancia derecha (85-90% de la población), la arteria coronaria derecha da la rama interventricular posterior en la cruz del corazón.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Arterias Coronarias',
    order: 2
  },
  {
    id: 'quiz_t2_car_03',
    topicId: 'cardiovascular_corazon_pericardio',
    type: 'case_study',
    question: 'Paciente con infarto agudo de miocardio transmural anteroseptal (elevación del ST de V1 a V4). ¿Qué arteria coronaria se encuentra ocluida?',
    options: ['Arteria descendente anterior (interventricular anterior)', 'Arteria coronaria derecha', 'Arteria marginal derecha'],
    correctIndex: 0,
    rationale: 'La arteria descendente anterior (rama de la coronaria izquierda) irriga los dos tercios anteriores del tabique interventricular y la pared anterior ventricular.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Coronaria Izquierda e Infartos',
    order: 3
  },
  {
    id: 'quiz_t2_car_04',
    topicId: 'cardiovascular_corazon_pericardio',
    type: 'single_choice',
    question: 'El seno coronario, principal colector venoso del miocardio, desemboca en:',
    options: ['La aurícula derecha (entre la vena cava inferior y la válvula tricúspide)', 'La aurícula izquierda', 'La vena cava superior'],
    correctIndex: 0,
    rationale: 'El orificio del seno coronario está provisto de la válvula de Tebesio y desemboca en la pared posteroinferior de la aurícula derecha.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Venas Cardíacas y Seno Coronario',
    order: 4
  },
  {
    id: 'quiz_t2_car_05',
    topicId: 'cardiovascular_corazon_pericardio',
    type: 'matching',
    question: 'Relaciona cada válvula cardíaca con su correspondiente foco de auscultación clínico:',
    matchingPairs: [
      { left: 'Foco aórtico', right: '2.º espacio intercostal derecho en la línea paraesternal' },
      { left: 'Foco pulmonar', right: '2.º espacio intercostal izquierdo en la línea paraesternal' },
      { left: 'Foco mitral (ápex)', right: '5.º espacio intercostal izquierdo en la línea medioclavicular' }
    ],
    options: ['Focos de auscultación cardíaca'],
    correctIndex: 0,
    rationale: 'Aórtico en 2.° EID; Pulmonar en 2.° EII; Mitral en 5.° EII línea medioclavicular (choque de la punta).',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Focos Clínicos de Auscultación',
    order: 5
  },
  {
    id: 'quiz_t2_car_06',
    topicId: 'cardiovascular_corazon_pericardio',
    type: 'ordering',
    question: 'Ordena la propagación del impulso eléctrico a través del sistema cardionector intrínseco:',
    orderingItems: [
      'Nódulo sinoauricular (de Keith y Flack)',
      'Nódulo auriculoventricular (de Aschoff-Tawara)',
      'Fascículo auriculoventricular (Haz de His) y sus ramas',
      'Red subendocárdica de Purkinje'
    ],
    options: ['Sistema de conducción cardíaco'],
    correctIndex: 0,
    rationale: 'El impulso eléctrico viaja: Nódulo SA -> Nódulo AV -> Haz de His -> Fibras de Purkinje.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Sistema Cardionector',
    order: 6
  },
  {
    id: 'quiz_t2_car_07',
    topicId: 'cardiovascular_corazon_pericardio',
    type: 'single_choice',
    question: 'El seno transverso del pericardio (de Theile) separa:',
    options: ['La aorta ascendente y tronco pulmonar por delante, de las aurículas y vena cava por detrás', 'El ventrículo derecho del ventrículo izquierdo', 'La aurícula izquierda del esófago'],
    correctIndex: 0,
    rationale: 'El seno transverso de Theile es un túnel seroso horizontal que pasa posterior a los troncos arteriales (aorta y arteria pulmonar) y anterior a las aurículas.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Senos del Pericardio',
    order: 7
  },
  {
    id: 'quiz_t2_car_08',
    topicId: 'cardiovascular_corazon_pericardio',
    type: 'single_choice',
    question: '¿Qué formación muscular del ventrículo derecho conduce la rama derecha del haz de His desde el tabique interventricular hacia el músculo papilar anterior?',
    options: ['Trabécula septomarginal (banda moderadora)', 'Cresta terminal', 'Músculos pectíneos'],
    correctIndex: 0,
    rationale: 'La trabécula septomarginal (banda moderadora) cruza la luz del ventrículo derecho llevando la rama derecha del haz de His para la despolarización rápida del músculo papilar.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Ventrículo Derecho',
    order: 8
  },
  {
    id: 'quiz_t2_car_09',
    topicId: 'cardiovascular_corazon_pericardio',
    type: 'case_study',
    question: 'Paciente con taponamiento cardíaco secundario a hemopericardio traumático (tríada de Beck). Se realiza pericardiocentesis de urgencia por vía subxifoidea (de Marfan). ¿Hacia qué hombro se orienta la aguja a 45 grados?',
    options: ['Hacia el hombro izquierdo', 'Hacia el hombro derecho', 'En ángulo recto hacia la columna'],
    correctIndex: 0,
    rationale: 'La punción subxifoidea de Marfan ingresa entre el apéndice xifoides y el reborde costal izquierdo dirigiéndose hacia el hombro izquierdo para drenar la fosa pericárdica posteroinferior.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Saco Pericárdico y Pericardiocentesis',
    order: 9
  },
  {
    id: 'quiz_t2_car_10',
    topicId: 'cardiovascular_corazon_pericardio',
    type: 'single_choice',
    question: 'La fosa oval y el limbo de la fosa oval (anillo de Vieussens) se sitúan en:',
    options: ['El tabique interauricular en la aurícula derecha', 'El tabique interventricular membranoso', 'El cono arterioso del ventrículo derecho'],
    correctIndex: 0,
    rationale: 'La fosa oval es el remanente del foramen oval fetal y se observa en la cara derecha del tabique interauricular.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Aurícula Derecha',
    order: 10
  },
  {
    id: 'quiz_t2_car_11',
    topicId: 'cardiovascular_corazon_pericardio',
    type: 'single_choice',
    question: '¿Qué válvula cardíaca posee dos valvas (anterior y posterior) y orificio atrioventricular izquierdo?',
    options: ['Válvula mitral (bicúspide)', 'Válvula tricúspide', 'Válvula aórtica'],
    correctIndex: 0,
    rationale: 'La válvula mitral une la aurícula izquierda con el ventrículo izquierdo y está compuesta por dos valvas amplias con aspecto de mitra episcopal.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Válvula Mitral',
    order: 11
  },
  {
    id: 'quiz_t2_car_12',
    topicId: 'cardiovascular_corazon_pericardio',
    type: 'single_choice',
    question: 'El ligamento arterioso se extiende entre:',
    options: ['La concavidad del cayado aórtico y el tronco de la arteria pulmonar izquierda', 'La aorta y la vena cava superior', 'Las arterias coronarias'],
    correctIndex: 0,
    rationale: 'El ligamento arterioso es el remanente fibroso del conducto arterioso fetal de Botal, conectando la aorta con la bifurcación pulmonar.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Grandes Vasos de la Base Cardíaca',
    order: 12
  },
  {
    id: 'quiz_t2_car_13',
    topicId: 'cardiovascular_corazon_pericardio',
    type: 'matching',
    question: 'Empareja el accidente valvular con su correspondiente válvula semilunar:',
    matchingPairs: [
      { left: 'Nódulos de Arancio', right: 'Borde libre de las valvas semilunares de la válvula aórtica' },
      { left: 'Nódulos de Morgagni', right: 'Borde libre de las valvas semilunares de la válvula pulmonar' },
      { left: 'Senos de Valsalva', right: 'Dilataciones aórticas de donde nacen las arterias coronarias' }
    ],
    options: ['Válvulas semilunares'],
    correctIndex: 0,
    rationale: 'Arancio sella la válvula aórtica; Morgagni sella la pulmonar; los senos aórticos de Valsalva alojan los ostia coronarios.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Válvulas Aórtica y Pulmonar',
    order: 13
  },
  {
    id: 'quiz_t2_car_14',
    topicId: 'cardiovascular_corazon_pericardio',
    type: 'ordering',
    question: 'Ordena el recorrido de la sangre en el circuito menor (circulación pulmonar):',
    orderingItems: [
      'Ventrículo derecho y válvula pulmonar',
      'Tronco y arterias pulmonares (derecha e izquierda)',
      'Capilares alveolares de ambos pulmones',
      'Venas pulmonares y aurícula izquierda'
    ],
    options: ['Circulación menor'],
    correctIndex: 0,
    rationale: 'Ventrículo derecho -> Tronco pulmonar -> Alvéolos pulmonares -> 4 Venas pulmonares -> Aurícula izquierda.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Circulación Pulmonar Menor',
    order: 14
  },
  {
    id: 'quiz_t2_car_15',
    topicId: 'cardiovascular_corazon_pericardio',
    type: 'single_choice',
    question: 'La aurícula izquierda se relaciona inmediatamente por su cara posterior con:',
    options: ['El esófago torácico (a través del seno oblicuo del pericardio)', 'El esternón', 'La tráquea exclusivamente'],
    correctIndex: 0,
    rationale: 'La pared posterior de la aurícula izquierda reposa directamente anterior al esófago torácico, permitiendo el ecocardiograma transesofágico de alta resolución.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Relaciones Posteriores del Corazón',
    order: 15
  },
  {
    id: 'quiz_t2_car_16',
    topicId: 'cardiovascular_corazon_pericardio',
    type: 'single_choice',
    question: 'El triángulo de Koch en la aurícula derecha es la referencia topográfica fundamental para localizar:',
    options: ['El nódulo auriculoventricular (de Aschoff-Tawara)', 'El nódulo sinoauricular', 'El haz de Bachmann'],
    correctIndex: 0,
    rationale: 'El triángulo de Koch lo delimitan el tendón de Todaro, la válvula septal de la tricúspide y el ostium del seno coronario; aloja al nódulo AV.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Triángulo de Koch',
    order: 16
  },
  {
    id: 'quiz_t2_car_17',
    topicId: 'cardiovascular_corazon_pericardio',
    type: 'case_study',
    question: 'Un paciente presenta regurgitación valvular severa. El ecocardiograma revela ruptura de cuerdas tendinosas del músculo papilar anterior en el ventrículo izquierdo. ¿A qué válvula estabilizaba este aparato subvalvular?',
    options: ['Válvula mitral', 'Válvula tricúspide', 'Válvula sigmoidea aórtica'],
    correctIndex: 0,
    rationale: 'El ventrículo izquierdo posee dos grandes músculos papilares (anterior y posterior) cuyas cuerdas tendinosas se anclan en las valvas de la válvula mitral impidiendo su prolapso en sístole.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Aparato Subvalvular Mitral',
    order: 17
  },
  {
    id: 'quiz_t2_car_18',
    topicId: 'cardiovascular_corazon_pericardio',
    type: 'single_choice',
    question: '¿Qué arteria coronaria rodea el surco auriculoventricular izquierdo y da las ramas marginales obtusas?',
    options: ['Arteria circunfleja', 'Arteria coronaria derecha', 'Arteria interventricular posterior'],
    correctIndex: 0,
    rationale: 'La arteria circunfleja (rama de la coronaria izquierda) discurre por el surco coronario izquierdo irrigando la pared lateral del ventrículo izquierdo.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Arteria Circunfleja',
    order: 18
  },
  {
    id: 'quiz_t2_car_19',
    topicId: 'cardiovascular_corazon_pericardio',
    type: 'single_choice',
    question: 'El pericardio fibroso se fusiona inferiormente con:',
    options: ['El centro tendinoso del diafragma (espejo de Van Helmont)', 'La vértebra T12', 'Los músculos rectos del abdomen'],
    correctIndex: 0,
    rationale: 'La base del pericardio fibroso descansa y se halla íntimamente soldada al centro tendinoso del diafragma mediante el ligamento frenopericárdico.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Saco Pericárdico Fibroso',
    order: 19
  },
  {
    id: 'quiz_t2_car_20',
    topicId: 'cardiovascular_corazon_pericardio',
    type: 'single_choice',
    question: 'La inervación simpática del corazón procede de los nervios cardíacos cervicales y torácicos y produce:',
    options: ['Aumento de la frecuencia cardíaca (cronotropismo positivo) y de la contractilidad (inotropismo positivo)', 'Bradicardia y broncoconstricción', 'Paro sinusal'],
    correctIndex: 0,
    rationale: 'La estimulación simpática miocárdica (vía receptores beta-1) eleva la frecuencia cardíaca, contractilidad, dromotropismo y batmotropismo cardíacos.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Inervación Cardíaca Autónoma',
    order: 20
  },

  // =========================================================================
  // TEMA 4: pared_abdominal_conducto_inguinal (20 QUIZZES)
  // =========================================================================
  {
    id: 'quiz_t2_abd_01',
    topicId: 'pared_abdominal_conducto_inguinal',
    type: 'single_choice',
    question: 'El ligamento inguinal (de Falopio o Poupart) se extiende entre qué puntos óseos:',
    options: ['Espina ilíaca anterosuperior y tubérculo del pubis (espina púbica)', 'Espina ilíaca anteroinferior y sínfisis púbica', 'Cresta ilíaca y trocánter mayor'],
    correctIndex: 0,
    rationale: 'El ligamento inguinal es el borde inferior engrosado y reflejado de la aponeurosis del músculo oblicuo externo que va de la EIAS al tubérculo del pubis.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Conducto Inguinal',
    order: 1
  },
  {
    id: 'quiz_t2_abd_02',
    topicId: 'pared_abdominal_conducto_inguinal',
    type: 'single_choice',
    question: '¿Qué estructura anatómica constituye el contenido fundamental del conducto inguinal en el varón y en la mujer, respectivamente?',
    options: ['Cordón espermático en el varón y ligamento redondo del útero en la mujer', 'Nervio ciático y arteria femoral', 'Uréter y conducto deferente'],
    correctIndex: 0,
    rationale: 'El conducto inguinal transmite el funículo (cordón) espermático en el hombre y el ligamento redondo del útero en la mujer hacia los labios mayores.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Contenido del Conducto Inguinal',
    order: 2
  },
  {
    id: 'quiz_t2_abd_03',
    topicId: 'pared_abdominal_conducto_inguinal',
    type: 'case_study',
    question: 'Un paciente de 25 años presenta masa reducible en el escroto que desciende por dentro del cordón espermático lateral a los vasos epigástricos inferiores. ¿Qué tipo de hernia inguinal presenta?',
    options: ['Hernia inguinal indirecta (oblicua externa)', 'Hernia inguinal directa', 'Hernia crural (femoral)'],
    correctIndex: 0,
    rationale: 'Las hernias inguinales indirectas penetran por el anillo inguinal profundo, situándose laterales a los vasos epigástricos inferiores y recorriendo todo el cordón espermático.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Anatomía Quirúrgica de las Hernias Inguinales',
    order: 3
  },
  {
    id: 'quiz_t2_abd_04',
    topicId: 'pared_abdominal_conducto_inguinal',
    type: 'single_choice',
    question: 'El trígono inguinal (de Hesselbach), sitio de protrusión de las hernias directas, está delimitado por:',
    options: ['Vasos epigástricos inferiores (lateral), borde lateral del músculo recto (medial) y ligamento inguinal (inferior)', 'Pecten del pubis y arteria femoral', 'Cresta ilíaca y músculo dorsal ancho'],
    correctIndex: 0,
    rationale: 'El triángulo de Hesselbach es la zona de debilidad de la fascia transversalis delimitada por los vasos epigástricos inferiores, el recto abdominal y el ligamento inguinal.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Trígono Inguinal de Hesselbach',
    order: 4
  },
  {
    id: 'quiz_t2_abd_05',
    topicId: 'pared_abdominal_conducto_inguinal',
    type: 'matching',
    question: 'Relaciona cada pared del conducto inguinal con su elemento anatómico formador:',
    matchingPairs: [
      { left: 'Pared anterior', right: 'Aponeurosis del músculo oblicuo externo' },
      { left: 'Pared posterior', right: 'Fascia transversalis reforzada por el tendón conjunto' },
      { left: 'Piso (pared inferior)', right: 'Ligamento inguinal y ligamento lacunar (de Gimbernat)' }
    ],
    options: ['Paredes del conducto inguinal'],
    correctIndex: 0,
    rationale: 'Pared anterior: oblicuo externo; pared posterior: fascia transversalis; piso: ligamento inguinal; techo: tendón conjunto.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Conducto Inguinal',
    order: 5
  },
  {
    id: 'quiz_t2_abd_06',
    topicId: 'pared_abdominal_conducto_inguinal',
    type: 'ordering',
    question: 'Ordena de superficial a profundo los músculos y capas de la pared anterolateral del abdomen:',
    orderingItems: [
      'Piel y tejido subcutáneo (fascias de Camper y Scarpa)',
      'Músculo oblicuo externo',
      'Músculo oblicuo interno',
      'Músculo transverso del abdomen y fascia transversalis'
    ],
    options: ['Capas de la pared abdominal'],
    correctIndex: 0,
    rationale: 'De superficial a profundo: Piel/subcutáneo -> Oblicuo externo -> Oblicuo interno -> Transverso del abdomen -> Fascia transversalis -> Peritoneo.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Paredes Abdominales',
    order: 6
  },
  {
    id: 'quiz_t2_abd_07',
    topicId: 'pared_abdominal_conducto_inguinal',
    type: 'single_choice',
    question: 'Por debajo de la línea arqueada (arco de Douglas), la hoja posterior de la vaina del recto está formada únicamente por:',
    options: ['La fascia transversalis y el peritoneo parietal', 'La aponeurosis del transverso', 'La aponeurosis del oblicuo interno'],
    correctIndex: 0,
    rationale: 'Por debajo de la línea arqueada, las aponeurosis de los tres músculos planos pasan por delante del recto abdominal; por detrás sólo queda la fascia transversalis.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Vaina de los Músculos Rectos',
    order: 7
  },
  {
    id: 'quiz_t2_abd_08',
    topicId: 'pared_abdominal_conducto_inguinal',
    type: 'single_choice',
    question: 'El tendón conjunto (hoz inguinal) se forma por la fusión de las aponeurosis de:',
    options: ['Músculo oblicuo interno y músculo transverso del abdomen', 'Músculo oblicuo externo y recto anterior', 'Músculo piramidal y psoas'],
    correctIndex: 0,
    rationale: 'El tendón conjunto o hoz inguinal resulta de la unión de las fibras inferiores del oblicuo interno y del transverso insertándose en el pubis.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Tendón Conjunto',
    order: 8
  },
  {
    id: 'quiz_t2_abd_09',
    topicId: 'pared_abdominal_conducto_inguinal',
    type: 'case_study',
    question: 'Una mujer de 65 años consulta por dolor y tumoración irreductible por debajo del ligamento inguinal, medial a los vasos femorales. ¿Qué orificio herniario está comprometido?',
    options: ['Anillo femoral (anillo crural)', 'Anillo inguinal superficial', 'Foramen obturador'],
    correctIndex: 0,
    rationale: 'La hernia crural protruye a través del anillo femoral (por debajo del ligamento inguinal, medial a la vena femoral), teniendo alto riesgo de estrangulación.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Anillo Crural y Conducto Femoral',
    order: 9
  },
  {
    id: 'quiz_t2_abd_10',
    topicId: 'pared_abdominal_conducto_inguinal',
    type: 'single_choice',
    question: 'El anillo inguinal profundo se define anatómicamente como una evaginación de:',
    options: ['La fascia transversalis', 'La aponeurosis del oblicuo externo', 'El músculo cremáster'],
    correctIndex: 0,
    rationale: 'El anillo inguinal profundo es la hendidura oval en la fascia transversalis situada 1.5 cm por encima del punto medio del ligamento inguinal.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Anillo Inguinal Profundo',
    order: 10
  },
  {
    id: 'quiz_t2_abd_11',
    topicId: 'pared_abdominal_conducto_inguinal',
    type: 'single_choice',
    question: 'El músculo cremáster y su fascia derivan embriológicamente de cuál capa de la pared abdominal:',
    options: ['Músculo oblicuo interno y transverso', 'Músculo oblicuo externo', 'Músculo recto del abdomen'],
    correctIndex: 0,
    rationale: 'Las fibras en asa del cremáster proceden del borde inferior del oblicuo interno arrastradas durante el descenso testicular.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Envolturas del Testículo y Cordón',
    order: 11
  },
  {
    id: 'quiz_t2_abd_12',
    topicId: 'pared_abdominal_conducto_inguinal',
    type: 'single_choice',
    question: 'La línea alba es un rafe tendinoso fibroso mediano formado por el entrecruzamiento de las aponeurosis de:',
    options: ['Los músculos planos del abdomen (oblicuos y transversos) de ambos lados', 'Los músculos rectos exclusivamente', 'El diafragma'],
    correctIndex: 0,
    rationale: 'La línea alba va desde la apófisis xifoides hasta la sínfisis del pubis y se constituye por el cruce en la línea media de las aponeurosis abdominales.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Línea Alba',
    order: 12
  },
  {
    id: 'quiz_t2_abd_13',
    topicId: 'pared_abdominal_conducto_inguinal',
    type: 'matching',
    question: 'Relaciona cada pliegue umbilical de la pared abdominal interna con la estructura que lo oblitera o aloja:',
    matchingPairs: [
      { left: 'Pliegue umbilical medio', right: 'Uraco obliterado (ligamento umbilical medio)' },
      { left: 'Pliegues umbilicales mediales', right: 'Arterias umbilicales obliteradas' },
      { left: 'Pliegues umbilicales laterales', right: 'Vasos epigástricos inferiores activos' }
    ],
    options: ['Pliegues umbilicales y fositas peritoneales'],
    correctIndex: 0,
    rationale: 'Medio: uraco; medial: arterias umbilicales obliteradas; lateral: vasos epigástricos inferiores.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Cara Posterior de la Pared Abdominal',
    order: 13
  },
  {
    id: 'quiz_t2_abd_14',
    topicId: 'pared_abdominal_conducto_inguinal',
    type: 'ordering',
    question: 'Ordena de lateral a medial los elementos que cruzan por el espacio subinguinal bajo el ligamento inguinal:',
    orderingItems: [
      'Nervio cutáneo femoral lateral y músculo iliopsoas con el nervio femoral',
      'Arteria femoral',
      'Vena femoral',
      'Conducto femoral con ganglio de Cloquet y ligamento lacunar'
    ],
    options: ['Laguna muscular y laguna vascular NAVEL'],
    correctIndex: 0,
    rationale: 'Mnemotecnia NAVEL de lateral a medial: Nervio, Arteria, Vena, Espacio (canal femoral con Cloquet), Ligamento lacunar.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Espacio Subinguinal',
    order: 14
  },
  {
    id: 'quiz_t2_abd_15',
    topicId: 'pared_abdominal_conducto_inguinal',
    type: 'single_choice',
    question: '¿Qué nervio perfora el músculo oblicuo interno cerca de la EIAS y transcurre por el conducto inguinal inervando el pubis y la raíz del escroto/labio mayor?',
    options: ['Nervio ilioinguinal', 'Nervio genitofemoral', 'Nervio femoral'],
    correctIndex: 0,
    rationale: 'El nervio ilioinguinal (L1) penetra al conducto inguinal y emerge por el anillo superficial dando ramas genitales anteriores.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Nervio Ilioinguinal',
    order: 15
  },
  {
    id: 'quiz_t2_abd_16',
    topicId: 'pared_abdominal_conducto_inguinal',
    type: 'single_choice',
    question: 'El ligamento pectíneo (de Cooper) es una fuerte banda fibrosa adherida al periostio de:',
    options: ['La cresta pectínea del pubis', 'La espina ilíaca anterosuperior', 'La cabeza del fémur'],
    correctIndex: 0,
    rationale: 'El ligamento de Cooper refuerza la cresta pectínea y sirve de anclaje indispensable en las técnicas de hernioplastia preperitoneal.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Ligamento Pectíneo de Cooper',
    order: 16
  },
  {
    id: 'quiz_t2_abd_17',
    topicId: 'pared_abdominal_conducto_inguinal',
    type: 'case_study',
    question: 'Durante una laparotomía de urgencia, el cirujano corta horizontalmente a 3 cm por encima del pubis dañando el ramo genital del nervio genitofemoral. ¿Qué reflejo cutáneo se perderá?',
    options: ['Reflejo cremasteriano', 'Reflejo rotuliano', 'Reflejo aquiliano'],
    correctIndex: 0,
    rationale: 'El reflejo cremasteriano (L1-L2) tiene como vía motora al ramo genital del nervio genitofemoral que inerva el músculo cremáster.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Reflejo Cremasteriano',
    order: 17
  },
  {
    id: 'quiz_t2_abd_18',
    topicId: 'pared_abdominal_conducto_inguinal',
    type: 'single_choice',
    question: 'El músculo piramidal del abdomen es un pequeño músculo inconstante situado en:',
    options: ['La parte anterior e inferior de la vaina del recto, por delante del músculo recto', 'El conducto inguinal', 'El triángulo lumbar'],
    correctIndex: 0,
    rationale: 'El piramidal es un tensor rudimentario de la línea alba ubicado en el tercio inferior de la pared abdominal por delante del músculo recto mayor.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Músculo Piramidal',
    order: 18
  },
  {
    id: 'quiz_t2_abd_19',
    topicId: 'pared_abdominal_conducto_inguinal',
    type: 'single_choice',
    question: 'La anastomosis arterial longitudinal de la pared abdominal anterior que une los sistemas de la subclavia y de la ilíaca externa se da entre:',
    options: ['Arteria epigástrica superior y arteria epigástrica inferior', 'Arteria aorta y celíaca', 'Arterias lumbares y pudendas'],
    correctIndex: 0,
    rationale: 'La epigástrica superior (de la torácica interna/subclavia) se anastomosa dentro de la vaina del recto con la epigástrica inferior (de la ilíaca externa).',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Vascularización de la Pared Abdominal',
    order: 19
  },
  {
    id: 'quiz_t2_abd_20',
    topicId: 'pared_abdominal_conducto_inguinal',
    type: 'single_choice',
    question: 'El triángulo lumbar inferior (de Petit), punto débil de la pared posterior, está delimitado por:',
    options: ['Cresta ilíaca (base), borde lateral del dorsal ancho y borde posterior del oblicuo externo', '12.ª costilla y psoas', 'Músculo recto del abdomen y línea alba'],
    correctIndex: 0,
    rationale: 'El trígono lumbar de Petit lo forman la cresta ilíaca, el músculo oblicuo externo y el músculo dorsal ancho; su piso es el oblicuo interno.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Pared Lumbar y Puntos Débiles',
    order: 20
  },

  // =========================================================================
  // TEMA 5: digestivo_abdominal_peritoneo (20 QUIZZES)
  // =========================================================================
  {
    id: 'quiz_t2_dig_01',
    topicId: 'digestivo_abdominal_peritoneo',
    type: 'single_choice',
    question: 'El foramen omental (hiato de Winslow), comunicación con la transcavidad de los epiplones, tiene en su borde anterior a:',
    options: ['El ligamento hepatoduodenal con la tríada portal', 'La vena cava inferior', 'El lóbulo caudado del hígado'],
    correctIndex: 0,
    rationale: 'El borde anterior del foramen epiploico (Winslow) lo forma el pedículo hepático en el ligamento hepatoduodenal (vena porta, arteria hepática propia y colédoco).',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Bolsa Omental y Foramen Omental',
    order: 1
  },
  {
    id: 'quiz_t2_dig_02',
    topicId: 'digestivo_abdominal_peritoneo',
    type: 'single_choice',
    question: '¿Qué arteria irriga la curvatura menor del estómago discurriendo desde el cardias hacia el píloro?',
    options: ['Arteria gástrica izquierda (coronaria estomáquica)', 'Arteria gastroepiploica derecha', 'Arteria gástrica posterior'],
    correctIndex: 0,
    rationale: 'La arteria gástrica izquierda (del tronco celíaco) desciende por la curvatura menor para anastomosarse con la arteria gástrica derecha.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Estómago y Tronco Celíaco',
    order: 2
  },
  {
    id: 'quiz_t2_dig_03',
    topicId: 'digestivo_abdominal_peritoneo',
    type: 'case_study',
    question: 'Paciente con úlcera duodenal perforada en la cara posterior de la primera porción del duodeno con hemorragia masiva exanguinante. ¿Qué gran arteria retroperitoneal fue erosionada?',
    options: ['Arteria gastroduodenal', 'Arteria mesentérica inferior', 'Arteria esplénica'],
    correctIndex: 0,
    rationale: 'La arteria gastroduodenal desciende inmediatamente posterior a la primera porción del duodeno; las úlceras pépticas posteriores la erosionan con frecuencia.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Duodeno y Arteria Gastroduodenal',
    order: 3
  },
  {
    id: 'quiz_t2_dig_04',
    topicId: 'digestivo_abdominal_peritoneo',
    type: 'single_choice',
    question: 'La ampolla hepatopancreática (de Vater) y la papila duodenal mayor desembocan en:',
    options: ['La segunda porción del duodeno (porción descendente)', 'La primera porción del duodeno', 'La tercera porción horizontal'],
    correctIndex: 0,
    rationale: 'El conducto colédoco y el conducto pancreático principal (de Wirsung) se unen y desembocan en la cara posteromedial de la 2.ª porción duodenal.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Duodeno y Páncreas',
    order: 4
  },
  {
    id: 'quiz_t2_dig_05',
    topicId: 'digestivo_abdominal_peritoneo',
    type: 'matching',
    question: 'Relaciona las ramas del tronco celíaco con su territorio principal de distribución:',
    matchingPairs: [
      { left: 'Arteria gástrica izquierda', right: 'Curvatura menor del estómago y esófago distal' },
      { left: 'Arteria esplénica', right: 'Bazo, cuerpo y cola del páncreas, curvatura mayor gástrica' },
      { left: 'Arteria hepática común', right: 'Hígado, vesícula biliar, píloro y cabeza de páncreas' }
    ],
    options: ['Trípode celíaco de Haller'],
    correctIndex: 0,
    rationale: 'El trípode de Haller lo componen: gástrica izquierda, esplénica y hepática común.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Tronco Celíaco',
    order: 5
  },
  {
    id: 'quiz_t2_dig_06',
    topicId: 'digestivo_abdominal_peritoneo',
    type: 'ordering',
    question: 'Ordena de proximal a distal las porciones anatómicas del estómago:',
    orderingItems: [
      'Cardias',
      'Fundus gástrico (tuberosidad mayor)',
      'Cuerpo del estómago',
      'Antro y canal pilórico'
    ],
    options: ['Segmentos del estómago'],
    correctIndex: 0,
    rationale: 'De superior a distal: Cardias -> Fundus -> Cuerpo -> Antro y píloro.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Configuración Anatómica del Estómago',
    order: 6
  },
  {
    id: 'quiz_t2_dig_07',
    topicId: 'digestivo_abdominal_peritoneo',
    type: 'single_choice',
    question: 'La flexura duodenoyeyunal está fijada y suspendida a la pared posterior por el músculo suspensorio del duodeno, también llamado:',
    options: ['Ligamento de Treitz', 'Ligamento gastrofrénico', 'Epiplón mayor'],
    correctIndex: 0,
    rationale: 'El ligamento de Treitz (músculo suspensorio del duodeno) fija el ángulo duodenoyeyunal a los pilares diafragmáticos y marca el límite entre hemorragia digestiva alta y baja.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Ángulo Duodenoyeyunal',
    order: 7
  },
  {
    id: 'quiz_t2_dig_08',
    topicId: 'digestivo_abdominal_peritoneo',
    type: 'single_choice',
    question: 'La arteria mesentérica superior cruza por delante de qué porción del duodeno pudiendo comprimirla (síndrome de Wilkie):',
    options: ['Tercera porción (porción horizontal)', 'Primera porción', 'Cuarta porción ascendente'],
    correctIndex: 0,
    rationale: 'La 3.ª porción duodenal queda atrapada en la pinza aortomesentérica entre la aorta abdominal por detrás y la arteria mesentérica superior por delante.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Pinza Aortomesentérica',
    order: 8
  },
  {
    id: 'quiz_t2_dig_09',
    topicId: 'digestivo_abdominal_peritoneo',
    type: 'case_study',
    question: 'Paciente joven con apendicitis aguda. ¿Hacia qué punto de la pared abdominal converge la base del apéndice vermiforme en el ciego?',
    options: ['La convergencia de las tres tenias cólicas en el fondo del ciego', 'La válvula ileocecal exclusivamente', 'El polo superior del ciego'],
    correctIndex: 0,
    rationale: 'La base del apéndice vermiforme se implanta con exactitud matemática en el sitio donde confluyen las tres tenias del colon (anterior, posterolateral y posteromedial).',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Ciego y Apéndice Vermiforme',
    order: 9
  },
  {
    id: 'quiz_t2_dig_10',
    topicId: 'digestivo_abdominal_peritoneo',
    type: 'single_choice',
    question: 'El mesenterio fija las asas de yeyuno e íleon a la pared abdominal posterior a lo largo de una raíz que mide aproximadamente:',
    options: ['15 cm de longitud', '1 metro', '50 cm'],
    correctIndex: 0,
    rationale: 'La raíz del mesenterio mide sólo 15 cm de largo, extendiéndose oblicuamente desde la flexura duodenoyeyunal (L2) hasta la fosa ilíaca derecha.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Raíz del Mesenterio',
    order: 10
  },
  {
    id: 'quiz_t2_dig_11',
    topicId: 'digestivo_abdominal_peritoneo',
    type: 'single_choice',
    question: '¿Qué porción del colon carece de mesocolon móvil y se halla adosada a la pared posterior (retroperitoneal secundaria por fascia de Toldt I)?',
    options: ['Colon ascendente y colon descendente', 'Colon transverso', 'Colon sigmoide'],
    correctIndex: 0,
    rationale: 'El colon ascendente y el descendente están coalescidos a la pared posterior por las fascias de Toldt I y II; transverso y sigmoide poseen meso libre.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Fascias de Coalescencia Peritoneal',
    order: 11
  },
  {
    id: 'quiz_t2_dig_12',
    topicId: 'digestivo_abdominal_peritoneo',
    type: 'single_choice',
    question: 'El divertículo de Meckel es una anomalía congénita del tubo digestivo producida por la persistencia de:',
    options: ['El conducto onfalomesentérico (conducto vitelino)', 'El uraco', 'El conducto colédoco'],
    correctIndex: 0,
    rationale: 'El divertículo ileal de Meckel resulta del cierre incompleto del conducto vitelino y se localiza en el borde antimesentérico del íleon a unos 60 cm de la válvula ileocecal.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Íleon y Divertículo de Meckel',
    order: 12
  },
  {
    id: 'quiz_t2_dig_13',
    topicId: 'digestivo_abdominal_peritoneo',
    type: 'matching',
    question: 'Empareja las arterias cólicas con su arteria madre de origen:',
    matchingPairs: [
      { left: 'Arteria cólica media y cólica derecha', right: 'Arteria mesentérica superior' },
      { left: 'Arteria cólica izquierda y sigmoideas', right: 'Arteria mesentérica inferior' },
      { left: 'Arco marginal de Drummond', right: 'Arcada anastomótica paracólica a lo largo de todo el colon' }
    ],
    options: ['Vascularización del marco cólico'],
    correctIndex: 0,
    rationale: 'Mesentérica superior irriga colon derecho hasta 2/3 del transverso; mesentérica inferior irriga 1/3 distal de transverso, colon izquierdo y recto superior.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Arterias Mesentéricas',
    order: 13
  },
  {
    id: 'quiz_t2_dig_14',
    topicId: 'digestivo_abdominal_peritoneo',
    type: 'ordering',
    question: 'Ordena de cefálico a caudal las porciones del intestino grueso:',
    orderingItems: [
      'Ciego y colon ascendente',
      'Flexura cólica derecha (hepática) y colon transverso',
      'Flexura cólica izquierda (esplénica) y colon descendente',
      'Colon sigmoide, recto y conducto anal'
    ],
    options: ['Marco cólico'],
    correctIndex: 0,
    rationale: 'Ciego -> Colon ascendente -> Transverso -> Colon descendente -> Sigmoide -> Recto -> Ano.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Intestino Grueso',
    order: 14
  },
  {
    id: 'quiz_t2_dig_15',
    topicId: 'digestivo_abdominal_peritoneo',
    type: 'single_choice',
    question: 'El epiplón (omento) mayor cuelga a modo de delantal sobre las asas delgadas originándose en:',
    options: ['La curvatura mayor del estómago y colon transverso', 'La curvatura menor y el hígado', 'El bazo y el riñón'],
    correctIndex: 0,
    rationale: 'El epiplón mayor desciende desde la curvatura mayor gástrica y se fusiona con la cara anterior del colon transverso y su mesocolon.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Omento Mayor',
    order: 15
  },
  {
    id: 'quiz_t2_dig_16',
    topicId: 'digestivo_abdominal_peritoneo',
    type: 'single_choice',
    question: '¿Qué estructura anatómica separa el yeyuno del íleon por sus características morfológicas internas?',
    options: ['El yeyuno tiene pliegues circulares (de Kerkring) más altos y vascularización en arcadas simples con vasos rectos largos', 'El yeyuno carece de pliegues circulares', 'El yeyuno tiene placas de Peyer prominentes'],
    correctIndex: 0,
    rationale: 'El yeyuno es más grueso, vascularizado, con arcadas simples y vasos rectos largos. El íleon tiene arcadas complejas, vasos cortos y placas de Peyer.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Yeyuno e Íleon',
    order: 16
  },
  {
    id: 'quiz_t2_dig_17',
    topicId: 'digestivo_abdominal_peritoneo',
    type: 'case_study',
    question: 'Un paciente presenta vólvulo de colon sigmoide con obstrucción intestinal mecánica aguda ("signo del grano de café"). ¿Por qué el sigmoide tiene predisposición al vólvulo?',
    options: ['Por tener un mesocolon sigmoide largo con una raíz de implantación estrecha', 'Por ser un órgano retroperitoneal fijo', 'Por carecer de tenias musculares'],
    correctIndex: 0,
    rationale: 'El asa sigmoidea tiene gran movilidad debido a su mesocolon amplio y raíz estrecha en V invertida, facilitando la torsión sobre su eje mesentérico.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Colon Sigmoide',
    order: 17
  },
  {
    id: 'quiz_t2_dig_18',
    topicId: 'digestivo_abdominal_peritoneo',
    type: 'single_choice',
    question: 'El ángulo de His (incisura cardíaca) del estómago se forma entre:',
    options: ['El borde izquierdo del esófago abdominal y el fundus gástrico', 'El píloro y el duodeno', 'La curvatura mayor y menor'],
    correctIndex: 0,
    rationale: 'El ángulo de His es el ángulo agudo esofagogástrico que previene mecánicamente el reflujo gastroesofágico.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Unión Esofagogástrica',
    order: 18
  },
  {
    id: 'quiz_t2_dig_19',
    topicId: 'digestivo_abdominal_peritoneo',
    type: 'single_choice',
    question: 'El conducto pancreático accesorio (de Santorini) desemboca habitualmente en:',
    options: ['La papila duodenal menor (2 cm por encima de la mayor)', 'La papila duodenal mayor', 'La 3.ª porción duodenal'],
    correctIndex: 0,
    rationale: 'El conducto accesorio de Santorini drena la porción anterosuperior de la cabeza pancreática desembocando en la carúncula menor.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Conductos Pancreáticos',
    order: 19
  },
  {
    id: 'quiz_t2_dig_20',
    topicId: 'digestivo_abdominal_peritoneo',
    type: 'single_choice',
    question: 'La flexura cólica izquierda (ángulo esplénico) se halla unida al diafragma por:',
    options: ['El ligamento frenicocólico izquierdo (sustentaculum lienis)', 'El ligamento falciforme', 'El ligamento redondo'],
    correctIndex: 0,
    rationale: 'El ligamento frenicocólico izquierdo sostiene el polo inferior del bazo e inserta firmemente el ángulo esplénico en el diafragma.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Flexura Cólica Izquierda',
    order: 20
  },

  // =========================================================================
  // TEMA 6: visceras_retroperitoneo_rinones (20 QUIZZES)
  // =========================================================================
  {
    id: 'quiz_t2_ret_01',
    topicId: 'visceras_retroperitoneo_rinones',
    type: 'single_choice',
    question: 'En la segmentación hepática de Couinaud, ¿cuántos segmentos funcionales independientes se delimitan alrededor del eje de las venas suprahepáticas y la porta?',
    options: ['8 segmentos (del I al VIII)', '4 lóbulos tradicionales', '12 subsegmentos'],
    correctIndex: 0,
    rationale: 'Couinaud dividió el hígado en 8 segmentos independientes con pedículo portal propio (arteria hepática, vena porta y conducto biliar) y drenaje suprahepático.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Segmentación Hepática de Couinaud',
    order: 1
  },
  {
    id: 'quiz_t2_ret_02',
    topicId: 'visceras_retroperitoneo_rinones',
    type: 'single_choice',
    question: 'El lóbulo caudado (lóbulo de Spigel) del hígado corresponde en la nomenclatura de Couinaud al:',
    options: ['Segmento I', 'Segmento IV', 'Segmento VIII'],
    correctIndex: 0,
    rationale: 'El segmento I es el lóbulo caudado (retroportal y para-cava), el cual posee drenaje venoso autónomo directo hacia la vena cava inferior.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Lóbulo Caudado',
    order: 2
  },
  {
    id: 'quiz_t2_ret_03',
    topicId: 'visceras_retroperitoneo_rinones',
    type: 'case_study',
    question: 'Durante una colecistectomía por laparoscopia, el cirujano debe disecar con precisión el triángulo hepatocístico (de Calot) para clipar la arteria cística. ¿Cuáles son los límites de este triángulo?',
    options: ['Conducto cístico, conducto hepático común y cara visceral del hígado', 'Colédoco, vena porta y arteria gástrica', 'Ligamento falciforme y duodeno'],
    correctIndex: 0,
    rationale: 'El triángulo de Calot está delimitado por el conducto cístico (inferior), el conducto hepático común (medial) y el borde inferior hepático (superior); aloja la arteria cística.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Vías Biliares y Triángulo de Calot',
    order: 3
  },
  {
    id: 'quiz_t2_ret_04',
    topicId: 'visceras_retroperitoneo_rinones',
    type: 'single_choice',
    question: 'La vena porta hepática se forma por la confluencia retropancreática de:',
    options: ['Vena mesentérica superior y vena esplénica (recibiendo a la mesentérica inferior)', 'Vena cava inferior y venas renales', 'Venas ilíacas comunes'],
    correctIndex: 0,
    rationale: 'La vena porta se constituye detrás del cuello del páncreas por la unión de la vena mesentérica superior y el tronco espleno-mesaraico (o vena esplénica).',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Sistema Venoso Porta',
    order: 4
  },
  {
    id: 'quiz_t2_ret_05',
    topicId: 'visceras_retroperitoneo_rinones',
    type: 'matching',
    question: 'Relaciona cada estrechamiento fisiológico del uréter con su nivel anatómico:',
    matchingPairs: [
      { left: 'Primer estrechamiento', right: 'Unión pieloureteral (pelvis renal con el uréter)' },
      { left: 'Segundo estrechamiento', right: 'Cruce sobre los vasos ilíacos (estrecho superior de la pelvis)' },
      { left: 'Tercer estrechamiento', right: 'Unión vesicoureteral (al penetrar la pared vesical)' }
    ],
    options: ['Estrechamientos del uréter'],
    correctIndex: 0,
    rationale: 'Son los 3 sitios más frecuentes de enclavamiento de litiasis urinaria: unión pieloureteral, vasos ilíacos e intramural vesical.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Uréter y Vía Urinaria',
    order: 5
  },
  {
    id: 'quiz_t2_ret_06',
    topicId: 'visceras_retroperitoneo_rinones',
    type: 'ordering',
    question: 'Ordena de anterior a posterior las estructuras del pedículo renal en el hilio del riñón:',
    orderingItems: [
      'Vena renal',
      'Arteria renal',
      'Pelvis renal (vía urinaria excretora)'
    ],
    options: ['Pedículo renal VAP'],
    correctIndex: 0,
    rationale: 'La disposición del hilio renal de adelante hacia atrás es: Vena renal -> Arteria renal -> Pelvis renal (V-A-P).',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Hilio y Pedículo Renal',
    order: 6
  },
  {
    id: 'quiz_t2_ret_07',
    topicId: 'visceras_retroperitoneo_rinones',
    type: 'single_choice',
    question: '¿Por qué el riñón derecho se ubica normalmente entre 1 y 2 cm más bajo que el riñón izquierdo?',
    options: ['Por la presencia y volumen del lóbulo derecho del hígado', 'Por la presión del estómago', 'Por la tracción del uréter'],
    correctIndex: 0,
    rationale: 'La gran masa del lóbulo hepático derecho desciende la posición del riñón derecho (T12 a L3), mientras el izquierdo se ubica de T11 a L2.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Riñones y Retroperitoneo',
    order: 7
  },
  {
    id: 'quiz_t2_ret_08',
    topicId: 'visceras_retroperitoneo_rinones',
    type: 'single_choice',
    question: 'La fascia renal (de Gerota) envuelve al riñón y a la glándula suprarrenal, separándolos mediante:',
    options: ['Una lámina intersuprarrenorrenal que permite la nefrectomía preservando la glándula', 'Hueso cortical', 'Peritoneo parietal'],
    correctIndex: 0,
    rationale: 'El tabique intersuprarrenorrenal divide el compartimento de la cápsula adiposa permitiendo extirpar el riñón sin resecar obligadamente la suprarrenal.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Celda Renal y Fascia de Gerota',
    order: 8
  },
  {
    id: 'quiz_t2_ret_09',
    topicId: 'visceras_retroperitoneo_rinones',
    type: 'case_study',
    question: 'Un paciente con hipertensión renovascular severa presenta estenosis de la arteria renal izquierda por ateromatosis. ¿De qué gran tronco nace la arteria renal a nivel de L1-L2?',
    options: ['Aorta abdominal', 'Arteria ilíaca común', 'Tronco celíaco'],
    correctIndex: 0,
    rationale: 'Las arterias renales derecha e izquierda nacen directamente de las caras laterales de la aorta abdominal justo por debajo de la emergencia de la arteria mesentérica superior.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Arterias Renales y Aorta',
    order: 9
  },
  {
    id: 'quiz_t2_ret_10',
    topicId: 'visceras_retroperitoneo_rinones',
    type: 'single_choice',
    question: 'La vena renal izquierda es significativamente más larga que la derecha y pasa entre:',
    options: ['La aorta abdominal por detrás y la arteria mesentérica superior por delante (pinza vascular)', 'El diafragma y el hígado', 'La vena cava y el psoas'],
    correctIndex: 0,
    rationale: 'La vena renal izquierda cruza la línea media por delante de la aorta dentro de la pinza aortomesentérica (síndrome de Cascanueces o Nutcracker).',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Vena Renal Izquierda',
    order: 10
  },
  {
    id: 'quiz_t2_ret_11',
    topicId: 'visceras_retroperitoneo_rinones',
    type: 'single_choice',
    question: '¿Qué vena desemboca en la vena renal izquierda en lugar de desembocar directamente en la vena cava inferior?',
    options: ['Vena testicular (o ovárica) izquierda y vena suprarrenal izquierda', 'Vena testicular derecha', 'Vena porta'],
    correctIndex: 0,
    rationale: 'Las venas gonadal y suprarrenal izquierdas drenan en la vena renal izquierda en ángulo recto, favoreciendo el varicocele testicular izquierdo.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Drenaje Venoso Gonadal',
    order: 11
  },
  {
    id: 'quiz_t2_ret_12',
    topicId: 'visceras_retroperitoneo_rinones',
    type: 'single_choice',
    question: 'Las glándulas suprarrenales reciben irrigación de tres arterias suprarrenales. La arteria suprarrenal superior procede de:',
    options: ['La arteria frénica inferior', 'La arteria aorta directamente', 'La arteria renal'],
    correctIndex: 0,
    rationale: 'Suprarrenal superior viene de la frénica inferior; media nace de la aorta abdominal; inferior proviene de la arteria renal.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Glándulas Suprarrenales',
    order: 12
  },
  {
    id: 'quiz_t2_ret_13',
    topicId: 'visceras_retroperitoneo_rinones',
    type: 'matching',
    question: 'Empareja los conductos biliares con su desembocadura o anastomosis:',
    matchingPairs: [
      { left: 'Conductos hepáticos derecho e izquierdo', right: 'Se unen para formar el conducto hepático común' },
      { left: 'Conducto cístico y hepático común', right: 'Confluyen para originar el conducto colédoco' },
      { left: 'Conducto colédoco y pancreático principal', right: 'Forman la ampolla de Vater en la 2.ª porción duodenal' }
    ],
    options: ['Vía biliar extrahepática'],
    correctIndex: 0,
    rationale: 'Hepáticos derecho e izquierdo -> Hepático común + Cístico -> Colédoco + Wirsung -> Ampolla de Vater.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Vías Biliares Extrahepáticas',
    order: 13
  },
  {
    id: 'quiz_t2_ret_14',
    topicId: 'visceras_retroperitoneo_rinones',
    type: 'ordering',
    question: 'Ordena de proximal a distal las estructuras de la vía urinaria intrarrenal:',
    orderingItems: [
      'Papila renal con orificios de los túbulos colectores',
      'Cálices menores (de 7 a 14)',
      'Cálices mayores (habitualmente superior, medio e inferior)',
      'Pelvis renal'
    ],
    options: ['Vía urinaria intrarrenal'],
    correctIndex: 0,
    rationale: 'Papilas renales -> Cálices menores -> Cálices mayores -> Pelvis renal -> Uréter.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Configuración Interna del Riñón',
    order: 14
  },
  {
    id: 'quiz_t2_ret_15',
    topicId: 'visceras_retroperitoneo_rinones',
    type: 'single_choice',
    question: 'El ligamento falciforme del hígado contiene en su borde libre inferior al:',
    options: ['Ligamento redondo del hígado (vena umbilical obliterada)', 'Conducto venoso de Arancio', 'Uraco'],
    correctIndex: 0,
    rationale: 'El ligamento redondo discurre en el borde libre del ligamento falciforme desde el ombligo hasta la rama izquierda de la vena porta.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Ligamentos Hepáticos',
    order: 15
  },
  {
    id: 'quiz_t2_ret_16',
    topicId: 'visceras_retroperitoneo_rinones',
    type: 'single_choice',
    question: 'La cápsula adiposa del riñón (grasa perirrenal) está contenida dentro de:',
    options: ['La fascia renal (de Gerota)', 'El peritoneo visceral hepático', 'La pleura parietal'],
    correctIndex: 0,
    rationale: 'La grasa perirrenal rodea directamente la cápsula propia del riñón dentro de la fascia renal; por fuera de la fascia está la grasa pararrenal.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Grasa Perirrenal y Pararrenal',
    order: 16
  },
  {
    id: 'quiz_t2_ret_17',
    topicId: 'visceras_retroperitoneo_rinones',
    type: 'case_study',
    question: 'Paciente con cirrosis hepática avanzada presenta hemorragia digestiva por várices esofágicas sangrantes. ¿Qué sistema venoso anastomótico de hipertensión portal comunica la vena gástrica izquierda con la circulación sistémica?',
    options: ['Plexo venoso periesofágico que drena en el sistema ácigos', 'Plexo hemorroidal inferior', 'Vena cava inferior directamente'],
    correctIndex: 0,
    rationale: 'Las várices esofágicas se forman por la anastomosis portocava entre la vena gástrica izquierda (sistema porta) y las venas esofágicas que drenan en la vena ácigos (sistema cava).',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Anastomosis Portocavas',
    order: 17
  },
  {
    id: 'quiz_t2_ret_18',
    topicId: 'visceras_retroperitoneo_rinones',
    type: 'single_choice',
    question: 'La cisterna del quilo (de Pecquet) se ubica habitualmente en el retroperitoneo a nivel de:',
    options: ['L1-L2, inmediatamente por detrás de la aorta abdominal', 'T4', 'La sínfisis púbica'],
    correctIndex: 0,
    rationale: 'La cisterna del quilo es la dilatación sacular receptora de los troncos linfáticos lumbares e intestinales situada en L1-L2, dando origen al conducto torácico.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Linfáticos Retroperitoneales',
    order: 18
  },
  {
    id: 'quiz_t2_ret_19',
    topicId: 'visceras_retroperitoneo_rinones',
    type: 'single_choice',
    question: 'La bifurcación de la aorta abdominal en las dos arterias ilíacas comunes se produce a nivel de:',
    options: ['L4 (inmediatamente a la izquierda de la línea media)', 'L1', 'S1'],
    correctIndex: 0,
    rationale: 'La aorta termina a la altura de la vértebra L4 (proyectada al ombligo o a la altura de las crestas ilíacas) bifurcándose en arterias ilíacas comunes y sacra media.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Aorta Abdominal',
    order: 19
  },
  {
    id: 'quiz_t2_ret_20',
    topicId: 'visceras_retroperitoneo_rinones',
    type: 'single_choice',
    question: 'Las columnas renales (de Bertin) son prolongaciones de:',
    options: ['La corteza renal entre las pirámides medulares de Malpighi', 'La cápsula fibrosa externa', 'La pelvis renal'],
    correctIndex: 0,
    rationale: 'Las columnas renales de Bertin son tabiques de sustancia cortical que descienden entre las pirámides medulares de Malpighi.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Parénquima Renal',
    order: 20
  }
];

export async function run() {
  await uploadQuizzesBatch(tomo2Part2Quizzes, 'Rouvière Tomo 2 (Bloque B: Temas 3 a 6)');
}
