// Script de carga integral para Anatomía Humana Tomo 3 (Miembros: Superior e Inferior - Rouvière / Delmas)
// NO MODIFICA LOS TEMAS DEL TOMO 1 NI DEL TOMO 2 (permanecen 100% intactos).
// Se agregan los temas 13 a 18 con sus respectivas chuletas clínicas.
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
  console.log('Iniciando carga de Tomo 3 de Rouvière (Miembros: Superior e Inferior)...\n');

  // 1. ACTUALIZAR CONTADORES GLOBALES DEL ÁREA MÉDICA (12 temas anteriores + 6 temas nuevos = 18 temas; 34 + 15 = 49 chuletas)
  await setDocument('medical_areas/anatomia', {
    name: 'Anatomía Humana',
    code: 'ANATOMIA',
    order: 1,
    topicsCount: 18,
    cheatsheetsCount: 49,
    quizzesCount: 0,
    isAvailable: true
  });

  // ============================================================================
  // TEMA 13: CINTURA ESCAPULAR, HOMBRO Y REGIÓN AXILAR
  // ============================================================================
  await setDocument('medical_areas/anatomia/topics/cintura_escapular_hombro', {
    areaId: 'anatomia',
    title: 'Cintura Escapular, Hombro y Región Axilar',
    description: 'Clavícula, escápula, articulación glenohumeral, manguito rotador y límites/contenido de la axila.',
    order: 13,
    cheatsheetsCount: 2,
    quizzesCount: 0
  });

  await setDocument('medical_areas/anatomia/topics/cintura_escapular_hombro/cheatsheets/manguito_rotador_glenohumeral', {
    areaId: 'anatomia',
    topicId: 'cintura_escapular_hombro',
    title: 'Manguito Rotador y Articulación Glenohumeral',
    summary: 'Sinovial esferoidea de máxima movilidad, rodete glenoideo y los cuatro tendones del manguito estabilizador.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 3 (Miembros)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Articulación Glenohumeral: Esferoidea multiaxial; la cavidad glenoidea es poco profunda y se amplía con el labrum o rodete glenoideo fibrocartilaginoso.',
      'Manguito de los Rotadores: Cuatro músculos que coaptan la cabeza humeral activamente en la fosa glenoidea: Supraespinoso, Infraespinoso, Redondo menor y Subescapular (regla SITS).',
      'Supraespinoso: Inicia los primeros 15° de abducción del brazo; es el tendón más frecuentemente lesionado en el síndrome subacromial.',
      'Subescapular: Único rotador medial del manguito; se inserta en el troquín (tubérculo menor).',
      'Infraespinoso y Redondo Menor: Potentes rotadores laterales del hombro; se insertan en el troquíter (tubérculo mayor).'
    ],
    mnemonics: [
      'Mnemotecnia "SITS": Supraespinoso, Infraespinoso, Teres minor (Redondo menor) y Subescapular.'
    ],
    contentMarkdown: `### Biomecánica y Manguito del Hombro
La articulación con mayor rango de movimiento del cuerpo humano sacrifica estabilidad ósea a favor de la movilidad, dependiendo críticamente de la cinemática del manguito rotador.`
  });

  await setDocument('medical_areas/anatomia/topics/cintura_escapular_hombro/cheatsheets/fosa_axilar_paredes_contenido', {
    areaId: 'anatomia',
    topicId: 'cintura_escapular_hombro',
    title: 'Fosa Axilar: Paredes y Contenido Neurovascular',
    summary: 'Pirámide cuadrangular, límites anatómicos, paquete axilar y ramas del plexo braquial.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 3 (Miembros)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Vértice: Conducto cervicoaxilar delimitado por la clavícula, 1.ª costilla y borde superior de la escápula.',
      'Pared Anterior: Músculos pectoral mayor, pectoral menor y subclavio, con la fascia clavipectoral.',
      'Pared Posterior: Músculos subescapular, redondo mayor y dorsal ancho.',
      'Pared Medial: Primeras 4 costillas con los músculos intercostales y serrato anterior (inervado por el nervio torácico largo de Bell).',
      'Pared Lateral: Surco intertubercular del húmero.',
      'Contenido: Arteria axilar y sus ramas, vena axilar, fascículos del plexo braquial y ganglios linfáticos axilares (niveles de Berg I, II y III).'
    ],
    mnemonics: [
      'Lesión del Nervio Torácico Largo (serrato anterior) = "Escápula alada".'
    ],
    contentMarkdown: `### Encrucijada Axilar
Paso obligatorio de todos los vasos y nervios que comunican la raíz del cuello con el miembro superior.`
  });

  // ============================================================================
  // TEMA 14: BRAZO, CODO Y ANTEBRAZO: PLEXO BRAQUIAL
  // ============================================================================
  await setDocument('medical_areas/anatomia/topics/brazo_codo_antebrazo', {
    areaId: 'anatomia',
    title: 'Brazo, Codo y Antebrazo: Plexo Braquial',
    description: 'Plexo braquial (C5-T1), compartimentos braquiales, fosa del codo y músculos del antebrazo.',
    order: 14,
    cheatsheetsCount: 3,
    quizzesCount: 0
  });

  await setDocument('medical_areas/anatomia/topics/brazo_codo_antebrazo/cheatsheets/plexo_braquial_raices_terminales', {
    areaId: 'anatomia',
    topicId: 'brazo_codo_antebrazo',
    title: 'Plexo Braquial: De las Raíces a los Ramos Terminales',
    summary: 'Raíces C5-T1, troncos primarios, divisiones, fascículos secundarios y los cinco grandes nervios terminales.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 3 (Miembros)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Raíces: Ramos anteriores de C5, C6, C7, C8 y T1.',
      'Troncos Primarios: Superior (C5-C6), Medio (C7), Inferior (C8-T1).',
      'Fascículos (Cordones en relación a la arteria axilar): Lateral, Medial y Posterior (formado por las 3 divisiones posteriores).',
      'Ramos Terminales del Fascículo Posterior: Nervio Radial (extensor de todo el miembro superior) y Nervio Axilar (deltoides y redondo menor).',
      'Ramos Terminales del Fascículo Lateral y Medial: Nervio Musculocutáneo (lateral), Nervio Cubital (medial) y Nervio Mediano (formado por la horquilla de las raíces lateral y medial).'
    ],
    mnemonics: [
      'Horquilla del Nervio Mediano en "M" sobre la cara anterior de la arteria axilar.'
    ],
    contentMarkdown: `### Organización del Plexo Braquial
Proporciona la inervación sensitiva y motora para todo el hombro, brazo, antebrazo y mano.`
  });

  await setDocument('medical_areas/anatomia/topics/brazo_codo_antebrazo/cheatsheets/fosa_codo_canales_bicipitales', {
    areaId: 'anatomia',
    topicId: 'brazo_codo_antebrazo',
    title: 'Fosa del Codo y Canales Bicipitales',
    summary: 'Triángulo anterior del codo, aponeurosis bicipital, paquete braquial y bifurcación radial/cubital.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 3 (Miembros)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Límites: Base (línea bicondílea transversal entre epicóndilo y epitróclea), Límite lateral (músculo braquiorradial), Límite medial (músculo pronador redondo).',
      'Suelo: Músculo braquial anterior y músculo supinador corto.',
      'Canal Bicipital Medial: Entre el tendón del bíceps y el pronador redondo. Contiene la Arteria Braquial (humeral) y el Nervio Mediano.',
      'Canal Bicipital Lateral: Entre el tendón del bíceps y el braquiorradial. Contiene el Nervio Radial dividiéndose en rama superficial (sensitiva) y profunda (motora).',
      'Superficial: Vena mediana del codo uniendo la vena cefálica y la basílica (sitio común de punción venosa).'
    ],
    mnemonics: [
      'En el pliegue del codo de medial a lateral: Nervio mediano, Arteria braquial, Tendón del bíceps (NAT).'
    ],
    contentMarkdown: `### Anatomía Topográfica de la Fosa Cubital
Región de transición crítica donde la arteria braquial se bifurca en sus dos ramas terminales: arteria radial y arteria cubital.`
  });

  await setDocument('medical_areas/anatomia/topics/brazo_codo_antebrazo/cheatsheets/compartimentos_antebrazo_musculos', {
    areaId: 'anatomia',
    topicId: 'brazo_codo_antebrazo',
    title: 'Músculos del Antebrazo: Flexores y Extensores',
    summary: 'Grupos anterior (epitrocleares), posterior (radiales y extensores) y lateral; inervación por Mediano, Radial y Cubital.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 3 (Miembros)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Compartimento Anterior (Flexor/Pronador): Inervado predominantemente por el Nervio Mediano, EXCEPTO el flexor cubital del carpo y la mitad medial del flexor profundo de los dedos (inervados por el nervio Cubital).',
      'Músculos Epitrocleares Superficiales (de lateral a medial): Pronador redondo, Flexor radial del carpo (palmar mayor), Palmar largo (menor) y Flexor cubital del carpo (cubital anterior).',
      'Compartimento Posterior y Lateral (Extensor/Supinador): Todos inervados por ramos del Nervio Radial.',
      'Músculo Pronador Cuadrado: El músculo más profundo del compartimento anterior, clave en la pronación.'
    ],
    mnemonics: [
      'Músculos epitrocleares superficiales: "Pro-Pal-Pal-Cu" (Pronador redondo, Palmar mayor, Palmar menor, Cubital anterior).'
    ],
    contentMarkdown: `### Miología del Antebrazo
Veinte músculos distribuidos en tres compartimentos fasciales que controlan la muñeca, los dedos y los movimientos de pronosupinación.`
  });

  // ============================================================================
  // TEMA 15: MUÑECA, MANO Y TÚNEL CARPIANO
  // ============================================================================
  await setDocument('medical_areas/anatomia/topics/muneca_mano_tunel_carpiano', {
    areaId: 'anatomia',
    title: 'Muñeca, Mano y Túnel Carpiano',
    description: 'Huesos del carpo, retináculo flexor, túnel carpiano, canal de Guyon y tabaquera anatómica.',
    order: 15,
    cheatsheetsCount: 3,
    quizzesCount: 0
  });

  await setDocument('medical_areas/anatomia/topics/muneca_mano_tunel_carpiano/cheatsheets/huesos_carpo_mnemotecnia', {
    areaId: 'anatomia',
    topicId: 'muneca_mano_tunel_carpiano',
    title: 'Huesos del Carpo y Disposición en Dos Filas',
    summary: 'Los 8 huesos carpianos, articulación radiocarpiana, polo proximal y distal.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 3 (Miembros)',
    readMinutes: 2,
    isPremium: false,
    keyPoints: [
      'Fila Proximal (de lateral a medial): Escafoides, Semilunar, Piramidal y Pisiforme (sesamoideo que asienta sobre el piramidal).',
      'Fila Distal (de lateral a medial): Trapecio, Trapezoide, Grande (hueso central más voluminoso) y Ganchoso (con su apófisis unciforme).',
      'Escafoides: El hueso carpiano que más se fractura (caída con la mano en extensión); riesgo de necrosis avascular por irrigación retrógrada.',
      'Semilunar: El hueso que más frecuentemente se luxa (desplazamiento anterior hacia el túnel del carpo).'
    ],
    mnemonics: [
      'Regla mnemotécnica del carpo (fila proximal y distal de lateral a medial): "Es-Se-Pi-Pi, Tra-Tra-Gran-Gan" (Escafoides, Semilunar, Piramidal, Pisiforme / Trapecio, Trapezoide, Grande, Ganchoso).'
    ],
    contentMarkdown: `### Arquitectura Ósea del Carpo
Ocho pequeños huesos esponjosos dispuestos en dos filas transversales que forman el suelo osteofibroso cóncavo del túnel carpiano.`
  });

  await setDocument('medical_areas/anatomia/topics/muneca_mano_tunel_carpiano/cheatsheets/tunel_carpiano_canal_guyon', {
    areaId: 'anatomia',
    topicId: 'muneca_mano_tunel_carpiano',
    title: 'Túnel Carpiano y Canal de Guyon',
    summary: 'Retináculo flexor, los 10 elementos del túnel del carpo, nervio mediano y canal cubital.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 3 (Miembros)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Límites del Túnel Carpiano: Posterior (huesos del carpo), Anterior (Retináculo Flexor o ligamento anular anterior del carpo).',
      'Contenido del Túnel Carpiano (10 estructuras): 1 Nervio (Nervio Mediano) + 9 Tendones flexores (4 del flexor superficial, 4 del flexor profundo y 1 del flexor largo del pulgar).',
      'Síndrome del Túnel Carpiano: Parestesias y dolor en pulgar, índice, medio y mitad radial del anular, con atrofia de la eminencia tenar.',
      'Canal de Guyon: Espacio fibroso superficial por fuera del túnel del carpo, entre el pisiforme y el gancho del ganchoso. Transmite el Nervio Cubital y la Arteria Cubital.'
    ],
    mnemonics: [
      'El tendón del Flexor Radial del Carpo NO cruza por dentro del túnel carpiano, tiene su propio túnel osteofibroso lateral.'
    ],
    contentMarkdown: `### Síndromes Canaliculares de la Muñeca
El atrapamiento del nervio mediano en el túnel carpiano es la neuropatía por compresión periférica más común en la práctica clínica.`
  });

  await setDocument('medical_areas/anatomia/topics/muneca_mano_tunel_carpiano/cheatsheets/tabaquera_anatomica_mano', {
    areaId: 'anatomia',
    topicId: 'muneca_mano_tunel_carpiano',
    title: 'Tabaquera Anatómica y Eminencias de la Mano',
    summary: 'Depresión triangular radial en la extensión del pulgar, arteria radial, eminencia tenar e hipotenar.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 3 (Miembros)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Límite Medial de la Tabaquera: Tendón del músculo extensor largo del pulgar.',
      'Límite Lateral de la Tabaquera: Tendones de los músculos extensor corto del pulgar y abductor largo del pulgar.',
      'Suelo: Huesos escafoides y trapecio.',
      'Contenido: Arteria Radial (se palpa el pulso en el fondo) y ramas terminales del nervio radial sensitivo.',
      'Eminencia Tenar (base del pulgar): Abductor corto, flexor corto, oponente y aductor del pulgar (inervados por el nervio mediano, excepto aductor por el cubital).',
      'Eminencia Hipotenar (base del meñique): Palmar corto, abductor, flexor corto y oponente del meñique (inervados por el nervio cubital).'
    ],
    mnemonics: [
      'Dolor a la palpación en el suelo de la tabaquera anatómica = Sospecha clínica mandatoria de fractura de escafoides.'
    ],
    contentMarkdown: `### Referencias de la Mano Funcional
La oposición del pulgar es el movimiento fundamental de la mano humana, gobernado por el músculo oponente del pulgar bajo comando del nervio mediano.`
  });

  // ============================================================================
  // TEMA 16: CINTURA PÉLVICA, CADERA Y MUSLO: TRIÁNGULO FEMORAL
  // ============================================================================
  await setDocument('medical_areas/anatomia/topics/cadera_muslo_triangulo_femoral', {
    areaId: 'anatomia',
    title: 'Cintura Pélvica, Cadera y Muslo',
    description: 'Hueso coxal, fémur, articulación coxofemoral, músculos glúteos y triángulo femoral de Scarpa.',
    order: 16,
    cheatsheetsCount: 2,
    quizzesCount: 0
  });

  await setDocument('medical_areas/anatomia/topics/cadera_muslo_triangulo_femoral/cheatsheets/articulacion_coxofemoral_gluteos', {
    areaId: 'anatomia',
    topicId: 'cadera_muslo_triangulo_femoral',
    title: 'Articulación Coxofemoral y Músculos Glúteos',
    summary: 'Sinovial esferoidea cotiloidea (enartrosis), ligamentos iliofemoral/isquiofemoral y marcha de Trendelenburg.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 3 (Miembros)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Superficies: Cabeza femoral (2/3 de esfera) y acetábulo (cotilo) del hueso coxal, aumentado por el rodete acetabular.',
      'Ligamento Iliofemoral (de Bigelow en Y): El ligamento más potente del cuerpo humano; impide la hiperextensión de la cadera en bipedestación.',
      'Ligamento Redondo (de la cabeza femoral): Conduce la rama acetabular de la arteria obturatriz.',
      'Músculo Glúteo Mayor: Principal extensor de la cadera (subir escaleras, levantarse del asiento); inervado por el nervio glúteo inferior.',
      'Músculos Glúteo Medio y Menor: Principales abductores y estabilizadores horizontales de la pelvis en la marcha; inervados por el nervio glúteo superior.',
      'Signo de Trendelenburg: Caída de la hemipelvis contralateral durante el apoyo monopodal por debilidad del glúteo medio ipsilateral.'
    ],
    mnemonics: [
      'Trendelenburg positivo: La pelvis cae hacia el lado sano porque el glúteo medio del lado apoyado falla.'
    ],
    contentMarkdown: `### Anatomía y Estabilidad de la Cadera
A diferencia del hombro, la cadera prioriza la congruencia ósea y la resistencia de carga para soportar el peso corporal en la marcha.`
  });

  await setDocument('medical_areas/anatomia/topics/cadera_muslo_triangulo_femoral/cheatsheets/triangulo_femoral_scarpa_conducto_aductores', {
    areaId: 'anatomia',
    topicId: 'cadera_muslo_triangulo_femoral',
    title: 'Triángulo Femoral (de Scarpa) y Conducto de los Aductores',
    summary: 'Espacio subinguinal, límites anatómicos y disposición neurovascular femoral (NAV).',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 3 (Miembros)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Límites del Triángulo Femoral: Superior (Ligamento Inguinal de Poupart), Lateral (Músculo Sartorio), Medial (Músculo Aductor Largo).',
      'Suelo del Triángulo: Músculo Pectíneo (medialmente) y Músculo Iliopsoas / Psoas Ilíaco (lateralmente).',
      'Contenido Neurovascular de Lateral a Medial: Nervio Femoral -> Arteria Femoral -> Vena Femoral (regla "NAV").',
      'Conducto de los Aductores (de Hunter): Túnel aponeurótico en el tercio medio del muslo cubierto por el sartorio; conduce los vasos femorales y el nervio safeno hacia el hiato aductor del aductor mayor.'
    ],
    mnemonics: [
      'Disposición en la ingle de lateral a medial: "NAV" = Nervio, Arteria, Vena (y linfáticos mediales en el anillo crural).'
    ],
    contentMarkdown: `### Vía de Acceso Vascular Inguinal
El triángulo de Scarpa es el punto estándar para la punción arterial femoral y cateterismos cardíacos intervencionistas.`
  });

  // ============================================================================
  // TEMA 17: RODILLA, PIERNA Y FOSA POPLÍTEA
  // ============================================================================
  await setDocument('medical_areas/anatomia/topics/rodilla_pierna_fosa_poplitea', {
    areaId: 'anatomia',
    title: 'Rodilla, Pierna y Fosa Poplítea',
    description: 'Meniscos, ligamentos cruzados, fosa poplítea y compartimentos musculares de la pierna.',
    order: 17,
    cheatsheetsCount: 3,
    quizzesCount: 0
  });

  await setDocument('medical_areas/anatomia/topics/rodilla_pierna_fosa_poplitea/cheatsheets/rodilla_meniscos_ligamentos_cruzados', {
    areaId: 'anatomia',
    topicId: 'rodilla_pierna_fosa_poplitea',
    title: 'Articulación de la Rodilla: Meniscos y Ligamentos Cruzados',
    summary: 'Bicondílea, menisco medial vs lateral, LCA y LCP, pruebas de cajón y tríada de O\'Donoghue.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 3 (Miembros)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Menisco Medial (Interno): Forma de "C" abierta; se inserta íntimamente en el ligamento colateral medial (más fijo y con mayor frecuencia de rotura).',
      'Menisco Lateral (Externo): Forma de "O" más cerrada; más móvil y cruzado posteriormente por el tendón del poplíteo.',
      'Ligamento Cruzado Anterior (LCA): Se inserta en el área intercondílea anterior de la tibia y sube hacia el cóndilo femoral externo; impide el desplazamiento anterior de la tibia (Cajón anterior).',
      'Ligamento Cruzado Posterior (LCP): Se inserta en el área intercondílea posterior y sube hacia el cóndilo femoral interno; impide el desplazamiento posterior de la tibia (Cajón posterior).',
      'Tríada Desgraciada de O\'Donoghue: Lesión combinada de LCA + Menisco Medial + Ligamento Colateral Medial.'
    ],
    mnemonics: [
      'Mnemotecnia meniscal: "C-I-T-O" = C (Interno) | O (Externo).'
    ],
    contentMarkdown: `### Dinámica y Estabilidad Articular de la Rodilla
La mayor articulación sinovial del cuerpo humano depende fundamentalmente de sus estabilizadores ligamentosos centrales (cruzados) y periféricos (colaterales).`
  });

  await setDocument('medical_areas/anatomia/topics/rodilla_pierna_fosa_poplitea/cheatsheets/fosa_poplitea_limites_contenido', {
    areaId: 'anatomia',
    topicId: 'rodilla_pierna_fosa_poplitea',
    title: 'Fosa Poplítea: Rombo y Paquete Neurovascular',
    summary: 'Espacio romboidal posterior de la rodilla, límites musculares y disposición profunda de los vasos poplíteos.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 3 (Miembros)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Límites Superiores: Superolateral (músculo bíceps femoral); Superomedial (músculos semitendinoso y semimembranoso).',
      'Límites Inferiores: Cabezas lateral y medial del músculo gastrocnemio (gemelos) y músculo plantar.',
      'Suelo: Superficie poplítea del fémur, ligamento poplíteo oblicuo y músculo poplíteo.',
      'Disposición del Paquete de Superficial a Profundo: Nervio Tibial (ciático poplíteo interno) -> Vena Poplítea -> Arteria Poplítea (apoyada sobre el hueso en lo más profundo).',
      'Bifurcación del Nervio Ciático: En el ángulo superior del rombo poplíteo en Nervio Tibial y Nervio Peroneo Común (que rodea el cuello del peroné).'
    ],
    mnemonics: [
      'De superficial a profundo en el rombo poplíteo: "N-V-A" = Nervio, Vena, Arteria.'
    ],
    contentMarkdown: `### El Hueco Poplíteo
La arteria poplítea se encuentra en íntimo contacto con el plano óseo; las luxaciones posteriores de rodilla conllevan alto riesgo de sección o trombosis arterial poplítea.`
  });

  await setDocument('medical_areas/anatomia/topics/rodilla_pierna_fosa_poplitea/cheatsheets/compartimentos_pierna_sindrome', {
    areaId: 'anatomia',
    topicId: 'rodilla_pierna_fosa_poplitea',
    title: 'Compartimentos de la Pierna y Síndrome Compartimental',
    summary: 'Compartimento anterior, lateral y posterior; inervación periférica y fasciotomía de urgencia.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 3 (Miembros)',
    readMinutes: 2,
    isPremium: false,
    keyPoints: [
      'Compartimento Anterior: Músculos tibial anterior, extensor largo de los dedos y extensor largo del dedo gordo; inervados por el Nervio Peroneo Profundo (tibial anterior). Causa pie péndulo o caído si se lesiona.',
      'Compartimento Lateral: Músculos peroneo largo y peroneo corto (eversores del pie); inervados por el Nervio Peroneo Superficial.',
      'Compartimento Posterior: Superficial (tríceps sural: gemelos y sóleo con el tendón calcáneo de Aquiles) y Profundo (tibial posterior, flexores); inervados por el Nervio Tibial.',
      'Síndrome Compartimental: Aumento de presión tisular dentro de la fascia inelástica de la pierna tras traumatismos; requiere fasciotomía descompresiva urgente.'
    ],
    mnemonics: [
      'Lesión del Nervio Peroneo Común en el cuello del peroné = Marcha en estepaje (pie caído, sin dorsiflexión).'
    ],
    contentMarkdown: `### Miología y Fascias de la Pierna
La rigidez de la membrana interósea y los tabiques intermusculares define espacios osteofasciales cerrados de alto interés clínico y traumatológico.`
  });

  // ============================================================================
  // TEMA 18: TOBILLO, PIE Y ARCOS PLANTARES
  // ============================================================================
  await setDocument('medical_areas/anatomia/topics/tobillo_pie_arcos_plantares', {
    areaId: 'anatomia',
    title: 'Tobillo, Pie y Arcos Plantares',
    description: 'Huesos del tarso, articulación talocrural, túnel del tarso y biomecánica de la bóveda plantar.',
    order: 18,
    cheatsheetsCount: 2,
    quizzesCount: 0
  });

  await setDocument('medical_areas/anatomia/topics/tobillo_pie_arcos_plantares/cheatsheets/tarso_articulacion_talocrural', {
    areaId: 'anatomia',
    topicId: 'tobillo_pie_arcos_plantares',
    title: 'Huesos del Tarso y Articulación Talocrural',
    summary: 'Astrágalo, calcáneo, mortaja tibioperonea y ligamento colateral medial (deltoideo).',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 3 (Miembros)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Tarso Posterior: Astrágalo (talus, transmite todo el peso corporal sin inserciones musculares) y Calcáneo (hueso del talón con el sustentaculum tali).',
      'Tarso Anterior: Navicular (escafoides), Cuboides y las 3 Cuñas (cuneiformes medial, intermedio y lateral).',
      'Articulación Talocrural (Tobillo): Trocleartrosis o gínglimo (flexión dorsal y flexión plantar).',
      'Ligamento Deltoideo (Colateral Medial): Muy potente, triangular, previene la eversión excesiva.',
      'Ligamentos Laterales: Fibulotalar anterior (LFTA), fibulocalcáneo y fibulotalar posterior. El LFTA es el ligamento que más frecuentemente se lesiona en los esguinces por inversión.'
    ],
    mnemonics: [
      'Esguince de tobillo común: Lesión del Ligamento Fibulotalar (Peroneoastragalino) Anterior por inversión forzada.'
    ],
    contentMarkdown: `### El Tarso y la Mortaja del Tobillo
La mortaja tibioperonea encaja perfectamente la tróclea astragalina permitiendo la marcha estable sobre superficies irregulares.`
  });

  await setDocument('medical_areas/anatomia/topics/tobillo_pie_arcos_plantares/cheatsheets/tunel_tarso_boveda_plantar', {
    areaId: 'anatomia',
    topicId: 'tobillo_pie_arcos_plantares',
    title: 'Túnel del Tarso y Bóveda Plantar',
    summary: 'Retináculo flexor medial, paquete tibial posterior, arcos longitudinal y transversal del pie.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 3 (Miembros)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Túnel del Tarso: Conducto osteofibroso detrás del maléolo medial de la tibia bajo el retináculo flexor.',
      'Contenido de anterior a posterior: Tendón del tibial posterior, Tendón del flexor largo de los dedos, Arteria y vena tibiales posteriores, Nervio Tibial y Tendón del flexor largo del dedo gordo.',
      'Bóveda Plantar: Estructura elástica amortiguadora compuesta por dos arcos longitudinales (medial más alto y lateral de apoyo) y un arco transversal.',
      'Aponeurosis Plantar: Fascia tensa desde el calcáneo a las falanges; su inflamación crónica genera la fascitis plantar.'
    ],
    mnemonics: [
      'Contenido del túnel del tarso detrás del maléolo medial: "T-D-AV-H" (Tibial post, Digitorum flexor, Arteria/Vena tibial, Hallux flexor).'
    ],
    contentMarkdown: `### El Túnel del Tarso y el Pie como Trípode Dinámico
El apoyo del pie se distribuye en tres puntos principales: la tuberosidad del calcáneo, la cabeza del 1.er metatarsiano y la cabeza del 5.° metatarsiano.`
  });

  console.log('\n=================================================================');
  console.log('¡CARGA DEL TOMO 3 DE ROUVIÈRE (MIEMBROS) EN FIRESTORE FINALIZADA!');
  console.log('Nuevos temas: 13 al 18 | Nuevas chuletas: 15 adicionales.');
  console.log('Total en Anatomía: 18 Temas y 49 Chuletas de Alto Rendimiento.');
  console.log('Tomos 1 y 2 intactos sin alteraciones.');
  console.log('=================================================================');
}

main().catch(err => {
  console.error('Error durante la carga:', err);
  process.exit(1);
});
