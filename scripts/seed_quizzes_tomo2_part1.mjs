// Quizzes Clínicos de Anatomía Humana - Rouvière Tomo 2 (Tronco: Tórax y Abdomen)
// 6 Temas x 20 Quizzes = 120 Quizzes
import { uploadQuizzesBatch } from './seed_quizzes_common.mjs';

const tomo2Quizzes = [
  // =========================================================================
  // TEMA 1: torax_mediastino_diafragma (20 QUIZZES)
  // =========================================================================
  {
    id: 'quiz_t2_tor_01',
    topicId: 'torax_mediastino_diafragma',
    type: 'single_choice',
    question: '¿A qué nivel vertebral atraviesa la vena cava inferior el diafragma a través de su foramen tendinoso?',
    options: ['T8 (centro tendinoso / espejo de Van Helmont)', 'T10 (hiato muscular)', 'T12 (hiato fibroso aórtico)'],
    correctIndex: 0,
    rationale: 'El orificio de la vena cava inferior se ubica a nivel de T8 en el centro tendinoso del diafragma; al ser tendinoso no sufre constricción con la contracción diafragmática.',
    sourceBook: 'Rouvière - Delmas: Tomo 2 (Tronco), Músculo Diafragma',
    order: 1
  },
  {
    id: 'quiz_t2_tor_02',
    topicId: 'torax_mediastino_diafragma',
    type: 'single_choice',
    question: 'El hiato esofágico del diafragma se ubica a nivel de T10 y está formado habitualmente por fibras procedentes de:',
    options: ['Pilar derecho del diafragma', 'Pilar izquierdo exclusivamente', 'Ligamento arqueado medio'],
    correctIndex: 0,
    rationale: 'El pilar derecho del diafragma emite haces musculares que rodean al esófago a modo de cabestrillo a nivel de T10 junto a los troncos vagales anterior y posterior.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Hiatos Diafragmáticos',
    order: 2
  },
  {
    id: 'quiz_t2_tor_03',
    topicId: 'torax_mediastino_diafragma',
    type: 'case_study',
    question: 'Paciente en sala de urgencias requiere drenaje torácico por hemitórax derecho. El médico realiza la punción sobre el borde superior de la costilla inferior. ¿Por qué razón anatómica?',
    options: ['Para evitar lesionar el paquete vasculonervioso intercostal que discurre en el surco subcostal superior', 'Porque el borde inferior es más ancho', 'Para no pinzar el músculo pectoral mayor'],
    correctIndex: 0,
    rationale: 'El paquete intercostal (Vena, Arteria, Nervio = VAN de arriba a abajo) discurre protegido por el surco costal en el borde inferior de la costilla suprayacente.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Espacio Intercostal',
    order: 3
  },
  {
    id: 'quiz_t2_tor_04',
    topicId: 'torax_mediastino_diafragma',
    type: 'single_choice',
    question: '¿Qué estructura anatómica pasa junto con la aorta por el hiato aórtico diafragmático a nivel de T12?',
    options: ['Conducto torácico', 'Nervio frénico derecho', 'Esófago'],
    correctIndex: 0,
    rationale: 'El hiato aórtico a nivel T12 está delimitado por el ligamento arqueado medio y transmite la aorta torácica y el conducto torácico linfático.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Hiato Aórtico',
    order: 4
  },
  {
    id: 'quiz_t2_tor_05',
    topicId: 'torax_mediastino_diafragma',
    type: 'matching',
    question: 'Relaciona los principales orificios diafragmáticos con su nivel vertebral y contenido:',
    matchingPairs: [
      { left: 'Foramen de la vena cava (T8)', right: 'Vena cava inferior y ramo del nervio frénico derecho' },
      { left: 'Hiato esofágico (T10)', right: 'Esófago y troncos vagales anterior y posterior' },
      { left: 'Hiato aórtico (T12)', right: 'Aorta descendente y conducto torácico' }
    ],
    options: ['Hiatos del diafragma'],
    correctIndex: 0,
    rationale: 'Regla mnemotécnica clásica: Vena Cava (8 letras) = T8, Esófago (10 letras) = T10, Aórtico (12 letras) = T12.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Músculo Diafragma',
    order: 5
  },
  {
    id: 'quiz_t2_tor_06',
    topicId: 'torax_mediastino_diafragma',
    type: 'ordering',
    question: 'Ordena de arriba a abajo los elementos vasculonerviosos del espacio intercostal en el surco subcostal:',
    orderingItems: [
      'Vena intercostal',
      'Arteria intercostal',
      'Nervio intercostal'
    ],
    options: ['Paquete intercostal VAN'],
    correctIndex: 0,
    rationale: 'La disposición constante en el surco costal de superior a inferior es: Vena, Arteria, Nervio (VAN).',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Espacios Intercostales',
    order: 6
  },
  {
    id: 'quiz_t2_tor_07',
    topicId: 'torax_mediastino_diafragma',
    type: 'single_choice',
    question: 'El ángulo esternal (ángulo de Louis) señala el plano transverso del tórax que coincide con:',
    options: ['El disco intervertebral T4-T5 y la bifurcación traqueal (carina)', 'El nivel de C7', 'El nivel de T10 y el hiato esofágico'],
    correctIndex: 0,
    rationale: 'El ángulo de Louis (manubrio-esternal) proyecta hacia T4-T5, marcando el plano horizontal que divide el mediastino superior del inferior y señala la carina traqueal y el inicio del cayado aórtico.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Esternón y Mediastino',
    order: 7
  },
  {
    id: 'quiz_t2_tor_08',
    topicId: 'torax_mediastino_diafragma',
    type: 'single_choice',
    question: '¿Qué mediastino contiene al corazón, el pericardio y las porciones intrapericárdicas de los grandes vasos?',
    options: ['Mediastino medio', 'Mediastino anterior', 'Mediastino posterior'],
    correctIndex: 0,
    rationale: 'El mediastino medio está ocupado centralmente por el saco pericárdico, el corazón y los orígenes de los grandes troncos vasculares.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, División Topográfica del Mediastino',
    order: 8
  },
  {
    id: 'quiz_t2_tor_09',
    topicId: 'torax_mediastino_diafragma',
    type: 'case_study',
    question: 'Lactante con hernia diafragmática congénita de Bochdalek con compromiso pulmonar izquierdo. ¿Por qué orificio embriológico se produce esta hernia posterolateral?',
    options: ['Trígono lumbocostal posterolateral', 'Trígono esternocostal de Larrey / Morgagni', 'Hiato esofágico'],
    correctIndex: 0,
    rationale: 'La hernia de Bochdalek ocurre por defecto del trígono lumbocostal (cierre incompleto de la membrana pleuroperitoneal posterolateral izquierda).',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Diafragma y sus Puntos Débiles',
    order: 9
  },
  {
    id: 'quiz_t2_tor_10',
    topicId: 'torax_mediastino_diafragma',
    type: 'single_choice',
    question: 'La vena ácigos mayor desemboca en la vena cava superior describiendo un arco (cayado de la ácigos) por encima de:',
    options: ['El pedículo pulmonar derecho (bronquio principal derecho)', 'El pedículo pulmonar izquierdo', 'El cayado de la aorta'],
    correctIndex: 0,
    rationale: 'La vena ácigos contornea superiormente el pedículo del pulmón derecho a nivel de T4 para verter su sangre en la cara posterior de la vena cava superior.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Sistema de las Venas Ácigos',
    order: 10
  },
  {
    id: 'quiz_t2_tor_11',
    topicId: 'torax_mediastino_diafragma',
    type: 'single_choice',
    question: '¿Qué nervio desciende por el mediastino anterior por delante de los pedículos pulmonares acompañado por los vasos pericardiofrénicos?',
    options: ['Nervio frénico', 'Nervio vago (X)', 'Cadena simpática torácica'],
    correctIndex: 0,
    rationale: 'El nervio frénico pasa anterior al hilio pulmonar entre la pleura mediastínica y el pericardio, mientras que el vago desciende posterior al hilio.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Nervio Frénico en el Tórax',
    order: 11
  },
  {
    id: 'quiz_t2_tor_12',
    topicId: 'torax_mediastino_diafragma',
    type: 'single_choice',
    question: 'El ligamento arqueado medial del diafragma forma un puente tendinoso sobre el músculo:',
    options: ['Músculo psoas mayor', 'Músculo cuadrado lumbar', 'Músculo recto del abdomen'],
    correctIndex: 0,
    rationale: 'El ligamento arqueado medial cruza por encima del psoas mayor; el ligamento arqueado lateral cabalga sobre el cuadrado lumbar.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Inserciones Diafragmáticas Lumbares',
    order: 12
  },
  {
    id: 'quiz_t2_tor_13',
    topicId: 'torax_mediastino_diafragma',
    type: 'matching',
    question: 'Asocia el compartimento del mediastino con un órgano característico:',
    matchingPairs: [
      { left: 'Mediastino anterior', right: 'Timo o sus restos adiposos y ligamentos esternopericárdicos' },
      { left: 'Mediastino medio', right: 'Corazón y pericardio' },
      { left: 'Mediastino posterior', right: 'Esófago torácico, aorta descendente y conducto torácico' }
    ],
    options: ['Contenido de los compartimentos mediastínicos'],
    correctIndex: 0,
    rationale: 'Anterior: timo; medio: corazón/pericardio; posterior: esófago, aorta y conducto torácico.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Mediastino',
    order: 13
  },
  {
    id: 'quiz_t2_tor_14',
    topicId: 'torax_mediastino_diafragma',
    type: 'ordering',
    question: 'Ordena las costillas según su clasificación anatómica de cefálico a caudal:',
    orderingItems: [
      'Costillas verdaderas (1.ª a 7.ª costilla, con cartílago directo al esternón)',
      'Costillas falsas (8.ª, 9.ª y 10.ª costilla, unidas al cartílago supra)',
      'Costillas flotantes (11.ª y 12.ª costilla, libres sin cartílago anterior)'
    ],
    options: ['Clasificación costal'],
    correctIndex: 0,
    rationale: '1-7 son verdaderas; 8-10 son falsas o vertebrocondrales; 11-12 son flotantes o vertebrales libres.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Jaula Torácica',
    order: 14
  },
  {
    id: 'quiz_t2_tor_15',
    topicId: 'torax_mediastino_diafragma',
    type: 'single_choice',
    question: '¿Qué arteria nutre la cara anterior de la pared torácica y origina las arterias epigástrica superior y musculofrénica?',
    options: ['Arteria torácica interna (mamaria interna)', 'Arteria torácica lateral', 'Arteria aorta'],
    correctIndex: 0,
    rationale: 'La arteria torácica interna (rama de la subclavia) desciende a 1 cm del borde esternal y se bifurca en el 6.° espacio intercostal en epigástrica superior y musculofrénica.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Arteria Torácica Interna',
    order: 15
  },
  {
    id: 'quiz_t2_tor_16',
    topicId: 'torax_mediastino_diafragma',
    type: 'single_choice',
    question: 'El músculo triangular del esternón (transverso del tórax) se sitúa en:',
    options: ['La cara posterior del plastrón esternocostal (dentro del tórax)', 'La cara anterior superficial del esternón', 'El orificio superior del tórax'],
    correctIndex: 0,
    rationale: 'El transverso del tórax tapiza la cara endotorácica del esternón y cartílagos costales; la arteria torácica interna desciende anterior a él.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Pared Torácica Anterior',
    order: 16
  },
  {
    id: 'quiz_t2_tor_17',
    topicId: 'torax_mediastino_diafragma',
    type: 'case_study',
    question: 'Un paciente sufre herida por arma de fuego que lesiona el nervio laríngeo recurrente izquierdo en el mediastino superior. ¿Alrededor de qué estructura vascular dobla este nervio?',
    options: ['Cayado de la aorta (inmediatamente lateral al ligamento arterioso)', 'Arteria subclavia derecha', 'Vena cava superior'],
    correctIndex: 0,
    rationale: 'El nervio laríngeo recurrente izquierdo se origina del vago izquierdo y describe su asa rodeando por debajo al cayado aórtico, lateral al ligamento arterioso.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Nervio Vago y Recurrente Izquierdo',
    order: 17
  },
  {
    id: 'quiz_t2_tor_18',
    topicId: 'torax_mediastino_diafragma',
    type: 'single_choice',
    question: '¿Qué elemento atraviesa el hiato de Larrey (triángulo esternocostal anterior)?',
    options: ['Vasos epigástricos superiores', 'Nervio vago', 'Arteria aorta'],
    correctIndex: 0,
    rationale: 'El hiato de Larrey o trígono esternocostal da paso a la arteria epigástrica superior y venas satélites hacia la vaina de los rectos abdominales.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Hiatos Menores del Diafragma',
    order: 18
  },
  {
    id: 'quiz_t2_tor_19',
    topicId: 'torax_mediastino_diafragma',
    type: 'single_choice',
    question: 'La articulación manubrioesternal en el adulto joven se clasifica como:',
    options: ['Sínfisis (anfiartrosis con fibrocartílago)', 'Sinovial plana', 'Gonfosis'],
    correctIndex: 0,
    rationale: 'La articulación entre el manubrio y el cuerpo del esternón es una sínfisis cartilaginosa secundaria que frecuentemente se osifica en la vejez.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Articulaciones del Esternón',
    order: 19
  },
  {
    id: 'quiz_t2_tor_20',
    topicId: 'torax_mediastino_diafragma',
    type: 'single_choice',
    question: 'Los nervios esplácnicos mayor, menor e imo nacen de los ganglios simpáticos torácicos y atraviesan el diafragma a través de:',
    options: ['Los pilares principales del diafragma', 'El hiato esofágico', 'El foramen de la vena cava'],
    correctIndex: 0,
    rationale: 'Los nervios esplácnicos torácicos perforan los pilares del diafragma para alcanzar los ganglios del plexo celíaco en el abdomen superior.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Inervación Simpática y Diafragma',
    order: 20
  },

  // =========================================================================
  // TEMA 2: respiratorio_pulmones_pleuras (20 QUIZZES)
  // =========================================================================
  {
    id: 'quiz_t2_res_01',
    topicId: 'respiratorio_pulmones_pleuras',
    type: 'single_choice',
    question: '¿Cuántos lóbulos y fisuras posee normalmente el pulmón derecho en comparación con el pulmón izquierdo?',
    options: ['Pulmón derecho: 3 lóbulos y 2 fisuras / Pulmón izquierdo: 2 lóbulos y 1 fisura', 'Pulmón derecho: 2 lóbulos / Pulmón izquierdo: 3 lóbulos', 'Ambos pulmones tienen 3 lóbulos idénticos'],
    correctIndex: 0,
    rationale: 'El pulmón derecho tiene 3 lóbulos (superior, medio e inferior) separados por la fisura oblicua y la fisura horizontal. El izquierdo tiene 2 lóbulos separados por una sola fisura oblicua.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Pulmones y Fisuras Interlobares',
    order: 1
  },
  {
    id: 'quiz_t2_res_02',
    topicId: 'respiratorio_pulmones_pleuras',
    type: 'single_choice',
    question: 'La língula del pulmón es una proyección anatómica del lóbulo superior de:',
    options: ['El pulmón izquierdo (equivalente al lóbulo medio)', 'El pulmón derecho', 'Ambos pulmones por igual'],
    correctIndex: 0,
    rationale: 'La língula es una lengüeta del lóbulo superior del pulmón izquierdo situada por debajo de la incisura cardíaca, homóloga al lóbulo medio derecho.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Pulmón Izquierdo',
    order: 2
  },
  {
    id: 'quiz_t2_res_03',
    topicId: 'respiratorio_pulmones_pleuras',
    type: 'case_study',
    question: 'Un niño de 3 años aspira un maní jugando. ¿Hacia qué bronquio principal tiene mayor probabilidad de alojarse el cuerpo extraño por razones anatómicas?',
    options: ['Bronquio principal derecho (más vertical, más corto y más ancho)', 'Bronquio principal izquierdo (más horizontal)', 'Hacia la tráquea cervical exclusivamente'],
    correctIndex: 0,
    rationale: 'El bronquio principal derecho es más ancho, más corto (2.5 cm vs 5 cm) y discurre casi en línea recta con la tráquea (más vertical), facilitando la aspiración.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Árbol Traqueobronquial',
    order: 3
  },
  {
    id: 'quiz_t2_res_04',
    topicId: 'respiratorio_pulmones_pleuras',
    type: 'single_choice',
    question: 'El receso pleural más profundo y dependiente de la gravedad en posición erguida es:',
    options: ['Receso costodiafragmático', 'Receso costomediastínico', 'Receso frenicomediastínico'],
    correctIndex: 0,
    rationale: 'El receso o seno costodiafragmático es el fondo de saco pleural posteroinferior más declive, donde se acumulan los primeros 200-300 ml de derrame pleural.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Pleuras y Recesos Pleurales',
    order: 4
  },
  {
    id: 'quiz_t2_res_05',
    topicId: 'respiratorio_pulmones_pleuras',
    type: 'matching',
    question: 'Relaciona la disposición anatómica de los elementos en el hilio pulmonar de anterior a posterior:',
    matchingPairs: [
      { left: 'Elemento más anterior en ambos hilios', right: 'Vena pulmonar superior' },
      { left: 'Elemento intermedio', right: 'Arteria pulmonar' },
      { left: 'Elemento más posterior en ambos hilios', right: 'Bronquio principal' }
    ],
    options: ['Secuencia anteroposterior del hilio'],
    correctIndex: 0,
    rationale: 'En ambos hilios de adelante hacia atrás la secuencia constante es: Vena pulmonar -> Arteria pulmonar -> Bronquio principal (V-A-B).',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Hilios Pulmonares',
    order: 5
  },
  {
    id: 'quiz_t2_res_06',
    topicId: 'respiratorio_pulmones_pleuras',
    type: 'ordering',
    question: 'Ordena la ramificación de la vía aérea desde la tráquea hasta el intercambio gaseoso:',
    orderingItems: [
      'Tráquea y bronquios principales',
      'Bronquios lobares (secundarios)',
      'Bronquios segmentarios (terciarios)',
      'Bronquiolos y alvéolos pulmonares'
    ],
    options: ['Jerarquía de la vía respiratoria'],
    correctIndex: 0,
    rationale: 'Tráquea -> Bronquios principales -> Bronquios lobares -> Bronquios segmentarios -> Bronquiolos -> Alvéolos.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Árbol Bronquial',
    order: 6
  },
  {
    id: 'quiz_t2_res_07',
    topicId: 'respiratorio_pulmones_pleuras',
    type: 'single_choice',
    question: 'El ligamento pulmonar (ligamento triangular) se forma por la prolongación inferior de:',
    options: ['El manguito pleural alrededor del pedículo pulmonar', 'La fascia endotorácica', 'El ligamento arterioso'],
    correctIndex: 0,
    rationale: 'El ligamento pulmonar es un repliegue bilaminar de la pleura que desciende verticalmente desde el hilio pulmonar hacia el diafragma.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Pleura y Ligamento Pulmonar',
    order: 7
  },
  {
    id: 'quiz_t2_res_08',
    topicId: 'respiratorio_pulmones_pleuras',
    type: 'single_choice',
    question: '¿Cuántos segmentos broncopulmonares existen habitualmente en cada pulmón?',
    options: ['10 en el pulmón derecho y típicamente 8 a 10 en el izquierdo', '5 en cada pulmón', '15 en cada pulmón'],
    correctIndex: 0,
    rationale: 'El pulmón derecho presenta 10 segmentos anatómicos definidos; el pulmón izquierdo suele fusionar algunos dando entre 8 y 10 segmentos.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Segmentación Broncopulmonar',
    order: 8
  },
  {
    id: 'quiz_t2_res_09',
    topicId: 'respiratorio_pulmones_pleuras',
    type: 'case_study',
    question: 'Paciente con neumotórax a tensión en hemitórax derecho con shock obstructivo por colapso venoso central. ¿Hacia dónde se desvían el mediastino y la tráquea?',
    options: ['Hacia el lado contralateral (hacia la izquierda)', 'Hacia el mismo lado de la lesión (derecha)', 'Permanecen fijos en la línea media'],
    correctIndex: 0,
    rationale: 'La hiperpresión intrapleural en el neumotórax a tensión empuja masivamente el mediastino, el corazón y la tráquea hacia el lado contralateral sano.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Dinámica de las Presiones Pleurales',
    order: 9
  },
  {
    id: 'quiz_t2_res_10',
    topicId: 'respiratorio_pulmones_pleuras',
    type: 'single_choice',
    question: 'Las arterias bronquiales encargadas de la irrigación nutricia del tejido pulmonar proceden habitualmente de:',
    options: ['La aorta torácica descendente', 'La arteria pulmonar principal', 'Las arterias coronarias'],
    correctIndex: 0,
    rationale: 'La irrigación nutricia (oxigenada) del estroma pulmonar procede de las arterias bronquiales nacidas de la aorta torácica. La arteria pulmonar cumple función funcional.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Vascularización Pulmonar Nutricia y Funcional',
    order: 10
  },
  {
    id: 'quiz_t2_res_11',
    topicId: 'respiratorio_pulmones_pleuras',
    type: 'single_choice',
    question: '¿Qué pleura es insensible al dolor debido a que carece de terminaciones para dolor somático?',
    options: ['Pleura visceral', 'Pleura parietal costal', 'Pleura parietal diafragmática'],
    correctIndex: 0,
    rationale: 'La pleura visceral carece de inervación para dolor somático; el dolor torácico pleurítico sólo ocurre cuando se inflama la pleura parietal (inervada por nervios intercostales y frénicos).',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Inervación Pleural',
    order: 11
  },
  {
    id: 'quiz_t2_res_12',
    topicId: 'respiratorio_pulmones_pleuras',
    type: 'single_choice',
    question: 'La cúpula pleural sobrepasa el orificio superior del tórax ascendiendo hasta:',
    options: ['2 a 3 cm por encima del tercio medial de la clavícula (base del cuello)', 'El borde superior del cartílago tiroides', 'El nivel de C3'],
    correctIndex: 0,
    rationale: 'La cúpula pleural sobresale 2 a 3 cm por encima de la primera costilla y tercio medial clavicular hacia el hueco supraclavicular.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Cúpula Pleural y Fosa Supraclavicular',
    order: 12
  },
  {
    id: 'quiz_t2_res_13',
    topicId: 'respiratorio_pulmones_pleuras',
    type: 'matching',
    question: 'Empareja el segmento broncopulmonar con su correspondiente lóbulo en el pulmón derecho:',
    matchingPairs: [
      { left: 'Segmento apical, posterior y anterior', right: 'Lóbulo superior derecho' },
      { left: 'Segmento lateral y medial', right: 'Lóbulo medio derecho' },
      { left: 'Segmento apical de Nelson y basales', right: 'Lóbulo inferior derecho' }
    ],
    options: ['Lóbulos y segmentos del pulmón derecho'],
    correctIndex: 0,
    rationale: 'Lóbulo superior: S1, S2, S3; lóbulo medio: S4, S5; lóbulo inferior: S6 a S10.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Segmentación Pulmonar Derecha',
    order: 13
  },
  {
    id: 'quiz_t2_res_14',
    topicId: 'respiratorio_pulmones_pleuras',
    type: 'ordering',
    question: 'Ordena de cefálico a caudal la proyección esternal de la pleura y el pulmón en la línea medioclavicular:',
    orderingItems: [
      'Cúpula pleural (supraclavicular)',
      'Borde inferior del pulmón (6.ª costilla)',
      'Borde inferior de la pleura parietal (8.ª costilla)'
    ],
    options: ['Niveles de reflexión pleural anterior'],
    correctIndex: 0,
    rationale: 'En línea medioclavicular: pulmón termina en 6.ª costilla, pleura en la 8.ª (dejando el receso costodiafragmático).',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Topografía Toracopulmonar',
    order: 14
  },
  {
    id: 'quiz_t2_res_15',
    topicId: 'respiratorio_pulmones_pleuras',
    type: 'single_choice',
    question: 'El bronquio lobar superior derecho nace antes de ingresar al parénquima, por lo que se denomina históricamente:',
    options: ['Bronquio epiarterial', 'Bronquio hipoarterial', 'Bronquio segmentario lingular'],
    correctIndex: 0,
    rationale: 'En el pulmón derecho, el bronquio lobar superior se ubica por encima de la arteria pulmonar (epiarterial); a la izquierda la arteria cabalga sobre el bronquio.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Pedículos Pulmonares',
    order: 15
  },
  {
    id: 'quiz_t2_res_16',
    topicId: 'respiratorio_pulmones_pleuras',
    type: 'single_choice',
    question: 'La carina traqueal es una cresta cartilaginosa interna ubicada en:',
    options: ['La bifurcación traqueal a nivel de T4-T5', 'El cartílago cricoides', 'El hilio del pulmón'],
    correctIndex: 0,
    rationale: 'La carina separa el ostium de ambos bronquios principales en la luz traqueal inferior y posee un reflejo tusígeno de máxima sensibilidad.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Tráquea',
    order: 16
  },
  {
    id: 'quiz_t2_res_17',
    topicId: 'respiratorio_pulmones_pleuras',
    type: 'case_study',
    question: 'Un paciente presenta neumonía del segmento apical del lóbulo inferior (segmento de Nelson o S6). ¿En qué parte del dorso se ausculta con mayor nitidez este segmento?',
    options: ['En la región interescapular media a la altura de T4-T6', 'En la base axilar anterior', 'En el hueco supraclavicular'],
    correctIndex: 0,
    rationale: 'El segmento superior del lóbulo inferior (S6 o de Fowler/Nelson) ocupa la parte más alta del lóbulo inferior y se ausculta en la región interescapulovertebral.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Topografía Auscultatoria Pulmonar',
    order: 17
  },
  {
    id: 'quiz_t2_res_18',
    topicId: 'respiratorio_pulmones_pleuras',
    type: 'single_choice',
    question: '¿Cuántas venas pulmonares desembocan comúnmente en la aurícula izquierda llevando sangre oxigenada?',
    options: ['4 venas pulmonares (dos derechas y dos izquierdas)', '2 venas pulmonares', '1 vena pulmonar común'],
    correctIndex: 0,
    rationale: 'Las venas pulmonares son cuatro (superior derecha, inferior derecha, superior izquierda e inferior izquierda) y drenan en la aurícula izquierda.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Venas Pulmonares',
    order: 18
  },
  {
    id: 'quiz_t2_res_19',
    topicId: 'respiratorio_pulmones_pleuras',
    type: 'single_choice',
    question: 'La membrana suprapleural (fascia de Sibson) refuerza la cúpula pleural insertándose en:',
    options: ['La apófisis transversa de C7 y el borde interno de la 1.ª costilla', 'El manubrio del esternón', 'El cartílago tiroides'],
    correctIndex: 0,
    rationale: 'La fascia de Sibson (aparato suspensorio de la pleura) se fija en la apófisis transversa de C7 y la primera costilla, protegiendo el vértice pulmonar.',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Cúpula Pleural',
    order: 19
  },
  {
    id: 'quiz_t2_res_20',
    topicId: 'respiratorio_pulmones_pleuras',
    type: 'single_choice',
    question: 'El plexo pulmonar autónomo está integrado por fibras de:',
    options: ['Nervios vagos (X) y cadena simpática torácica', 'Nervio frénico exclusivamente', 'Nervios intercostales únicamente'],
    correctIndex: 0,
    rationale: 'El plexo pulmonar anterior y posterior lo constituyen ramas del vago (parasimpático, broncoconstrictor) y de la cadena simpática (broncodilatador).',
    sourceBook: 'Rouvière - Delmas: Tomo 2, Inervación Autónoma Pulmonar',
    order: 20
  }
];

export async function run() {
  await uploadQuizzesBatch(tomo2Quizzes, 'Rouvière Tomo 2 (Bloque A: Temas 1 y 2)');
}
