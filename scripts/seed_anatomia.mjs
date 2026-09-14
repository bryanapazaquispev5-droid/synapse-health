// Script de carga integral de Anatomía Humana (Rouvière Tomo 1: Cabeza y Cuello)
// Cobertura completa de los 6 grandes sistemas anatómicos del libro.
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

async function main() {
  console.log('Iniciando carga completa del Tomo 1 de Rouvière (Cabeza y Cuello)...\n');

  // 1. ÁREA MÉDICA PRINCIPAL: ANATOMÍA HUMANA
  await setDocument('medical_areas/anatomia', {
    name: 'Anatomía Humana',
    code: 'ANATOMIA',
    order: 1,
    topicsCount: 6,
    cheatsheetsCount: 18,
    quizzesCount: 0,
    isAvailable: true
  });

  // ============================================================================
  // TEMA 1: OSTEOLOGÍA DEL CRÁNEO, MACIZO FACIAL Y COLUMNA CERVICAL
  // ============================================================================
  await setDocument('medical_areas/anatomia/topics/osteologia_craneo', {
    areaId: 'anatomia',
    title: 'Osteología Craneofacial y Columna Cervical',
    description: 'Huesos del neurocráneo, viscerocráneo, base del cráneo, forámenes y vértebras cervicales.',
    order: 1,
    cheatsheetsCount: 4,
    quizzesCount: 0
  });

  await setDocument('medical_areas/anatomia/topics/osteologia_craneo/cheatsheets/esfenoides_orificios', {
    areaId: 'anatomia',
    topicId: 'osteologia_craneo',
    title: 'Hueso Esfenoides y Forámenes de la Base',
    summary: 'Arquitectura central de la base craneal, fosas hipofisarias y conductos neurovasculares mayores.',
    sourceBook: 'Rouvière - Anatomía Humana: Cabeza y Cuello (Tomo 1)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Cuerpo: Aloja la fosa hipofisaria (silla turca) y los senos esfenoidales neumáticos.',
      'Alas Menores: Delimitan el conducto óptico (Nervio Óptico [II] y Arteria Oftálmica).',
      'Fisura Orbitaria Superior: Da paso a pares III, IV, VI, ramas del V1 (frontal, lagrimal, nasociliar) y vena oftálmica.',
      'Forámenes del Ala Mayor: Foramen Redondo (nervio maxilar V2), Foramen Oval (nervio mandibular V3 y arteria meníngea accesoria) y Foramen Espinoso (arteria meníngea media).'
    ],
    mnemonics: ['ROSE: Redondo (V2) | Oval (V3) | Spinoso (A. Meníngea Media).'],
    contentMarkdown: `### Morfología del Hueso Esfenoides
Pieza impar y media central de la base del cráneo, articula con todos los huesos del neurocráneo.

#### Elementos Principales
- **Cuerpo:** Silla turca, surco quiasmático y senos esfenoidales.
- **Alas Menores:** Forman el borde posterior de la fosa craneal anterior.
- **Alas Mayores:** Forman el suelo de la fosa craneal media y la pared lateral de la órbita.
- **Apófisis Pterigoides:** Inserción de los músculos masticadores homónimos.`
  });

  await setDocument('medical_areas/anatomia/topics/osteologia_craneo/cheatsheets/temporal_penasco', {
    areaId: 'anatomia',
    topicId: 'osteologia_craneo',
    title: 'Hueso Temporal y Peñasco Petroso',
    summary: 'Porciones escamosa, timpánica y petrosa; acueductos, meato acústico interno y forámenes.',
    sourceBook: 'Rouvière - Anatomía Humana: Cabeza y Cuello (Tomo 1)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Porción Petrosa (Peñasco): Contiene el oído medio e interno y el laberinto óseo.',
      'Meato Acústico Interno: Entrada de los nervios Facial (VII), Intermedio de Wrisberg (VII bis), Vestibulococlear (VIII) y Arteria Laberíntica.',
      'Foramen Estilomastoideo: Salida extracraneal del nervio Facial (VII).',
      'Conducto Carotídeo: Trayecto en codo de la Arteria Carótida Interna.',
      'Foramen Yugular: Compartido con el occipital; transmite pares IX, X, XI y Vena Yugular Interna.'
    ],
    mnemonics: ['Contenido del Meato Acústico Interno: "7-8 L" (Par VII, Par VIII y arteria Laberíntica).'],
    contentMarkdown: `### Morfología del Hueso Temporal
Aloja los órganos de la audición y el equilibrio y forma la cavidad glenoidea para la ATM.

#### Las Tres Porciones
1. **Porción Escamosa:** Fosa temporal y raíz del arco cigomático.
2. **Porción Timpánica:** Paredes óseas del meato acústico externo.
3. **Porción Petrosa:** Cara anterosuperior (eminencia arcuata, tegmen tympani) y posterosuperior (meato acústico interno).`
  });

  await setDocument('medical_areas/anatomia/topics/osteologia_craneo/cheatsheets/frontal_etmoides_occipital', {
    areaId: 'anatomia',
    topicId: 'osteologia_craneo',
    title: 'Frontal, Etmoides y Occipital: Fosas y Foramen Magno',
    summary: 'Lámina cribosa, clivus basilar, cóndilos y tránsito cráneo-raquídeo.',
    sourceBook: 'Rouvière - Anatomía Humana: Cabeza y Cuello (Tomo 1)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Lámina Cribosa del Etmoides: Da paso a los filetes del nervio olfatorio (I par).',
      'Apófisis Crista Galli: Proyección sagital para la inserción anterior de la hoz del cerebro.',
      'Occipital - Foramen Magno: Transición bulbomedular, arterias vertebrales, arterias espinales y raíces espinales del par XI.',
      'Conducto del Hipogloso: En la base de los cóndilos occipitales, transmite el par XII.'
    ],
    mnemonics: ['Lámina Cribosa: Criba de poros para el I par craneal (Olfatorio).'],
    contentMarkdown: `### Huesos de la Bóveda y Eje Basilar
El hueso frontal cierra la porción anterior de la bóveda, el etmoides forma el tabique y techo nasal, y el occipital conforma el suelo de la fosa craneal posterior y la articulación con el atlas.`
  });

  await setDocument('medical_areas/anatomia/topics/osteologia_craneo/cheatsheets/vertebras_cervicales', {
    areaId: 'anatomia',
    topicId: 'osteologia_craneo',
    title: 'Columna Cervical: Atlas, Axis y Vértebras Tipo',
    summary: 'Características de C1 a C7, foramen transverso, diente del axis y curvatura lordótica.',
    sourceBook: 'Rouvière - Anatomía Humana: Cabeza y Cuello (Tomo 1)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Foramen Transverso: Presente en todas las vértebras cervicales; transmite la arteria vertebral (de C6 a C1).',
      'Atlas (C1): Carece de cuerpo y apófisis espinosa; formado por dos masas laterales y arcos anterior y posterior.',
      'Axis (C2): Presenta el diente o apófisis odontoides, que actúa como eje de rotación de la cabeza.',
      'C7 (Prominente): Apófisis espinosa larga y no bifurcada; su foramen transverso no transmite la arteria vertebral.'
    ],
    mnemonics: ['La arteria vertebral entra por C6 y sube hasta C1, saltándose el foramen transverso de C7.'],
    contentMarkdown: `### Osteología Cervical
Las vértebras cervicales se caracterizan por cuerpos pequeños, apófisis espinosas bífidas (C2-C6) y forámenes transversos para el paquete vertebral.`
  });

  // ============================================================================
  // TEMA 2: ARTROLOGÍA CRANEOFACIAL Y VERTEBRAL
  // ============================================================================
  await setDocument('medical_areas/anatomia/topics/articulaciones_cabeza_cuello', {
    areaId: 'anatomia',
    title: 'Artrología Craneofacial y Cervical',
    description: 'Articulación temporomandibular (ATM), suturas craneales y articulaciones craneovertebrales.',
    order: 2,
    cheatsheetsCount: 2,
    quizzesCount: 0
  });

  await setDocument('medical_areas/anatomia/topics/articulaciones_cabeza_cuello/cheatsheets/atm_biomecanica', {
    areaId: 'anatomia',
    topicId: 'articulaciones_cabeza_cuello',
    title: 'Articulación Temporomandibular (ATM)',
    summary: 'Bicondílea diartrósica, menisco articular, ligamentos de refuerzo y dinámica mandibular.',
    sourceBook: 'Rouvière - Anatomía Humana: Cabeza y Cuello (Tomo 1)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Clasificación: Sinovial bicondílea con fibrocartílago interarticular (disco o menisco articular).',
      'Compartimentos: Supradiscal (movimientos de traslación) e Infradiscal (movimientos de rotación).',
      'Ligamentos Intrínsecos: Ligamento lateral (principal freno del descenso y retropulsión).',
      'Ligamentos Extrínsecos: Esfenomandibular, estilomandibular y rafe pterigomandibular.',
      'Biomecánica: Apertura, cierre, propulsión, retropulsión y diducción (lateralidad).'
    ],
    mnemonics: ['ATM: Rotación en piso inferior, Traslación en piso superior.'],
    contentMarkdown: `### Anatomía Funcional de la ATM
Articulación doble que une la mandíbula con la base del cráneo permitiendo la masticación y fonación.

#### Componentes
- **Superficies articulares:** Cóndilo de la mandíbula y fosa mandibular (cavidad glenoidea) con el tubérculo articular del temporal.
- **Disco articular:** Bicóncavo, absorbe fuerzas y compensa la discordancia de las superficies óseas.`
  });

  await setDocument('medical_areas/anatomia/topics/articulaciones_cabeza_cuello/cheatsheets/articulaciones_craneovertebrales', {
    areaId: 'anatomia',
    topicId: 'articulaciones_cabeza_cuello',
    title: 'Articulaciones Craneovertebrales y Ligamentos',
    summary: 'Articulaciones atlanto-occipital y atlanto-axial; ligamento transverso y membrana tectoria.',
    sourceBook: 'Rouvière - Anatomía Humana: Cabeza y Cuello (Tomo 1)',
    readMinutes: 2,
    isPremium: false,
    keyPoints: [
      'Atlanto-occipital: Sinovial condílea; responsable de los movimientos de flexoextensión de la cabeza ("gesto del Sí").',
      'Atlanto-axial Media: Trocoide (pivote); responsable de la rotación cefálica ("gesto del No").',
      'Ligamento Transverso del Atlas: Mantiene el diente del axis contra el arco anterior de C1, impidiendo el desplazamiento posterior hacia la médula espinal.',
      'Ligamentos Alares: Limitan la rotación excesiva del cráneo.'
    ],
    mnemonics: ['Atlanto-occipital = "SÍ" (flexión) | Atlanto-axial = "NO" (rotación).'],
    contentMarkdown: `### Unión Cráneo-Cervical
Complejo ligamentario especializado que otorga máxima movilidad cefálica a la vez que protege la unión bulbomedular.`
  });

  // ============================================================================
  // TEMA 3: MIOLOGÍA DE LA CABEZA Y EL CUELLO
  // ============================================================================
  await setDocument('medical_areas/anatomia/topics/musculos_masticacion_cuello', {
    areaId: 'anatomia',
    title: 'Miología de Cabeza, Cara y Cuello',
    description: 'Músculos de la masticación, de la expresión facial, suprahioideos, infrahioideos y triángulos cervicales.',
    order: 3,
    cheatsheetsCount: 3,
    quizzesCount: 0
  });

  await setDocument('medical_areas/anatomia/topics/musculos_masticacion_cuello/cheatsheets/musculos_masticadores', {
    areaId: 'anatomia',
    topicId: 'musculos_masticacion_cuello',
    title: 'Músculos Masticadores e Inervación por V3',
    summary: 'Temporal, Masetero, Pterigoideo Medial y Pterigoideo Lateral; funciones en la dinámica mandibular.',
    sourceBook: 'Rouvière - Anatomía Humana: Cabeza y Cuello (Tomo 1)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Todos están inervados por ramos motores del nervio mandibular (V3 del trigémino).',
      'Masetero y Pterigoideo Medial: Elevadores potentes de la mandíbula (fuerza oclusal).',
      'Temporal: Elevador y sus fibras posteriores son las principales retractoras de la mandíbula.',
      'Pterigoideo Lateral: Único músculo que participa activamente en la apertura de la boca mediante propulsión del cóndilo y el disco articular.'
    ],
    mnemonics: ['El Pterigoideo Lateral "Lanza" la mandíbula hacia adelante (apertura y propulsión).'],
    contentMarkdown: `### Los Cuatro Músculos Masticadores Principales
Derivados del 1.er arco faríngeo, responsables directos de los movimientos mandibulares.

| Músculo | Origen | Inserción | Acción Primaria |
| :--- | :--- | :--- | :--- |
| **Masetero** | Arco cigomático | Rama y ángulo de la mandíbula | Elevación potente |
| **Temporal** | Fosa temporal | Apófisis coronoides mandibular | Elevación y retrusión |
| **Pterigoideo Medial** | Fosa pterigoidea | Cara interna del ángulo mandibular | Elevación mandibular |
| **Pterigoideo Lateral** | Ala mayor y apófisis pterigoides | Cuello del cóndilo y disco ATM | Propulsión y apertura |`
  });

  await setDocument('medical_areas/anatomia/topics/musculos_masticacion_cuello/cheatsheets/musculos_faciales_mimica', {
    areaId: 'anatomia',
    topicId: 'musculos_masticacion_cuello',
    title: 'Músculos de la Mímica Facial (Inervación Par VII)',
    summary: 'Músculos cutáneos periorificiales derivados del 2.° arco branquial inervados por el nervio facial.',
    sourceBook: 'Rouvière - Anatomía Humana: Cabeza y Cuello (Tomo 1)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Origen embrionario: 2.° arco faríngeo; inervación motora exclusiva por el Nervio Facial (VII par).',
      'Carecen de fascia verdadera y se insertan directamente en la dermis profunda.',
      'Orbicular de los párpados: Cierre palpebral; su parálisis ocasiona lagoftalmos.',
      'Bucinador: Músculo de la mejilla atravesado por el conducto parotídeo (de Stenon).',
      'Orbicular de los labios: Esfínter oral fundamental para la fonación y continencia de alimentos.'
    ],
    mnemonics: ['Parálisis de Bell: Afecta todos los músculos de la mímica del lado ipsilateral (VII par).'],
    contentMarkdown: `### Músculos Faciales de la Expresión
Agrupados alrededor de los orificios de la cara (órbita, nariz, boca) cumpliendo funciones protectoras y expresivas.`
  });

  await setDocument('medical_areas/anatomia/topics/musculos_masticacion_cuello/cheatsheets/musculos_cuello_triangulos', {
    areaId: 'anatomia',
    topicId: 'musculos_masticacion_cuello',
    title: 'Músculos del Cuello y Triángulos Cervicales',
    summary: 'Esternocleidomastoideo, suprahioideos, infrahioideos y división topográfica del cuello.',
    sourceBook: 'Rouvière - Anatomía Humana: Cabeza y Cuello (Tomo 1)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Esternocleidomastoideo (ECM): Divide el cuello en triángulo anterior y posterior; inervado por el nervio Accesorio (XI).',
      'Músculos Suprahioideos: Digástrico, Estilohioideo, Milohioideo y Geniohioideo (elevan el hioides y deprimen la mandíbula).',
      'Músculos Infrahioideos: Esternohioideo, Omohioideo, Esternotiroideo y Tirohioideo (inervados por el asa cervical).',
      'Triángulo Carotídeo: Límites: ECM, vientre posterior del digástrico y vientre superior del omohioideo. Contiene la bifurcación carotídea.'
    ],
    mnemonics: ['Infrahioideos: "Este Hombre Está Tirado" (Esternohioideo, Omohioideo, Esternotiroideo, Tirohioideo).'],
    contentMarkdown: `### Topografía Muscular del Cuello
El hueso hioides y el músculo esternocleidomastoideo son las dos referencias clave para la disección y orientación quirúrgica del cuello.`
  });

  // ============================================================================
  // TEMA 4: ANGIOLOGÍA CÉRVICO-CEFÁLICA (VASCULARIZACIÓN)
  // ============================================================================
  await setDocument('medical_areas/anatomia/topics/vascularizacion_cabeza_cuello', {
    areaId: 'anatomia',
    title: 'Vascularización de la Cabeza y el Cuello',
    description: 'Sistema carotídeo, polígono de Willis, senos venosos durales y drenaje yugular.',
    order: 4,
    cheatsheetsCount: 3,
    quizzesCount: 0
  });

  await setDocument('medical_areas/anatomia/topics/vascularizacion_cabeza_cuello/cheatsheets/arteria_carotida_ramas', {
    areaId: 'anatomia',
    topicId: 'vascularizacion_cabeza_cuello',
    title: 'Sistema Carotídeo y Ramas de la Carótida Externa',
    summary: 'Bifurcación carotídea (C4), seno carotídeo y ramas colaterales/terminales externas.',
    sourceBook: 'Rouvière - Anatomía Humana: Cabeza y Cuello (Tomo 1)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Bifurcación Carotídea: Ocurre a nivel del borde superior del cartílago tiroides (vértebra C4).',
      'Seno Carotídeo (barorreceptor) y Glomo Carotídeo (quimiorreceptor): Inervados por el nervio glosofaríngeo (IX).',
      'Carótida Interna: No da ramas en el cuello; penetra por el conducto carotídeo hacia el cráneo.',
      'Carótida Externa - Ramas Colaterales: Tiroidea superior, Faríngea ascendente, Lingual, Facial, Occipital y Auricular posterior.',
      'Carótida Externa - Ramas Terminales: Arteria Temporal Superficial y Arteria Maxilar.'
    ],
    mnemonics: ['Ramas colaterales de Carótida Externa: "Ti-Fa-Li-Fa-O-Au" (Tiroidea sup, Faríngea asc, Lingual, Facial, Occipital, Auricular post).'],
    contentMarkdown: `### Árbol Arterial Cérvico-Facial
La arteria carótida común izquierda nace del arco aórtico, mientras que la derecha proviene del tronco braquiocefálico.`
  });

  await setDocument('medical_areas/anatomia/topics/vascularizacion_cabeza_cuello/cheatsheets/poligono_willis', {
    areaId: 'anatomia',
    topicId: 'vascularizacion_cabeza_cuello',
    title: 'Polígono de Willis y Circulación Cerebral',
    summary: 'Anastomosis arterial de la base del encéfalo entre el sistema carotídeo interno y el sistema vértebro-basilar.',
    sourceBook: 'Rouvière - Anatomía Humana: Cabeza y Cuello (Tomo 1)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Ubicación: En la cisterna interpeduncular en la base del cerebro, rodeando el quiasma óptico y el infundíbulo.',
      'Componentes Anteriores: Arterias carótidas internas, cerebrales anteriores y comunicante anterior.',
      'Componentes Posteriores: Arterias vertebrales -> Arteria Basilar -> Arterias cerebrales posteriores y comunicantes posteriores.',
      'Importancia Clínica: Garantiza circulación colateral ante la oclusión de una de las arterias principales.'
    ],
    mnemonics: ['Polígono de Willis = Puente salvador entre la carótida interna y la arteria basilar.'],
    contentMarkdown: `### Circuito Arterial Cerebral
Anillo vascular anastomótico heptagonal fundamental para la perfusión continua del sistema nervioso central.`
  });

  await setDocument('medical_areas/anatomia/topics/vascularizacion_cabeza_cuello/cheatsheets/senos_durales_yugular', {
    areaId: 'anatomia',
    topicId: 'vascularizacion_cabeza_cuello',
    title: 'Senos Venosos Durales y Vena Yugular Interna',
    summary: 'Seno longitudinal superior, seno transverso, seno sigmoideo, seno cavernoso y confluencia venosa.',
    sourceBook: 'Rouvière - Anatomía Humana: Cabeza y Cuello (Tomo 1)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Senos Venosos: Canales entre las dos capas de la duramadre, desprovistos de válvulas y de capa muscular.',
      'Confluencia de los Senos (Presa de Herófilo): Unión en la protuberancia occipital interna de los senos sagital superior, recto y occipital.',
      'Seno Cavernoso: A ambos lados de la silla turca; atravesado por la arteria carótida interna y el VI par. En su pared lateral corren los pares III, IV, V1 y V2.',
      'Vena Yugular Interna: Continuación del seno sigmoideo tras atravesar el foramen yugular.'
    ],
    mnemonics: ['Contenido central del Seno Cavernoso: Carótida Interna y Nervio Abducens (VI).'],
    contentMarkdown: `### Retorno Venoso Encefálico
Todo el drenaje venoso profundo y superficial del cerebro confluye en los senos durales para desembocar en las venas yugulares internas.`
  });

  // ============================================================================
  // TEMA 5: NEUROLOGÍA: PARES CRANEALES Y PLEXO CERVICAL
  // ============================================================================
  await setDocument('medical_areas/anatomia/topics/pares_craneales_inervacion', {
    areaId: 'anatomia',
    title: 'Pares Craneales y Sistema Nervioso',
    description: 'Origen real, origen aparente, orificio de salida e inervación funcional de los doce pares craneales.',
    order: 5,
    cheatsheetsCount: 3,
    quizzesCount: 0
  });

  await setDocument('medical_areas/anatomia/topics/pares_craneales_inervacion/cheatsheets/pares_craneales_tabla_general', {
    areaId: 'anatomia',
    topicId: 'pares_craneales_inervacion',
    title: 'Guía Maestra de los 12 Pares Craneales',
    summary: 'Nomenclatura, orificio de salida en la base del cráneo y función clínica esencial.',
    sourceBook: 'Rouvière - Anatomía Humana: Cabeza y Cuello (Tomo 1)',
    readMinutes: 4,
    isPremium: false,
    keyPoints: [
      'I (Olfatorio): Lámina cribosa | Sensitivo puro.',
      'II (Óptico): Conducto óptico | Sensitivo puro.',
      'III, IV, VI (Oculomotores): Fisura orbitaria superior | Motores de la musculatura extraocular.',
      'V (Trigémino): V1 (Fisura orbitaria superior), V2 (Foramen redondo), V3 (Foramen oval) | Mixto (sensibilidad facial y masticación).',
      'VII (Facial): Meato acústico interno y foramen estilomastoideo | Mixto (mímica facial, gusto 2/3 anteriores de la lengua).',
      'VIII (Vestibulococlear): Meato acústico interno | Sensorial (audición y equilibrio).',
      'IX (Glosofaríngeo), X (Vago), XI (Accesorio): Foramen yugular.',
      'XII (Hipogloso): Conducto del hipogloso | Motor de los músculos de la lengua.'
    ],
    mnemonics: ['"Oh Oh Madre Por Ti Me Fui A Galicia, No Van A Hospitalizarme" (I al XII).'],
    contentMarkdown: `### Resumen Sistemático de los 12 Pares Craneales
Los pares craneales inervan los órganos sensoriales, la musculatura cefálica y visceral toracoabdominal.`
  });

  await setDocument('medical_areas/anatomia/topics/pares_craneales_inervacion/cheatsheets/nervio_trigemino_v_ramas', {
    areaId: 'anatomia',
    topicId: 'pares_craneales_inervacion',
    title: 'Nervio Trigémino (V Par) y sus Tres Divisiones',
    summary: 'Nervio Oftálmico (V1), Maxilar (V2) y Mandibular (V3); ganglio de Gasser y territorios sensitivo/motores.',
    sourceBook: 'Rouvière - Anatomía Humana: Cabeza y Cuello (Tomo 1)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Ganglio Trigeminal (de Gasser): Asentado en la fosita trigeminal del peñasco del temporal (cueva de Meckel).',
      'V1 (Oftálmico): Sensitivo puro; ramas frontal, nasociliar y lagrimal.',
      'V2 (Maxilar): Sensitivo puro; ramas meníngea, cigomática, pterigopalatina, alveolar superior e infraorbitaria.',
      'V3 (Mandibular): Nervio mixto (único que lleva fibras motoras para los músculos masticadores); nervio lingual y nervio alveolar inferior.'
    ],
    mnemonics: ['V1 y V2 son puramente sensitivos; solo V3 es mixto (sensitivo y motor).'],
    contentMarkdown: `### El Nervio Trigémino
Principal nervio sensitivo de la cabeza y motor de los músculos de la masticación.`
  });

  await setDocument('medical_areas/anatomia/topics/pares_craneales_inervacion/cheatsheets/plexo_cervical_nervio_frenico', {
    areaId: 'anatomia',
    topicId: 'pares_craneales_inervacion',
    title: 'Plexo Cervical y Nervio Frénico',
    summary: 'Ramas superficiales (sensitivas) y profundas (motoras); asa cervical y origen del nervio frénico.',
    sourceBook: 'Rouvière - Anatomía Humana: Cabeza y Cuello (Tomo 1)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Constitución: Ramos anteriores de los primeros cuatro nervios cervicales (C1-C4).',
      'Plexo Cervical Superficial (Sensitivo): Emerge en el punto de Erb (borde posterior del ECM): occipital menor, auricular mayor, cervical transverso y supraclaviculares.',
      'Plexo Cervical Profundo (Motor): Ramos para los músculos prevertebrales, asa cervical (inerva músculos infrahioideos).',
      'Nervio Frénico: Se origina principalmente de C4 (con aportes de C3 y C5). Desciende por la cara anterior del músculo escaleno anterior hacia el diafragma.'
    ],
    mnemonics: ['"C3, 4 y 5 mantienen el diafragma vivo" (Nervio Frénico).'],
    contentMarkdown: `### Plexo Cervical y Funcionalidad
Inerva sensitivamente el cuello y hombro, y proporciona el control motor primario de la respiración (frénico).`
  });

  // ============================================================================
  // TEMA 6: VÍSCERAS DEL CUELLO Y ÓRGANOS DE LOS SENTIDOS
  // ============================================================================
  await setDocument('medical_areas/anatomia/topics/visceras_cuello_sentidos', {
    areaId: 'anatomia',
    title: 'Vísceras Cervicales y Órganos de los Sentidos',
    description: 'Faringe, laringe, glándula tiroides, ojo y aparato auditivo.',
    order: 6,
    cheatsheetsCount: 3,
    quizzesCount: 0
  });

  await setDocument('medical_areas/anatomia/topics/visceras_cuello_sentidos/cheatsheets/laringe_cuerdas_vocales', {
    areaId: 'anatomia',
    topicId: 'visceras_cuello_sentidos',
    title: 'Laringe, Cartílagos y Cuerdas Vocales',
    summary: 'Esqueleto cartilaginoso laríngeo, hendidura glótica y nervios laríngeos recurrente y superior.',
    sourceBook: 'Rouvière - Anatomía Humana: Cabeza y Cuello (Tomo 1)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Cartílagos Impares: Tiroides (manzana de Adán), Cricoides (en anillo de sello) y Epiglotis.',
      'Cartílagos Pares: Aritenoides (fijación de cuerdas vocales), Corniculados y Cuneiformes.',
      'Cuerdas Vocales Verdaderas: Músculo vocal y ligamento vocal fijados desde el tiroides al aritenoides.',
      'Inervación: Todos los músculos intrínsecos de la laringe están inervados por el Nervio Laríngeo Recurrente (X par), EXCEPTO el músculo cricotiroideo (inervado por el nervio laríngeo superior).'
    ],
    mnemonics: ['El músculo Cricotiroideo es el ÚNICO inervado por el Laríngeo Superior (tensa las cuerdas vocales).'],
    contentMarkdown: `### Anatomía de la Laringe
Órgano fonador y esfínter de la vía aérea inferior situado entre C3 y C6.`
  });

  await setDocument('medical_areas/anatomia/topics/visceras_cuello_sentidos/cheatsheets/tiroides_paratiroides', {
    areaId: 'anatomia',
    topicId: 'visceras_cuello_sentidos',
    title: 'Glándula Tiroides y Paratiroides',
    summary: 'Lóbulos tiroideos, istmo, cápsula peritiroidea, relación íntima con el nervio laríngeo recurrente.',
    sourceBook: 'Rouvière - Anatomía Humana: Cabeza y Cuello (Tomo 1)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Localización: Cara anterolateral del cuello, abrazando la tráquea y el cartílago cricoides.',
      'Morfología: Dos lóbulos laterales unidos por un istmo central a nivel del 2.° y 3.er anillo traqueal.',
      'Vascularización: Arterias tiroideas superiores (rama de carótida externa) y tiroideas inferiores (del tronco tirocervical de la subclavia).',
      'Relación Quirúrgica Crítica: El nervio laríngeo recurrente corre inmediatamente por detrás de los lóbulos tiroideos en el surco traqueoesofágico.'
    ],
    mnemonics: ['En la tiroidectomía, la lesión del nervio laríngeo recurrente causa disfonía o parálisis de la cuerda vocal.'],
    contentMarkdown: `### Glándula Tiroides y Paratiroides
Principal glándula endocrina metabólica del cuello, junto con las 4 glándulas paratiroides que regulan el metabolismo del calcio.`
  });

  await setDocument('medical_areas/anatomia/topics/visceras_cuello_sentidos/cheatsheets/aparato_auditivo_oido', {
    areaId: 'anatomia',
    topicId: 'visceras_cuello_sentidos',
    title: 'Órgano de la Audición y el Equilibrio (Oído)',
    summary: 'Oído externo, membrana timpánica, cadena de huesecillos del oído medio y laberinto del oído interno.',
    sourceBook: 'Rouvière - Anatomía Humana: Cabeza y Cuello (Tomo 1)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Oído Externo: Pabellón auricular y meato acústico externo.',
      'Oído Medio (Caja del Tímpano): Contiene la cadena osicular: Martillo, Yunque y Estribo (que apoya sobre la ventana oval).',
      'Trompa de Eustaquio (Auditiva): Comunica la caja timpánica con la nasofaringe para equilibrar presiones.',
      'Oído Interno (Laberinto Óseo y Membranoso): Cóclea o caracol (audición, órgano de Corti) y Canales Semicirculares con Utrículo y Sáculo (equilibrio cinético y estático).'
    ],
    mnemonics: ['Cadena Osicular de lateral a medial: Martillo -> Yunque -> Estribo.'],
    contentMarkdown: `### Anatomía del Aparato Auditivo
Encapsulado dentro de la porción petrosa del temporal, combina la transducción acústica y la orientación espacial en los tres ejes.`
  });

  console.log('\n=================================================================');
  console.log('¡CARGA COMPLETA DE ROUVIÈRE TOMO 1 EN FIRESTORE FINALIZADA!');
  console.log('6 Temas Clínicos y 18 Chuletas de Alto Rendimiento sincronizadas.');
  console.log('Relación de datos: Estrictamente 1:N sin relaciones muchos a muchos.');
  console.log('=================================================================');
}

main().catch(err => {
  console.error('Error durante la carga:', err);
  process.exit(1);
});
