// Script de carga de Quizzes Clínicos de Anatomía Humana (Rouvière Tomos 1 a 4)
// Todos con 3 alternativas (A, B, C), justificación médica y tipología variada (opción múltiple, relacionar, ordenar).
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
          values: value.map(item => ({ stringValue: item }))
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
  // ==========================================
  // BLOQUE 1: TOMO 1 (CABEZA Y CUELLO)
  // ==========================================
  {
    id: 'quiz_esfenoides_foramen_redondo',
    areaId: 'anatomia',
    topicId: 'osteologia_craneo',
    type: 'multiple_choice',
    question: '¿Cuál de los siguientes pares craneales o ramas atraviesa el foramen redondo (redondo mayor) del hueso esfenoides?',
    options: [
      'Nervio oftálmico (V1)',
      'Nervio maxilar (V2)',
      'Nervio mandibular (V3)'
    ],
    correctIndex: 1,
    rationale: 'Según la regla mnemotécnica ROSE: el foramen Redondo da paso al nervio maxilar (V2), el foramen Oval al nervio mandibular (V3) y el Espinoso a la arteria meníngea media. El nervio oftálmico (V1) atraviesa la fisura orbitaria superior.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 1 (Cabeza y Cuello)'
  },
  {
    id: 'quiz_temporal_relacionar_orificios',
    areaId: 'anatomia',
    topicId: 'osteologia_craneo',
    type: 'matching',
    question: 'Relaciona cada orificio del hueso temporal con su elemento neurovascular principal:\n1. Meato acústico interno\n2. Foramen estilomastoideo\n3. Conducto carotídeo',
    options: [
      '1: Nervios VII, VIII y A. laberíntica | 2: Tronco del nervio facial (VII) | 3: Arteria carótida interna',
      '1: Arteria meníngea media | 2: Nervio hipogloso | 3: Vena yugular interna',
      '1: Nervio maxilar | 2: Arteria auditiva externa | 3: Nervio trigémino'
    ],
    correctIndex: 0,
    rationale: 'Por el meato acústico interno ingresan los pares VII, VII bis, VIII y la arteria laberíntica; por el estilomastoideo emerge extracranealmente el tronco motor del nervio facial; y por el conducto carotídeo asciende la arteria carótida interna hacia el seno cavernoso.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 1 (Cabeza y Cuello)'
  },
  {
    id: 'quiz_masticadores_apertura',
    areaId: 'anatomia',
    topicId: 'musculos_masticacion_cuello',
    type: 'multiple_choice',
    question: 'Paciente acude a emergencias tras traumatismo mandibular con incapacidad para la apertura bucal y propulsión activa. ¿Qué músculo masticador se encuentra afectado primariamente?',
    options: [
      'Músculo masetero',
      'Músculo pterigoideo lateral',
      'Músculo temporal'
    ],
    correctIndex: 1,
    rationale: 'El músculo pterigoideo lateral es el ÚNICO músculo masticador que participa activamente en la apertura de la boca y la propulsión mandibular. El masetero, el temporal y el pterigoideo medial son potentes músculos elevadores (cierre de la boca).',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 1 (Cabeza y Cuello)'
  },
  {
    id: 'quiz_eje_carotideo_ordenar',
    areaId: 'anatomia',
    topicId: 'vascularizacion_cabeza_cuello',
    type: 'ordering',
    question: 'Ordena de caudal a cefálico (origen a terminación) la disposición del eje arterial carotídeo en el cuello:\n1. Arteria carótida común\n2. Bifurcación carotídea en C4 (seno y glomo carotídeo)\n3. Arterias temporal superficial y maxilar',
    options: [
      '2 -> 1 -> 3',
      '1 -> 2 -> 3',
      '3 -> 1 -> 2'
    ],
    correctIndex: 1,
    rationale: 'La arteria carótida común asciende por el cuello hasta la vértebra C4 (borde superior del cartílago tiroides), donde se bifurca en carótida interna y externa; esta última asciende dando sus dos ramas terminales a nivel del cuello del cóndilo mandibular.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 1 (Cabeza y Cuello)'
  },

  // ==========================================
  // BLOQUE 2: TOMO 2 (TRONCO: TÓRAX Y ABDOMEN)
  // ==========================================
  {
    id: 'quiz_hiatos_diafragma_ordenar',
    areaId: 'anatomia',
    topicId: 'torax_mediastino_diafragma',
    type: 'ordering',
    question: 'Ordena de superior a inferior (cráneo-caudal) el nivel vertebral en que se ubican los tres grandes hiatos del diafragma:',
    options: [
      'Hiato Vena Cava Inferior (T8) -> Hiato Esofágico (T10) -> Hiato Aórtico (T12)',
      'Hiato Aórtico (T8) -> Hiato Esofágico (T10) -> Hiato Vena Cava (T12)',
      'Hiato Esofágico (T8) -> Hiato Vena Cava (T10) -> Hiato Aórtico (T12)'
    ],
    correctIndex: 0,
    rationale: 'La regla mnemotécnica "VEA" establece: Vena Cava en T8 (en el centro tendinoso), Esófago en T10 (en el pilar muscular derecho) y Aorta en T12 (retroperitoneal junto al conducto torácico).',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 2 (Tronco)'
  },
  {
    id: 'quiz_hernias_inguinales_diferencial',
    areaId: 'anatomia',
    topicId: 'pared_abdominal_conducto_inguinal',
    type: 'multiple_choice',
    question: 'Durante una intervención quirúrgica, el cirujano constata que el saco herniario protruye a través del triángulo de Hesselbach, MEDIAL a los vasos epigástricos inferiores. ¿Cuál es el diagnóstico?',
    options: [
      'Hernia inguinal indirecta',
      'Hernia inguinal directa',
      'Hernia femoral o crural'
    ],
    correctIndex: 1,
    rationale: 'La regla "MD" determina: Medial a los vasos epigástricos inferiores es Hernia Directa (adquirida, por debilidad de la fascia transversalis). Las hernias indirectas penetran por el anillo inguinal profundo, laterales a los vasos epigástricos.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 2 (Tronco)'
  },
  {
    id: 'quiz_duodeno_papilas_relacionar',
    areaId: 'anatomia',
    topicId: 'digestivo_abdominal_peritoneo',
    type: 'matching',
    question: 'Relaciona los conductos excretores con su papila duodenal de desembocadura:\n1. Conducto colédoco y pancreático principal (de Wirsung)\n2. Conducto pancreático accesorio (de Santorini)',
    options: [
      '1: Papila duodenal mayor (Ampolla de Vater) | 2: Papila duodenal menor',
      '1: Bulbo duodenal | 2: Ángulo de Treitz',
      '1: Papila duodenal menor | 2: Papila duodenal mayor'
    ],
    correctIndex: 0,
    rationale: 'En la segunda porción descendente del duodeno, la papila duodenal mayor recibe al colédoco y al conducto de Wirsung (con el esfínter de Oddi); la papila menor recibe al conducto de Santorini 2 cm por encima.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 2 (Tronco)'
  },
  {
    id: 'quiz_triada_portal_ordenar',
    areaId: 'anatomia',
    topicId: 'visceras_retroperitoneo_rinones',
    type: 'ordering',
    question: 'En el ligamento hepatoduodenal (hiato de Winslow), ¿cómo se disponen de posterior a anterior los elementos de la tríada portal?',
    options: [
      'Plano posterior: Vena Porta | Plano anterior: Arteria Hepática Propia (izq.) y Colédoco (der.)',
      'Plano posterior: Arteria Hepática Propia | Plano anterior: Vena Porta y Colédoco',
      'Plano posterior: Conducto Colédoco | Plano anterior: Vena Cava Inferior y Vena Porta'
    ],
    correctIndex: 0,
    rationale: 'La regla mnemotécnica "VAC" del pedículo hepático ubica la Vena Porta en el plano posterior profundo, y en el plano anterior a la Arteria Hepática Propia hacia la izquierda y el Conducto Colédoco hacia la derecha.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 2 (Tronco)'
  },

  // ==========================================
  // BLOQUE 3: TOMO 3 (MIEMBROS: SUPERIOR E INFERIOR)
  // ==========================================
  {
    id: 'quiz_manguito_rotador_abduccion',
    areaId: 'anatomia',
    topicId: 'cintura_escapular_hombro',
    type: 'multiple_choice',
    question: 'Un paciente presenta dolor agudo en el hombro y es incapaz de iniciar los primeros 15 grados de abducción del brazo. ¿Qué tendón del manguito rotador está afectado?',
    options: [
      'Tendón del músculo subescapular',
      'Tendón del músculo supraespinoso',
      'Tendón del músculo redondo menor'
    ],
    correctIndex: 1,
    rationale: 'El músculo supraespinoso inicia la abducción del brazo en los primeros 15 grados, tras lo cual el músculo deltoides asume la función principal. Es el tendón que más frecuentemente sufre tendinitis y rotura en el hombro.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 3 (Miembros)'
  },
  {
    id: 'quiz_tunel_carpiano_nervio',
    areaId: 'anatomia',
    topicId: 'muneca_mano_tunel_carpiano',
    type: 'multiple_choice',
    question: '¿Cuál es la única estructura nerviosa que discurre por dentro del túnel carpiano junto a los nueve tendones flexores de los dedos?',
    options: [
      'Nervio radial',
      'Nervio mediano',
      'Nervio cubital'
    ],
    correctIndex: 1,
    rationale: 'El túnel del carpo contiene 10 elementos: el Nervio Mediano y 9 tendones flexores. Su compresión produce parestesias en los tres primeros dedos y atrofia de la eminencia tenar. El nervio cubital pasa por fuera a través del canal de Guyon.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 3 (Miembros)'
  },
  {
    id: 'quiz_triangulo_scarpa_ordenar',
    areaId: 'anatomia',
    topicId: 'cadera_muslo_triangulo_femoral',
    type: 'ordering',
    question: 'En la región subinguinal (triángulo femoral de Scarpa), ¿cuál es el orden estricto de LATERAL a MEDIAL de los elementos vasculonerviosos?',
    options: [
      'Nervio Femoral -> Arteria Femoral -> Vena Femoral',
      'Vena Femoral -> Arteria Femoral -> Nervio Femoral',
      'Arteria Femoral -> Nervio Femoral -> Vena Femoral'
    ],
    correctIndex: 0,
    rationale: 'La regla mnemotécnica de la ingle "NAV" establece de afuera hacia adentro: Nervio femoral, Arteria femoral y Vena femoral (con los vasos linfáticos en el anillo crural medial).',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 3 (Miembros)'
  },
  {
    id: 'quiz_rodilla_ligamentos_relacionar',
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
    rationale: 'El cajón anterior evalúa el LCA impidiendo el desplazamiento anterior de la tibia; el cajón posterior evalúa el LCP; y la apertura en bostezo medial evalúa la estabilidad del ligamento colateral medial.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 3 (Miembros)'
  },

  // ==========================================
  // BLOQUE 4: TOMO 4 (SISTEMA NERVIOSO CENTRAL)
  // ==========================================
  {
    id: 'quiz_cono_medular_puncion',
    areaId: 'anatomia',
    topicId: 'medula_espinal_meninges',
    type: 'multiple_choice',
    question: '¿A qué nivel vertebral concluye la médula espinal (cono medular) en el adulto, garantizando la seguridad de la punción lumbar a nivel L3-L4 o L4-L5?',
    options: [
      'T10 - T11',
      'L1 - L2',
      'L4 - L5'
    ],
    correctIndex: 1,
    rationale: 'En el adulto, la médula espinal concluye a la altura del disco L1-L2 en el cono medular. En la cisterna lumbar subyacente (L3-S2) solo flotan las raíces de la cauda equina bañadas en LCR, permitiendo introducir la aguja de punción lumbar sin riesgo de sección medular.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 4 (Sistema Nervioso Central)'
  },
  {
    id: 'quiz_cerebelo_filogenia_relacionar',
    areaId: 'anatomia',
    topicId: 'cerebelo_vias_cerebelosas',
    type: 'matching',
    question: 'Relaciona la división funcional del cerebelo con su función motora primordial:\n1. Arquicerebelo (Vestibulocerebelo / Lóbulo floculonodular)\n2. Paleocerebelo (Espinocerebelo / Vermis)\n3. Neocerebelo (Cerebrocerebelo / Hemisferios)',
    options: [
      '1: Equilibrio corporal y reflejos oculares | 2: Tono postural y marcha axial | 3: Coordinación fina y destreza voluntaria',
      '1: Coordinación motora fina | 2: Equilibrio vestibular | 3: Tono postural',
      '1: Tono muscular | 2: Movimiento fino | 3: Reflejos oculomotores'
    ],
    correctIndex: 0,
    rationale: 'El arquicerebelo regula el equilibrio y movimientos sacádicos oculares; el paleocerebelo regula el tono y la postura axial; y el neocerebelo programa, ajusta y amortigua los movimientos voluntarios finos distales.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 4 (Sistema Nervioso Central)'
  },
  {
    id: 'quiz_areas_brodmann_afasia',
    areaId: 'anatomia',
    topicId: 'telencefalo_corteza_ganglios_base',
    type: 'multiple_choice',
    question: 'Un paciente tras un ictus comprende perfectamente el lenguaje hablado y escrito, pero es incapaz de articular palabras fluidamente (afasia motora no fluente). ¿Qué área de Brodmann está lesionada?',
    options: [
      'Área de Broca (44 y 45, giro frontal inferior)',
      'Área de Wernicke (22, giro temporal superior)',
      'Área visual primaria (17, cisura calcarina)'
    ],
    correctIndex: 0,
    rationale: 'El área de Broca (áreas 44 y 45 en el giro frontal inferior del hemisferio dominante) coordina la programación motora del lenguaje articulado. Su daño ocasiona afasia de Broca motora con comprensión preservada.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 4 (Sistema Nervioso Central)'
  },
  {
    id: 'quiz_lcr_circulacion_ordenar',
    areaId: 'anatomia',
    topicId: 'vias_nerviosas_lcr_meninges',
    type: 'ordering',
    question: 'Ordena la ruta fisiológica de circulación del líquido cefalorraquídeo desde su producción hasta el espacio subaracnoideo:\n1. Ventrículos laterales (plexos coroideos)\n2. Agujeros interventriculares de Monro\n3. Tercer ventrículo\n4. Acueducto mesencefálico de Silvio\n5. Cuarto ventrículo y forámenes de Luschka y Magendie',
    options: [
      '1 -> 2 -> 3 -> 4 -> 5',
      '1 -> 3 -> 2 -> 5 -> 4',
      '2 -> 1 -> 4 -> 3 -> 5'
    ],
    correctIndex: 0,
    rationale: 'El LCR fluye desde los ventrículos laterales al 3.er ventrículo a través de los forámenes de Monro, desciende por el estrecho acueducto de Silvio al 4.° ventrículo y sale a la cisterna magna por los orificios laterales de Luschka y medial de Magendie.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 4 (Sistema Nervioso Central)'
  }
];

async function main() {
  console.log('Iniciando carga de Quizzes Clínicos de Anatomía Humana...\n');

  // 1. Guardar cada quiz en medical_areas/anatomia/quizzes y en la colección raíz quizzes
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

    // Subcolección jerárquica 1:N dentro del área de anatomía
    await setDocument(`medical_areas/anatomia/quizzes/${q.id}`, docData);
    // Colección global para consultas directas por categoría/área
    await setDocument(`quizzes/${q.id}`, docData);
  }

  // 2. Actualizar el contador quizzesCount en medical_areas/anatomia
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
  console.log(`¡CARGA DE ${quizzes.length} QUIZZES DE ANATOMÍA FINALIZADA CON ÉXITO!`);
  console.log('Formato: 3 Alternativas, Justificación Médica y Tipos Variados.');
  console.log('=================================================================');
}

main().catch(err => {
  console.error('Error durante la carga de quizzes:', err);
  process.exit(1);
});
