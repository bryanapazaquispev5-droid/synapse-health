// Quizzes Clínicos de Anatomía Humana - Rouvière Tomo 4 (SNC: Parte 1: Temas 1 a 3)
// 3 Temas x 20 Quizzes = 60 Quizzes
import { uploadQuizzesBatch } from './seed_quizzes_common.mjs';

const tomo4Part1Quizzes = [
  // =========================================================================
  // TEMA 1: medula_espinal_meninges (20 QUIZZES)
  // =========================================================================
  {
    id: 'quiz_t4_med_01',
    topicId: 'medula_espinal_meninges',
    type: 'single_choice',
    question: 'En el adulto, ¿a qué nivel vertebral termina habitualmente el cono medular de la médula espinal?',
    options: ['Borde inferior de L1 o borde superior de L2', 'Borde inferior de L4', 'Nivel de S2'],
    correctIndex: 0,
    rationale: 'El cono medular finaliza entre L1 y L2 en el adulto. Por debajo de este nivel, el saco dural contiene únicamente la cauda equina (cola de caballo) y el filum terminale.',
    sourceBook: 'Rouvière - Delmas: Tomo 4 (Sistema Nervioso Central), Médula Espinal',
    order: 1
  },
  {
    id: 'quiz_t4_med_02',
    topicId: 'medula_espinal_meninges',
    type: 'single_choice',
    question: 'El espacio subaracnoideo donde se realiza la punción lumbar para obtener líquido cefalorraquídeo se extiende caudalmente hasta la vértebra:',
    options: ['Segunda vértebra sacra (S2)', 'Quinta vértebra lumbar (L5)', 'Cóccix'],
    correctIndex: 0,
    rationale: 'El saco dural y el espacio subaracnoideo descienden hasta S2, donde la duramadre se adosa al filum terminale para formar el ligamento coccígeo.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Meninges Raquídeas y Cisterna Lumbar',
    order: 2
  },
  {
    id: 'quiz_t4_med_03',
    topicId: 'medula_espinal_meninges',
    type: 'single_choice',
    question: 'Paciente requiere punción lumbar diagnóstica. Para evitar lesionar el cono medular, ¿entre qué apófisis espinosas lumbares se introduce con máxima seguridad la aguja?',
    options: ['Entre L3-L4 o L4-L5 (línea bi-ilíaca de Tuffier)', 'Entre T12-L1', 'Entre L1-L2'],
    correctIndex: 0,
    rationale: 'La línea que une las crestas ilíacas más altas (línea de Tuffier/Jacoby) cruza a nivel de L4 o el espacio L4-L5, bien por debajo del fin del cono medular.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Punción Lumbar',
    order: 3
  },
  {
    id: 'quiz_t4_med_04',
    topicId: 'medula_espinal_meninges',
    type: 'single_choice',
    question: 'Los ligamentos dentados son engrosamientos fibrosos de qué capa meníngea que anclan la médula a la duramadre:',
    options: ['Piamadre espinal', 'Aracnoides', 'Duramadre perióstica'],
    correctIndex: 0,
    rationale: 'Los ligamentos dentados (21 pares) nacen de la piamadre a lo largo de las caras laterales de la médula y se insertan entre los orificios durales de las raíces nerviosas.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Piamadre y Ligamentos Dentados',
    order: 4
  },
  {
    id: 'quiz_t4_med_05',
    topicId: 'medula_espinal_meninges',
    type: 'matching',
    question: 'Relaciona cada espacio meníngeo perimedular con su contenido anatómico normal:',
    matchingPairs: [
      { left: 'Espacio epidural raquídeo', right: 'Plexos venosos vertebrales internos (de Batson) y grasa areolar' },
      { left: 'Espacio subaracnoideo', right: 'Líquido cefalorraquídeo y raíces de la cauda equina' },
      { left: 'Espacio subdural', right: 'Espacio virtual entre la duramadre y la aracnoides' }
    ],
    options: ['Espacios meníngeos raquídeos'],
    correctIndex: 0,
    rationale: 'Epidural: grasa y plexos venosos; subaracnoideo: LCR; subdural: virtual.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Meninges Espinales',
    order: 5
  },
  {
    id: 'quiz_t4_med_06',
    topicId: 'medula_espinal_meninges',
    type: 'ordering',
    question: 'Ordena de superficial a profundo las capas anatómicas atravesadas por la aguja en una punción lumbar estándar:',
    orderingItems: [
      'Piel y tejido celular subcutáneo',
      'Ligamentos supraespinoso e interespinoso',
      'Ligamento amarillo (resistencia elástica perceptible)',
      'Espacio epidural, duramadre y aracnoides (hacia el espacio subaracnoideo)'
    ],
    options: ['Capas de la punción lumbar'],
    correctIndex: 0,
    rationale: 'Piel -> Grasa -> Ligamento supraespinoso -> Ligamento interespinoso -> Ligamento amarillo -> Duramadre/aracnoides -> LCR.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Técnica de Punción Lumbar',
    order: 6
  },
  {
    id: 'quiz_t4_med_07',
    topicId: 'medula_espinal_meninges',
    type: 'single_choice',
    question: '¿Cuántos pares de nervios espinales raquídeos emergen de la médula espinal?',
    options: ['31 pares (8 cervicales, 12 torácicos, 5 lumbares, 5 sacros y 1 coccígeo)', '30 pares', '33 pares'],
    correctIndex: 0,
    rationale: 'La médula origina 31 pares de nervios espinales: 8 C, 12 T, 5 L, 5 S y 1 Co. Notar que hay 8 nervios cervicales pero 7 vértebras cervicales.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Nervios Espinales',
    order: 7
  },
  {
    id: 'quiz_t4_med_08',
    topicId: 'medula_espinal_meninges',
    type: 'single_choice',
    question: 'El primer par de nervios cervicales (C1 o nervio suboccipital) emerge del conducto vertebral:',
    options: ['Entre el hueso occipital y el arco posterior del atlas', 'Entre el atlas y el axis', 'Por el foramen de C2'],
    correctIndex: 0,
    rationale: 'El nervio C1 sale por encima del arco posterior del atlas, entre éste y el foramen magno occipital en el triángulo suboccipital.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Raíces Cervicales',
    order: 8
  },
  {
    id: 'quiz_t4_med_09',
    topicId: 'medula_espinal_meninges',
    type: 'single_choice',
    question: 'Paciente con hemisección medular derecha a nivel de T8 (Síndrome de Brown-Séquard). ¿Qué déficit clínico presentará por debajo de la lesión?',
    options: ['Pérdida motora y propioceptiva ipsilateral (derecha) con pérdida de termoalgesia contralateral (izquierda)', 'Parálisis flácida bilateral', 'Pérdida sensitiva total derecha únicamente'],
    correctIndex: 0,
    rationale: 'Las vías corticoespinal y de cordones posteriores ya han decusado o decusan arriba (déficit ipsilateral), mientras el haz espinotalámico decusa 1-2 segmentos sobre su entrada medular (déficit contralateral).',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Vías de Conducción Medular y Síndrome de Brown-Séquard',
    order: 9
  },
  {
    id: 'quiz_t4_med_10',
    topicId: 'medula_espinal_meninges',
    type: 'single_choice',
    question: 'En la médula espinal, las láminas de Rexed subdividen la sustancia gris. ¿En qué láminas se localizan las motoneuronas alfa del asta anterior?',
    options: ['Lámina IX de Rexed', 'Lámina II (sustancia gelatinosa de Rolando)', 'Lámina X periependimaria'],
    correctIndex: 0,
    rationale: 'La lámina IX agrupa los núcleos motores somáticos del asta anterior (motoneuronas alfa y gamma para la musculatura esquelética).',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Láminas de Rexed',
    order: 10
  },
  {
    id: 'quiz_t4_med_11',
    topicId: 'medula_espinal_meninges',
    type: 'single_choice',
    question: 'La arteria espinal anterior que irriga los dos tercios anteriores de la médula espinal se forma por la confluencia de ramas de:',
    options: ['Las dos arterias vertebrales', 'La arteria basilar', 'Las arterias carótidas internas'],
    correctIndex: 0,
    rationale: 'La arteria espinal anterior se origina de dos ramas de las arterias vertebrales que se unen en la cara anterior del bulbo raquídeo.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Vascularización de la Médula Espinal',
    order: 11
  },
  {
    id: 'quiz_t4_med_12',
    topicId: 'medula_espinal_meninges',
    type: 'single_choice',
    question: 'La arteria radicular magna (de Adamkiewicz), aporte nutricio vital para la médula toracolumbar, penetra habitualmente por el lado izquierdo entre:',
    options: ['T9 y L1', 'C3 y C5', 'L4 y S1'],
    correctIndex: 0,
    rationale: 'La arteria de Adamkiewicz nace de una intercostal posterior o lumbar entre T9 y L1 (más comúnmente T10 izquierda) e irriga el engrosamiento lumbosacro.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Arteria de Adamkiewicz',
    order: 12
  },
  {
    id: 'quiz_t4_med_13',
    topicId: 'medula_espinal_meninges',
    type: 'matching',
    question: 'Empareja los cordones de la médula espinal con sus fascículos ascendentes principales:',
    matchingPairs: [
      { left: 'Cordón posterior', right: 'Fascículos grácil (de Goll) y cuneiforme (de Burdach) para propiocepción consciente' },
      { left: 'Cordón lateral', right: 'Haz espinotalámico lateral (termoalgesia) y espinocerebelosos' },
      { left: 'Cordón anterior', right: 'Haz espinotalámico anterior (tacto grueso o protopático)' }
    ],
    options: ['Cordones medulares y haces sensitivos'],
    correctIndex: 0,
    rationale: 'Cordón posterior: Goll y Burdach; lateral: espinotalámico lateral; anterior: espinotalámico anterior.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Sustancia Blanca Medular',
    order: 13
  },
  {
    id: 'quiz_t4_med_14',
    topicId: 'medula_espinal_meninges',
    type: 'ordering',
    question: 'Ordena de cefálico a caudal los engrosamientos (intumescencias) y extremos de la médula espinal:',
    orderingItems: [
      'Intumescencia cervical (C4 a T1, origen del plexo braquial)',
      'Porción torácica intermedia',
      'Intumescencia lumbosacra (T11 a L1, origen del plexo lumbosacro)',
      'Cono medular y filum terminale'
    ],
    options: ['Topografía macroscópica medular'],
    correctIndex: 0,
    rationale: 'Intumescencia cervical -> Torácica -> Intumescencia lumbosacra -> Cono medular.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Morfología Externa de la Médula',
    order: 14
  },
  {
    id: 'quiz_t4_med_15',
    topicId: 'medula_espinal_meninges',
    type: 'single_choice',
    question: 'El cuerno lateral de la sustancia gris medular que contiene motoneuronas simpáticas preganglionares está presente en:',
    options: ['Segmentos torácicos y lumbares superiores (T1 a L2)', 'Segmentos cervicales exclusivamente', 'Segmentos sacros S2-S4'],
    correctIndex: 0,
    rationale: 'El asta lateral contiene la columna intermediolateral simpática desde T1 hasta L2. (En S2-S4 se localizan neuronas parasimpáticas sacras).',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Sistema Nervioso Autónomo Medular',
    order: 15
  },
  {
    id: 'quiz_t4_med_16',
    topicId: 'medula_espinal_meninges',
    type: 'single_choice',
    question: 'El filum terminale interno está rodeado por las raíces de la cauda equina y se compone de:',
    options: ['Prolongación piamadre recubierta de duramadre', 'Tejido óseo', 'Nervios motores'],
    correctIndex: 0,
    rationale: 'El filum terminale es una prolongación filamentosa de la piamadre que desciende desde el cono medular hasta fijarse en el periostio del cóccix.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Filum Terminale',
    order: 16
  },
  {
    id: 'quiz_t4_med_17',
    topicId: 'medula_espinal_meninges',
    type: 'single_choice',
    question: 'Paciente con siringomielia (dilatación quística del conducto ependimario central a nivel cervical) presenta pérdida selectiva de la sensibilidad al dolor y a la temperatura en "capelina" (hombros y brazos) conservando el tacto fino. ¿Qué fibras se decusan y lesionan en la comisura blanca anterior?',
    options: ['Fibras espinotalámicas laterales que cruzan por delante del conducto del epéndimo', 'Fascículo grácil', 'Haz corticoespinal lateral'],
    correctIndex: 0,
    rationale: 'La expansión del canal central lesiona primero las fibras espinotalámicas decusantes en la comisura blanca anterior provocando disociación termoalgésica suspendida.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Comisura Blanca Anterior y Siringomielia',
    order: 17
  },
  {
    id: 'quiz_t4_med_18',
    topicId: 'medula_espinal_meninges',
    type: 'single_choice',
    question: 'El fascículo cuneiforme (de Burdach) transporta propiocepción consciente del:',
    options: ['Miembro superior y tórax superior (por encima de T6)', 'Miembro inferior (por debajo de T6)', 'Cuello exclusivamente'],
    correctIndex: 0,
    rationale: 'El fascículo grácil (de Goll) lleva la propiocepción de los miembros inferiores (debajo de T6); el cuneiforme (de Burdach) se añade por fuera para el miembro superior.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Cordones Posteriores',
    order: 18
  },
  {
    id: 'quiz_t4_med_19',
    topicId: 'medula_espinal_meninges',
    type: 'single_choice',
    question: 'El ganglio espinal anexo a la raíz posterior aloja a los somas neuronales de tipo:',
    options: ['Neuronas sensitivas pseudomonopolares (en T)', 'Neuronas motoras multipolares', 'Interneuronas piramidales'],
    correctIndex: 0,
    rationale: 'Los ganglios raquídeos posteriores contienen los cuerpos celulares de las primeras neuronas sensitivas pseudounipolares.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Raíces Espinales y Ganglios',
    order: 19
  },
  {
    id: 'quiz_t4_med_20',
    topicId: 'medula_espinal_meninges',
    type: 'single_choice',
    question: 'La fisura media anterior de la médula espinal aloja a la arteria:',
    options: ['Arteria espinal anterior', 'Arteria espinal posterior', 'Arteria basilar'],
    correctIndex: 0,
    rationale: 'La arteria espinal anterior desciende a lo largo de toda la hendidura o surco medio anterior de la médula espinal emitiendo ramas surcales perforantes.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Arteria Espinal Anterior',
    order: 20
  },

  // =========================================================================
  // TEMA 2: tronco_encefalico_cuarto_ventriculo (20 QUIZZES)
  // =========================================================================
  {
    id: 'quiz_t4_tro_01',
    topicId: 'tronco_encefalico_cuarto_ventriculo',
    type: 'single_choice',
    question: 'La decusación motora de las pirámides bulbares marca en la cara anterior el límite inferior entre:',
    options: ['La médula oblongada (bulbo) y la médula espinal', 'El puente y el mesencéfalo', 'El cerebelo y el bulbo'],
    correctIndex: 0,
    rationale: 'La decusación piramidal (donde cruza el 85-90% de las fibras corticoespinales) señala el límite de transición entre el bulbo raquídeo y la médula espinal.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Bulbo Raquídeo',
    order: 1
  },
  {
    id: 'quiz_t4_tro_02',
    topicId: 'tronco_encefalico_cuarto_ventriculo',
    type: 'single_choice',
    question: 'En el surco pontocerebeloso (bulbopontino), ¿cuál es el nervio que emerge en la posición más medial inmediatamente por encima de las pirámides?',
    options: ['Nervio abducens (VI par craneal)', 'Nervio facial (VII par craneal)', 'Nervio vestibulococlear (VIII par craneal)'],
    correctIndex: 0,
    rationale: 'El nervio abducens (VI) emerge sobre las pirámides en el surco bulbopontino. Más lateralmente emergen el facial (VII) y en el ángulo pontocerebeloso el VIII.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Surco Bulbopontino',
    order: 2
  },
  {
    id: 'quiz_t4_tro_03',
    topicId: 'tronco_encefalico_cuarto_ventriculo',
    type: 'single_choice',
    question: 'Paciente de 58 años sufre oclusión de la arteria cerebelosa posteroinferior (PICA) presentando Síndrome bulbar lateral de Wallenberg. ¿Cuál de los siguientes núcleos bulbares está lesionado?',
    options: ['Núcleo ambiguo (pares IX, X) y núcleo espinal del trigémino', 'Núcleo del nervio hipogloso', 'Núcleo del nervio abducens'],
    correctIndex: 0,
    rationale: 'El síndrome de Wallenberg compromete la región dorsolateral del bulbo: núcleo ambiguo (disfagia/disfonía), núcleo espinal del V (anestesia facial homolateral) y vías simpáticas (Horner).',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Síndrome de Wallenberg y Bulbo Raquídeo',
    order: 3
  },
  {
    id: 'quiz_t4_tro_04',
    topicId: 'tronco_encefalico_cuarto_ventriculo',
    type: 'single_choice',
    question: 'En la cara posterior del mesencéfalo, la lámina cuadrigémina (techo del mesencéfalo) contiene:',
    options: ['Dos colículos superiores (reflejos visuales) y dos colículos inferiores (vía auditiva)', 'El acueducto de Silvio únicamente', 'Los pedúnculos cerebrales'],
    correctIndex: 0,
    rationale: 'Los colículos superiores o tubérculos cuadrigéminos anteriores se integran con la vía visual y los inferiores con la vía acústica.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Mesencéfalo y Lámina Cuadrigémina',
    order: 4
  },
  {
    id: 'quiz_t4_tro_05',
    topicId: 'tronco_encefalico_cuarto_ventriculo',
    type: 'matching',
    question: 'Relaciona cada nivel del tronco encefálico con el conducto o ventrículo que lo atraviesa o respalda:',
    matchingPairs: [
      { left: 'Mesencéfalo', right: 'Acueducto mesencefálico (de Silvio)' },
      { left: 'Puente y bulbo superior', right: 'Cuarto ventrículo (fosa romboidea)' },
      { left: 'Bulbo inferior cerrado', right: 'Conducto central del epéndimo' }
    ],
    options: ['Cavidades ventriculares del tronco encefálico'],
    correctIndex: 0,
    rationale: 'Mesencéfalo contiene el acueducto; puente y bulbo abierto forman el piso del 4.° ventrículo; bulbo inferior continúa el conducto ependimario.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Cuarto Ventrículo y Acueducto de Silvio',
    order: 5
  },
  {
    id: 'quiz_t4_tro_06',
    topicId: 'tronco_encefalico_cuarto_ventriculo',
    type: 'ordering',
    question: 'Ordena de caudal a cefálico las tres porciones constitutivas del tronco del encéfalo:',
    orderingItems: [
      'Médula oblongada (bulbo raquídeo)',
      'Puente (protuberancia anular)',
      'Mesencéfalo (pedúnculos cerebrales y lámina cuadrigémina)'
    ],
    options: ['Segmentos del tronco encefálico'],
    correctIndex: 0,
    rationale: 'De caudal a cefálico: Bulbo raquídeo -> Protuberancia o Puente -> Mesencéfalo.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Tronco Encefálico',
    order: 6
  },
  {
    id: 'quiz_t4_tro_07',
    topicId: 'tronco_encefalico_cuarto_ventriculo',
    type: 'single_choice',
    question: 'El piso del cuarto ventrículo se denomina fosa romboidea y está dividido simétricamente por:',
    options: ['El surco medio posterior (tallo del calamus scriptorius)', 'El acueducto de Silvio', 'Las estrías medulares acústicas exclusivamente'],
    correctIndex: 0,
    rationale: 'El surco longitudinal medio divide la fosa romboidea en dos triángulos laterales semejando la pluma de un escribano (calamus scriptorius).',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Fosa Romboidea',
    order: 7
  },
  {
    id: 'quiz_t4_tro_08',
    topicId: 'tronco_encefalico_cuarto_ventriculo',
    type: 'single_choice',
    question: 'El trígono del hipogloso (ala blanca interna) y el trígono vagal (ala gris) se sitúan en:',
    options: ['El triángulo inferior (bulbar) del piso del cuarto ventrículo', 'El triángulo superior pontino', 'Los colículos superiores'],
    correctIndex: 0,
    rationale: 'En la porción bulbar del piso ventricular, el ala blanca interna corresponde al núcleo del XII par y el ala gris al núcleo dorsal del vago (X).',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Piso del Cuarto Ventrículo',
    order: 8
  },
  {
    id: 'quiz_t4_tro_09',
    topicId: 'tronco_encefalico_cuarto_ventriculo',
    type: 'single_choice',
    question: 'Paciente hipertenso presenta infarto medial del puente con hemiplejía motora contralateral y parálisis facial periférica ipsilateral y del VI par (Síndrome de Millard-Gubler). ¿Qué estructura ventricular protruye en el puente sobre el núcleo del VI par?',
    options: ['Colículo facial (eminencia teres)', 'Locus coeruleus', 'Tubérculo cuneiforme'],
    correctIndex: 0,
    rationale: 'El colículo facial o eminencia teres se forma por las fibras del nervio facial contorneando en rodilla al núcleo del nervio motor ocular externo (VI par).',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Colículo Facial',
    order: 9
  },
  {
    id: 'quiz_t4_tro_10',
    topicId: 'tronco_encefalico_cuarto_ventriculo',
    type: 'single_choice',
    question: 'Los orificios laterales de Luschka y el orificio medio de Magendie del cuarto ventrículo drenan el LCR hacia:',
    options: ['El espacio subaracnoideo (cisterna magna y cisternas basales)', 'El tercer ventrículo', 'Los senos durales directamente'],
    correctIndex: 0,
    rationale: 'El techo del 4.° ventrículo presenta tres perforaciones: el foramen medio de Magendie y los dos forámenes laterales de Luschka, por donde el LCR pasa al espacio subaracnoideo.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Techo del Cuarto Ventrículo',
    order: 10
  },
  {
    id: 'quiz_t4_tro_11',
    topicId: 'tronco_encefalico_cuarto_ventriculo',
    type: 'single_choice',
    question: 'La sustancia negra (locus niger de Soemmerring), rica en neuronas dopaminérgicas cuya degeneración causa Parkinson, se sitúa en:',
    options: ['Mesencéfalo (separando el pie del pedúnculo del tegmento)', 'Bulbo raquídeo', 'Puente posterior'],
    correctIndex: 0,
    rationale: 'La sustancia negra se extiende por todo el mesencéfalo entre el pie peduncular y el tegmento o calota mesencefálica.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Mesencéfalo y Sustancia Negra',
    order: 11
  },
  {
    id: 'quiz_t4_tro_12',
    topicId: 'tronco_encefalico_cuarto_ventriculo',
    type: 'single_choice',
    question: 'El núcleo rojo es una masa neuronal ovoide y vascularizada característica de:',
    options: ['El tegmento (calota) del mesencéfalo a nivel de los colículos superiores', 'La médula oblongada', 'El cerebelo'],
    correctIndex: 0,
    rationale: 'El núcleo rojo se encuentra en el tegmento mesencefálico y participa en el control motor extrapiramidal a través del fascículo rubroespinal.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Núcleo Rojo',
    order: 12
  },
  {
    id: 'quiz_t4_tro_13',
    topicId: 'tronco_encefalico_cuarto_ventriculo',
    type: 'matching',
    question: 'Asocia el par craneal con su punto de emergencia aparente en el tronco:',
    matchingPairs: [
      { left: 'Nervio oculomotor (III par)', right: 'Fosa interpeduncular de la cara anterior del mesencéfalo' },
      { left: 'Nervio trigémino (V par)', right: 'Cara anterolateral del puente (entre fibras transversas)' },
      { left: 'Nervio hipogloso (XII par)', right: 'Surco preolivar del bulbo raquídeo' }
    ],
    options: ['Orígenes aparentes de los pares craneales'],
    correctIndex: 0,
    rationale: 'III en fosa interpeduncular; V en cara anterolateral pontina; XII en surco preolivar.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Orígenes Aparentes del Tronco',
    order: 13
  },
  {
    id: 'quiz_t4_tro_14',
    topicId: 'tronco_encefalico_cuarto_ventriculo',
    type: 'ordering',
    question: 'Ordena de anterior a posterior las regiones de un corte transversal del mesencéfalo:',
    orderingItems: [
      'Pie del pedúnculo cerebral (fibras corticoespinales y corticopontinas)',
      'Sustancia negra (locus niger)',
      'Tegmento o calota mesencefálica (núcleo rojo y acueducto de Silvio)',
      'Tectum o techo (lámina cuadrigémina con los colículos)'
    ],
    options: ['Corte transversal del mesencéfalo'],
    correctIndex: 0,
    rationale: 'Pie peduncular -> Sustancia negra -> Tegmento -> Techo (lámina tectal).',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Estructura Interna del Mesencéfalo',
    order: 14
  },
  {
    id: 'quiz_t4_tro_15',
    topicId: 'tronco_encefalico_cuarto_ventriculo',
    type: 'single_choice',
    question: 'El lemnisco medial (cinta de Reil media) transmite hacia el tálamo la información de:',
    options: ['Propiocepción consciente y tacto discriminativo epicrítico', 'Dolor y temperatura', 'Vía visual'],
    correctIndex: 0,
    rationale: 'El lemnisco medial se origina en los núcleos grácil y cuneiforme del bulbo tras la decusación sensitiva de las fibras arcuatas internas.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Lemnisco Medial',
    order: 15
  },
  {
    id: 'quiz_t4_tro_16',
    topicId: 'tronco_encefalico_cuarto_ventriculo',
    type: 'single_choice',
    question: 'El fascículo longitudinal medial (FLM) interconecta los núcleos de los pares craneales III, IV y VI con los núcleos vestibulares para coordinar:',
    options: ['Los movimientos oculares conjugados con los giros de la cabeza', 'La deglución', 'El ritmo cardíaco'],
    correctIndex: 0,
    rationale: 'El FLM sincroniza los movimientos sacádicos y el reflejo vestibuloocular; su desmielinización causa oftalmoplejía internuclear.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Fascículo Longitudinal Medial',
    order: 16
  },
  {
    id: 'quiz_t4_tro_17',
    topicId: 'tronco_encefalico_cuarto_ventriculo',
    type: 'single_choice',
    question: 'Un paciente en coma presenta respiración irregular atáxica (de Biot) por enclavamiento tonsilar a través del foramen magno. ¿En qué estructura se localizan los centros vitales cardiorrespiratorios primitivos?',
    options: ['Formación reticular de la médula oblongada (bulbo raquídeo)', 'Cuerpo calloso', 'Lóbulo temporal'],
    correctIndex: 0,
    rationale: 'Los centros bulbares respiratorios dorsal y ventral y los núcleos vasomotores de la formación reticular bulbar mantienen el automatismo vital.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Formación Reticular Bulbar',
    order: 17
  },
  {
    id: 'quiz_t4_tro_18',
    topicId: 'tronco_encefalico_cuarto_ventriculo',
    type: 'single_choice',
    question: 'Los pedúnculos cerebelosos unen el tronco encefálico con el cerebelo. El pedúnculo cerebeloso medio conecta el cerebelo con:',
    options: ['El puente (protuberancia anular)', 'El mesencéfalo', 'La médula oblongada'],
    correctIndex: 0,
    rationale: 'El pedúnculo cerebeloso medio (brazo del puente) es el más grueso y transmite las fibras pontocerebelosas de la corteza al neocerebelo.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Pedúnculos Cerebelosos',
    order: 18
  },
  {
    id: 'quiz_t4_tro_19',
    topicId: 'tronco_encefalico_cuarto_ventriculo',
    type: 'single_choice',
    question: 'El núcleo olivar inferior (oliva bulbar) participa activamente en los circuitos de:',
    options: ['Aprendizaje motor y sincronización cerebelosa (fibras trepadoras)', 'Sensibilidad auditiva', 'Control del dolor medular'],
    correctIndex: 0,
    rationale: 'El complejo olivar inferior origina las fibras trepadoras que se proyectan directamente sobre las células de Purkinje de la corteza cerebelosa.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Núcleo Olivar Inferior',
    order: 19
  },
  {
    id: 'quiz_t4_tro_20',
    topicId: 'tronco_encefalico_cuarto_ventriculo',
    type: 'single_choice',
    question: 'El locus coeruleus se localiza en la pared dorsolateral del cuarto ventrículo pontino y es el principal centro productor de:',
    options: ['Noradrenalina del sistema nervioso central', 'Serotonina', 'Acetilcolina'],
    correctIndex: 0,
    rationale: 'El locus coeruleus contiene neuronas pigmentadas ricas en noradrenalina implicadas en el estado de alerta y ciclo sueño-vigilia.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Locus Coeruleus',
    order: 20
  },

  // =========================================================================
  // TEMA 3: cerebelo_vias_cerebelosas (20 QUIZZES)
  // =========================================================================
  {
    id: 'quiz_t4_cer_01',
    topicId: 'cerebelo_vias_cerebelosas',
    type: 'single_choice',
    question: '¿Cuál es el núcleo profundo del cerebelo más voluminoso y lateral, relacionado filogenéticamente con el neocerebelo y la coordinación motora fina?',
    options: ['Núcleo dentado', 'Núcleo del fastigio (del techo)', 'Núcleo emboliforme'],
    correctIndex: 0,
    rationale: 'El núcleo dentado es el mayor de los 4 núcleos intracerebelosos; se sitúa en los hemisferios cerebelosos y proyecta al tálamo y corteza motora.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Núcleos Profundos del Cerebelo',
    order: 1
  },
  {
    id: 'quiz_t4_cer_02',
    topicId: 'cerebelo_vias_cerebelosas',
    type: 'single_choice',
    question: 'El lóbulo floculonodular del cerebelo corresponde filogenéticamente a qué división:',
    options: ['Arquicerebelo (vestibulocerebelo)', 'Paleocerebelo (espinocerebelo)', 'Neocerebelo (cerebrocerebelo)'],
    correctIndex: 0,
    rationale: 'El arquicerebelo comprende el nódulo del vermis y los flóculos; está conectado con los núcleos vestibulares para el equilibrio y movimientos oculares.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Arquicerebelo y Floculonodular',
    order: 2
  },
  {
    id: 'quiz_t4_cer_03',
    topicId: 'cerebelo_vias_cerebelosas',
    type: 'single_choice',
    question: 'Paciente alcohólico crónico presenta marcha atáxica de base ancha con dismetría y disdiadococinesia en miembros ("ebrio"). La prueba de Romberg resulta negativa (oscila tanto con ojos abiertos como cerrados). ¿Qué estructura del SNC está comprometida?',
    options: ['Cerebelo (síndrome cerebeloso hemisférico y del vermis)', 'Cordones posteriores de la médula', 'Ganglios basales'],
    correctIndex: 0,
    rationale: 'En la ataxia cerebelosa la alteración de la coordinación no mejora con la visión (Romberg negativo), a diferencia de la ataxia sensitiva por cordones posteriores.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Síndrome Cerebeloso y Semiología',
    order: 3
  },
  {
    id: 'quiz_t4_cer_04',
    topicId: 'cerebelo_vias_cerebelosas',
    type: 'single_choice',
    question: 'La corteza cerebelosa se compone histológicamente de tres capas. ¿Cuál de ellas alberga las grandes neuronas de Purkinje?',
    options: ['Capa intermedia (capa de células de Purkinje)', 'Capa molecular externa', 'Capa granulosa interna'],
    correctIndex: 0,
    rationale: 'La capa media o de Purkinje contiene los somas piriformes de las células de Purkinje, cuyos axones constituyen la única eferencia inhibitoria de la corteza cerebelosa.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Corteza Cerebelosa',
    order: 4
  },
  {
    id: 'quiz_t4_cer_05',
    topicId: 'cerebelo_vias_cerebelosas',
    type: 'matching',
    question: 'Relaciona cada núcleo profundo del cerebelo con su división filogenética funcional:',
    matchingPairs: [
      { left: 'Núcleo del fastigio (del techo)', right: 'Arquicerebelo (equilibrio y tono postural axial)' },
      { left: 'Núcleos interpuestos (globoso y emboliforme)', right: 'Paleocerebelo (tono muscular y postura de extremidades)' },
      { left: 'Núcleo dentado', right: 'Neocerebelo (planificación y motricidad distal voluntaria)' }
    ],
    options: ['Núcleos cerebelosos y filogenia'],
    correctIndex: 0,
    rationale: 'Fastigio = arquicerebelo; interpuestos = paleocerebelo; dentado = neocerebelo.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Divisiones Filogenéticas Cerebelosas',
    order: 5
  },
  {
    id: 'quiz_t4_cer_06',
    topicId: 'cerebelo_vias_cerebelosas',
    type: 'ordering',
    question: 'Ordena de medial a lateral los 4 núcleos profundos del cerebelo humano:',
    orderingItems: [
      'Núcleo del fastigio (del techo, medial junto a la línea media)',
      'Núcleo globoso',
      'Núcleo emboliforme',
      'Núcleo dentado (el más lateral y voluminoso)'
    ],
    options: ['Secuencia medial a lateral de los núcleos cerebelosos'],
    correctIndex: 0,
    rationale: 'Mnemotecnia clásica de medial a lateral: Fas-Glo-Em-Den (Fastigio, Globoso, Emboliforme y Dentado).',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Topografía de los Núcleos Cerebelosos',
    order: 6
  },
  {
    id: 'quiz_t4_cer_07',
    topicId: 'cerebelo_vias_cerebelosas',
    type: 'single_choice',
    question: 'Las amígdalas cerebelosas (tonsilas) descansan inmediatamente por encima de qué orificio de la base del cráneo:',
    options: ['Foramen magno (agujero occipital)', 'Conducto auditivo interno', 'Foramen yugular'],
    correctIndex: 0,
    rationale: 'Las amígdalas cerebelosas reposan sobre el foramen magno; la hipertensión endocraneana las hernia hacia el canal raquídeo comprimiendo el bulbo raquídeo.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Amígdalas Cerebelosas y Herniación',
    order: 7
  },
  {
    id: 'quiz_t4_cer_08',
    topicId: 'cerebelo_vias_cerebelosas',
    type: 'single_choice',
    question: 'La vermis cerebelosa es la estructura media impar que une a:',
    options: ['Los dos hemisferios cerebelosos', 'Los pedúnculos cerebrales', 'El tálamo con el hipotálamo'],
    correctIndex: 0,
    rationale: 'El vermis es el cuerpo medio anillado del cerebelo que coordina la motricidad axial del tronco y la marcha.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Vermis del Cerebelo',
    order: 8
  },
  {
    id: 'quiz_t4_cer_09',
    topicId: 'cerebelo_vias_cerebelosas',
    type: 'single_choice',
    question: 'Niño con hidrocefalia y tumor en el vermis cerebeloso (meduloblastoma del techo del 4.° ventrículo). Desarrolla marcha en estrella, temblor troncal e inestabilidad al estar de pie. ¿Qué tipo de ataxia presenta?',
    options: ['Ataxia del vermis (ataxia de tronco / estática)', 'Ataxia sensitiva pura', 'Ataxia cortical'],
    correctIndex: 0,
    rationale: 'Las lesiones de la línea media cerebelosa (vermis) causan ataxia axial o de tronco con incapacidad para mantenerse de pie o sentado, sin gran dismetría en extremidades.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Síndrome de Vermis Cerebeloso',
    order: 9
  },
  {
    id: 'quiz_t4_cer_10',
    topicId: 'cerebelo_vias_cerebelosas',
    type: 'single_choice',
    question: 'Las fibras trepadoras aferentes que terminan directamente en el árbol dendrítico de las células de Purkinje se originan exclusivamente en:',
    options: ['El complejo olivar inferior del bulbo', 'Los núcleos vestibulares', 'Los núcleos del puente'],
    correctIndex: 0,
    rationale: 'Las fibras trepadoras nacen 100% de la oliva bulbar contralateral y tienen una relación monosináptica excitadora potente 1:1 con las células de Purkinje.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Fibras Trepadoras y Complejo Olivar',
    order: 10
  },
  {
    id: 'quiz_t4_cer_11',
    topicId: 'cerebelo_vias_cerebelosas',
    type: 'single_choice',
    question: 'Las fibras musgosas, segundo gran contingente aferente cerebeloso, hacen sinapsis con:',
    options: ['Las células granulosas en los glomérulos cerebelosos', 'Las células de Purkinje directamente', 'Las neuronas del asta anterior'],
    correctIndex: 0,
    rationale: 'Las fibras musgosas excitan a las células de la capa granulosa, cuyos axones ascienden y se bifurcan en "fibras paralelas" en la capa molecular.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Circuito Cortical Cerebeloso',
    order: 11
  },
  {
    id: 'quiz_t4_cer_12',
    topicId: 'cerebelo_vias_cerebelosas',
    type: 'single_choice',
    question: '¿Qué neurotransmisor liberan las células de Purkinje sobre los núcleos profundos del cerebelo?',
    options: ['GABA (ácido gamma-aminobutírico, efecto inhibitorio)', 'Glutamato', 'Dopamina'],
    correctIndex: 0,
    rationale: 'Las células de Purkinje son neuronas gabaérgicas inhibitorias; modulan por inhibición fásica la descarga tónica de los núcleos profundos cerebelosos.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Neuroquímica de la Corteza Cerebelosa',
    order: 12
  },
  {
    id: 'quiz_t4_cer_13',
    topicId: 'cerebelo_vias_cerebelosas',
    type: 'matching',
    question: 'Empareja los pedúnculos cerebelosos con sus vías principales:',
    matchingPairs: [
      { left: 'Pedúnculo cerebeloso superior (brachium conjunctivum)', right: 'Principal vía eferente (haces dentadotalámico y cerebelorrubral)' },
      { left: 'Pedúnculo cerebeloso medio (brachium pontis)', right: 'Vía aferente cortico-ponto-cerebelosa' },
      { left: 'Pedúnculo cerebeloso inferior (cuerpo restiforme)', right: 'Fibras espinocerebelosas dorsales y olivocerebelosas' }
    ],
    options: ['Vías de los pedúnculos cerebelosos'],
    correctIndex: 0,
    rationale: 'Superior es la eferencia principal al tálamo; medio recibe del puente; inferior recibe de médula y bulbo.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Conexiones del Cerebelo',
    order: 13
  },
  {
    id: 'quiz_t4_cer_14',
    topicId: 'cerebelo_vias_cerebelosas',
    type: 'ordering',
    question: 'Ordena de externo a interno las capas histológicas de la corteza del cerebelo:',
    orderingItems: [
      'Capa molecular (células estrelladas y en cesto)',
      'Capa de células de Purkinje',
      'Capa granulosa (células granulares y de Golgi)',
      'Sustancia blanca central (árbol de la vida con núcleos profundos)'
    ],
    options: ['Histología de la corteza cerebelosa'],
    correctIndex: 0,
    rationale: 'Molecular -> Células de Purkinje -> Granulosa -> Sustancia blanca medular.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Capas de la Corteza Cerebelosa',
    order: 14
  },
  {
    id: 'quiz_t4_cer_15',
    topicId: 'cerebelo_vias_cerebelosas',
    type: 'single_choice',
    question: 'La tienda del cerebelo (tentorio) separa el cerebelo de:',
    options: ['Los lóbulos occipitales del cerebro', 'El tronco del encéfalo', 'La médula espinal'],
    correctIndex: 0,
    rationale: 'El tentorio es un tabique horizontal dural que separa la fosa craneal posterior (cerebelo) de la fosa supratentorial (lóbulos occipitales).',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Tienda del Cerebelo',
    order: 15
  },
  {
    id: 'quiz_t4_cer_16',
    topicId: 'cerebelo_vias_cerebelosas',
    type: 'single_choice',
    question: 'El temblor característico de la disfunción cerebelosa se clasifica semiológicamente como:',
    options: ['Temblor de acción o intencional (aumenta al aproximarse al blanco)', 'Temblor de reposo ("cuenta de monedas")', 'Temblor postural fino'],
    correctIndex: 0,
    rationale: 'El temblor cerebeloso es intencional; aparece al ejecutar un movimiento dirigido y se agrava al final de la trayectoria (dismetría).',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Temblor Intencional Cerebeloso',
    order: 16
  },
  {
    id: 'quiz_t4_cer_17',
    topicId: 'cerebelo_vias_cerebelosas',
    type: 'single_choice',
    question: 'Un paciente presenta incapacidad para realizar movimientos alternantes rápidos de pronosupinación en las manos ("prueba de las marionetas" alterada). ¿Cómo se denomina este signo cerebeloso?',
    options: ['Disdiadococinesia (adiadococinesia)', 'Dismetría', 'Asinergia'],
    correctIndex: 0,
    rationale: 'La disdiadococinesia es la dificultad para realizar movimientos alternantes rítmicos y rápidos debido a fallo en la sincronización cerebelosa de agonistas y antagonistas.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Signos Clínicos Cerebelosos',
    order: 17
  },
  {
    id: 'quiz_t4_cer_18',
    topicId: 'cerebelo_vias_cerebelosas',
    type: 'single_choice',
    question: 'La fisura primaria (sulcus primarius) del cerebelo divide el cuerpo del cerebelo en:',
    options: ['Lóbulo anterior y lóbulo posterior', 'Lóbulo floculonodular y lóbulo anterior', 'Vermis y hemisferios'],
    correctIndex: 0,
    rationale: 'La fisura prima es un surco profundo en la cara superior que delimita el lóbulo anterior del lóbulo posterior cerebeloso.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Fisuras del Cerebelo',
    order: 18
  },
  {
    id: 'quiz_t4_cer_19',
    topicId: 'cerebelo_vias_cerebelosas',
    type: 'single_choice',
    question: 'Las alteraciones motoras derivadas de una lesión hemisférica cerebelosa unilateral se manifiestan clínicamente en el cuerpo:',
    options: ['En el mismo lado de la lesión (ipsilaterales)', 'En el lado contralateral opuesto', 'Bilateralmente de forma simétrica'],
    correctIndex: 0,
    rationale: 'A diferencia de la corteza cerebral, el cerebelo controla el hemicuerpo ipsilateral (debido a la doble decusación de las vías eferentes y aferentes).',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Lateralización de los Signos Cerebelosos',
    order: 19
  },
  {
    id: 'quiz_t4_cer_20',
    topicId: 'cerebelo_vias_cerebelosas',
    type: 'single_choice',
    question: 'La arteria cerebelosa anteroinferior (AICA) nace habitualmente de:',
    options: ['La arteria basilar', 'La arteria vertebral', 'La carótida interna'],
    correctIndex: 0,
    rationale: 'La AICA nace de la arteria basilar a nivel del puente e irriga la cara anteroinferior del cerebelo y emite la arteria laberíntica auditiva.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Arterias del Cerebelo',
    order: 20
  }
];

export async function run() {
  await uploadQuizzesBatch(tomo4Part1Quizzes, 'Rouvière Tomo 4 (Bloque A: Temas 1 a 3)');
}
