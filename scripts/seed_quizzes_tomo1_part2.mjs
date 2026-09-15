// Quizzes Clínicos de Anatomía Humana - Rouvière Tomo 1 (Parte 2: Temas 4 a 7)
// 4 Temas x 20 Quizzes = 80 Quizzes
import { uploadQuizzesBatch } from './seed_quizzes_common.mjs';

const tomo1Part2Quizzes = [
  // =========================================================================
  // TEMA 4: musculos_masticacion_cuello (20 QUIZZES)
  // =========================================================================
  {
    id: 'quiz_t1_mus_01',
    topicId: 'musculos_masticacion_cuello',
    type: 'single_choice',
    question: '¿Cuál de los siguientes músculos de la masticación es el principal responsable de la apertura bucal y protrusión mandibular?',
    options: ['Músculo pterigoideo lateral', 'Músculo masetero', 'Músculo temporal'],
    correctIndex: 0,
    rationale: 'El músculo pterigoideo lateral tira de los cóndilos mandibulares y discos articulares hacia adelante, propulsando y deprimiendo la mandíbula (apertura). Masetero y temporal son elevadores.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Músculos Masticadores',
    order: 1
  },
  {
    id: 'quiz_t1_mus_02',
    topicId: 'musculos_masticacion_cuello',
    type: 'single_choice',
    question: 'El músculo esternocleidomastoideo está inervado motoramente por el nervio:',
    options: ['Nervio accesorio (XI par craneal)', 'Nervio hipogloso (XII par craneal)', 'Nervio frénico'],
    correctIndex: 0,
    rationale: 'El músculo ECM y el trapecio reciben su inervación motora principal del nervio accesorio (XI par craneal), complementada sensitivamente por ramos del plexo cervical.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Músculo Esternocleidomastoideo',
    order: 2
  },
  {
    id: 'quiz_t1_mus_03',
    topicId: 'musculos_masticacion_cuello',
    type: 'single_choice',
    question: 'Un recién nacido presenta inclinación de la cabeza hacia la derecha con rotación del mentón hacia la izquierda (tortícolis congénita). ¿Qué músculo se encuentra contracturado o acortado?',
    options: ['Músculo esternocleidomastoideo derecho', 'Músculo esplenio del cuello izquierdo', 'Músculo platisma derecho'],
    correctIndex: 0,
    rationale: 'La contracción unilateral del ECM produce flexión e inclinación homolateral de la cabeza con rotación contralateral de la cara.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Acción del Músculo Esternocleidomastoideo',
    order: 3
  },
  {
    id: 'quiz_t1_mus_04',
    topicId: 'musculos_masticacion_cuello',
    type: 'single_choice',
    question: '¿Qué músculo suprahioideo posee dos vientres unidos por un tendón intermedio que perfora al músculo estilohioideo?',
    options: ['Músculo digástrico', 'Músculo milohioideo', 'Músculo genihioideo'],
    correctIndex: 0,
    rationale: 'El tendón intermedio del músculo digástrico perfora la inserción inferior del músculo estilohioideo antes de unirse al cuerpo del hioides mediante una polea fibrosa.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Músculos Suprahioideos',
    order: 4
  },
  {
    id: 'quiz_t1_mus_05',
    topicId: 'musculos_masticacion_cuello',
    type: 'matching',
    question: 'Relaciona cada músculo infrahioideo con su plano anatómico en el cuello:',
    matchingPairs: [
      { left: 'Esternohioideo y omohioideo', right: 'Plano superficial de los infrahioideos' },
      { left: 'Esternotiroideo y tirohioideo', right: 'Plano profundo de los infrahioideos' },
      { left: 'Músculo platisma', right: 'Tejido celular subcutáneo (fascia superficial)' }
    ],
    options: ['Planos musculares del cuello'],
    correctIndex: 0,
    rationale: 'Los infrahioideos se disponen en superficial (esternohioideo y omohioideo) y profundo (esternotiroideo y tirohioideo).',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Músculos Infrahioideos',
    order: 5
  },
  {
    id: 'quiz_t1_mus_06',
    topicId: 'musculos_masticacion_cuello',
    type: 'ordering',
    question: 'Ordena de anterior a posterior los elementos en el hiato interescalénico en la base del cuello:',
    orderingItems: [
      'Músculo escaleno anterior',
      'Troncos del plexo braquial y arteria subclavia',
      'Músculo escaleno medio',
      'Músculo escaleno posterior'
    ],
    options: ['Secuencia en el hiato interescalénico'],
    correctIndex: 0,
    rationale: 'El hiato interescalénico está limitado por el escaleno anterior por delante y el medio por detrás, transmitiendo la arteria subclavia y el plexo braquial.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Músculos Escalenos',
    order: 6
  },
  {
    id: 'quiz_t1_mus_07',
    topicId: 'musculos_masticacion_cuello',
    type: 'single_choice',
    question: '¿Qué músculo forma el piso muscular de la boca separando la cavidad oral del cuello?',
    options: ['Músculo milohioideo', 'Músculo hiogloso', 'Músculo geniogloso'],
    correctIndex: 0,
    rationale: 'Los dos músculos milohioideos se unen en la línea media en un rafe fibroso para constituir el diafragma muscular del suelo de la boca.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Piso de la Boca',
    order: 7
  },
  {
    id: 'quiz_t1_mus_08',
    topicId: 'musculos_masticacion_cuello',
    type: 'single_choice',
    question: 'El vientre anterior del músculo digástrico y el músculo milohioideo están inervados por:',
    options: ['Nervio milohioideo (rama de V3)', 'Nervio facial (VII)', 'Asa cervical'],
    correctIndex: 0,
    rationale: 'Ambos músculos derivan del 1.er arco faríngeo y son inervados por el nervio milohioideo de V3. El vientre posterior del digástrico deriva del 2.º arco y lo inerva el facial.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Inervación Suprahioidea',
    order: 8
  },
  {
    id: 'quiz_t1_mus_09',
    topicId: 'musculos_masticacion_cuello',
    type: 'single_choice',
    question: 'Durante la cirugía del quiste tirogloso, el cirujano debe resecar la porción media de qué estructura para evitar recidivas (procedimiento de Sistrunk):',
    options: ['Cuerpo del hueso hioides', 'Cartílago tiroides', 'Cartílago cricoides'],
    correctIndex: 0,
    rationale: 'El conducto tirogloso embrionario mantiene estrecha relación con el centro del cuerpo del hueso hioides, por lo que la resección del cuerpo hioideo es obligatoria.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Hueso Hioides',
    order: 9
  },
  {
    id: 'quiz_t1_mus_10',
    topicId: 'musculos_masticacion_cuello',
    type: 'single_choice',
    question: '¿Cuál es la función primordial del músculo cricotiroideo?',
    options: ['Tensar y alargar las cuerdas vocales', 'Abducir las cuerdas vocales', 'Relajar las cuerdas vocales'],
    correctIndex: 0,
    rationale: 'El músculo cricotiroideo tracciona el cartílago tiroides hacia abajo y adelante, tensando los ligamentos vocales (cuerdas vocales verdaderas).',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Laringe y Músculos Laríngeos',
    order: 10
  },
  {
    id: 'quiz_t1_mus_11',
    topicId: 'musculos_masticacion_cuello',
    type: 'single_choice',
    question: 'El músculo buccinador está atravesado perpendicularmente por qué estructura antes de su desembocadura bucal:',
    options: ['Conducto parotídeo (de Stenon)', 'Conducto submandibular (de Wharton)', 'Arteria facial'],
    correctIndex: 0,
    rationale: 'El conducto parotídeo de Stenon cruza el masetero, perfora el buccinador y desemboca a nivel del 2.° molar superior.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Glándula Parótida y Mejilla',
    order: 11
  },
  {
    id: 'quiz_t1_mus_12',
    topicId: 'musculos_masticacion_cuello',
    type: 'single_choice',
    question: 'Los músculos infrahioideos (excepto el tirohioideo) reciben inervación motora a través de:',
    options: ['El asa cervical (asa del hipogloso, C1-C3)', 'El nervio accesorio', 'El nervio facial'],
    correctIndex: 0,
    rationale: 'El asa cervical inerva omohioideo, esternohioideo y esternotiroideo. El tirohioideo recibe inervación directa de fibras de C1 que viajan con el nervio hipogloso.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Asa Cervical',
    order: 12
  },
  {
    id: 'quiz_t1_mus_13',
    topicId: 'musculos_masticacion_cuello',
    type: 'matching',
    question: 'Empareja el músculo con su acción masticatoria principal:',
    matchingPairs: [
      { left: 'Músculo temporal (fibras posteriores)', right: 'Retrusión (retracción) mandibular' },
      { left: 'Músculo pterigoideo medial', right: 'Elevación y cierre mandibular' },
      { left: 'Músculo pterigoideo lateral', right: 'Apertura y diducción (lateralidad)' }
    ],
    options: ['Acciones musculares masticatorias'],
    correctIndex: 0,
    rationale: 'Las fibras posteriores del temporal retraen; el pterigoideo medial eleva fuertemente; el pterigoideo lateral propulsa y lateraliza.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Dinámica Masticatoria',
    order: 13
  },
  {
    id: 'quiz_t1_mus_14',
    topicId: 'musculos_masticacion_cuello',
    type: 'ordering',
    question: 'Ordena de superficial a profundo los planos fasciales y musculares de la cara anterior del cuello:',
    orderingItems: [
      'Piel y músculo platisma (fascia superficial)',
      'Lámina superficial de la fascia cervical profunda (envuelve al ECM)',
      'Lámina pretraqueal (envuelve músculos infrahioideos)',
      'Glándula tiroides y tráquea cervical'
    ],
    options: ['Fascias cervicales'],
    correctIndex: 0,
    rationale: 'Platisma -> Lámina superficial de la fascia cervical profunda -> Lámina pretraqueal -> Compartimento visceral.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Fascias del Cuello',
    order: 14
  },
  {
    id: 'quiz_t1_mus_15',
    topicId: 'musculos_masticacion_cuello',
    type: 'single_choice',
    question: '¿Qué músculo se inserta en el tubérculo de Lisfranc de la primera costilla?',
    options: ['Músculo escaleno anterior', 'Músculo escaleno posterior', 'Músculo subclavio'],
    correctIndex: 0,
    rationale: 'El músculo escaleno anterior se inserta en el tubérculo del escaleno anterior (tubérculo de Lisfranc) en la cara superior de la 1.ª costilla.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Músculos Escalenos',
    order: 15
  },
  {
    id: 'quiz_t1_mus_16',
    topicId: 'musculos_masticacion_cuello',
    type: 'single_choice',
    question: 'El único músculo que abduce (abre) las cuerdas vocales verdaderas es:',
    options: ['Músculo cricoaritenoideo posterior', 'Músculo cricoaritenoideo lateral', 'Músculo tiroaritenoideo'],
    correctIndex: 0,
    rationale: 'El músculo cricoaritenoideo posterior es el único dilatador de la hendidura glótica; su parálisis bilateral causa asfixia aguda.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Músculos Laríngeos Intrínsecos',
    order: 16
  },
  {
    id: 'quiz_t1_mus_17',
    topicId: 'musculos_masticacion_cuello',
    type: 'single_choice',
    question: 'Paciente sometida a tiroidectomía presenta voz bitonal y disfonía. La laringoscopia muestra parálisis de la cuerda vocal izquierda en posición paramediana. ¿Qué nervio fue lesionado?',
    options: ['Nervio laríngeo recurrente izquierdo', 'Nervio laríngeo superior izquierdo', 'Nervio hipogloso'],
    correctIndex: 0,
    rationale: 'El nervio laríngeo recurrente inerva todos los músculos laríngeos intrínsecos excepto el cricotiroideo. Su lesión provoca parálisis de la cuerda vocal homolateral.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Nervio Laríngeo Recurrente',
    order: 17
  },
  {
    id: 'quiz_t1_mus_18',
    topicId: 'musculos_masticacion_cuello',
    type: 'single_choice',
    question: '¿Qué músculo cutáneo de la mímica desciende la comisura labial expresando tristeza o disgusto?',
    options: ['Músculo depresor del ángulo de la boca (triangular de los labios)', 'Músculo cigomático mayor', 'Músculo elevador del labio superior'],
    correctIndex: 0,
    rationale: 'El músculo depresor del ángulo de la boca tracciona inferior y lateralmente la comisura labial.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Músculos Faciales',
    order: 18
  },
  {
    id: 'quiz_t1_mus_19',
    topicId: 'musculos_masticacion_cuello',
    type: 'single_choice',
    question: 'El músculo constrictor superior de la faringe se fija anteriormente en:',
    options: ['El rafe pterigomandibular y el gancho de la pterigoides', 'El asta mayor del hioides', 'La línea oblicua del cartílago tiroides'],
    correctIndex: 0,
    rationale: 'El constrictor superior nace en el gancho pterigoideo, el rafe pterigomandibular y la línea milohioidea mandibular.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Faringe y Músculos Constrictores',
    order: 19
  },
  {
    id: 'quiz_t1_mus_20',
    topicId: 'musculos_masticacion_cuello',
    type: 'single_choice',
    question: 'El tendón del músculo digástrico divide el espacio suprahioideo delimitando:',
    options: ['Triángulo submandibular y triángulo carotídeo', 'Triángulo muscular y triángulo occipital', 'Triángulo submentoniano únicamente'],
    correctIndex: 0,
    rationale: 'Los dos vientres del digástrico delimitan con la mandíbula el triángulo submandibular, y el vientre posterior contribuye a formar el límite anterosuperior del triángulo carotídeo.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Triángulos del Cuello',
    order: 20
  },

  // =========================================================================
  // TEMA 5: vascularizacion_cabeza_cuello (20 QUIZZES)
  // =========================================================================
  {
    id: 'quiz_t1_vas_01',
    topicId: 'vascularizacion_cabeza_cuello',
    type: 'single_choice',
    question: '¿A qué nivel vertebral ocurre comúnmente la bifurcación de la arteria carótida común en carótida externa e interna?',
    options: ['Borde superior del cartílago tiroides (C3-C4)', 'Borde inferior del cartílago cricoides (C6)', 'Nivel del hueso hioides (C2)'],
    correctIndex: 0,
    rationale: 'La bifurcación carotídea tiene lugar a la altura de C3-C4, correspondiente al borde superior del cartílago tiroides.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Arterias Carótidas',
    order: 1
  },
  {
    id: 'quiz_t1_vas_02',
    topicId: 'vascularizacion_cabeza_cuello',
    type: 'single_choice',
    question: '¿Cuál es la primera rama colateral anterior de la arteria carótida externa?',
    options: ['Arteria tiroidea superior', 'Arteria lingual', 'Arteria facial'],
    correctIndex: 0,
    rationale: 'La arteria tiroidea superior es la primera colateral emitida por la cara anterior de la carótida externa en el triángulo carotídeo.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Arteria Carótida Externa',
    order: 2
  },
  {
    id: 'quiz_t1_vas_03',
    topicId: 'vascularizacion_cabeza_cuello',
    type: 'single_choice',
    question: 'Un paciente presenta sangrado nasal masivo (epistaxis anterior). La compresión digital sobre el tabique nasal anterior comprime el plexo de Kiesselbach. ¿Cuál de las siguientes arterias NO contribuye a este plexo?',
    options: ['Arteria carótida interna directamente', 'Arteria labial superior', 'Arteria esfenopalatina'],
    correctIndex: 0,
    rationale: 'El plexo de Kiesselbach lo nutren ramas terminales de la esfenopalatina, etmoidal anterior, palatina mayor y labial superior. La carótida interna nutre solo indirectamente a través de la etmoidal.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Vascularización de las Fosas Nasales',
    order: 3
  },
  {
    id: 'quiz_t1_vas_04',
    topicId: 'vascularizacion_cabeza_cuello',
    type: 'single_choice',
    question: 'El seno carotídeo, receptor barorregulador de la presión arterial, está inervado principalmente por el ramo sinusal del:',
    options: ['Nervio glosofaríngeo (IX)', 'Nervio facial (VII)', 'Nervio vago (X)'],
    correctIndex: 0,
    rationale: 'El nervio del seno carotídeo (nervio de Hering) es un ramo aferente del nervio glosofaríngeo (IX par craneal).',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Seno y Glomo Carotídeo',
    order: 4
  },
  {
    id: 'quiz_t1_vas_05',
    topicId: 'vascularizacion_cabeza_cuello',
    type: 'matching',
    question: 'Relaciona cada rama colateral de la arteria subclavia con su destino anatómico principal:',
    matchingPairs: [
      { left: 'Arteria vertebral', right: 'Asciende por los forámenes transversos hacia el foramen magno' },
      { left: 'Arteria torácica interna', right: 'Desciende posterior a los cartílagos costales para el tórax anterior' },
      { left: 'Tronco tirocervical', right: 'Da la tiroidea inferior, cervical transversa y supraescapular' }
    ],
    options: ['Ramas de la arteria subclavia'],
    correctIndex: 0,
    rationale: 'La vertebral va al cráneo; la torácica interna desciende al tórax; el tirocervical nutre cuello y tiroides inferior.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Arteria Subclavia',
    order: 5
  },
  {
    id: 'quiz_t1_vas_06',
    topicId: 'vascularizacion_cabeza_cuello',
    type: 'ordering',
    question: 'Ordena el flujo venoso desde el cerebro y senos durales hacia la vena cava superior:',
    orderingItems: [
      'Seno sagital superior',
      'Confluencia de los senos (presa de Herófilo)',
      'Seno sigmoideo',
      'Vena yugular interna'
    ],
    options: ['Secuencia de retorno venoso intracraneal'],
    correctIndex: 0,
    rationale: 'El seno sagital drena en la confluencia -> seno transverso -> seno sigmoideo -> vena yugular interna a nivel del foramen yugular.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Senos Venosos de la Duramadre',
    order: 6
  },
  {
    id: 'quiz_t1_vas_07',
    topicId: 'vascularizacion_cabeza_cuello',
    type: 'single_choice',
    question: '¿Qué vena superficial desciende cruzando oblicuamente la cara lateral del músculo esternocleidomastoideo?',
    options: ['Vena yugular externa', 'Vena yugular interna', 'Vena yugular anterior'],
    correctIndex: 0,
    rationale: 'La vena yugular externa cruza oblicuamente sobre la cara lateral del ECM cubierta únicamente por el músculo platisma y la piel.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Venas del Cuello',
    order: 7
  },
  {
    id: 'quiz_t1_vas_08',
    topicId: 'vascularizacion_cabeza_cuello',
    type: 'single_choice',
    question: 'El tronco tirolinguofaringofacial desemboca habitualmente en la vena:',
    options: ['Vena yugular interna', 'Vena yugular externa', 'Vena subclavia'],
    correctIndex: 0,
    rationale: 'El tronco venoso de Farabeuf (tirolinguofaringofacial) es un afluente constante y voluminoso de la vena yugular interna.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Vena Yugular Interna',
    order: 8
  },
  {
    id: 'quiz_t1_vas_09',
    topicId: 'vascularizacion_cabeza_cuello',
    type: 'single_choice',
    question: 'Paciente con forúnculo infectado en el labio superior y la nariz desarrolla cefalea intensa, edema palpebral bilateral y oftalmoplejía (trombosis séptica del seno cavernoso). ¿Qué vena anastomótica facial comunicó la infección cutánea con el seno intracraneal?',
    options: ['Vena oftálmica superior (a través de la vena angular)', 'Vena yugular externa', 'Vena tiroidea superior'],
    correctIndex: 0,
    rationale: 'La vena facial se comunica en el ángulo medial del ojo mediante la vena angular con la vena oftálmica superior, la cual drena directamente en el seno cavernoso (triángulo del peligro de la cara).',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Vena Facial y Seno Cavernoso',
    order: 9
  },
  {
    id: 'quiz_t1_vas_10',
    topicId: 'vascularizacion_cabeza_cuello',
    type: 'single_choice',
    question: '¿Cuáles son las dos ramas terminales de la arteria carótida externa dentro de la celda parotídea?',
    options: ['Arteria maxilar y arteria temporal superficial', 'Arteria facial y arteria lingual', 'Arteria meníngea media y arteria oftálmica'],
    correctIndex: 0,
    rationale: 'La carótida externa asciende por detrás de la mandíbula y se bifurca en sus dos ramas terminales: arteria maxilar y arteria temporal superficial.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Bifurcación Terminal de la Carótida Externa',
    order: 10
  },
  {
    id: 'quiz_t1_vas_11',
    topicId: 'vascularizacion_cabeza_cuello',
    type: 'single_choice',
    question: 'El triángulo carotídeo está delimitado por:',
    options: ['Vientre posterior del digástrico, vientre superior del omohioideo y borde anterior del ECM', 'Borde posterior del ECM, trapecio y clavícula', 'Línea media, mandíbula y vientre anterior del digástrico'],
    correctIndex: 0,
    rationale: 'El triángulo carotídeo lo delimitan: borde anterior del ECM (posterior), vientre superior del omohioideo (inferior) y vientre posterior del digástrico (superior).',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Triángulo Carotídeo',
    order: 11
  },
  {
    id: 'quiz_t1_vas_12',
    topicId: 'vascularizacion_cabeza_cuello',
    type: 'single_choice',
    question: 'La arteria facial cruza el borde inferior de la mandíbula en relación inmediata con:',
    options: ['El ángulo anteroinferior del músculo masetero', 'El foramen mentoniano', 'La sínfisis mentoniana'],
    correctIndex: 0,
    rationale: 'La arteria facial contornea el borde inferior mandibular justo por delante del ángulo anteroinferior del músculo masetero, donde es fácilmente palpable.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Arteria Facial',
    order: 12
  },
  {
    id: 'quiz_t1_vas_13',
    topicId: 'vascularizacion_cabeza_cuello',
    type: 'matching',
    question: 'Empareja la arteria de la cabeza con su origen directo:',
    matchingPairs: [
      { left: 'Arteria meníngea media', right: 'Primera porción (mandibular) de la arteria maxilar' },
      { left: 'Arteria laberíntica', right: 'Arteria basilar o arteria cerebelosa anteroinferior' },
      { left: 'Arteria oftálmica', right: 'Porción cerebral de la arteria carótida interna' }
    ],
    options: ['Orígenes arteriales'],
    correctIndex: 0,
    rationale: 'La meníngea media nace de la maxilar; la laberíntica del tronco basilar/AICA; la oftálmica de la carótida interna intracraneal.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Ramas de la Cabeza',
    order: 13
  },
  {
    id: 'quiz_t1_vas_14',
    topicId: 'vascularizacion_cabeza_cuello',
    type: 'ordering',
    question: 'Ordena las colaterales anteriores de la arteria carótida externa según su emergencia cráneo-caudal (desde la más inferior hasta la más superior):',
    orderingItems: [
      'Arteria tiroidea superior',
      'Arteria lingual',
      'Arteria facial',
      'Bifurcación terminal (maxilar y temporal superficial)'
    ],
    options: ['Orden de colaterales carotídeas'],
    correctIndex: 0,
    rationale: 'De caudal a cefálico: Tiroidea superior -> Lingual -> Facial -> Ramas terminales.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Arteria Carótida Externa',
    order: 14
  },
  {
    id: 'quiz_t1_vas_15',
    topicId: 'vascularizacion_cabeza_cuello',
    type: 'single_choice',
    question: '¿Qué arteria acompaña al nervio laríngeo recurrente en el surco traqueoesofágico hacia el polo inferior del tiroides?',
    options: ['Arteria tiroidea inferior', 'Arteria tiroidea superior', 'Arteria carótida interna'],
    correctIndex: 0,
    rationale: 'La arteria tiroidea inferior (del tronco tirocervical) cruza en el cuello en íntima vecindad con el nervio laríngeo recurrente cerca de la cápsula tiroidea.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Glándula Tiroides y sus Vasos',
    order: 15
  },
  {
    id: 'quiz_t1_vas_16',
    topicId: 'vascularizacion_cabeza_cuello',
    type: 'single_choice',
    question: 'El conducto torácico desemboca en el sistema venoso en:',
    options: ['El ángulo yugulosubclavio izquierdo (ángulo de Pirogoff)', 'El ángulo yugulosubclavio derecho', 'La vena cava superior directamente'],
    correctIndex: 0,
    rationale: 'El conducto torácico finaliza formando un cayado que drena en el ángulo yugulosubclavio izquierdo; la gran vena linfática drena en el derecho.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Sistema Linfático Cervical',
    order: 16
  },
  {
    id: 'quiz_t1_vas_17',
    topicId: 'vascularizacion_cabeza_cuello',
    type: 'single_choice',
    question: 'Una paciente de 58 años presenta masa pétrea supraclavicular izquierda (nódulo de Virchow o Troisier). Anatómicamente, este hallazgo alerta sobre metástasis de:',
    options: ['Neoplasia maligna digestiva o abdominal (vía conducto torácico)', 'Cáncer primario de cuero cabelludo occipital', 'Otitis media supurada'],
    correctIndex: 0,
    rationale: 'El ganglio de Virchow (supraclavicular izquierdo) recibe la linfa de vísceras abdominopélvicas conducida por el conducto torácico.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Linfáticos de la Base del Cuello',
    order: 17
  },
  {
    id: 'quiz_t1_vas_18',
    topicId: 'vascularizacion_cabeza_cuello',
    type: 'single_choice',
    question: '¿Qué arteria irriga la duramadre de la fosa craneal anterior penetrando por el foramen etmoidal anterior?',
    options: ['Arteria meníngea anterior (rama de la arteria etmoidal anterior)', 'Arteria meníngea media', 'Arteria meníngea posterior'],
    correctIndex: 0,
    rationale: 'La arteria meníngea anterior nace de la etmoidal anterior (proveniente de la oftálmica) e irriga la duramadre de la fosa craneal anterior.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Arteria Oftálmica y Meninges',
    order: 18
  },
  {
    id: 'quiz_t1_vas_19',
    topicId: 'vascularizacion_cabeza_cuello',
    type: 'single_choice',
    question: 'El seno cavernoso se encuentra situado a ambos lados de:',
    options: ['El cuerpo del hueso esfenoides y la silla turca', 'La porción basilar del occipital', 'La lámina cribosa del etmoides'],
    correctIndex: 0,
    rationale: 'Los senos cavernosos se ubican bilateralmente a los flancos del cuerpo esfenoidal y de la glándula hipofisaria.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Seno Cavernoso',
    order: 19
  },
  {
    id: 'quiz_t1_vas_20',
    topicId: 'vascularizacion_cabeza_cuello',
    type: 'single_choice',
    question: 'La arteria basilar se forma por la confluencia de:',
    options: ['Las dos arterias vertebrales', 'Las dos arterias carótidas internas', 'Las arterias cerebrales medias'],
    correctIndex: 0,
    rationale: 'Las dos arterias vertebrales penetran por el foramen magno y confluyen en el surco basilar del puente para constituir la arteria basilar.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Sistema Vértebro-Basilar',
    order: 20
  },

  // =========================================================================
  // TEMA 6: pares_craneales_inervacion (20 QUIZZES)
  // =========================================================================
  {
    id: 'quiz_t1_par_01',
    topicId: 'pares_craneales_inervacion',
    type: 'single_choice',
    question: '¿Cuál es el único par craneal que emerge de la cara posterior del tronco encefálico?',
    options: ['Nervio troclear (patético, IV)', 'Nervio oculomotor (III)', 'Nervio abducens (VI)'],
    correctIndex: 0,
    rationale: 'El nervio troclear (IV par) es el único con origen aparente en la cara posterior del mesencéfalo, inmediatamente inferior a los colículos inferiores.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Nervio Troclear',
    order: 1
  },
  {
    id: 'quiz_t1_par_02',
    topicId: 'pares_craneales_inervacion',
    type: 'single_choice',
    question: 'El nervio cuerda del tímpano transporta el gusto de los dos tercios anteriores de la lengua y fibras parasimpáticas para las glándulas submandibular y sublingual. ¿A qué nervio se une en la fosa infratemporal?',
    options: ['Nervio lingual (de V3)', 'Nervio bucal', 'Nervio alveolar inferior'],
    correctIndex: 0,
    rationale: 'La cuerda del tímpano (rama del facial, VII) se anastomosa con el nervio lingual (de V3) para alcanzar el ganglio submandibular y la mucosa lingual.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Nervio Facial y Nervio Lingual',
    order: 2
  },
  {
    id: 'quiz_t1_par_03',
    topicId: 'pares_craneales_inervacion',
    type: 'single_choice',
    question: 'Paciente con parálisis de Bell presenta asimetría facial completa, incapacidad para cerrar el ojo izquierdo (lagoftalmos) y desaparición del surco nasogeniano homolateral. ¿Qué par craneal está afectado periféricamente?',
    options: ['Nervio facial (VII)', 'Nervio trigémino (V)', 'Nervio accesorio (XI)'],
    correctIndex: 0,
    rationale: 'El nervio facial proporciona la inervación motora a todos los músculos cutáneos de la mímica facial. Su afección periférica compromete tanto la hemicara superior como la inferior.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Nervio Facial',
    order: 3
  },
  {
    id: 'quiz_t1_par_04',
    topicId: 'pares_craneales_inervacion',
    type: 'single_choice',
    question: '¿Qué nervio craneal emerge del cráneo por el foramen estilomastoideo?',
    options: ['Tronco principal del nervio facial (VII)', 'Nervio glosofaríngeo (IX)', 'Nervio accesorio (XI)'],
    correctIndex: 0,
    rationale: 'El nervio facial sale de la base del cráneo a través del foramen estilomastoideo antes de penetrar en el espesor de la glándula parótida.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Foramen Estilomastoideo',
    order: 4
  },
  {
    id: 'quiz_t1_par_05',
    topicId: 'pares_craneales_inervacion',
    type: 'matching',
    question: 'Relaciona cada músculo extraocular con el par craneal que lo inerva de manera exclusiva:',
    matchingPairs: [
      { left: 'Músculo recto lateral', right: 'Nervio abducens (VI par)' },
      { left: 'Músculo oblicuo superior', right: 'Nervio troclear (IV par)' },
      { left: 'Músculo oblicuo inferior y rectos medial, superior e inferior', right: 'Nervio oculomotor (III par)' }
    ],
    options: ['Inervación de la musculatura extrínseca del ojo'],
    correctIndex: 0,
    rationale: 'Mnemotecnia clásica: RL6 - OS4 - Resto3.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Pares Craneales Motores Oculares',
    order: 5
  },
  {
    id: 'quiz_t1_par_06',
    topicId: 'pares_craneales_inervacion',
    type: 'ordering',
    question: 'Ordena de medial a lateral los elementos contenidos en el foramen yugular (agujero rasgado posterior):',
    orderingItems: [
      'Seno petroso inferior',
      'Nervio glosofaríngeo (IX)',
      'Nervios vago (X) y accesorio (XI)',
      'Bulbo superior de la vena yugular interna'
    ],
    options: ['Compartimentos del foramen yugular'],
    correctIndex: 0,
    rationale: 'El foramen yugular se divide en una pars nervosa anteromedial (IX y seno petroso) y una pars vascular posterolateral (X, XI y golfo de la yugular).',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Foramen Yugular',
    order: 6
  },
  {
    id: 'quiz_t1_par_07',
    topicId: 'pares_craneales_inervacion',
    type: 'single_choice',
    question: 'El reflejo corneal evalúa la aferencia sensitiva de qué nervio y la eferencia motora de cuál otro:',
    options: ['Aferente: Nervio oftálmico (V1) / Eferente: Nervio facial (VII)', 'Aferente: Nervio óptico (II) / Eferente: Nervio oculomotor (III)', 'Aferente: Nervio maxilar (V2) / Eferente: Nervio abducens (VI)'],
    correctIndex: 0,
    rationale: 'La aferencia corneal la conducen las ramas ciliares de V1; el centro se ubica en el tallo cerebral y la eferencia motora va por el VII para el cierre del orbicular de los párpados.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Nervio Trigémino y Reflejos',
    order: 7
  },
  {
    id: 'quiz_t1_par_08',
    topicId: 'pares_craneales_inervacion',
    type: 'single_choice',
    question: '¿Qué nervio suministra inervación sensitiva general y gustativa al tercio posterior de la lengua?',
    options: ['Nervio glosofaríngeo (IX)', 'Nervio lingual (de V3)', 'Nervio hipogloso (XII)'],
    correctIndex: 0,
    rationale: 'El IX par craneal inerva sensorial y sensitivamente el tercio posterior de la lengua (detrás de la V lingual) y los corpúsculos gustativos de las papilas caliciformes.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Nervio Glosofaríngeo',
    order: 8
  },
  {
    id: 'quiz_t1_par_09',
    topicId: 'pares_craneales_inervacion',
    type: 'single_choice',
    question: 'Al pedirle a un paciente que saque la lengua, la punta se desvía visiblemente hacia el lado derecho con atrofia de la hemilengua derecha. ¿Qué nervio se encuentra denervado?',
    options: ['Nervio hipogloso (XII) derecho', 'Nervio glosofaríngeo (IX) izquierdo', 'Nervio lingual derecho'],
    correctIndex: 0,
    rationale: 'En la lesión periférica del nervio hipogloso (XII), la lengua protruida se desvía hacia el lado de la lesión debido a la acción no contrarrestada del geniogloso sano contralateral.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Nervio Hipogloso',
    order: 9
  },
  {
    id: 'quiz_t1_par_10',
    topicId: 'pares_craneales_inervacion',
    type: 'single_choice',
    question: 'El ganglio trigeminal (de Gasser) se aloja en la fosa craneal media sobre:',
    options: ['La fosita o cavum de Meckel en la cara anterosuperior del peñasco temporal', 'La fosa pterigopalatina', 'La fisura orbitaria superior'],
    correctIndex: 0,
    rationale: 'El cavum trigeminal (de Meckel) es un fondo de saco de la duramadre situado en la cara anterosuperior de la porción petrosa del temporal que aloja al ganglio sensitivo de Gasser.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Nervio Trigémino',
    order: 10
  },
  {
    id: 'quiz_t1_par_11',
    topicId: 'pares_craneales_inervacion',
    type: 'single_choice',
    question: '¿Cuál de las tres ramas del nervio trigémino es mixta (sensitiva y motora)?',
    options: ['Nervio mandibular (V3)', 'Nervio oftálmico (V1)', 'Nervio maxilar (V2)'],
    correctIndex: 0,
    rationale: 'V1 y V2 son puramente sensitivos. V3 es mixto: lleva fibras sensitivas y la totalidad de las fibras motoras del trigémino para los músculos masticadores.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Nervio Mandibular',
    order: 11
  },
  {
    id: 'quiz_t1_par_12',
    topicId: 'pares_craneales_inervacion',
    type: 'single_choice',
    question: 'Las fibras parasimpáticas preganglionares para la glándula parótida se originan en el núcleo salival inferior y viajan sucesivamente por el par IX y el nervio:',
    options: ['Nervio petroso menor hacia el ganglio ótico', 'Nervio petroso mayor hacia el ganglio pterigopalatino', 'Nervio cuerda del tímpano'],
    correctIndex: 0,
    rationale: 'La vía secretora parotídea es: Núcleo salival inferior -> IX par -> nervio timpánico -> nervio petroso menor -> ganglio ótico -> nervio auriculotemporal -> glándula parótida.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Inervación Autónoma Cefálica',
    order: 12
  },
  {
    id: 'quiz_t1_par_13',
    topicId: 'pares_craneales_inervacion',
    type: 'matching',
    question: 'Asocia cada ganglio parasimpático cefálico con su órgano o glándula efectora blanco:',
    matchingPairs: [
      { left: 'Ganglio ciliar', right: 'Músculo esfínter de la pupila y músculo ciliar' },
      { left: 'Ganglio pterigopalatino', right: 'Glándula lagrimal y glándulas de la mucosa nasal' },
      { left: 'Ganglio ótico', right: 'Glándula parótida' }
    ],
    options: ['Ganglios parasimpáticos'],
    correctIndex: 0,
    rationale: 'Ciliar (III) -> esfínter pupilar; pterigopalatino (VII) -> glándula lagrimal; ótico (IX) -> glándula parótida.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Sistema Parasimpático Craneal',
    order: 13
  },
  {
    id: 'quiz_t1_par_14',
    topicId: 'pares_craneales_inervacion',
    type: 'ordering',
    question: 'Ordena la emergencia de los ramos terminales del plexo parotídeo del nervio facial de superior a inferior:',
    orderingItems: [
      'Ramos temporales',
      'Ramos cigomáticos',
      'Ramos bucales',
      'Ramos marginal mandibular y cervical'
    ],
    options: ['Ramos de la pata de ganso del facial'],
    correctIndex: 0,
    rationale: 'La dispersión dentro de la parótida es: Temporal -> Cigomático -> Bucal -> Marginal de la mandíbula -> Cervical.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Plexo Intraparotídeo Facial',
    order: 14
  },
  {
    id: 'quiz_t1_par_15',
    topicId: 'pares_craneales_inervacion',
    type: 'single_choice',
    question: '¿Qué nervio proporciona inervación motora al músculo trapecio para la elevación del hombro?',
    options: ['Nervio accesorio (XI par craneal)', 'Nervio torácico largo', 'Nervio dorsal de la escápula'],
    correctIndex: 0,
    rationale: 'El nervio accesorio inerva el ECM y cruza el triángulo posterior del cuello para alcanzar la cara profunda del trapecio.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Nervio Accesorio',
    order: 15
  },
  {
    id: 'quiz_t1_par_16',
    topicId: 'pares_craneales_inervacion',
    type: 'single_choice',
    question: 'El nervio frénico, responsable de la motilidad diafragmática, se origina de las raíces:',
    options: ['C3, C4 y principalmente C5', 'C1, C2 y C3', 'C5, C6 y C7'],
    correctIndex: 0,
    rationale: 'El nervio frénico nace del plexo cervical profundo con aportes de C3, C4 y C5 ("C3, 4, 5 keep the diaphragm alive"). Desciende sobre el escaleno anterior.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Nervio Frénico',
    order: 16
  },
  {
    id: 'quiz_t1_par_17',
    topicId: 'pares_craneales_inervacion',
    type: 'single_choice',
    question: 'Un paciente presenta neuralgia del trigémino con crisis lancinantes disparadas al rozarse el labio superior y la mejilla. ¿Qué división del V par está involucrada?',
    options: ['Nervio maxilar (V2)', 'Nervio oftálmico (V1)', 'Nervio mandibular (V3)'],
    correctIndex: 0,
    rationale: 'El nervio maxilar (V2) conduce la sensibilidad del párpado inferior, la mejilla, el ala de la nariz y el labio superior.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Territorios Sensitivos Faciales',
    order: 17
  },
  {
    id: 'quiz_t1_par_18',
    topicId: 'pares_craneales_inervacion',
    type: 'single_choice',
    question: '¿Qué nervio craneal atraviesa la pared lateral del seno cavernoso en posición más superior?',
    options: ['Nervio oculomotor (III)', 'Nervio troclear (IV)', 'Nervio abducens (VI)'],
    correctIndex: 0,
    rationale: 'En la pared lateral del seno cavernoso, de arriba a abajo, se disponen: III par, IV par, nervio oftálmico (V1) y nervio maxilar (V2). El VI par discurre libre en el interior de la luz vascular.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Relaciones del Seno Cavernoso',
    order: 18
  },
  {
    id: 'quiz_t1_par_19',
    topicId: 'pares_craneales_inervacion',
    type: 'single_choice',
    question: 'El ramo interno del nervio laríngeo superior perfora la membrana tirohioidea acompañado de:',
    options: ['Arteria laríngea superior', 'Arteria tiroidea inferior', 'Vena yugular interna'],
    correctIndex: 0,
    rationale: 'El ramo interno del laríngeo superior perfora la membrana tirohioidea junto con la arteria laríngea superior para dar la sensibilidad a la laringe supraglótica.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Nervio Laríngeo Superior',
    order: 19
  },
  {
    id: 'quiz_t1_par_20',
    topicId: 'pares_craneales_inervacion',
    type: 'single_choice',
    question: 'El asa cervical superficial o asa de Haller se forma por la anastomosis entre:',
    options: ['El nervio cervical transverso y el ramo cervical del facial', 'El nervio frénico y el hipogloso', 'El nervio vago y el simpático'],
    correctIndex: 0,
    rationale: 'El ramo cervical del nervio facial se anastomosa en el cuello con el nervio cervical transverso del plexo cervical superficial formando el asa cervical superficial.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Plexo Cervical Superficial',
    order: 20
  },

  // =========================================================================
  // TEMA 7: visceras_cuello_sentidos (20 QUIZZES)
  // =========================================================================
  {
    id: 'quiz_t1_vis_01',
    topicId: 'visceras_cuello_sentidos',
    type: 'single_choice',
    question: '¿Qué cartílago laríngeo tiene forma de anillo completo con una lámina posterior alta y un arco anterior delgado?',
    options: ['Cartílago cricoides', 'Cartílago tiroides', 'Cartílago epiglótico'],
    correctIndex: 0,
    rationale: 'El cartílago cricoides es el único anillo cartilaginoso completo de la vía aérea respiratoria superior, fundamental para evitar el colapso laríngeo.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Esqueleto Cartilaginoso de la Laringe',
    order: 1
  },
  {
    id: 'quiz_t1_vis_02',
    topicId: 'visceras_cuello_sentidos',
    type: 'single_choice',
    question: 'El istmo de la glándula tiroides cruza habitualmente por delante de cuáles anillos traqueales:',
    options: ['Segundo, tercer y cuarto anillo traqueal', 'Primer anillo traqueal exclusivamente', 'Sexto y séptimo anillo traqueal'],
    correctIndex: 0,
    rationale: 'El istmo tiroideo reposa comúnmente sobre el 2.°, 3.° y 4.° anillo traqueal, delimitando el sitio de seguridad para la traqueostomía formal.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Glándula Tiroides',
    order: 2
  },
  {
    id: 'quiz_t1_vis_03',
    topicId: 'visceras_cuello_sentidos',
    type: 'single_choice',
    question: 'Paciente sometido a tiroidectomía total desarrolla espasmos musculares dolorosos en manos (signo de Trousseau) y contracción peribucal al percutir el nervio facial (signo de Chvostek). ¿Qué estructuras fueron extirpadas o desvascularizadas accidentalmente?',
    options: ['Glándulas paratiroides (hipocalcemia aguda)', 'Glándula submandibular', 'Ganglio estrellado simpático'],
    correctIndex: 0,
    rationale: 'Las cuatro glándulas paratiroides se localizan en la cara posterior de los lóbulos tiroideos y regulan el metabolismo del calcio mediante la paratohormona (PTH).',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Glándulas Paratiroides',
    order: 3
  },
  {
    id: 'quiz_t1_vis_04',
    topicId: 'visceras_cuello_sentidos',
    type: 'single_choice',
    question: 'El conducto auditivo externo óseo y la cavidad timpánica están separados por:',
    options: ['Membrana timpánica', 'Ventana oval', 'Trompa auditiva (de Eustaquio)'],
    correctIndex: 0,
    rationale: 'La membrana timpánica se interpone entre el meato auditivo externo y la cavidad timpánica (oído medio), transmitiendo las vibraciones acústicas al martillo.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Oído Medio',
    order: 4
  },
  {
    id: 'quiz_t1_vis_05',
    topicId: 'visceras_cuello_sentidos',
    type: 'matching',
    question: 'Relaciona cada huesecillo del oído medio con su articulación o inserción clave:',
    matchingPairs: [
      { left: 'Martillo (malleus)', right: 'Manubrio insertado en la membrana timpánica' },
      { left: 'Yunque (incus)', right: 'Articula entre el martillo y la cabeza del estribo' },
      { left: 'Estribo (stapes)', right: 'Base (platina) encajada en la ventana vestibular (oval)' }
    ],
    options: ['Cadena oscicular del oído medio'],
    correctIndex: 0,
    rationale: 'Martillo se fija al tímpano; el yunque interconecta; la platina del estribo sella la ventana oval transmitiendo energía al laberinto.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Cadena de Huesecillos',
    order: 5
  },
  {
    id: 'quiz_t1_vis_06',
    topicId: 'visceras_cuello_sentidos',
    type: 'ordering',
    question: 'Ordena de anterior a posterior las capas de la pared del globo ocular:',
    orderingItems: [
      'Córnea',
      'Cámara anterior y cristalino',
      'Cuerpo vítreo',
      'Retina, coroides y esclera'
    ],
    options: ['Secuencia óptica del globo ocular'],
    correctIndex: 0,
    rationale: 'La luz atraviesa: Córnea -> Cámara anterior/humor acuoso -> Cristalino -> Humor vítreo -> Retina fotorreceptora.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Órgano de la Visión',
    order: 6
  },
  {
    id: 'quiz_t1_vis_07',
    topicId: 'visceras_cuello_sentidos',
    type: 'single_choice',
    question: 'La trompa auditiva (de Eustaquio) comunica la cavidad timpánica con:',
    options: ['La nasofaringe (rinofaringe)', 'La orofaringe', 'La laringofaringe'],
    correctIndex: 0,
    rationale: 'La trompa de Eustaquio equipara presiones abriéndose en la pared lateral de la nasofaringe a nivel del rodete tubárico.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Trompa Auditiva y Nasofaringe',
    order: 7
  },
  {
    id: 'quiz_t1_vis_08',
    topicId: 'visceras_cuello_sentidos',
    type: 'single_choice',
    question: 'El humor acuoso es secretado en la cámara posterior del ojo por:',
    options: ['Los procesos ciliares del cuerpo ciliar', 'La córnea', 'El iris exclusivamente'],
    correctIndex: 0,
    rationale: 'El epitelio de los procesos ciliares secreta activamente el humor acuoso hacia la cámara posterior, fluyendo luego por la pupila a la cámara anterior.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Cuerpo Ciliar y Dinámica del Humor Acuoso',
    order: 8
  },
  {
    id: 'quiz_t1_vis_09',
    topicId: 'visceras_cuello_sentidos',
    type: 'single_choice',
    question: 'Un paciente de 60 años con glaucoma de ángulo cerrado presenta aumento crítico de la presión intraocular. ¿En qué estructura del ángulo iridocorneal se encuentra bloqueada la reabsorción del humor acuoso?',
    options: ['Malla trabecular y conducto de Schlemm (seno venoso escleral)', 'Procesos ciliares', 'Mácula lútea'],
    correctIndex: 0,
    rationale: 'El drenaje del humor acuoso ocurre a través de la red trabecular hacia el conducto de Schlemm en el ángulo iridocorneal.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Ángulo Iridocorneal',
    order: 9
  },
  {
    id: 'quiz_t1_vis_10',
    topicId: 'visceras_cuello_sentidos',
    type: 'single_choice',
    question: 'La hendidura o espacio comprendido entre los dos pliegues vocales verdaderos se denomina:',
    options: ['Glotis (hendidura glótica)', 'Vestíbulo laríngeo', 'Ventrículo laríngeo de Morgagni'],
    correctIndex: 0,
    rationale: 'La glotis es el aparato fonador y comprende las cuerdas vocales verdaderas y el espacio entre ellas (hendidura glótica).',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Cavidad Laríngea',
    order: 10
  },
  {
    id: 'quiz_t1_vis_11',
    topicId: 'visceras_cuello_sentidos',
    type: 'single_choice',
    question: 'El lóbulo piramidal (de Lalouette) de la glándula tiroides es un vestigio embriológico de:',
    options: ['El conducto tirogloso', 'La 1.ª hendidura faríngea', 'El timo cervical'],
    correctIndex: 0,
    rationale: 'El lóbulo piramidal asciende desde el istmo tiroideo hacia el hueso hioides como remanente del conducto tirogloso.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Anatomía Tiroidea',
    order: 11
  },
  {
    id: 'quiz_t1_vis_12',
    topicId: 'visceras_cuello_sentidos',
    type: 'single_choice',
    question: '¿Qué músculo intrínseco del ojo produce la acomodación del cristalino para la visión cercana al contraerse?',
    options: ['Músculo ciliar', 'Músculo dilatador de la pupila', 'Músculo elevador del párpado'],
    correctIndex: 0,
    rationale: 'La contracción del músculo ciliar relaja la zónula de Zinn, permitiendo que el cristalino aumente su curvatura anteroposterior (mayor poder de refracción).',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Acomodación y Cristalino',
    order: 12
  },
  {
    id: 'quiz_t1_vis_13',
    topicId: 'visceras_cuello_sentidos',
    type: 'matching',
    question: 'Empareja la región laríngea con sus límites anatómicos:',
    matchingPairs: [
      { left: 'Supraglotis (vestíbulo)', right: 'Desde el aditus laríngeo hasta los pliegues vestibulares (cuerdas falsas)' },
      { left: 'Glotis', right: 'Pliegues vocales verdaderos y hendidura glótica' },
      { left: 'Infraglotis', right: 'Desde las cuerdas vocales hasta el borde inferior del cricoides' }
    ],
    options: ['Pisos de la laringe'],
    correctIndex: 0,
    rationale: 'La laringe se divide topográficamente en supraglotis, glotis e infraglotis.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, División Topográfica de la Laringe',
    order: 13
  },
  {
    id: 'quiz_t1_vis_14',
    topicId: 'visceras_cuello_sentidos',
    type: 'ordering',
    question: 'Ordena cráneo-caudalmente los cartílagos del esqueleto laríngeo:',
    orderingItems: [
      'Epiglotis',
      'Cartílago tiroides',
      'Cartílagos aritenoides (apoyados en la lámina cricoidea)',
      'Cartílago cricoides'
    ],
    options: ['Secuencia de cartílagos laríngeos'],
    correctIndex: 0,
    rationale: 'Epiglotis (superior) -> Tiroides -> Aritenoides posteriores -> Cricoides (base inferior).',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Laringe',
    order: 14
  },
  {
    id: 'quiz_t1_vis_15',
    topicId: 'visceras_cuello_sentidos',
    type: 'single_choice',
    question: 'El conducto submandibular (de Wharton) desemboca en la cavidad oral a nivel de:',
    options: ['La carúncula sublingual a los lados del frenillo lingual', 'El fondo de saco vestibular superior', 'La fosa amigdalina'],
    correctIndex: 0,
    rationale: 'El conducto de Wharton se abre en la carúncula o papila sublingual, justo lateral a la inserción inferior del frenillo de la lengua.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Glándula Submandibular',
    order: 15
  },
  {
    id: 'quiz_t1_vis_16',
    topicId: 'visceras_cuello_sentidos',
    type: 'single_choice',
    question: 'La fascia alar se interpone en el cuello entre:',
    options: ['La lámina prevertebral y la vaina visceral (espacio retrofaríngeo)', 'El músculo cutáneo y el ECM', 'La glándula tiroides y el esternón'],
    correctIndex: 0,
    rationale: 'La fascia alar subdivide el espacio retrofaríngeo del "espacio de peligro" (danger space), que se extiende hasta el mediastino posterior.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Espacio Retrofaríngeo',
    order: 16
  },
  {
    id: 'quiz_t1_vis_17',
    topicId: 'visceras_cuello_sentidos',
    type: 'single_choice',
    question: 'Un paciente presenta quemazón esofágica tras ingestión accidental de cáusticos. ¿A qué nivel vertebral comienza el esófago cervical continuándose con la faringe?',
    options: ['Borde inferior del cartílago cricoides (C6)', 'Borde superior del tiroides (C4)', 'Nivel de la vértebra prominente (T1)'],
    correctIndex: 0,
    rationale: 'El límite laringofaringe-esófago se ubica en el borde inferior del cricoides a nivel de C6, marcado por el esfínter esofágico superior (músculo cricofaríngeo).',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Esófago Cervical',
    order: 17
  },
  {
    id: 'quiz_t1_vis_18',
    topicId: 'visceras_cuello_sentidos',
    type: 'single_choice',
    question: '¿Qué papilas linguales contienen los corpúsculos gustativos más numerosos y forman la V lingual en el dorso de la lengua?',
    options: ['Papilas circunvaladas (caliciformes)', 'Papilas filiformes', 'Papilas fungiformes'],
    correctIndex: 0,
    rationale: 'Las papilas circunvaladas o caliciformes (de 8 a 12) dibujan la V lingual y poseen abundantes botones gustativos inervados por el par IX.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Lengua y Sentido del Gusto',
    order: 18
  },
  {
    id: 'quiz_t1_vis_19',
    topicId: 'visceras_cuello_sentidos',
    type: 'single_choice',
    question: 'El órgano receptor acústico de Corti se localiza en el laberinto coclear sobre:',
    options: ['La membrana basilar de la rampa coclear', 'La membrana de Reissner', 'La estría vascular'],
    correctIndex: 0,
    rationale: 'El órgano espiral de Corti reposa sobre la membrana basilar en el interior del conducto coclear membranoso del oído interno.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Oído Interno y Cóclea',
    order: 19
  },
  {
    id: 'quiz_t1_vis_20',
    topicId: 'visceras_cuello_sentidos',
    type: 'single_choice',
    question: 'El anillo linfático de Waldeyer está compuesto principalmente por las amígdalas:',
    options: ['Faríngea (adenoidea), tubáricas, palatinas y lingual', 'Tiroidea y paratiroideas', 'Submandibulares y parotídeas'],
    correctIndex: 0,
    rationale: 'El anillo de Waldeyer constituye una barrera inmunológica en la entrada de las vías aerodigestivas formado por las amígdalas faríngea, tubáricas, palatinas y lingual.',
    sourceBook: 'Rouvière - Delmas: Tomo 1, Faringe y Anillo de Waldeyer',
    order: 20
  }
];

export async function run() {
  await uploadQuizzesBatch(tomo1Part2Quizzes, 'Rouvière Tomo 1 (Bloque B: Temas 4 a 7)');
}
