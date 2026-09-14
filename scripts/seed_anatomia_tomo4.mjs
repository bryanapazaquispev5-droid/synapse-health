// Script de carga integral para Anatomía Humana Tomo 4 (Sistema Nervioso Central - Rouvière / Delmas)
// NO MODIFICA LOS TEMAS DEL TOMO 1, 2 NI 3 (permanecen 100% intactos).
// Se agregan los temas 19 a 24 con sus respectivas chuletas clínicas.
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
  console.log('Iniciando carga de Tomo 4 de Rouvière (Sistema Nervioso Central)...\n');

  // 1. ACTUALIZAR CONTADORES GLOBALES DEL ÁREA MÉDICA (18 temas previos + 6 temas nuevos = 24 temas; 49 + 12 = 61 chuletas)
  await setDocument('medical_areas/anatomia', {
    name: 'Anatomía Humana',
    code: 'ANATOMIA',
    order: 1,
    topicsCount: 24,
    cheatsheetsCount: 61,
    quizzesCount: 0,
    isAvailable: true
  });

  // ============================================================================
  // TEMA 19: MÉDULA ESPINAL Y MENINGES RAQUÍDEAS
  // ============================================================================
  await setDocument('medical_areas/anatomia/topics/medula_espinal_meninges', {
    areaId: 'anatomia',
    title: 'Médula Espinal y Meninges Raquídeas',
    description: 'Configuración externa/interna, cono medular, astas de sustancia gris, cordones y punción lumbar.',
    order: 19,
    cheatsheetsCount: 2,
    quizzesCount: 0
  });

  await setDocument('medical_areas/anatomia/topics/medula_espinal_meninges/cheatsheets/medula_espinal_puncion_lumbar', {
    areaId: 'anatomia',
    topicId: 'medula_espinal_meninges',
    title: 'Morfología Medular y Punción Lumbar',
    summary: 'Límites, intumescencias cervical y lumbar, terminación en cono medular y espacio subaracnoideo.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 4 (Sistema Nervioso Central)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Límites: Comienza en el foramen magno (continuación del bulbo) y finaliza en el cono medular a nivel de L1-L2 en adultos (L3 en recién nacidos).',
      'Filum Terminale: Prolongación de la piamadre que desciende desde el cono hasta fijarse en el cóccix (ligamento coccígeo).',
      'Cauda Equina (Cola de Caballo): Conjunto de raíces nerviosas lumbosacras que descienden verticalmente por debajo del cono medular.',
      'Cisterna Lumbar y Punción Lumbar: Se realiza en el espacio intervertebral L3-L4 o L4-L5 (línea bitrocantérea o de Tuffier sobre las crestas ilíacas) atravesando piel, ligamentos supraespinoso, interespinoso, amarillo y duramadre.',
      'Ligamentos Dentados: Engrosamientos laterales triangulares de piamadre que fijan la médula a la duramadre entre las raíces anterior y posterior.'
    ],
    mnemonics: [
      'Nivel de Punción Lumbar: "L3-L4 o L4-L5, la aguja pasa y la médula no toca".'
    ],
    contentMarkdown: `### Anatomía Topográfica de la Médula Espinal
Alojada en el conducto vertebral, presenta dos engrosamientos (intumescencias cervical y lumbosacra) correspondientes al origen de los plexos para las extremidades.`
  });

  await setDocument('medical_areas/anatomia/topics/medula_espinal_meninges/cheatsheets/sustancia_gris_laminas_rexed', {
    areaId: 'anatomia',
    topicId: 'medula_espinal_meninges',
    title: 'Sustancia Gris Medular y Láminas de Rexed',
    summary: 'Astas anterior motora, posterior sensitiva y lateral vegetativa; organización citoarquitectónica.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 4 (Sistema Nervioso Central)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Asta Anterior (Ventral): Función motora somática (motoneuronas alfa y gamma); somatotopía: flexores mediales, extensores laterales.',
      'Asta Posterior (Dorsal): Función sensitiva aferente somática y visceral; recibe los axones de los ganglios de la raíz dorsal.',
      'Asta Lateral (Intermediolateral): Presente únicamente en los segmentos T1 a L2 (eferencia simpática presináptica) y S2 a S4 (eferencia parasimpática sacra).',
      'Láminas de Rexed: División en 10 láminas; Lámina II = Sustancia gelatinosa de Rolando (modulación del dolor); Lámina IX = Núcleos motores de motoneuronas alfa.'
    ],
    mnemonics: [
      'Asta Anterior = Motora (eferente) | Asta Posterior = Sensitiva (aferente).'
    ],
    contentMarkdown: `### Citoarquitectura Medular
La sustancia gris en forma de 'H' o mariposa rodea el conducto ependimario central y se divide en núcleos y láminas funcionales de Rexed.`
  });

  // ============================================================================
  // TEMA 20: TRONCO ENCEFÁLICO Y CUARTO VENTRÍCULO
  // ============================================================================
  await setDocument('medical_areas/anatomia/topics/tronco_encefalico_cuarto_ventriculo', {
    areaId: 'anatomia',
    title: 'Tronco Encefálico y Cuarto Ventrículo',
    description: 'Bulbo raquídeo, protuberancia anular, mesencéfalo, fosa romboidea y orígenes de pares craneales.',
    order: 20,
    cheatsheetsCount: 2,
    quizzesCount: 0
  });

  await setDocument('medical_areas/anatomia/topics/tronco_encefalico_cuarto_ventriculo/cheatsheets/bulbo_puente_fosa_romboidea', {
    areaId: 'anatomia',
    topicId: 'tronco_encefalico_cuarto_ventriculo',
    title: 'Bulbo Raquídeo y Protuberancia: Fosa Romboidea',
    summary: 'Pirámides, decusación motora, olivas, núcleos gracil/cuneiforme y suelo del 4.° ventrículo.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 4 (Sistema Nervioso Central)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Bulbo Raquídeo (Médula Oblongada): Pirámides anteriores (vía corticoespinal motora con decusación en el tercio inferior); Olivas bulbares (núcleo olivar inferior para coordinación motora).',
      'Cara Posterior del Bulbo: Tubérculos grácil (de Goll, medial) y cuneiforme (de Burdach, lateral) para la propiocepción consciente.',
      'Surco Bulboprotuberancial: Origen aparente de los pares craneales VI (abducens en línea media), VII (facial con el intermediario) y VIII (vestibulococlear lateralmente).',
      'Protuberancia (Puente de Varolio): Cara anterior surcada por el canal basilar; emergencia del nervio trigémino (V) en su cara anterolateral.',
      'Fosa Romboidea: Suelo del 4.° ventrículo; dividida en triángulo bulbar inferior (alas blanca interna/hipogloso, gris/vago y blanca externa) y triángulo pontino superior (eminencia media y colículo facial/colículo del VII).'
    ],
    mnemonics: [
      'En el surco bulboprotuberancial de medial a lateral: Pares VI, VII y VIII.'
    ],
    contentMarkdown: `### Anatomía del Bulbo y el Puente
Contiene los centros reflejos autónomos vitales del organismo: centro respiratorio, vasomotor y de la deglución.`
  });

  await setDocument('medical_areas/anatomia/topics/tronco_encefalico_cuarto_ventriculo/cheatsheets/mesencefalo_coliculos_techo', {
    areaId: 'anatomia',
    topicId: 'tronco_encefalico_cuarto_ventriculo',
    title: 'Mesencéfalo: Pedúnculos, Colículos y Cuarto Ventrículo',
    summary: 'Pedúnculos cerebrales, sustancia negra de Soemmerring, techo mesencefálico y acueducto de Silvio.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 4 (Sistema Nervioso Central)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Pedúnculos Cerebrales: Dos gruesos pilares divergentes que conducen las vías motoras descendentes (haz corticoespinal y corticobulbar).',
      'Sustancia Negra (Locus Niger de Soemmerring): Núcleo dopaminérgico interpuesto entre el pie peduncular y el tegmento; su degeneración causa la enfermedad de Parkinson.',
      'Núcleo Rojo: Relevo motor subcortical del tono flexor (haz rubroespinal).',
      'Lámina del Techo (Tectum): Presenta los 4 tubérculos cuadrigéminos: Colículos Superiores (reflejos visuales y movimientos sacádicos) y Colículos Inferiores (relevo de la vía auditiva).',
      'Acueducto Mesencefálico (de Silvio): Estrecho conducto central que comunica el 3.er ventrículo con el 4.° ventrículo.',
      'Emergencia del IV Par (Troclear/Patético): Único par craneal que emerge por la cara POSTERIOR del tronco del encéfalo y cruza hacia el lado opuesto.'
    ],
    mnemonics: [
      'Colículos Superiores = Ojos (Visión) | Colículos Inferiores = Oídos (Audición).'
    ],
    contentMarkdown: `### El Segmento Mesencefálico
Es el segmento superior del tronco encefálico que conecta la protuberancia con el diencéfalo y prosencéfalo.`
  });

  // ============================================================================
  // TEMA 21: CEREBELO Y CONEXIONES CEREBELOSAS
  // ============================================================================
  await setDocument('medical_areas/anatomia/topics/cerebelo_vias_cerebelosas', {
    areaId: 'anatomia',
    title: 'Cerebelo y Circuitos de Coordinación Motora',
    description: 'Vermis, hemisferios cerebelosos, corteza, núcleos profundos y división funcional filogenética.',
    order: 21,
    cheatsheetsCount: 2,
    quizzesCount: 0
  });

  await setDocument('medical_areas/anatomia/topics/cerebelo_vias_cerebelosas/cheatsheets/arquitectura_nucleos_profundos', {
    areaId: 'anatomia',
    topicId: 'cerebelo_vias_cerebelosas',
    title: 'Corteza Cerebelosa y Núcleos Grises Profundos',
    summary: 'Las 3 capas de la corteza, células de Purkinje, árbol de la vida y los 4 núcleos profundos.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 4 (Sistema Nervioso Central)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Configuración: Ocupa la fosa craneal posterior debajo de la tienda del cerebelo (tentorio); consta de un lóbulo central (vermis) y dos hemisferios cerebelosos.',
      'Corteza Cerebelosa (3 capas de superficial a profunda): 1. Capa Molecular (interneuronas estrelladas y en cesto); 2. Capa de Células de Purkinje (únicas neuronas eferentes de la corteza, inhibidoras GABAérgicas); 3. Capa Granular (neuronas granulosas excitadoras con fibras musgosas).',
      'Núcleos Profundos (de lateral a medial): Núcleo Dentado (el más grande, neocerebelo), Núcleo Émbolo (emboliforme), Núcleo Globoso y Núcleo del Fastigio (del techo).',
      'Pedúnculos Cerebelosos: Superior (eferencias al tálamo y núcleo rojo), Medio (aferencias corticopontinas, el más grueso) e Inferior (aferencias vestibulares y espinocerebelosas).'
    ],
    mnemonics: [
      'Núcleos profundos de lateral a medial: "D-E-G-F" = Dentado, Émbolo, Globoso, Fastigio ("Don Émbolo Guarda Frutas").'
    ],
    contentMarkdown: `### Morfología Interna del Cerebelo
La sustancia blanca central se ramifica con aspecto arborescente ("árbol de la vida") envolviendo los núcleos grises profundos.`
  });

  await setDocument('medical_areas/anatomia/topics/cerebelo_vias_cerebelosas/cheatsheets/division_filogenetica_sindrome_cerebeloso', {
    areaId: 'anatomia',
    topicId: 'cerebelo_vias_cerebelosas',
    title: 'División Funcional y Síndrome Cerebeloso',
    summary: 'Arquicerebelo, paleocerebelo, neocerebelo, ataxia, dismetría y disdiadococinesia.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 4 (Sistema Nervioso Central)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Arquicerebelo (Vestibulocerebelo): Lóbulo floculonodular; conectado al aparato vestibular del oído; regula el equilibrio corporal y movimientos oculares (nistagmo si se lesiona).',
      'Paleocerebelo (Espinocerebelo): Vermis y zona paravermal; conectado a la médula por los haces espinocerebelosos; controla el tono muscular y la postura axial.',
      'Neocerebelo (Cerebrocerebelo / Pontocerebelo): La mayor parte de los hemisferios cerebelosos y núcleo dentado; conectado a la corteza cerebral motora; planifica y modula la motricidad fina voluntaria.',
      'Signos del Síndrome Neocerebeloso: Dismetría (prueba dedo-nariz alterada), Disdiadococinesia (incapacidad para movimientos alternantes rápidos), Temblor intencional (aumenta al llegar al blanco) y Ataxia apendicular ipsilateral.'
    ],
    mnemonics: [
      'Las lesiones cerebelosas causan déficit motor en el lado IPSILATERAL (mismo lado) del cuerpo.'
    ],
    contentMarkdown: `### Fisiopatología Topográfica Cerebelosa
El cerebelo no inicia el movimiento voluntario, sino que actúa como un servomecanismo comparador entre la intención motora y la ejecución periférica.`
  });

  // ============================================================================
  // TEMA 22: DIENCÉFALO Y SISTEMA LÍMBICO
  // ============================================================================
  await setDocument('medical_areas/anatomia/topics/diencefalo_sistema_limbico', {
    areaId: 'anatomia',
    title: 'Diencéfalo, Tercer Ventrículo y Sistema Límbico',
    description: 'Tálamo óptico, hipotálamo, subtálamo, epitálamo, hipocampo y circuito emocional de Papez.',
    order: 22,
    cheatsheetsCount: 2,
    quizzesCount: 0
  });

  await setDocument('medical_areas/anatomia/topics/diencefalo_sistema_limbico/cheatsheets/talamo_hipotalamo_nucleos', {
    areaId: 'anatomia',
    topicId: 'diencefalo_sistema_limbico',
    title: 'Tálamo e Hipotálamo: Centros de Relevo y Homeostasis',
    summary: 'Masa nuclear del tálamo, núcleos VPL/VPM, cuerpos geniculados y centros hipotalámicos.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 4 (Sistema Nervioso Central)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Tálamo: Gran masa ovoide de sustancia gris que forma las paredes laterales del 3.er ventrículo. Estación de relevo de TODAS las vías sensitivas antes de llegar a la corteza, con la única excepción del olfato.',
      'Núcleo Ventral Posterolateral (VPL): Releva la sensibilidad del cuerpo (vías lemniscal y espinotalámica).',
      'Núcleo Ventral Posteromedial (VPM): Releva la sensibilidad trigeminal de la cara y el gusto.',
      'Cuerpos Geniculados: Lateral (visión, recibe del tracto óptico) y Medial (audición, recibe del colículo inferior).',
      'Hipotálamo: Piso y paredes inferolaterales del 3.er ventrículo; controla el sistema nervioso autónomo, la hipófisis endocrina (eje hipotálamo-hipofisario), la temperatura, el hambre y la sed.'
    ],
    mnemonics: [
      'Geniculado Lateral = Luz (Visión) | Geniculado Medial = Música (Audición).'
    ],
    contentMarkdown: `### El Diencéfalo Central
Estructura medial profunda del cerebro interpuesta entre el tronco encefálico y los hemisferios telencefálicos.`
  });

  await setDocument('medical_areas/anatomia/topics/diencefalo_sistema_limbico/cheatsheets/tercer_ventriculo_circuito_papez', {
    areaId: 'anatomia',
    topicId: 'diencefalo_sistema_limbico',
    title: 'Tercer Ventrículo y Circuito de Papez (Memoria y Emociones)',
    summary: 'Agujero de Monro, fórnix, hipocampo, amígdala y memoria episódica.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 4 (Sistema Nervioso Central)',
    readMinutes: 2,
    isPremium: false,
    keyPoints: [
      'Tercer Ventrículo: Hendidura sagital media impar entre ambos tálamos; se comunica hacia arriba con los ventrículos laterales por los forámenes interventriculares (de Monro) y hacia abajo con el 4.° ventrículo por el acueducto de Silvio.',
      'Circuito de Papez: Circuito neuronal básico de las emociones y la consolidación de la memoria: Hipocampo -> Fórnix (trígono) -> Cuerpos mamilares -> Fascículo mamilotalámico (de Vicq d\'Azyr) -> Núcleo anterior del tálamo -> Giro del cíngulo -> Corteza entorrinal -> Hipocampo.',
      'Amígdala Cerebral: En el polo temporal anterior; centro del procesamiento del miedo y la agresividad.',
      'Hipocampo: Estructura del lóbulo temporal medial esencial para convertir la memoria a corto plazo en memoria a largo plazo (declarativa).'
    ],
    mnemonics: [
      'Lesión bilateral del hipocampo = Amnesia anterógrada (incapacidad para formar nuevos recuerdos).'
    ],
    contentMarkdown: `### El Cerebro Emocional y de la Memoria
El sistema límbico forma un anillo de corteza y núcleos alrededor del cuerpo calloso y el tronco encefálico fundamental para la supervivencia y conducta.`
  });

  // ============================================================================
  // TEMA 23: TELENCÉFALO: CORTEZA CEREBRAL Y NÚCLEOS BASALES
  // ============================================================================
  await setDocument('medical_areas/anatomia/topics/telencefalo_corteza_ganglios_base', {
    areaId: 'anatomia',
    title: 'Telencéfalo: Corteza y Núcleos Basales',
    description: 'Cisuras cerebrales, lóbulos, áreas citoarquitectónicas de Brodmann, núcleos basales y cápsula interna.',
    order: 23,
    cheatsheetsCount: 2,
    quizzesCount: 0
  });

  await setDocument('medical_areas/anatomia/topics/telencefalo_corteza_ganglios_base/cheatsheets/areas_brodmann_lobulos_cerebrales', {
    areaId: 'anatomia',
    topicId: 'telencefalo_corteza_ganglios_base',
    title: 'Lóbulos Cerebrales y Áreas de Brodmann',
    summary: 'Cisura de Rolando y Silvio, cortezas motora, sensitiva, visual, auditiva y áreas del lenguaje (Broca y Wernicke).',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 4 (Sistema Nervioso Central)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Cisura Central (de Rolando): Separa el lóbulo frontal del parietal. Delante está el giro precentral (Área 4 motora primaria); detrás está el giro poscentral (Áreas 3, 1, 2 somatosensitivas primarias con el homúnculo de Penfield).',
      'Cisura Lateral (de Silvio): Separa el lóbulo frontal y parietal del lóbulo temporal.',
      'Área Visual Primaria (Área 17 de Brodmann): En los labios de la cisura calcarina del lóbulo occipital.',
      'Área Auditiva Primaria (Áreas 41 y 42): Giros temporales transversos de Heschl en el lóbulo temporal.',
      'Área de Broca (Áreas 44 y 45): En la porción opercular y triangular del giro frontal inferior del hemisferio dominante (articulación motora del lenguaje; su lesión causa afasia motora o no fluente).',
      'Área de Wernicke (Área 22): En la porción posterior del giro temporal superior (comprensión del lenguaje; su lesión causa afasia sensitiva o fluente).'
    ],
    mnemonics: [
      'Broca "Boca" (expresión motora, lóbulo frontal) | Wernicke "Oído" (comprensión sensitiva, lóbulo temporal).'
    ],
    contentMarkdown: `### Cartografía de la Corteza Cerebral
Los hemisferios presentan una corteza plegada en giros y surcos que maximiza el área de superficie neuronal dentro de la cavidad craneal.`
  });

  await setDocument('medical_areas/anatomia/topics/telencefalo_corteza_ganglios_base/cheatsheets/ganglios_base_capsula_interna', {
    areaId: 'anatomia',
    topicId: 'telencefalo_corteza_ganglios_base',
    title: 'Ganglios de la Base y Cápsula Interna',
    summary: 'Núcleo caudado, putamen, globo pálido, cuerpo estriado y segmentos de la cápsula interna.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 4 (Sistema Nervioso Central)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Cuerpo Estriado: Formado por el Núcleo Caudado (en forma de "C" abrazando el ventrículo lateral) y el Núcleo Lenticular.',
      'Núcleo Lenticular: Dividido por una lámina medular en Putamen (lateral, más oscuro) y Globo Pálido (medial, pálido).',
      'Vías de los Ganglios Basales: Vía directa (activa el movimiento cortical, pro-motora) y Vía indirecta (frena e inhibe movimientos no deseados).',
      'Cápsula Interna: Gruesa banda en "V" de sustancia blanca interpuesta entre el tálamo, el caudado y el lenticular.',
      'Segmentos de la Cápsula Interna: Brazo Anterior (fibras frontopontinas), Rodilla (haz corticonuclear o corticobulbar hacia los pares craneales) y Brazo Posterior (haz corticoespinal motor y radiaciones somatosensitivas).',
      'Ictus Isquémico de la Cápsula Interna: La oclusión de las arterias lenticuloestriadas causa hemiplejía motora pura contralateral completa y proporcionada.'
    ],
    mnemonics: [
      'Por el brazo posterior de la cápsula interna bajan las fibras corticoespinales que controlan el cuerpo contralateral.'
    ],
    contentMarkdown: `### Núcleos Subcorticales Motores
Circuitos en asa que modulan la amplitud, velocidad y automatismo de los patrones motores antes de su ejecución.`
  });

  // ============================================================================
  // TEMA 24: VÍAS NERVIOSAS, LÍQUIDO CEFALORRAQUÍDEO Y MENINGES
  // ============================================================================
  await setDocument('medical_areas/anatomia/topics/vias_nerviosas_lcr_meninges', {
    areaId: 'anatomia',
    title: 'Vías Nerviosas, Líquido Cefalorraquídeo y Meninges',
    description: 'Vía piramidal motora, vías sensitivas lemniscal y espinotalámica, plexos coroideos y circulación del LCR.',
    order: 24,
    cheatsheetsCount: 2,
    quizzesCount: 0
  });

  await setDocument('medical_areas/anatomia/topics/vias_nerviosas_lcr_meninges/cheatsheets/vias_motoras_piramidales_sensitivas', {
    areaId: 'anatomia',
    topicId: 'vias_nerviosas_lcr_meninges',
    title: 'Vías Motoras Piramidales y Vías Sensitivas Mayores',
    summary: 'Haz corticoespinal cruzado/directo, sistema lemniscal (Goll y Burdach) y haz espinotalámico.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 4 (Sistema Nervioso Central)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Vía Motora Piramidal (Haz Corticoespinal): Nace en el área 4 motora (células gigantes de Betz); desciende por el brazo posterior de la cápsula interna, pedúnculos y protuberancia. En el bulbo, el 85-90% de las fibras decusan formando el Haz Corticoespinal Lateral, mientras que el 10-15% desciende directo como Haz Corticoespinal Anterior.',
      'Sistema de la Columna Dorsal - Lemnisco Medial: Conduce propiocepción consciente, vibración y tacto epicrítico (fino); axones ascienden ipsilateralmente por los fascículos grácil y cuneiforme, hacen sinapsis en el bulbo, decusan formando el lemnisco medial y llegan al núcleo VPL del tálamo.',
      'Haz Espinotalámico Lateral y Anterior: Conduce dolor y temperatura (lateral) y tacto protopático/grueso (anterior); los axones decusan INMEDIATAMENTE en la médula espinal por la comisura blanca anterior antes de ascender.',
      'Signo de Babinski: Respuesta extensora del dedo gordo al estimular la planta del pie; signo patognomónico de lesión de la primera motoneurona (vía piramidal).'
    ],
    mnemonics: [
      'Espinotalámico decusa en la MÉDULA | Lemnisco medial decusa en el BULBO.'
    ],
    contentMarkdown: `### Los Grandes Fascículos Ascendentes y Descendentes
Las autopistas neuronales que transmiten los comandos motores voluntarios hacia la periferia y devuelven la información somatosensorial consciente al encéfalo.`
  });

  await setDocument('medical_areas/anatomia/topics/vias_nerviosas_lcr_meninges/cheatsheets/circulacion_lcr_hidrocefalia', {
    areaId: 'anatomia',
    topicId: 'vias_nerviosas_lcr_meninges',
    title: 'Circulación del Líquido Cefalorraquídeo e Hidrocefalia',
    summary: 'Plexos coroideos, volumen y velocidad de producción, forámenes ventriculares y vellosidades aracnoideas.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 4 (Sistema Nervioso Central)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Producción de LCR: Producido continuamente a un ritmo de ~500 ml/día por los plexos coroideos en los ventrículos laterales, 3.er y 4.° ventrículo; volumen circulante normal: 120-150 ml.',
      'Ruta de Circulación: Ventrículos laterales -> Agujeros interventriculares (de Monro) -> 3.er ventrículo -> Acueducto mesencefálico (de Silvio) -> 4.° ventrículo.',
      'Salida al Espacio Subaracnoideo: Desde el 4.° ventrículo a través de tres orificios: 2 laterales (de Luschka) y 1 medio (de Magendie) hacia la cisterna magna.',
      'Reabsorción: En las vellosidades aracnoideas (granulaciones de Pacchioni) que drenan pasivamente el LCR hacia el seno sagital superior y la circulación venosa sistémica.',
      'Hidrocefalia: No comunicante u obstructiva (bloqueo en acueducto de Silvio o forámenes) vs Comunicante (falla en la reabsorción aracnoidea o hemorragia subaracnoidea).'
    ],
    mnemonics: [
      'Orificios del 4.° ventrículo: Luschka = Laterales | Magendie = Medial.'
    ],
    contentMarkdown: `### Hidrodinámica del LCR
Proporciona flotabilidad física amortiguando el peso neto del encéfalo de 1400 g a sólo 50 g, mantiene el equilibrio hidroelectrolítico y drena desechos metabólicos.`
  });

  console.log('\n=================================================================');
  console.log('¡CARGA DEL TOMO 4 DE ROUVIÈRE (SNC) EN FIRESTORE FINALIZADA!');
  console.log('Nuevos temas: 19 al 24 | Nuevas chuletas: 12 adicionales.');
  console.log('Total en Anatomía: 24 Temas y 61 Chuletas de Alto Rendimiento.');
  console.log('Tomos 1, 2 y 3 intactos sin alteraciones.');
  console.log('=================================================================');
}

main().catch(err => {
  console.error('Error durante la carga:', err);
  process.exit(1);
});
