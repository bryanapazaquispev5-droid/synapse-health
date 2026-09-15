// Banco Masivo de Quizzes Clínicos de Anatomía Humana (Rouvière Tomos 1 a 4)
// Total: 48 Quizzes de alta rentabilidad clínica.
// Formato: 3 Alternativas estrictas (A, B, C), UNA sola respuesta correcta por pregunta.
// Tipos: 'single_choice' (Selección Simple), 'matching' (Para Relacionar), 'ordering' (Para Ordenar).
// Relaciones estrictamente 1:N (Cero relaciones Muchos a Muchos).

const BASE_URL = 'https://firestore.googleapis.com/v1/projects/synapse-health/databases/(default)/documents';

async function setDocument(path, fields) {
  const url = `${BASE_URL}/${path}`;
  const formattedFields = {};

  for (const [key, value] of Object.entries(fields)) {
    if (typeof value === 'string') {
      formattedFields[key] = { stringValue: value };
    } else if (typeof value === 'number') {
      formattedFields[key] = { integerValue: value.toString() };
    } else if (typeof value === 'boolean') {
      formattedFields[key] = { booleanValue: value };
    } else if (Array.isArray(value)) {
      formattedFields[key] = {
        arrayValue: {
          values: value.map(item => {
            if (typeof item === 'object' && item !== null) {
              const mapFields = {};
              for (const [k, v] of Object.entries(item)) {
                mapFields[k] = { stringValue: String(v) };
              }
              return { mapValue: { fields: mapFields } };
            }
            return { stringValue: String(item) };
          })
        }
      };
    }
  }

  const res = await fetch(url, {
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ fields: formattedFields })
  });

  if (!res.ok) {
    const errorText = await res.text();
    throw new Error(`Error al guardar ${path}: ${res.status} - ${errorText}`);
  }

  console.log(`✓ ${path}`);
}

const quizzes = [
  // =========================================================================
  // BLOQUE 1: TOMO 1 (CABEZA Y CUELLO) - 12 QUIZZES
  // =========================================================================
  {
    id: 'quiz_t1_01_esfenoides_redondo',
    areaId: 'anatomia',
    topicId: 'osteologia_craneo',
    type: 'single_choice',
    question: '¿Cuál de las siguientes estructuras nerviosas atraviesa el foramen redondo (redondo mayor) del hueso esfenoides?',
    options: [
      'Nervio oftálmico (V1)',
      'Nervio maxilar (V2)',
      'Nervio mandibular (V3)'
    ],
    correctIndex: 1,
    rationale: 'Regla ROSE: El foramen Redondo da paso al nervio maxilar (V2), el foramen Oval al nervio mandibular (V3) y el Espinoso a la arteria meníngea media.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 1 (Cabeza y Cuello)'
  },
  {
    id: 'quiz_t1_02_temporal_relacionar',
    areaId: 'anatomia',
    topicId: 'osteologia_craneo',
    type: 'matching',
    question: 'Relaciona cada orificio del hueso temporal con su elemento anatómico principal:\n1. Meato acústico interno\n2. Foramen estilomastoideo\n3. Conducto carotídeo',
    options: [
      '1: Pares VII, VIII y A. laberíntica | 2: Nervio facial motor | 3: Arteria carótida interna',
      '1: Arteria meníngea media | 2: Nervio hipogloso | 3: Vena yugular interna',
      '1: Nervio maxilar | 2: Arteria auditiva externa | 3: Nervio trigémino'
    ],
    correctIndex: 0,
    matchingPairs: [
      { left: 'Meato acústico interno', right: 'Pares VII, VIII y A. laberíntica' },
      { left: 'Foramen estilomastoideo', right: 'Nervio facial motor' },
      { left: 'Conducto carotídeo', right: 'Arteria carótida interna' }
    ],
    rationale: 'El meato acústico interno conduce los nervios VII, VII bis, VIII y la arteria laberíntica; por el estilomastoideo emerge el tronco motor del facial; y el conducto carotídeo aloja a la carótida interna.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 1 (Cabeza y Cuello)'
  },
  {
    id: 'quiz_t1_03_pterigoideo_lateral_caso',
    areaId: 'anatomia',
    topicId: 'musculos_masticacion_cuello',
    type: 'single_choice',
    question: 'Paciente acude a consulta tras golpe mandibular con incapacidad activa para la apertura de la boca y propulsión hacia adelante. ¿Qué músculo masticador está comprometido?',
    options: [
      'Músculo masetero',
      'Músculo pterigoideo lateral',
      'Músculo temporal'
    ],
    correctIndex: 1,
    rationale: 'El pterigoideo lateral es el único músculo masticador responsable de la propulsión y apertura de la boca. El masetero, temporal y pterigoideo medial son elevadores (cierre de la boca).',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 1 (Cabeza y Cuello)'
  },
  {
    id: 'quiz_t1_04_eje_carotideo_ordenar',
    areaId: 'anatomia',
    topicId: 'vascularizacion_cabeza_cuello',
    type: 'ordering',
    question: 'Ordena de caudal a cefálico (origen a terminación) la trayectoria del sistema carotídeo en el cuello:\n1. Arteria carótida común\n2. Bifurcación carotídea en C4 (seno y glomo carotídeo)\n3. Arterias temporal superficial y maxilar',
    options: [
      '2 -> 1 -> 3',
      '1 -> 2 -> 3',
      '3 -> 1 -> 2'
    ],
    correctIndex: 1,
    orderingItems: [
      'Arteria carótida común',
      'Bifurcación carotídea en C4 (seno y glomo carotídeo)',
      'Arterias temporal superficial y maxilar'
    ],
    rationale: 'La carótida común asciende hasta C4 (borde superior del cartílago tiroides), donde se divide en carótida interna y externa; esta última culmina en la parótida dando la temporal superficial y la maxilar.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 1 (Cabeza y Cuello)'
  },
  {
    id: 'quiz_t1_05_lamina_cribosa_par',
    areaId: 'anatomia',
    topicId: 'osteologia_craneo',
    type: 'single_choice',
    question: '¿Qué par craneal atraviesa los múltiples orificios de la lámina cribosa del hueso etmoides hacia el bulbo correspondiente?',
    options: [
      'Nervio Olfatorio (I par)',
      'Nervio Óptico (II par)',
      'Nervio Oculomotor (III par)'
    ],
    correctIndex: 0,
    rationale: 'Los filetes del nervio olfatorio (I par) son los únicos que atraviesan los orificios de la lámina cribosa del etmoides desde la mucosa olfatoria superior nasal.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 1 (Cabeza y Cuello)'
  },
  {
    id: 'quiz_t1_06_foramen_magno_contenido',
    areaId: 'anatomia',
    topicId: 'osteologia_craneo',
    type: 'single_choice',
    question: '¿Cuál de los siguientes elementos vasculares transita a través del foramen magno del hueso occipital?',
    options: [
      'Arterias carótidas internas',
      'Arterias vertebrales',
      'Arteria meníngea media'
    ],
    correctIndex: 1,
    rationale: 'Las arterias vertebrales ascienden a través de los forámenes transversos cervicales y penetran en la cavidad craneal por el foramen magno para formar la arteria basilar.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 1 (Cabeza y Cuello)'
  },
  {
    id: 'quiz_t1_07_mimica_inervacion',
    areaId: 'anatomia',
    topicId: 'musculos_masticacion_cuello',
    type: 'single_choice',
    question: '¿Qué nervio proporciona la inervación motora a todos los músculos cutáneos de la mímica facial?',
    options: [
      'Nervio Trigémino (V par)',
      'Nervio Facial (VII par)',
      'Nervio Glosofaríngeo (IX par)'
    ],
    correctIndex: 1,
    rationale: 'El nervio Facial (VII par) es el nervio motor del 2.° arco branquial, inervando a todos los músculos de la mímica facial. El trigémino es predominantemente sensitivo en la cara.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 1 (Cabeza y Cuello)'
  },
  {
    id: 'quiz_t1_08_infrahioideos_ordenar',
    areaId: 'anatomia',
    topicId: 'musculos_masticacion_cuello',
    type: 'ordering',
    question: 'Ordena de superficial a profundo los dos planos musculares del grupo infrahioideo:\n1. Plano superficial: Esternohioideo y Omohioideo\n2. Plano profundo: Esternotiroideo y Tirohioideo',
    options: [
      '1 (superficial) y luego 2 (profundo)',
      '2 (superficial) y luego 1 (profundo)',
      'Ambos planos se encuentran al mismo nivel superficial'
    ],
    correctIndex: 0,
    orderingItems: [
      'Plano superficial: Esternohioideo y Omohioideo',
      'Plano profundo: Esternotiroideo y Tirohioideo'
    ],
    rationale: 'En los músculos infrahioideos, el esternohioideo y el vientre superior del omohioideo forman la capa superficial, mientras que el esternotiroideo y tirohioideo yacen inmediatamente por debajo.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 1 (Cabeza y Cuello)'
  },
  {
    id: 'quiz_t1_09_spix_mandibular_caso',
    areaId: 'anatomia',
    topicId: 'osteologia_craneo',
    type: 'single_choice',
    question: 'Un odontólogo busca anestesiar las piezas dentarias mandibulares inferiores antes de una extracción. ¿Qué referencia ósea utiliza para el bloqueo del nervio alveolar inferior?',
    options: [
      'Foramen mentoniano',
      'Espina de Spix (língula mandibular)',
      'Apófisis coronoides'
    ],
    correctIndex: 1,
    rationale: 'La espina de Spix (língula) en la cara interna de la rama ascendente mandibular señala la entrada del conducto mandibular por donde ingresa el nervio alveolar inferior.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 1 (Cabeza y Cuello)'
  },
  {
    id: 'quiz_t1_10_seno_cavernoso_contenido',
    areaId: 'anatomia',
    topicId: 'vascularizacion_cabeza_cuello',
    type: 'single_choice',
    question: '¿Qué par craneal atraviesa la luz central del seno cavernoso en íntima relación lateral con la arteria carótida interna?',
    options: [
      'Nervio Troclear (IV par)',
      'Nervio Abducens (VI par)',
      'Nervio Oculomotor (III par)'
    ],
    correctIndex: 1,
    rationale: 'El nervio Abducens (VI par) y la carótida interna corren directamente por el interior del seno cavernoso; los pares III, IV, V1 y V2 corren en el espesor de su pared lateral.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 1 (Cabeza y Cuello)'
  },
  {
    id: 'quiz_t1_11_laringeo_recurrente_caso',
    areaId: 'anatomia',
    topicId: 'visceras_cuello_sentidos',
    type: 'single_choice',
    question: 'Tras una tiroidectomía total, la paciente presenta voz bitonal y disfonía persistente. ¿Qué estructura nerviosa fue lesionada durante la intervención?',
    options: [
      'Nervio laríngeo superior',
      'Nervio laríngeo recurrente (rama del X par)',
      'Nervio hipogloso (XII par)'
    ],
    correctIndex: 1,
    rationale: 'El nervio laríngeo recurrente corre en el surco traqueoesofágico pegado a la cara posterior de los lóbulos tiroideos; inerva a casi todos los músculos de las cuerdas vocales.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 1 (Cabeza y Cuello)'
  },
  {
    id: 'quiz_t1_12_atm_disco_relacionar',
    areaId: 'anatomia',
    topicId: 'articulaciones_cabeza_cuello',
    type: 'matching',
    question: 'Relaciona los dos compartimentos de la articulación temporomandibular (ATM) con su cinemática:\n1. Compartimento Supradiscal (disco-temporal)\n2. Compartimento Infradiscal (disco-condilar)',
    options: [
      '1: Movimientos de traslación | 2: Movimientos de rotación pura',
      '1: Movimientos de rotación pura | 2: Movimientos de traslación',
      '1: Fijación estática | 2: Movimientos de lateralidad exclusiva'
    ],
    correctIndex: 0,
    matchingPairs: [
      { left: 'Compartimento Supradiscal (disco-temporal)', right: 'Movimientos de traslación' },
      { left: 'Compartimento Infradiscal (disco-condilar)', right: 'Movimientos de rotación pura' }
    ],
    rationale: 'La ATM es bicompartimental: en el compartimento superior o supradiscal el menisco se traslada hacia el tubérculo temporal, y en el inferior o infradiscal el cóndilo rota.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 1 (Cabeza y Cuello)'
  },

  // =========================================================================
  // BLOQUE 2: TOMO 2 (TRONCO: TÓRAX Y ABDOMEN) - 12 QUIZZES
  // =========================================================================
  {
    id: 'quiz_t2_01_hiatos_diafragma_ordenar',
    areaId: 'anatomia',
    topicId: 'torax_mediastino_diafragma',
    type: 'ordering',
    question: 'Ordena de cefálico a caudal el nivel vertebral de los 3 grandes orificios diafragmáticos:',
    options: [
      'Hiato Vena Cava Inferior (T8) -> Hiato Esofágico (T10) -> Hiato Aórtico (T12)',
      'Hiato Aórtico (T8) -> Hiato Esofágico (T10) -> Hiato Vena Cava (T12)',
      'Hiato Esofágico (T8) -> Hiato Vena Cava (T10) -> Hiato Aórtico (T12)'
    ],
    correctIndex: 0,
    orderingItems: [
      'Hiato Vena Cava Inferior (T8)',
      'Hiato Esofágico (T10)',
      'Hiato Aórtico (T12)'
    ],
    rationale: 'Mnemotecnia VEA: Vena Cava (T8 en centro tendinoso), Esófago (T10 en pilar derecho muscular), Aorta (T12 en plano osteofibroso posterior).',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 2 (Tronco)'
  },
  {
    id: 'quiz_t2_02_hernia_hesselbach_caso',
    areaId: 'anatomia',
    topicId: 'pared_abdominal_conducto_inguinal',
    type: 'single_choice',
    question: 'Durante la exploración inguinal, el cirujano evidencia protrusión peritoneal que empuja MEDIAL a los vasos epigástricos inferiores en el triángulo de Hesselbach. ¿Cuál es el diagnóstico?',
    options: [
      'Hernia inguinal indirecta',
      'Hernia inguinal directa',
      'Hernia crural o femoral'
    ],
    correctIndex: 1,
    rationale: 'Regla MD: Medial a los vasos epigástricos es Hernia Directa (por debilidad de fascia transversalis). Las hernias indirectas emergen laterales al anillo profundo.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 2 (Tronco)'
  },
  {
    id: 'quiz_t2_03_papila_duodenal_relacionar',
    areaId: 'anatomia',
    topicId: 'digestivo_abdominal_peritoneo',
    type: 'matching',
    question: 'Relaciona cada ampolla/papila duodenal con los conductos excretores que desembocan en ella:\n1. Papila Duodenal Mayor (Ampolla de Vater)\n2. Papila Duodenal Menor',
    options: [
      '1: Conducto Colédoco y Pancreático Principal (Wirsung) | 2: Conducto Pancreático Accesorio (Santorini)',
      '1: Conducto de Santorini | 2: Conducto de Wirsung y Colédoco',
      '1: Arteria mesentérica superior | 2: Vena porta hepática'
    ],
    correctIndex: 0,
    matchingPairs: [
      { left: 'Papila Duodenal Mayor (Ampolla de Vater)', right: 'Conducto Colédoco y Pancreático Principal (Wirsung)' },
      { left: 'Papila Duodenal Menor', right: 'Conducto Pancreático Accesorio (Santorini)' }
    ],
    rationale: 'En la 2.ª porción duodenal, la papila mayor recibe al colédoco y al conducto de Wirsung regulados por el esfínter de Oddi; la papila menor recibe al accesorio de Santorini 2 cm más arriba.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 2 (Tronco)'
  },
  {
    id: 'quiz_t2_04_triada_portal_ordenar',
    areaId: 'anatomia',
    topicId: 'visceras_retroperitoneo_rinones',
    type: 'ordering',
    question: 'En el ligamento hepatoduodenal (borde libre del omento menor), ¿cómo se disponen de posterior a anterior los elementos del pedículo hepático?',
    options: [
      'Plano posterior: Vena Porta | Plano anterior: Arteria Hepática Propia (izq.) y Colédoco (der.)',
      'Plano posterior: Arteria Hepática Propia | Plano anterior: Vena Porta y Colédoco',
      'Plano posterior: Colédoco | Plano anterior: Vena Cava Inferior y Vena Porta'
    ],
    correctIndex: 0,
    orderingItems: [
      'Plano posterior: Vena Porta',
      'Plano anterior izquierdo: Arteria Hepática Propia',
      'Plano anterior derecho: Conducto Colédoco'
    ],
    rationale: 'Regla VAC: Vena porta atrás, Arteria hepática propia adelante a la izquierda y Conducto colédoco adelante a la derecha.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 2 (Tronco)'
  },
  {
    id: 'quiz_t2_05_bronquio_derecho_aspiracion',
    areaId: 'anatomia',
    topicId: 'respiratorio_pulmones_pleuras',
    type: 'single_choice',
    question: '¿Por qué los cuerpos extraños aspirados accidentalmente suelen alojarse con mayor frecuencia en el árbol bronquial derecho?',
    options: [
      'Porque es más estrecho y horizontal',
      'Porque es más ancho, más corto y más vertical',
      'Porque carece de cartílagos traqueobronquiales'
    ],
    correctIndex: 1,
    rationale: 'El bronquio principal derecho sigue una dirección casi vertical en continuidad con la tráquea y posee mayor calibre, facilitando el paso gravitacional de cuerpos extraños.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 2 (Tronco)'
  },
  {
    id: 'quiz_t2_06_triangulo_koch_nodo',
    areaId: 'anatomia',
    topicId: 'cardiovascular_corazon_pericardio',
    type: 'single_choice',
    question: '¿Qué estructura crucial del sistema cardionector se encuentra ubicada en el vértice del triángulo de Koch en la aurícula derecha?',
    options: [
      'Nodo Sinoauricular (de Keith y Flack)',
      'Nodo Auriculoventricular (de Aschoff-Tawara)',
      'Fibras de Purkinje apicales'
    ],
    correctIndex: 1,
    rationale: 'El nodo auriculoventricular (AV) se localiza en el vértice del triángulo de Koch, delimitado por la valva septal tricúspide, la válvula del seno coronario (Tebesio) y el tendón de Todaro.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 2 (Tronco)'
  },
  {
    id: 'quiz_t2_07_angulolouis_nivel',
    areaId: 'anatomia',
    topicId: 'torax_mediastino_diafragma',
    type: 'single_choice',
    question: '¿A qué nivel del disco intervertebral corresponde el plano transversal trazado desde el ángulo esternal (de Louis)?',
    options: [
      'Disco T1 - T2',
      'Disco T4 - T5',
      'Disco T8 - T9'
    ],
    correctIndex: 1,
    rationale: 'El plano de Louis a nivel T4-T5 divide el mediastino superior del inferior y marca la bifurcación traqueal (carina) y el inicio y fin del arco aórtico.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 2 (Tronco)'
  },
  {
    id: 'quiz_t2_08_taponamiento_beck_caso',
    areaId: 'anatomia',
    topicId: 'cardiovascular_corazon_pericardio',
    type: 'single_choice',
    question: 'Paciente con herida torácica presenta hipotensión arterial, ingurgitación yugular y ruidos cardíacos apagados. ¿Qué cuadro anatómico explica esta tríada de Beck?',
    options: [
      'Neumotórax espontáneo',
      'Taponamiento cardíaco por hemopericardio',
      'Disección aórtica abdominal'
    ],
    correctIndex: 1,
    rationale: 'La acumulación súbita de sangre en la cavidad pericárdica inelástica colapsa las cavidades derechas del corazón, manifestando la tríada clínica de Beck.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 2 (Tronco)'
  },
  {
    id: 'quiz_t2_09_vaina_rectos_douglas',
    areaId: 'anatomia',
    topicId: 'pared_abdominal_conducto_inguinal',
    type: 'single_choice',
    question: '¿Qué estructura forma la pared posterior de la vaina del músculo recto abdominal por debajo de la línea arqueada (arco de Douglas)?',
    options: [
      'La aponeurosis del músculo transverso',
      'Únicamente la fascia transversalis y el peritoneo',
      'El tendón conjunto fusionado'
    ],
    correctIndex: 1,
    rationale: 'Por debajo del arco de Douglas, las aponeurosis de los tres músculos anchos pasan por delante del recto, dejando la cara posterior del músculo apoyada solo en la fascia transversalis.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 2 (Tronco)'
  },
  {
    id: 'quiz_t2_10_hilio_renal_ordenar',
    areaId: 'anatomia',
    topicId: 'visceras_retroperitoneo_rinones',
    type: 'ordering',
    question: 'Ordena de anterior a posterior las estructuras del pedículo que entran o salen del hilio renal:',
    options: [
      'Vena Renal -> Arteria Renal -> Pelvis Renal',
      'Arteria Renal -> Vena Renal -> Pelvis Renal',
      'Pelvis Renal -> Arteria Renal -> Vena Renal'
    ],
    correctIndex: 0,
    orderingItems: [
      'Vena Renal (anterior)',
      'Arteria Renal (intermedia)',
      'Pelvis Renal (posterior)'
    ],
    rationale: 'Mnemotecnia VAP: de adelante hacia atrás se disponen la Vena renal (anterior), Arteria renal (media) y Pelvis renal (posterior).',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 2 (Tronco)'
  },
  {
    id: 'quiz_t2_11_pinza_aortomesenterica_caso',
    areaId: 'anatomia',
    topicId: 'digestivo_abdominal_peritoneo',
    type: 'single_choice',
    question: 'Un paciente presenta obstrucción duodenal alta. Los estudios por imagen revelan compresión de la 3.ª porción duodenal entre la aorta y la arteria mesentérica superior. ¿Cómo se conoce este reparo?',
    options: [
      'Hiato de Winslow',
      'Pinza Aortomesentérica (Síndrome de Wilkie)',
      'Espacio retroinguinal de Bogros'
    ],
    correctIndex: 1,
    rationale: 'La 3.ª porción duodenal cruza horizontalmente por delante de la aorta y por detrás del pedículo mesentérico superior formando la clásica pinza vascular.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 2 (Tronco)'
  },
  {
    id: 'quiz_t2_12_aorta_ramas_relacionar',
    areaId: 'anatomia',
    topicId: 'visceras_retroperitoneo_rinones',
    type: 'matching',
    question: 'Relaciona cada tronco arterial digestivo impar con su nivel vertebral de origen en la aorta abdominal:\n1. Tronco Celíaco\n2. Arteria Mesentérica Superior\n3. Arteria Mesentérica Inferior',
    options: [
      '1: T12 | 2: L1 | 3: L3',
      '1: L1 | 2: L3 | 3: L5',
      '1: T10 | 2: T12 | 3: L2'
    ],
    correctIndex: 0,
    matchingPairs: [
      { left: 'Tronco Celíaco', right: 'Nivel T12 (hiato aórtico)' },
      { left: 'Arteria Mesentérica Superior', right: 'Nivel L1 (retropancreático)' },
      { left: 'Arteria Mesentérica Inferior', right: 'Nivel L3 (subduodenal)' }
    ],
    rationale: 'El tronco celíaco nace a la altura de T12, la arteria mesentérica superior en L1 y la arteria mesentérica inferior en L3.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 2 (Tronco)'
  },

  // =========================================================================
  // BLOQUE 3: TOMO 3 (MIEMBROS: SUPERIOR E INFERIOR) - 12 QUIZZES
  // =========================================================================
  {
    id: 'quiz_t3_01_supraespinoso_abduccion_caso',
    areaId: 'anatomia',
    topicId: 'cintura_escapular_hombro',
    type: 'single_choice',
    question: 'Un paciente presenta dolor agudo en el hombro y es incapaz de iniciar los primeros 15 grados de abducción del brazo. ¿Qué tendón del manguito rotador está lesionado?',
    options: [
      'Tendón del músculo subescapular',
      'Tendón del músculo supraespinoso',
      'Tendón del músculo redondo menor'
    ],
    correctIndex: 1,
    rationale: 'El músculo supraespinoso inicia la abducción del brazo en los primeros 15 grados, tras lo cual el deltoides asume la función principal.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 3 (Miembros)'
  },
  {
    id: 'quiz_t3_02_tunel_carpiano_nervio',
    areaId: 'anatomia',
    topicId: 'muneca_mano_tunel_carpiano',
    type: 'single_choice',
    question: '¿Cuál es la única estructura nerviosa que discurre por dentro del túnel carpiano por debajo del retináculo flexor?',
    options: [
      'Nervio radial',
      'Nervio mediano',
      'Nervio cubital'
    ],
    correctIndex: 1,
    rationale: 'El túnel del carpo contiene 1 nervio (Nervio Mediano) y 9 tendones flexores. El nervio cubital pasa por fuera a través del canal de Guyon.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 3 (Miembros)'
  },
  {
    id: 'quiz_t3_03_triangulo_scarpa_ordenar',
    areaId: 'anatomia',
    topicId: 'cadera_muslo_triangulo_femoral',
    type: 'ordering',
    question: 'En la región inguinal (triángulo femoral de Scarpa), ¿cuál es el orden estricto de LATERAL a MEDIAL de los elementos vasculonerviosos?',
    options: [
      'Nervio Femoral -> Arteria Femoral -> Vena Femoral',
      'Vena Femoral -> Arteria Femoral -> Nervio Femoral',
      'Arteria Femoral -> Nervio Femoral -> Vena Femoral'
    ],
    correctIndex: 0,
    orderingItems: [
      'Nervio Femoral (lateral)',
      'Arteria Femoral (intermedia)',
      'Vena Femoral (medial)'
    ],
    rationale: 'Regla NAV: de afuera hacia adentro en la ingle se hallan el Nervio femoral, la Arteria femoral y la Vena femoral (y los linfáticos mediales en el anillo crural).',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 3 (Miembros)'
  },
  {
    id: 'quiz_t3_04_rodilla_maniobras_relacionar',
    areaId: 'anatomia',
    topicId: 'rodilla_pierna_fosa_poplitea',
    type: 'matching',
    question: 'Relaciona la maniobra diagnóstica de rodilla con la estructura anatómica que valora primordialmente:\n1. Maniobra de Cajón Anterior\n2. Maniobra de Cajón Posterior\n3. Bostezo en valgo forzado',
    options: [
      '1: Ligamento Cruzado Anterior (LCA) | 2: Ligamento Cruzado Posterior (LCP) | 3: Ligamento Colateral Medial',
      '1: Menisco lateral | 2: Tendón rotuliano | 3: Ligamento Cruzado Anterior',
      '1: Ligamento Cruzado Posterior | 2: Ligamento Cruzado Anterior | 3: Menisco medial'
    ],
    correctIndex: 0,
    matchingPairs: [
      { left: 'Maniobra de Cajón Anterior', right: 'Ligamento Cruzado Anterior (LCA)' },
      { left: 'Maniobra de Cajón Posterior', right: 'Ligamento Cruzado Posterior (LCP)' },
      { left: 'Bostezo en valgo forzado', right: 'Ligamento Colateral Medial' }
    ],
    rationale: 'El cajón anterior evalúa el LCA impidiendo el desplazamiento anterior de la tibia; el cajón posterior evalúa el LCP; y la apertura en valgo evalúa el ligamento colateral medial.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 3 (Miembros)'
  },
  {
    id: 'quiz_t3_05_carpo_escafoides_caso',
    areaId: 'anatomia',
    topicId: 'muneca_mano_tunel_carpiano',
    type: 'single_choice',
    question: 'Tras una caída apoyando la palma de la mano en hiperextensión, un joven refiere intenso dolor a la presión en el fondo de la tabaquera anatómica. ¿Qué fractura ósea debe sospecharse?',
    options: [
      'Fractura del hueso piramidal',
      'Fractura del hueso escafoides',
      'Fractura del hueso ganchoso'
    ],
    correctIndex: 1,
    rationale: 'El hueso escafoides conforma el suelo de la tabaquera anatómica y es el hueso del carpo que más se fractura en caídas sobre la mano extendida.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 3 (Miembros)'
  },
  {
    id: 'quiz_t3_06_trendelenburg_gluteo',
    areaId: 'anatomia',
    topicId: 'cadera_muslo_triangulo_femoral',
    type: 'single_choice',
    question: 'La marcha de Trendelenburg (caída de la pelvis contralateral durante el apoyo monopodal) se produce por parálisis o insuficiencia de qué músculo:',
    options: [
      'Músculo glúteo mayor',
      'Músculo glúteo medio (inervado por el nervio glúteo superior)',
      'Músculo psoas ilíaco'
    ],
    correctIndex: 1,
    rationale: 'El glúteo medio es el principal abductor y estabilizador horizontal de la pelvis; al fallar en el miembro de apoyo, la pelvis cae hacia el lado contralateral opuesto.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 3 (Miembros)'
  },
  {
    id: 'quiz_t3_07_rombo_popliteo_ordenar',
    areaId: 'anatomia',
    topicId: 'rodilla_pierna_fosa_poplitea',
    type: 'ordering',
    question: 'En la fosa poplítea (hueco poplíteo), ¿cómo se disponen de superficial a profundo los elementos neurovasculares mayores?',
    options: [
      'Nervio Tibial -> Vena Poplítea -> Arteria Poplítea (apoyada en el hueso)',
      'Arteria Poplítea -> Vena Poplítea -> Nervio Tibial',
      'Vena Poplítea -> Arteria Poplítea -> Nervio Tibial'
    ],
    correctIndex: 0,
    orderingItems: [
      'Nervio Tibial (superficial)',
      'Vena Poplítea (intermedia)',
      'Arteria Poplítea (profunda)'
    ],
    rationale: 'Regla NVA de superficial a profundo: el nervio tibial es el más superficial, la vena poplítea es intermedia y la arteria poplítea es la más profunda en contacto con el fémur.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 3 (Miembros)'
  },
  {
    id: 'quiz_t3_08_pie_caido_peroneo_caso',
    areaId: 'anatomia',
    topicId: 'rodilla_pierna_fosa_poplitea',
    type: 'single_choice',
    question: 'Un paciente sufre una fractura a nivel del cuello del peroné y desarrolla marcha en estepaje (pie caído, con incapacidad para la flexión dorsal). ¿Qué nervio resultó lesionado?',
    options: [
      'Nervio Tibial posterior',
      'Nervio Peroneo Común (ciático poplíteo externo)',
      'Nervio Safeno'
    ],
    correctIndex: 1,
    rationale: 'El nervio peroneo común rodea íntimamente el cuello del peroné; al lesionarse se paralizan los músculos del compartimento anterior y lateral produciendo pie péndulo.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 3 (Miembros)'
  },
  {
    id: 'quiz_t3_09_carpo_ordenar_filas',
    areaId: 'anatomia',
    topicId: 'muneca_mano_tunel_carpiano',
    type: 'ordering',
    question: 'Ordena de lateral a medial los 4 huesos que componen la fila proximal del carpo:',
    options: [
      'Escafoides -> Semilunar -> Piramidal -> Pisiforme',
      'Trapecio -> Trapezoide -> Grande -> Ganchoso',
      'Pisiforme -> Piramidal -> Semilunar -> Escafoides'
    ],
    correctIndex: 0,
    orderingItems: [
      'Hueso Escafoides (lateral)',
      'Hueso Semilunar',
      'Hueso Piramidal',
      'Hueso Pisiforme (medial)'
    ],
    rationale: 'Mnemotecnia Es-Se-Pi-Pi: Escafoides, Semilunar, Piramidal y Pisiforme de radial a cubital en la fila proximal.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 3 (Miembros)'
  },
  {
    id: 'quiz_t3_10_esguince_tobillo_ligamento',
    areaId: 'anatomia',
    topicId: 'tobillo_pie_arcos_plantares',
    type: 'single_choice',
    question: 'En un esguince de tobillo común por mecanismo de inversión forzada, ¿cuál es el ligamento lateral que se lesiona con mayor frecuencia?',
    options: [
      'Ligamento Deltoideo (colateral medial)',
      'Ligamento Fibulotalar Anterior (Peroneoastragalino Anterior - LFTA)',
      'Ligamento Calcaneofibular posterior'
    ],
    correctIndex: 1,
    rationale: 'El ligamento peroneoastragalino anterior (LFTA) frena la inversión y flexión plantar; es el elemento ligamentario lesionado en más del 85% de los esguinces de tobillo.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 3 (Miembros)'
  },
  {
    id: 'quiz_t3_11_escapula_alada_nervio',
    areaId: 'anatomia',
    topicId: 'cintura_escapular_hombro',
    type: 'single_choice',
    question: 'La presencia de una "escápula alada" (despegamiento del borde medial de la escápula) revela la parálisis de qué músculo y su nervio correspondiente:',
    options: [
      'Músculo trapecio por el nervio accesorio (XI)',
      'Músculo serrato anterior por el nervio torácico largo (de Bell)',
      'Músculo dorsal ancho por el nervio toracodorsal'
    ],
    correctIndex: 1,
    rationale: 'El serrato anterior fija la escápula a la reja costal; al lesionarse su nervio motor (nervio torácico largo), la escápula protruye dorsalmente como un ala.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 3 (Miembros)'
  },
  {
    id: 'quiz_t3_12_meniscos_rodilla_relacionar',
    areaId: 'anatomia',
    topicId: 'rodilla_pierna_fosa_poplitea',
    type: 'matching',
    question: 'Relaciona la morfología y movilidad de los dos meniscos de la rodilla:\n1. Menisco Medial (Interno)\n2. Menisco Lateral (Externo)',
    options: [
      '1: Forma de "C", más fijo al ligamento colateral y más vulnerable | 2: Forma de "O", más móvil y circular',
      '1: Forma de "O", muy móvil | 2: Forma de "C", fusionado al tendón rotuliano',
      '1: Carece de vascularización periférica | 2: Es completamente óseo'
    ],
    correctIndex: 0,
    matchingPairs: [
      { left: 'Menisco Medial (Interno)', right: 'Forma de "C", más fijo al ligamento colateral y más vulnerable' },
      { left: 'Menisco Lateral (Externo)', right: 'Forma de "O", más móvil y circular' }
    ],
    rationale: 'Mnemotecnia CITO: C (Interno) y O (Externo). El menisco medial tiene forma de C y se ancla al ligamento colateral medial, lo que lo hace menos móvil y más propenso a roturas.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 3 (Miembros)'
  },

  // =========================================================================
  // BLOQUE 4: TOMO 4 (SISTEMA NERVIOSO CENTRAL) - 12 QUIZZES
  // =========================================================================
  {
    id: 'quiz_t4_01_cono_medular_seguridad',
    areaId: 'anatomia',
    topicId: 'medula_espinal_meninges',
    type: 'single_choice',
    question: '¿A qué nivel vertebral finaliza la médula espinal (cono medular) en el adulto, garantizando la seguridad de la punción lumbar a nivel L3-L4 o L4-L5?',
    options: [
      'T10 - T11',
      'L1 - L2',
      'L4 - L5'
    ],
    correctIndex: 1,
    rationale: 'En el adulto, la médula concluye a la altura del disco L1-L2 en el cono medular. En la cisterna lumbar inferior solo flotan las raíces de la cauda equina, permitiendo la punción lumbar.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 4 (Sistema Nervioso Central)'
  },
  {
    id: 'quiz_t4_02_cerebelo_filogenia_relacionar',
    areaId: 'anatomia',
    topicId: 'cerebelo_vias_cerebelosas',
    type: 'matching',
    question: 'Relaciona la división filogenética del cerebelo con su función motora primordial:\n1. Arquicerebelo (Vestibulocerebelo)\n2. Paleocerebelo (Espinocerebelo)\n3. Neocerebelo (Cerebrocerebelo)',
    options: [
      '1: Equilibrio corporal y movimientos oculares | 2: Tono muscular y postura axial | 3: Coordinación de motricidad fina voluntaria',
      '1: Movimiento voluntario fino | 2: Equilibrio | 3: Tono muscular',
      '1: Tono muscular | 2: Movimiento fino | 3: Reflejos oculares'
    ],
    correctIndex: 0,
    matchingPairs: [
      { left: 'Arquicerebelo (Vestibulocerebelo)', right: 'Equilibrio corporal y movimientos oculares' },
      { left: 'Paleocerebelo (Espinocerebelo)', right: 'Tono muscular y postura axial' },
      { left: 'Neocerebelo (Cerebrocerebelo)', right: 'Coordinación de motricidad fina voluntaria' }
    ],
    rationale: 'El arquicerebelo coordina el equilibrio; el paleocerebelo regula el tono postural y la marcha axial; y el neocerebelo programa y modula los movimientos voluntarios finos distales.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 4 (Sistema Nervioso Central)'
  },
  {
    id: 'quiz_t4_03_afasia_broca_caso',
    areaId: 'anatomia',
    topicId: 'telencefalo_corteza_ganglios_base',
    type: 'single_choice',
    question: 'Un paciente comprende perfectamente el lenguaje hablado pero es incapaz de articular palabras fluidamente (afasia motora no fluente). ¿Qué área de Brodmann está afectada?',
    options: [
      'Área de Broca (áreas 44 y 45, lóbulo frontal inferior)',
      'Área de Wernicke (área 22, lóbulo temporal superior)',
      'Área visual primaria (área 17, cisura calcarina)'
    ],
    correctIndex: 0,
    rationale: 'El área de Broca (44 y 45 en el giro frontal inferior del hemisferio dominante) programa la ejecución motora del lenguaje; su lesión causa la afasia motora de Broca.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 4 (Sistema Nervioso Central)'
  },
  {
    id: 'quiz_t4_04_lcr_circulacion_ordenar',
    areaId: 'anatomia',
    topicId: 'vias_nerviosas_lcr_meninges',
    type: 'ordering',
    question: 'Ordena la ruta fisiológica de circulación del líquido cefalorraquídeo desde los plexos coroideos laterales hasta su salida del encéfalo:',
    options: [
      'Ventrículos laterales -> Forámenes de Monro -> 3.er ventrículo -> Acueducto de Silvio -> 4.° ventrículo y forámenes de Luschka/Magendie',
      'Ventrículos laterales -> 3.er ventrículo -> Forámenes de Monro -> 4.° ventrículo -> Acueducto de Silvio',
      '4.° ventrículo -> Acueducto de Silvio -> 3.er ventrículo -> Ventrículos laterales'
    ],
    correctIndex: 0,
    orderingItems: [
      'Ventrículos laterales',
      'Forámenes de Monro',
      '3.er ventrículo',
      'Acueducto de Silvio',
      '4.° ventrículo y forámenes de Luschka/Magendie'
    ],
    rationale: 'El LCR fluye desde los ventrículos laterales al 3.er ventrículo por los forámenes de Monro, desciende por el acueducto de Silvio al 4.° ventrículo y sale a la cisterna magna por los orificios de Luschka y Magendie.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 4 (Sistema Nervioso Central)'
  },
  {
    id: 'quiz_t4_05_capsula_interna_hemiplejia_caso',
    areaId: 'anatomia',
    topicId: 'telencefalo_corteza_ganglios_base',
    type: 'single_choice',
    question: 'Un paciente sufre un ictus hemorrágico afectando el brazo posterior de la cápsula interna izquierda. ¿Qué déficit motor clásico esperaría encontrar?',
    options: [
      'Hemiplejía flácida contralateral derecha (fascículo corticoespinal)',
      'Parálisis facial homolateral izquierda aislada',
      'Ataxia sensitiva bilateral exclusiva'
    ],
    correctIndex: 0,
    rationale: 'Por el brazo posterior de la cápsula interna descienden las fibras del haz corticoespinal motor para el hemicuerpo opuesto; su destrucción provoca hemiplejía contralateral.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 4 (Sistema Nervioso Central)'
  },
  {
    id: 'quiz_t4_06_talamo_excepcion_olfato',
    areaId: 'anatomia',
    topicId: 'tronco_encefalico_cuarto_ventriculo',
    type: 'single_choice',
    question: '¿Cuál es la única modalidad sensorial que alcanza la corteza cerebral sin hacer relevo sináptico previo en los núcleos del tálamo?',
    options: [
      'Vía visual',
      'Vía auditiva',
      'Vía olfatoria'
    ],
    correctIndex: 2,
    rationale: 'La vía olfatoria es la única que proyecta directamente desde el bulbo olfatorio a la corteza piriforme temporal sin pasar previamente por los núcleos del tálamo.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 4 (Sistema Nervioso Central)'
  },
  {
    id: 'quiz_t4_07_nucleos_cerebelosos_ordenar',
    areaId: 'anatomia',
    topicId: 'cerebelo_vias_cerebelosas',
    type: 'ordering',
    question: 'Ordena de lateral a medial los cuatro pares de núcleos grises profundos del cerebelo:',
    options: [
      'Núcleo Dentado -> Núcleo Émbolo -> Núcleo Globoso -> Núcleo del Fastigio (del techo)',
      'Núcleo del Fastigio -> Núcleo Globoso -> Núcleo Émbolo -> Núcleo Dentado',
      'Núcleo Globoso -> Núcleo Dentado -> Núcleo del Fastigio -> Núcleo Émbolo'
    ],
    correctIndex: 0,
    orderingItems: [
      'Núcleo Dentado (lateral)',
      'Núcleo Émbolo (emboliforme)',
      'Núcleo Globoso',
      'Núcleo del Fastigio (del techo - medial)'
    ],
    rationale: 'Mnemotecnia DEGF ("Don Émbolo Guarda Frutas"): de lateral a medial se hallan el Dentado, Emboliforme, Globoso y Fastigio.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 4 (Sistema Nervioso Central)'
  },
  {
    id: 'quiz_t4_08_decusacion_piramidal_nivel',
    areaId: 'anatomia',
    topicId: 'vias_nerviosas_lcr_meninges',
    type: 'single_choice',
    question: '¿A qué nivel anatómico del tronco encefálico se produce la decusación piramidal de las fibras motoras del haz corticoespinal lateral?',
    options: [
      'En el pedúnculo cerebral del mesencéfalo',
      'En el tercio inferior del bulbo raquídeo (médula oblongada)',
      'En la comisura blanca anterior de la médula espinal'
    ],
    correctIndex: 1,
    rationale: 'El 85-90% de las fibras piramídicas se cruzan al lado opuesto en la decusación piramidal del bulbo raquídeo inferior para formar el haz corticoespinal lateral.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 4 (Sistema Nervioso Central)'
  },
  {
    id: 'quiz_t4_09_coliculos_mesencefalo_relacionar',
    areaId: 'anatomia',
    topicId: 'tronco_encefalico_cuarto_ventriculo',
    type: 'matching',
    question: 'Relaciona los colículos del techo mesencefálico con su vía sensitiva asociada:\n1. Colículos Superiores\n2. Colículos Inferiores',
    options: [
      '1: Reflejos visuales y movimientos sacádicos | 2: Relevo de la vía auditiva',
      '1: Relevo de la vía auditiva | 2: Reflejos visuales',
      '1: Centro del olfato | 2: Centro del gusto'
    ],
    correctIndex: 0,
    matchingPairs: [
      { left: 'Colículos Superiores', right: 'Reflejos visuales y movimientos sacádicos' },
      { left: 'Colículos Inferiores', right: 'Relevo de la vía auditiva' }
    ],
    rationale: 'Regla: Colículos Superiores arriba para los ojos (visión), Colículos Inferiores abajo para los oídos (audición).',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 4 (Sistema Nervioso Central)'
  },
  {
    id: 'quiz_t4_10_sustancia_negra_parkinson',
    areaId: 'anatomia',
    topicId: 'tronco_encefalico_cuarto_ventriculo',
    type: 'single_choice',
    question: 'La degeneración selectiva de las neuronas dopaminérgicas de la sustancia negra (locus niger) del mesencéfalo es la causa anatomopatológica de:',
    options: [
      'Esclerosis múltiple',
      'Enfermedad de Parkinson',
      'Corea de Huntington'
    ],
    correctIndex: 1,
    rationale: 'La pérdida de neuronas en la porción compacta de la sustancia negra mesencefálica priva de dopamina al cuerpo estriado, desatando la clínica cardinal del Parkinson.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 4 (Sistema Nervioso Central)'
  },
  {
    id: 'quiz_t4_11_babinski_signo_motora',
    areaId: 'anatomia',
    topicId: 'vias_nerviosas_lcr_meninges',
    type: 'single_choice',
    question: 'El signo de Babinski (extensión dorsal del dedo gordo y apertura en abanico al raspar la planta del pie) es patognomónico de lesión de:',
    options: [
      'La primera motoneurona (vía piramidal corticoespinal)',
      'La segunda motoneurona en el asta anterior',
      'Los núcleos vestibulares del bulbo'
    ],
    correctIndex: 0,
    rationale: 'El reflejo plantar extensor (signo de Babinski) es el signo por excelencia de síndrome piramidal por lesión de la primera motoneurona cortical o de su haz corticoespinal.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 4 (Sistema Nervioso Central)'
  },
  {
    id: 'quiz_t4_12_reabsorcion_lcr_pacchioni',
    areaId: 'anatomia',
    topicId: 'vias_nerviosas_lcr_meninges',
    type: 'single_choice',
    question: '¿En qué formaciones anatómicas se reabsorbe fisiológicamente la mayor parte del líquido cefalorraquídeo hacia el seno venoso sagital superior?',
    options: [
      'En los plexos coroideos',
      'En las vellosidades aracnoideas (granulaciones de Pacchioni)',
      'En el epéndimo del cono medular'
    ],
    correctIndex: 1,
    rationale: 'Las granulaciones o vellosidades aracnoideas de Pacchioni actúan como válvulas unidireccionales que filtran el LCR desde el espacio subaracnoideo hacia la sangre venosa del seno sagital superior.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 4 (Sistema Nervioso Central)'
  }
];

async function main() {
  console.log(`Iniciando carga de banco ampliado de ${quizzes.length} Quizzes Clínicos de Anatomía...\n`);

  for (const q of quizzes) {
    const docData = {
      areaId: q.areaId,
      topicId: q.topicId,
      type: q.type,
      question: q.question,
      options: q.options,
      correctIndex: q.correctIndex,
      rationale: q.rationale,
      sourceBook: q.sourceBook,
      order: quizzes.indexOf(q) + 1
    };

    await setDocument(`medical_areas/anatomia/quizzes/${q.id}`, docData);
    await setDocument(`quizzes/${q.id}`, docData);
  }

  // Actualizar el contador global de quizzes en medical_areas/anatomia
  await setDocument('medical_areas/anatomia', {
    name: 'Anatomía Humana',
    code: 'ANATOMIA',
    order: 1,
    topicsCount: 24,
    cheatsheetsCount: 61,
    quizzesCount: quizzes.length,
    isAvailable: true
  });

  console.log('\n=================================================================');
  console.log(`¡CARGA MASIVA FINALIZADA: ${quizzes.length} QUIZZES EN FIRESTORE!`);
  console.log('Todos con 3 alternativas estrictas, una sola respuesta correcta,');
  console.log('clasificados como Selección Simple, Para Relacionar o Para Ordenar.');
  console.log('=================================================================');
}

main().catch(err => {
  console.error('Error durante la carga:', err);
  process.exit(1);
});
