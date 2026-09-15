// Quizzes Clínicos de Anatomía Humana - Rouvière Tomo 1 (Cabeza y Cuello)
// 7 Temas x 20 Quizzes = 140 Quizzes
import { uploadQuizzesBatch } from './seed_quizzes_common.mjs';

const tomo1Quizzes = [
  // =========================================================================
  // TEMA 1: osteologia_craneo (20 QUIZZES)
  // =========================================================================
  {
    id: 'quiz_t1_ost_01',
    topicId: 'osteologia_craneo',
    type: 'single_choice',
    question: '¿Cuál de los siguientes forámenes de la base del cráneo transmite la arteria meníngea media?',
    options: ['Foramen espinoso (redondo menor)', 'Foramen oval', 'Foramen redondo'],
    correctIndex: 0,
    rationale: 'El foramen espinoso da paso a la arteria meníngea media y al ramo meníngeo del nervio mandibular. El foramen oval transmite V3 y el foramen redondo transmite V2.',
    sourceBook: 'Rouvière - Delmas: Tomo 1 (Cabeza y Cuello), Hueso Esfenoides',
    order: 1
  },
  {
    id: 'quiz_t1_ost_02',
    topicId: 'osteologia_craneo',
    type: 'single_choice',
    question: 'La lámina cribosa es un componente fundamental de cuál de las siguientes estructuras óseas:',
    options: ['Hueso etmoides', 'Hueso esfenoides', 'Porción petrosa del temporal'],
    correctIndex: 0,
    rationale: 'La lámina cribosa pertenece al hueso etmoides y transmite los filetes del nervio olfatorio (I par craneal) desde la mucosa nasal hacia la fosa craneal anterior.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Hueso Etmoides',
    order: 2
  },
  {
    id: 'quiz_t1_ost_03',
    topicId: 'osteologia_craneo',
    type: 'case_study',
    question: 'Paciente con traumatismo craneoencefálico presenta fractura de la porción petrosa del temporal con compromiso del conducto auditivo interno. ¿Cuáles elementos neurovasculares se encuentran en mayor riesgo?',
    options: ['Nervio facial (VII), vestibulococlear (VIII) y arteria laberíntica', 'Nervio trigémino (V) y arteria carótida interna', 'Nervio glosofaríngeo (IX) y vena yugular interna'],
    correctIndex: 0,
    rationale: 'El conducto auditivo interno (CAI) en el peñasco del temporal da paso al nervio facial (VII), al nervio intermedio de Wrisberg, al nervio vestibulococlear (VIII) y a los vasos laberínticos.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Hueso Temporal',
    order: 3
  },
  {
    id: 'quiz_t1_ost_04',
    topicId: 'osteologia_craneo',
    type: 'single_choice',
    question: '¿Qué estructura ósea aloja a la glándula hipófisis en la fosa craneal media?',
    options: ['Silla turca de la fosa hipofisaria del esfenoides', 'Clivus del hueso occipital', 'Cresta galli del hueso etmoides'],
    correctIndex: 0,
    rationale: 'La fosa hipofisaria o silla turca se localiza en el cuerpo del esfenoides, flanqueada por las apófisis clinoides anteriores y posteriores.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Hueso Esfenoides',
    order: 4
  },
  {
    id: 'quiz_t1_ost_05',
    topicId: 'osteologia_craneo',
    type: 'matching',
    question: 'Relaciona cada orificio de la base del cráneo con su principal contenido anatómico:',
    matchingPairs: [
      { left: 'Conducto óptico', right: 'Nervio óptico y arteria oftálmica' },
      { left: 'Fisura orbitaria superior', right: 'Pares III, IV, V1, VI y venas oftálmicas' },
      { left: 'Foramen magno', right: 'Médula oblongada y arterias vertebrales' }
    ],
    options: ['Relación anatómica estricta de forámenes craneales'],
    correctIndex: 0,
    rationale: 'El conducto óptico transmite el II par; la hendidura esfenoidal da paso a los motores oculares y ramos de V1; el foramen magno comunica el cráneo con el conducto vertebral.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Configuración de la Base del Cráneo',
    order: 5
  },
  {
    id: 'quiz_t1_ost_06',
    topicId: 'osteologia_craneo',
    type: 'ordering',
    question: 'Ordena de anterior a posterior los orificios del ala mayor del hueso esfenoides:',
    orderingItems: [
      'Fisura orbitaria superior',
      'Foramen redondo',
      'Foramen oval',
      'Foramen espinoso'
    ],
    options: ['Secuencia anteroposterior del esfenoides'],
    correctIndex: 0,
    rationale: 'La disposición topográfica de medial/anterior hacia posterolateral es: Fisura orbitaria superior -> Foramen redondo -> Foramen oval -> Foramen espinoso.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Ala Mayor del Esfenoides',
    order: 6
  },
  {
    id: 'quiz_t1_ost_07',
    topicId: 'osteologia_craneo',
    type: 'single_choice',
    question: '¿Qué hueso conforma el clivus junto con la porción basilar del hueso occipital?',
    options: ['Cuerpo del esfenoides', 'Porción escamosa del frontal', 'Ala mayor del esfenoides'],
    correctIndex: 0,
    rationale: 'El clivus se forma por la unión de la cara posterior del cuerpo del esfenoides con la porción basilar del occipital.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Fosa Craneal Posterior',
    order: 7
  },
  {
    id: 'quiz_t1_ost_08',
    topicId: 'osteologia_craneo',
    type: 'single_choice',
    question: 'El foramen yugular (agujero rasgado posterior) se ubica entre qué huesos:',
    options: ['Porción petrosa del temporal y hueso occipital', 'Hueso esfenoides y hueso frontal', 'Hueso parietal y hueso temporal'],
    correctIndex: 0,
    rationale: 'El foramen yugular está delimitado entre la porción petrosa del hueso temporal y el borde lateral del occipital, dando origen a la vena yugular interna y transmitiendo los pares IX, X y XI.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Foramen Yugular',
    order: 8
  },
  {
    id: 'quiz_t1_ost_09',
    topicId: 'osteologia_craneo',
    type: 'case_study',
    question: 'Una herida penetrante sobre el pterion lesiona la rama anterior de la arteria meníngea media. ¿Entre qué huesos confluye este punto craneométrico?',
    options: ['Frontal, parietal, temporal y ala mayor del esfenoides', 'Occipital, parietal y temporal', 'Frontal, nasal y maxilar'],
    correctIndex: 0,
    rationale: 'El pterion es la sutura en H formada por la convergencia de frontal, parietal, porción escamosa del temporal y ala mayor del esfenoides; el hematoma epidural es su principal riesgo.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Puntos Craneométricos',
    order: 9
  },
  {
    id: 'quiz_t1_ost_10',
    topicId: 'osteologia_craneo',
    type: 'single_choice',
    question: 'El conducto del nervio hipogloso (foramen condíleo anterior) se localiza en la base de qué estructura:',
    options: ['Cóndilos del hueso occipital', 'Apófisis mastoides del temporal', 'Apófisis pterigoides del esfenoides'],
    correctIndex: 0,
    rationale: 'El conducto del hipogloso perfora la base de cada cóndilo del occipital para dar salida al XII par craneal hacia el espacio retroestíleo.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Hueso Occipital',
    order: 10
  },
  {
    id: 'quiz_t1_ost_11',
    topicId: 'osteologia_craneo',
    type: 'single_choice',
    question: '¿Qué estructura ósea cervical carece de cuerpo vertebral y posee masas laterales?',
    options: ['Atlas (C1)', 'Axis (C2)', 'Séptima vértebra cervical (C7)'],
    correctIndex: 0,
    rationale: 'El atlas (C1) carece de cuerpo y de apófisis espinosa, estando constituido por dos arcos (anterior y posterior) unidos por dos masas laterales con carillas articulares.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Columna Cervical',
    order: 11
  },
  {
    id: 'quiz_t1_ost_12',
    topicId: 'osteologia_craneo',
    type: 'single_choice',
    question: 'La apófisis odontoides (diente del axis) se origina en:',
    options: ['La cara superior del cuerpo del axis (C2)', 'El arco anterior del atlas', 'La base del occipital'],
    correctIndex: 0,
    rationale: 'El diente o apófisis odontoides se eleva desde la cara superior del cuerpo del axis, sirviendo de pivote para la rotación de la cabeza.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Axis',
    order: 12
  },
  {
    id: 'quiz_t1_ost_13',
    topicId: 'osteologia_craneo',
    type: 'matching',
    question: 'Empareja el foramen con el par craneal que lo atraviesa de forma exclusiva o principal:',
    matchingPairs: [
      { left: 'Conducto óptico', right: 'Nervio óptico (II)' },
      { left: 'Foramen redondo', right: 'Nervio maxilar (V2)' },
      { left: 'Conducto hipogloso', right: 'Nervio hipogloso (XII)' }
    ],
    options: ['Correlación foramen - nervio craneal'],
    correctIndex: 0,
    rationale: 'El conducto óptico conduce al II par, el redondo a V2 y el hipogloso a XII.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Orificios de la Base Craneal',
    order: 13
  },
  {
    id: 'quiz_t1_ost_14',
    topicId: 'osteologia_craneo',
    type: 'ordering',
    question: 'Ordena cráneo-caudalmente las vértebras y accidentes cervicales clave:',
    orderingItems: [
      'Foramen magno del occipital',
      'Arco anterior del atlas (C1)',
      'Apófisis odontoides del axis (C2)',
      'Tubérculo carotídeo de Chassaignac (C6)'
    ],
    options: ['Secuencia cráneo-caudal cervical'],
    correctIndex: 0,
    rationale: 'De cefálico a caudal: Foramen magno -> Atlas -> Diente de C2 -> Tubérculo de Chassaignac en C6.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Raquis Cervical',
    order: 14
  },
  {
    id: 'quiz_t1_ost_15',
    topicId: 'osteologia_craneo',
    type: 'single_choice',
    question: '¿Qué elemento discurre por el foramen transverso de las vértebras cervicales desde C6 hasta C1?',
    options: ['Arteria vertebral y plexo venoso vertebral', 'Arteria carótida interna', 'Tronco simpático cervical'],
    correctIndex: 0,
    rationale: 'La arteria vertebral asciende por los forámenes transversos desde C6 hasta C1 antes de penetrar al cráneo por el foramen magno. C7 usualmente solo transmite venas accesorias.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Vértebras Cervicales',
    order: 15
  },
  {
    id: 'quiz_t1_ost_16',
    topicId: 'osteologia_craneo',
    type: 'single_choice',
    question: 'La cresta galli sirve de inserción anterior a cuál de los siguientes repliegues durales:',
    options: ['Hoz del cerebro (falx cerebri)', 'Tienda del cerebelo (tentorio)', 'Tienda de la hipófisis'],
    correctIndex: 0,
    rationale: 'La apófisis cresta galli del etmoides presta inserción al extremo anterior de la hoz del cerebro.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Hueso Etmoides y Meninges',
    order: 16
  },
  {
    id: 'quiz_t1_ost_17',
    topicId: 'osteologia_craneo',
    type: 'case_study',
    question: 'Paciente con rinorrea de líquido cefalorraquídeo tras fractura del tercio medio facial. ¿Qué estructura ósea de la fosa anterior se encuentra típicamente fracturada?',
    options: ['Lámina cribosa del etmoides', 'Ala mayor del esfenoides', 'Porción petrosa del temporal'],
    correctIndex: 0,
    rationale: 'La lámina cribosa es muy delgada; su fractura rasga la duramadre adherida y permite la fuga de LCR hacia las fosas nasales (fístula de LCR / rinolicuorrea).',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Fosa Craneal Anterior',
    order: 17
  },
  {
    id: 'quiz_t1_ost_18',
    topicId: 'osteologia_craneo',
    type: 'single_choice',
    question: '¿Qué estructura ósea separa la fosa craneal anterior de la fosa craneal media?',
    options: ['Borde posterior de las alas menores del esfenoides y surco prequiasmático', 'Borde superior del peñasco del temporal', 'Cresta occipital interna'],
    correctIndex: 0,
    rationale: 'El límite entre las fosas anterior y media está formado por el borde posterior del ala menor del esfenoides, las apófisis clinoides anteriores y el surco prequiasmático.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Configuración Interna del Cráneo',
    order: 18
  },
  {
    id: 'quiz_t1_ost_19',
    topicId: 'osteologia_craneo',
    type: 'single_choice',
    question: 'El conducto carotídeo se abre en la base del cráneo en la cara inferior de:',
    options: ['La porción petrosa del hueso temporal', 'El cuerpo del hueso esfenoides', 'La porción basilar del occipital'],
    correctIndex: 0,
    rationale: 'El conducto carotídeo inicia en la cara posteroinferior del peñasco del temporal y emerge en el vértice petroso en dirección al foramen lacerum.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Hueso Temporal',
    order: 19
  },
  {
    id: 'quiz_t1_ost_20',
    topicId: 'osteologia_craneo',
    type: 'single_choice',
    question: 'La protuberancia occipital externa y la línea nucal superior prestan inserción al músculo:',
    options: ['Músculo trapecio', 'Músculo platisma', 'Músculo masetero'],
    correctIndex: 0,
    rationale: 'El músculo trapecio inserta sus fibras superiores en el tercio medial de la línea nucal superior y en la protuberancia occipital externa.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Hueso Occipital y Músculos del Cuello',
    order: 20
  },

  // =========================================================================
  // TEMA 2: esqueleto_facial (20 QUIZZES)
  // =========================================================================
  {
    id: 'quiz_t1_fac_01',
    topicId: 'esqueleto_facial',
    type: 'single_choice',
    question: '¿Qué hueso de la cara forma la porción posteroinferior del tabique nasal óseo?',
    options: ['Vómer', 'Lámina perpendicular del etmoides', 'Hueso palatino'],
    correctIndex: 0,
    rationale: 'El vómer forma la parte posterior e inferior del tabique nasal, articulándose superiormente con la lámina perpendicular del etmoides y con el esfenoides.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Esqueleto Facial, Vómer',
    order: 1
  },
  {
    id: 'quiz_t1_fac_02',
    topicId: 'esqueleto_facial',
    type: 'single_choice',
    question: 'El foramen infraorbitario por donde emerge el nervio infraorbitario pertenece al hueso:',
    options: ['Maxilar', 'Cigomático', 'Mandíbula'],
    correctIndex: 0,
    rationale: 'El foramen infraorbitario se encuentra en la cara anterior del cuerpo del maxilar, inmediatamente por debajo del reborde orbitario inferior.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Hueso Maxilar',
    order: 2
  },
  {
    id: 'quiz_t1_fac_03',
    topicId: 'esqueleto_facial',
    type: 'case_study',
    question: 'Un golpe directo en la mejilla produce hundimiento del arco cigomático. ¿Qué apófisis óseas se unen para formar este arco?',
    options: ['Apófisis cigomática del temporal y apófisis temporal del cigomático', 'Apófisis palatina del maxilar y vómer', 'Apófisis coronoides y cóndilo mandibular'],
    correctIndex: 0,
    rationale: 'El arco cigomático está formado por la apófisis cigomática del hueso temporal articulada con la apófisis temporal del hueso cigomático.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Región Cigomática',
    order: 3
  },
  {
    id: 'quiz_t1_fac_04',
    topicId: 'esqueleto_facial',
    type: 'single_choice',
    question: '¿Qué hueso posee una lámina horizontal que forma el tercio posterior del paladar duro?',
    options: ['Hueso palatino', 'Hueso maxilar', 'Hueso esfenoides'],
    correctIndex: 0,
    rationale: 'La lámina horizontal del hueso palatino conforma el tercio posterior del paladar duro, completando los dos tercios anteriores dados por las apófisis palatinas de los maxilares.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Hueso Palatino',
    order: 4
  },
  {
    id: 'quiz_t1_fac_05',
    topicId: 'esqueleto_facial',
    type: 'matching',
    question: 'Relaciona cada accidente mandibular con su significado clínico o anatómico:',
    matchingPairs: [
      { left: 'Foramen mentoniano', right: 'Salida de ramas sensitivas del nervio alveolar inferior' },
      { left: 'Espina de Spix (língula)', right: 'Referencia para el bloqueo anestésico alveolar inferior' },
      { left: 'Apófisis coronoides', right: 'Inserción del tendón del músculo temporal' }
    ],
    options: ['Relación anatómica mandibular'],
    correctIndex: 0,
    rationale: 'La espina de Spix marca la entrada del conducto mandibular; el foramen mentoniano su salida anterior; la apófisis coronoides recibe al temporal.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Mandíbula',
    order: 5
  },
  {
    id: 'quiz_t1_fac_06',
    topicId: 'esqueleto_facial',
    type: 'ordering',
    question: 'Ordena de anterior a posterior las estructuras que forman el paladar duro y blando:',
    orderingItems: [
      'Apófisis palatina del maxilar',
      'Lámina horizontal del hueso palatino',
      'Velo del paladar (paladar blando)',
      'Úvula'
    ],
    options: ['Secuencia anteroposterior del paladar'],
    correctIndex: 0,
    rationale: 'El paladar se dispone: Apófisis palatina del maxilar (2/3 ant) -> Lámina horizontal del palatino (1/3 post) -> Paladar blando -> Úvula.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Bóveda Palatina',
    order: 6
  },
  {
    id: 'quiz_t1_fac_07',
    topicId: 'esqueleto_facial',
    type: 'single_choice',
    question: 'El seno maxilar drena naturalmente a través de su ostium hacia:',
    options: ['Meato nasal medio', 'Meato nasal inferior', 'Meato nasal superior'],
    correctIndex: 0,
    rationale: 'El seno maxilar drena en el meato medio a través del hiato semilunar junto con las celdillas etmoidales anteriores y el seno frontal.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Senos Paranasales y Fosas Nasales',
    order: 7
  },
  {
    id: 'quiz_t1_fac_08',
    topicId: 'esqueleto_facial',
    type: 'single_choice',
    question: '¿Qué estructura drena específicamente en el meato nasal inferior?',
    options: ['Conducto nasolagrimal', 'Seno maxilar', 'Seno esfenoidal'],
    correctIndex: 0,
    rationale: 'El conducto lacrimonasal (nasolagrimal) desemboca exclusivamente en el meato nasal inferior, bajo el cornete nasal inferior.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Fosas Nasales',
    order: 8
  },
  {
    id: 'quiz_t1_fac_09',
    topicId: 'esqueleto_facial',
    type: 'case_study',
    question: 'En una fractura tipo Le Fort II (piramidal), ¿cuál de los siguientes huesos se encuentra comprometido?',
    options: ['Huesos nasales y reborde orbitario medial e inferior del maxilar', 'Solo la apófisis alveolar de la mandíbula', 'Hueso parietal exclusivamente'],
    correctIndex: 0,
    rationale: 'La fractura Le Fort II tiene trayecto piramidal a través de los huesos nasales, apófisis frontal del maxilar, reborde infraorbitario y pared anterior del seno maxilar.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Macizo Facial y Trayectos de Resistencia',
    order: 9
  },
  {
    id: 'quiz_t1_fac_10',
    topicId: 'esqueleto_facial',
    type: 'single_choice',
    question: 'La fosa pterigopalatina se comunica con la fosa craneal media a través del:',
    options: ['Foramen redondo', 'Foramen oval', 'Conducto óptico'],
    correctIndex: 0,
    rationale: 'El foramen redondo comunica la fosa craneal media con el trasfondo de la fosa pterigopalatina dando paso al nervio maxilar (V2).',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Fosa Pterigopalatina',
    order: 10
  },
  {
    id: 'quiz_t1_fac_11',
    topicId: 'esqueleto_facial',
    type: 'single_choice',
    question: '¿Qué hueso de la órbita constituye su pared medial de aspecto papiráceo extremadamente delgada?',
    options: ['Lámina orbitaria (papirácea) del etmoides', 'Hueso cigomático', 'Ala mayor del esfenoides'],
    correctIndex: 0,
    rationale: 'La lámina orbitaria del etmoides (papirácea) forma la mayor parte de la pared medial de la órbita y separa la cavidad orbitaria de las celdillas etmoidales.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Cavidad Orbitaria',
    order: 11
  },
  {
    id: 'quiz_t1_fac_12',
    topicId: 'esqueleto_facial',
    type: 'single_choice',
    question: 'El orificio esfenopalatino da paso a los vasos esfenopalatinos y comunica la fosa pterigopalatina con:',
    options: ['La cavidad nasal (fosa nasal)', 'La cavidad orbitaria', 'La fosa craneal posterior'],
    correctIndex: 0,
    rationale: 'El foramen esfenopalatino conecta la fosa pterigopalatina directamente con la cavidad nasal, permitiendo el ingreso de la arteria esfenopalatina terminal.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Fosas Nasales y Fosa Pterigopalatina',
    order: 12
  },
  {
    id: 'quiz_t1_fac_13',
    topicId: 'esqueleto_facial',
    type: 'matching',
    question: 'Empareja el meato nasal con la estructura o seno que drena en él:',
    matchingPairs: [
      { left: 'Meato inferior', right: 'Conducto nasolagrimal' },
      { left: 'Meato medio', right: 'Seno frontal y seno maxilar' },
      { left: 'Receso esfenoetmoidal', right: 'Seno esfenoidal' }
    ],
    options: ['Correlación de drenaje en meatos'],
    correctIndex: 0,
    rationale: 'En meato inferior drena el lagrimal; en medio el frontal y maxilar; en receso esfenoetmoidal drena el seno esfenoidal.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Meatos Nasales',
    order: 13
  },
  {
    id: 'quiz_t1_fac_14',
    topicId: 'esqueleto_facial',
    type: 'ordering',
    question: 'Ordena de superficial a profundo los elementos óseos de la pared lateral de la fosa infratemporal:',
    orderingItems: [
      'Rama de la mandíbula',
      'Apófisis coronoides',
      'Lámina lateral de la apófisis pterigoides',
      'Fosa pterigopalatina'
    ],
    options: ['Secuencia topográfica de profundidad'],
    correctIndex: 0,
    rationale: 'La pared lateral de la fosa está dada por la rama mandibular -> hacia medial se encuentra la apófisis pterigoides -> en el fondo la fosa pterigopalatina.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Fosa Infratemporal',
    order: 14
  },
  {
    id: 'quiz_t1_fac_15',
    topicId: 'esqueleto_facial',
    type: 'single_choice',
    question: 'Las apófisis geni (espinas mentonianas) de la cara interna de la mandíbula dan inserción a:',
    options: ['Músculos genioglosos y genihioideos', 'Músculos masetero y temporal', 'Músculo buccinador'],
    correctIndex: 0,
    rationale: 'Las espinas mentonianas superiores prestan inserción al geniogloso y las inferiores al genihioideo.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Cara Interna Mandibular',
    order: 15
  },
  {
    id: 'quiz_t1_fac_16',
    topicId: 'esqueleto_facial',
    type: 'single_choice',
    question: 'El conducto palatino mayor da paso a los vasos palatinos mayores y al nervio:',
    options: ['Nervio palatino mayor', 'Nervio nasopalatino', 'Nervio lingual'],
    correctIndex: 0,
    rationale: 'El conducto palatino mayor conduce al nervio palatino mayor para la sensibilidad de la mucosa de los dos tercios posteriores del paladar duro.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Hueso Palatino',
    order: 16
  },
  {
    id: 'quiz_t1_fac_17',
    topicId: 'esqueleto_facial',
    type: 'case_study',
    question: 'Paciente con dolor dental severo en molares inferiores. Al infiltrar anestésico en la língula mandibular, ¿qué nervio se está bloqueando antes de su ingreso al conducto?',
    options: ['Nervio alveolar inferior', 'Nervio bucal', 'Nervio maseterino'],
    correctIndex: 0,
    rationale: 'El nervio alveolar inferior (rama de V3) ingresa al conducto mandibular a nivel de la língula (espina de Spix) para inervar los dientes mandibulares.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Mandíbula y Nervio Mandibular',
    order: 17
  },
  {
    id: 'quiz_t1_fac_18',
    topicId: 'esqueleto_facial',
    type: 'single_choice',
    question: 'El piso de la órbita está constituido principalmente por cuál de los siguientes huesos:',
    options: ['Cara orbitaria del maxilar', 'Hueso frontal', 'Hueso esfenoides'],
    correctIndex: 0,
    rationale: 'El piso orbitario lo forma predominantemente la cara orbitaria del maxilar, con contribución menor del cigomático y de la carilla orbitaria del palatino.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Cavidad Orbitaria',
    order: 18
  },
  {
    id: 'quiz_t1_fac_19',
    topicId: 'esqueleto_facial',
    type: 'single_choice',
    question: '¿Qué hueso facial se articula con el frontal, el esfenoides, el temporal y el maxilar?',
    options: ['Hueso cigomático (malar)', 'Hueso nasal', 'Hueso lagrimal (unguis)'],
    correctIndex: 0,
    rationale: 'El hueso cigomático articula con frontal, maxilar, ala mayor del esfenoides y apófisis cigomática del temporal.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Hueso Cigomático',
    order: 19
  },
  {
    id: 'quiz_t1_fac_20',
    topicId: 'esqueleto_facial',
    type: 'single_choice',
    question: 'La sutura sagital o interparietal finaliza anteriormente en qué punto craneométrico:',
    options: ['Bregma', 'Lambda', 'Glabela'],
    correctIndex: 0,
    rationale: 'El bregma es la unión de la sutura coronal con la sutura sagital; lambda es la unión con la sutura lambdoidea.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Bóveda Craneal',
    order: 20
  },

  // =========================================================================
  // TEMA 3: articulaciones_cabeza_cuello (20 QUIZZES)
  // =========================================================================
  {
    id: 'quiz_t1_art_01',
    topicId: 'articulaciones_cabeza_cuello',
    type: 'single_choice',
    question: 'La articulación temporomandibular (ATM) se clasifica anatómicamente como:',
    options: ['Sinovial bicondílea (o ginglimoartrodial)', 'Sincondrosis primaria', 'Sutura dentada'],
    correctIndex: 0,
    rationale: 'La ATM es una articulación sinovial de tipo bicondílea, con disco articular interpuesto que permite movimientos de bisagra (ginglimo) y deslizamiento (artrodia).',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Articulación Temporomandibular',
    order: 1
  },
  {
    id: 'quiz_t1_art_02',
    topicId: 'articulaciones_cabeza_cuello',
    type: 'single_choice',
    question: 'El ligamento que sujeta la apófisis odontoides contra el arco anterior del atlas es:',
    options: ['Ligamento transverso del atlas', 'Ligamento supraespinoso', 'Ligamento estilomandibular'],
    correctIndex: 0,
    rationale: 'El ligamento transverso del atlas cruza entre las masas laterales y mantiene al diente del axis firmemente adosado a la fosita del arco anterior.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Articulaciones Craneovertebrales',
    order: 2
  },
  {
    id: 'quiz_t1_art_03',
    topicId: 'articulaciones_cabeza_cuello',
    type: 'case_study',
    question: 'Paciente bosteza ampliamente y queda con la boca abierta fija sin poder cerrarla (luxación anterior de ATM). ¿Delante de qué eminencia ósea queda trabado el cóndilo mandibular?',
    options: ['Tubérculo articular del temporal (cóndilo del temporal)', 'Apófisis mastoides', 'Conducto auditivo externo'],
    correctIndex: 0,
    rationale: 'En la luxación anterior aguda de la ATM, la cabeza de la mandíbula se desliza anteriormente más allá de la cresta del tubérculo articular hacia la fosa infratemporal.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Biomecánica de la ATM',
    order: 3
  },
  {
    id: 'quiz_t1_art_04',
    topicId: 'articulaciones_cabeza_cuello',
    type: 'single_choice',
    question: '¿Cuál de los siguientes ligamentos se extiende desde el vértice del diente del axis hasta el borde anterior del foramen magno?',
    options: ['Ligamento del vértice del diente (apical)', 'Ligamento alar', 'Ligamento longitudinal anterior'],
    correctIndex: 0,
    rationale: 'El ligamento del vértice del diente (apical) va desde el ápice de la apófisis odontoides hasta el borde anterior del agujero occipital.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Articulación Atloidoaxoidea',
    order: 4
  },
  {
    id: 'quiz_t1_art_05',
    topicId: 'articulaciones_cabeza_cuello',
    type: 'matching',
    question: 'Relaciona cada ligamento craneocervical con su inserción anatómica fundamental:',
    matchingPairs: [
      { left: 'Ligamentos alares', right: 'Frenan la rotación excesiva del cráneo y C1 sobre C2' },
      { left: 'Membrana tectoria', right: 'Continuación cefálica del ligamento longitudinal posterior' },
      { left: 'Ligamento cruciforme', right: 'Compuesto por el ligamento transverso y fascículos longitudinales' }
    ],
    options: ['Ligamentos craneovertebrales'],
    correctIndex: 0,
    rationale: 'Los ligamentos alares van del diente a los cóndilos occipitales; la membrana tectoria continúa al LVP; el ligamento cruciforme incluye al transverso.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Ligamentos del Raquis Cervical',
    order: 5
  },
  {
    id: 'quiz_t1_art_06',
    topicId: 'articulaciones_cabeza_cuello',
    type: 'ordering',
    question: 'Ordena de anterior a posterior las capas ligamentosas en el conducto vertebral a nivel occipito-axial:',
    orderingItems: [
      'Diente del axis y arco anterior del atlas',
      'Ligamento transverso del atlas',
      'Membrana tectoria',
      'Duramadre espinal'
    ],
    options: ['Secuencia ligamentosa del canal raquídeo'],
    correctIndex: 0,
    rationale: 'De adelante hacia atrás: Diente -> Ligamento transverso del atlas -> Membrana tectoria -> Duramadre espinal.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Conducto Raquídeo a Nivel C1-C2',
    order: 6
  },
  {
    id: 'quiz_t1_art_07',
    topicId: 'articulaciones_cabeza_cuello',
    type: 'single_choice',
    question: 'La articulación atlantooccipital permite principalmente movimientos de:',
    options: ['Flexión y extensión de la cabeza ("asentimiento")', 'Rotación axial pura ("negación")', 'Inclinación lateral mayor a 45 grados'],
    correctIndex: 0,
    rationale: 'La articulación atlantooccipital es condílea y permite predominantemente movimientos de cabeceo (flexo-extensión). La rotación ocurre en la atlantoaxoidea.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Articulación Atlantooccipital',
    order: 7
  },
  {
    id: 'quiz_t1_art_08',
    topicId: 'articulaciones_cabeza_cuello',
    type: 'single_choice',
    question: '¿Qué tipo de articulación une los cuerpos vertebrales cervicales a través del disco intervertebral?',
    options: ['Sínfisis (anfiartrosis)', 'Sinovial esferoidea', 'Sindesmosis pura'],
    correctIndex: 0,
    rationale: 'Las uniones intervertebrales entre cuerpos son sínfisis cartilaginosas secundarias reforzadas por los ligamentos longitudinales anterior y posterior.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Articulaciones Intervertebrales',
    order: 8
  },
  {
    id: 'quiz_t1_art_09',
    topicId: 'articulaciones_cabeza_cuello',
    type: 'case_study',
    question: 'Un paciente presenta chasquido audible al abrir la boca y dolor preauricular. El disco articular de la ATM está dividido anatómicamente en dos compartimentos. ¿Qué movimiento ocurre en el compartimento inferior (infradiscal)?',
    options: ['Rotación pura en bisagra', 'Traslación anterior', 'Propulsión mandibular'],
    correctIndex: 0,
    rationale: 'El compartimento infradiscal (disco-condilar) realiza el movimiento de bisagra/rotación durante los primeros 20 mm de apertura; el supradiscal realiza la traslación.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Cinemática de la ATM',
    order: 9
  },
  {
    id: 'quiz_t1_art_10',
    topicId: 'articulaciones_cabeza_cuello',
    type: 'single_choice',
    question: 'Las articulaciones uncovertebrales (de Luschka) son características exclusivas de:',
    options: ['Vértebras cervicales (C3 a C7)', 'Vértebras torácicas', 'Vértebras lumbares'],
    correctIndex: 0,
    rationale: 'Las articulaciones de Luschka se forman entre las apófisis unciformes y las caras biseladas de los cuerpos cervicales C3-C7.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Articulaciones Uncovertebrales',
    order: 10
  },
  {
    id: 'quiz_t1_art_11',
    topicId: 'articulaciones_cabeza_cuello',
    type: 'single_choice',
    question: 'El ligamento esfenomandibular se extiende desde la espina del esfenoides hasta:',
    options: ['La língula mandibular (espina de Spix)', 'El ángulo de la mandíbula (gonion)', 'El mentón'],
    correctIndex: 0,
    rationale: 'El ligamento esfenomandibular va desde la espina del esfenoides a la língula mandibular, cubriendo la entrada del nervio alveolar inferior.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Ligamentos Accesorios de la ATM',
    order: 11
  },
  {
    id: 'quiz_t1_art_12',
    topicId: 'articulaciones_cabeza_cuello',
    type: 'single_choice',
    question: '¿Qué ligamento conecta las láminas vertebrales adyacentes a lo largo de la columna cervical?',
    options: ['Ligamento amarillo (flavum)', 'Ligamento longitudinal anterior', 'Ligamento nucal'],
    correctIndex: 0,
    rationale: 'Los ligamentos amarillos unen los bordes de las láminas de las vértebras contiguas, cerrando la pared posterior del conducto vertebral.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Ligamentos Interlaminares',
    order: 12
  },
  {
    id: 'quiz_t1_art_13',
    topicId: 'articulaciones_cabeza_cuello',
    type: 'matching',
    question: 'Asocia el ligamento extrínseco de la mandíbula con su origen óseo:',
    matchingPairs: [
      { left: 'Ligamento esfenomandibular', right: 'Espina del hueso esfenoides' },
      { left: 'Ligamento estilomandibular', right: 'Apófisis estiloides del temporal' },
      { left: 'Rafe pterigomandibular', right: 'Gancho de la apófisis pterigoides' }
    ],
    options: ['Ligamentos mandibulares'],
    correctIndex: 0,
    rationale: 'El esfenomandibular nace en la espina esfenoidal; el estilomandibular en la estiloides; el rafe en el gancho del ala medial pterigoidea.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, ATM y Fascias',
    order: 13
  },
  {
    id: 'quiz_t1_art_14',
    topicId: 'articulaciones_cabeza_cuello',
    type: 'ordering',
    question: 'Ordena la secuencia de movimientos mandibulares durante una apertura bucal máxima normal:',
    orderingItems: [
      'Rotación del cóndilo en la cavidad glenoidea (compartimento inferior)',
      'Deslizamiento anterior del disco sobre el tubérculo articular (compartimento superior)',
      'Apertura interincisal máxima',
      'Relajación y traslación posterior de retorno'
    ],
    options: ['Fases de apertura mandibular'],
    correctIndex: 0,
    rationale: 'La cinemática inicia con rotación pura infradiscal, seguida de traslación anterior supradiscal hasta apertura máxima.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Fisiología de la ATM',
    order: 14
  },
  {
    id: 'quiz_t1_art_15',
    topicId: 'articulaciones_cabeza_cuello',
    type: 'single_choice',
    question: 'El ligamento nucal representa la prolongación superior engrosada de cuál de los siguientes ligamentos:',
    options: ['Ligamento supraespinoso', 'Ligamento interespinoso', 'Ligamento longitudinal posterior'],
    correctIndex: 0,
    rationale: 'El ligamento nucal es una lámina fibroelástica triangular sagital que continúa hacia arriba al ligamento supraespinoso desde C7 hasta la cresta occipital externa.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Ligamento Nucal',
    order: 15
  },
  {
    id: 'quiz_t1_art_16',
    topicId: 'articulaciones_cabeza_cuello',
    type: 'single_choice',
    question: 'La articulación atlantoaxoidea media se clasifica como:',
    options: ['Trocoide (pivote)', 'Enartrosis (esferoidea)', 'Artrodia (plana)'],
    correctIndex: 0,
    rationale: 'La articulación entre el diente del axis y el arco anterior del atlas es un trocoide cilíndrico que permite la rotación cefálica.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Articulación Atlantoaxoidea Media',
    order: 16
  },
  {
    id: 'quiz_t1_art_17',
    topicId: 'articulaciones_cabeza_cuello',
    type: 'case_study',
    question: 'En pacientes con artritis reumatoide avanzada, la erosión de cuál de las siguientes estructuras puede causar luxación atlantoaxoidea con compresión bulbar mortal tras una intubación orotraqueal:',
    options: ['Ligamento transverso del atlas', 'Ligamento estilohioideo', 'Ligamento amarillo'],
    correctIndex: 0,
    rationale: 'La ruptura del ligamento transverso permite que el diente del axis se desplace posteriormente hacia el conducto raquídeo, comprimiendo la médula y el bulbo raquídeo.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Articulación C1-C2',
    order: 17
  },
  {
    id: 'quiz_t1_art_18',
    topicId: 'articulaciones_cabeza_cuello',
    type: 'single_choice',
    question: 'El disco articular de la ATM se compone histológicamente de:',
    options: ['Fibrocartílago denso y avascular en su zona central', 'Cartílago hialino puro vascularizado', 'Hueso trabecular esponjoso'],
    correctIndex: 0,
    rationale: 'El disco de la ATM es fibrocartilaginoso, con una banda anterior, una zona intermedia bicóncava avascular y una banda posterior ricamente inervada.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Disco Articular de la ATM',
    order: 18
  },
  {
    id: 'quiz_t1_art_19',
    topicId: 'articulaciones_cabeza_cuello',
    type: 'single_choice',
    question: 'Las articulaciones cigapofisarias (facetarias) de la columna cervical son de tipo:',
    options: ['Sinoviales planas (artrodias)', 'Sincondrosis', 'Troclear'],
    correctIndex: 0,
    rationale: 'Las articulaciones facetarias cervicales son sinoviales planas orientadas a 45 grados, permitiendo flexión, extensión y deslizamiento oblicuo.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Articulaciones Cigapofisarias',
    order: 19
  },
  {
    id: 'quiz_t1_art_20',
    topicId: 'articulaciones_cabeza_cuello',
    type: 'single_choice',
    question: '¿Qué nervio proporciona la inervación sensitiva principal a la cápsula y disco de la ATM?',
    options: ['Nervio auriculotemporal', 'Nervio facial', 'Nervio vago'],
    correctIndex: 0,
    rationale: 'El nervio auriculotemporal (rama de V3) proporciona la inervación sensorial primaria a la región posterior y lateral de la ATM.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Inervación de la ATM',
    order: 20
  }
];

export async function run() {
  await uploadQuizzesBatch(tomo1Quizzes, 'Rouvière Tomo 1 (Bloque A: Temas 1 a 3)');
}
