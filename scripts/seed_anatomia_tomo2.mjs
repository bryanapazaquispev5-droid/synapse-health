// Script de carga integral para Anatomía Humana Tomo 2 (Tronco: Tórax y Abdomen - Rouvière / Delmas)
// NO MODIFICA LOS TEMAS DEL TOMO 1 (permanecen 100% intactos).
// Se agregan los temas 7 a 12 con sus respectivas chuletas clínicas.
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
  console.log('Iniciando carga de Tomo 2 de Rouvière (Tronco: Tórax y Abdomen)...\n');

  // 1. ACTUALIZAR CONTADORES GLOBALES DEL ÁREA MÉDICA (6 temas Tomo 1 + 6 temas Tomo 2 = 12 temas, 34 chuletas)
  await setDocument('medical_areas/anatomia', {
    name: 'Anatomía Humana',
    code: 'ANATOMIA',
    order: 1,
    topicsCount: 12,
    cheatsheetsCount: 34,
    quizzesCount: 0,
    isAvailable: true
  });

  // ============================================================================
  // TEMA 7: PARED TORÁCICA, MEDIASTINO Y DIAFRAGMA
  // ============================================================================
  await setDocument('medical_areas/anatomia/topics/torax_mediastino_diafragma', {
    areaId: 'anatomia',
    title: 'Pared Torácica, Mediastino y Diafragma',
    description: 'Costillas, esternón, mecánica ventilatoria, compartimentos mediastínicos y orificios diafragmáticos.',
    order: 7,
    cheatsheetsCount: 2,
    quizzesCount: 0
  });

  await setDocument('medical_areas/anatomia/topics/torax_mediastino_diafragma/cheatsheets/diafragma_hiatos_inervacion', {
    areaId: 'anatomia',
    topicId: 'torax_mediastino_diafragma',
    title: 'Músculo Diafragma: Inserciones, Hiatos e Inervación',
    summary: 'Principal músculo inspiratorio, centro frénico, pilares tendinosos y forámenes de paso toracoabdominal.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 2 (Tronco)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Centro Frénico (Espejo de van Helmont): Centro tendinoso en forma de trébol donde convergen las fibras musculares.',
      'Hiato de la Vena Cava Inferior (T8): En el folíolo derecho del centro tendinoso; la contracción diafragmática lo dilata favoreciendo el retorno venoso.',
      'Hiato Esofágico (T10): Muscular, formado por el pilar derecho del diafragma; transmite el esófago y los troncos vagales anterior y posterior.',
      'Hiato Aórtico (T12): Osteofibroso, delimitado por el ligamento arqueado medio y la columna; transmite la aorta descendente y el conducto torácico.',
      'Inervación: Motora exclusiva por los nervios frénicos (C3-C5); sensitiva periférica por los últimos seis nervios intercostales.'
    ],
    mnemonics: [
      'Nivel vertebral de los hiatos diafragmáticos: "V-E-A" = Vena Cava (T8), Esófago (T10), Aorta (T12).'
    ],
    contentMarkdown: `### El Tabique Toracoabdominal

El **músculo diafragma** es una cúpula músculo-tendinosa que separa la cavidad torácica de la abdominal.

---

### Hiatos Principales y su Contenido

| Hiato | Nivel | Naturaleza | Contenido que lo atraviesa |
| :--- | :--- | :--- | :--- |
| **Foramen de la Vena Cava** | T8 | Tendinoso | Vena Cava Inferior y ramo del nervio frénico derecho |
| **Hiato Esofágico** | T10 | Muscular | Esófago y Nervios Vagos (X) anterior y posterior |
| **Hiato Aórtico** | T12 | Fibroso | Aorta torácica y Conducto Torácico linfático |`
  });

  await setDocument('medical_areas/anatomia/topics/torax_mediastino_diafragma/cheatsheets/mediastino_division_topografica', {
    areaId: 'anatomia',
    topicId: 'torax_mediastino_diafragma',
    title: 'Mediastino: División Topográfica y Contenido',
    summary: 'Espacio interpleural central, plano transversal de Louis (T4-T5) y compartimentos torácicos.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 2 (Tronco)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Plano Transversal de Louis: Línea imaginaria desde el ángulo esternal al disco T4-T5. Divide mediastino superior e inferior.',
      'Mediastino Superior: Timo (o vestigios), venas braquiocefálicas, VCS, arco aórtico y sus tres ramas, tráquea, esófago y nervios vagos/frénicos.',
      'Mediastino Anterior: Entre esternón y pericardio; contiene tejido areolar, ganglios linfáticos y ramas torácicas internas.',
      'Mediastino Medio: Pericardio, corazón, aorta ascendente, tronco pulmonar y nervios frénicos.',
      'Mediastino Posterior: Detrás del pericardio; contiene esófago, aorta torácica descendente, conducto torácico, venas ácigos/hemiácigos y cadena simpática.'
    ],
    mnemonics: [
      'El plano del ángulo esternal (T4-T5) marca: bifurcación traqueal, inicio/fin del arco aórtico y confluencia de la vena ácigos.'
    ],
    contentMarkdown: `### Compartimentalización del Mediastino
Región central del tórax ubicada entre ambos sacos pleurales pulmonares, la columna vertebral y el esternón.`
  });

  // ============================================================================
  // TEMA 8: APARATO RESPIRATORIO: PULMONES Y PLEURAS
  // ============================================================================
  await setDocument('medical_areas/anatomia/topics/respiratorio_pulmones_pleuras', {
    areaId: 'anatomia',
    title: 'Aparato Respiratorio: Pulmones y Pleuras',
    description: 'Tráquea torácica, árbol bronquial, segmentación pulmonar, pleuras y recesos costodiafragmáticos.',
    order: 8,
    cheatsheetsCount: 2,
    quizzesCount: 0
  });

  await setDocument('medical_areas/anatomia/topics/respiratorio_pulmones_pleuras/cheatsheets/segmentacion_broncopulmonar', {
    areaId: 'anatomia',
    topicId: 'respiratorio_pulmones_pleuras',
    title: 'Segmentación Broncopulmonar y Lóbulos',
    summary: 'Arquitectura lobular, cisuras mayor/menor, bronquios segmentarios e hilio pulmonar.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 2 (Tronco)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Pulmón Derecho: 3 lóbulos (superior, medio, inferior), divididos por dos cisuras (oblicua mayor y horizontal menor). Cuenta con 10 segmentos.',
      'Pulmón Izquierdo: 2 lóbulos (superior con língula e inferior) y una sola cisura oblicua. Cuenta con 8-9 segmentos.',
      'Bronquio Principal Derecho: Más ancho, más corto y más vertical que el izquierdo (mayor riesgo de aspiración de cuerpos extraños).',
      'Disposición del Hilio: Derecha: la arteria pulmonar es anterior al bronquio; Izquierda: la arteria pulmonar es superior al bronquio.'
    ],
    mnemonics: [
      'Bronquio derecho: "Aspiras por la derecha porque es más recto y ancho".'
    ],
    contentMarkdown: `### Anatomía de la Segmentación Pulmonar
Cada segmento broncopulmonar es una unidad anatomofuncional y quirúrgicamente resecable, con su propio bronquio segmentario y rama arterial pulmonar.`
  });

  await setDocument('medical_areas/anatomia/topics/respiratorio_pulmones_pleuras/cheatsheets/pleuras_recesos_presion', {
    areaId: 'anatomia',
    topicId: 'respiratorio_pulmones_pleuras',
    title: 'Pleuras, Cavidad Pleural y Recesos',
    summary: 'Hoja visceral, hoja parietal, presión intrapleural negativa y receso costodiafragmático.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 2 (Tronco)',
    readMinutes: 2,
    isPremium: false,
    keyPoints: [
      'Pleura Visceral: Reviste íntimamente el parénquima pulmonar y penetra en el fondo de las cisuras interlobulares.',
      'Pleura Parietal: Se divide en costal, diafragmática y mediastínica; posee inervación sensitiva somática muy dolorosa.',
      'Receso Costodiafragmático: El ángulo de reflexión más declive de la cavidad pleural; sitio donde se acumula primero el derrame pleural.',
      'Toracocentesis: Se efectúa en la línea axilar media en el 8.° o 9.° espacio intercostal, rozando el borde superior de la costilla inferior para no lesionar el paquete vasculonervioso intercostal (VAN).'
    ],
    mnemonics: [
      'Paquete intercostal de superior a inferior: Vena, Arteria, Nervio ("VAN").'
    ],
    contentMarkdown: `### Dinámica de las Membranas Pleurales
Las pleuras convierten la caja torácica rígida en una bomba de succión elástica grâce a la película líquida interpleural.`
  });

  // ============================================================================
  // TEMA 9: APARATO CARDIOVASCULAR: CORAZÓN Y PERICARDIO
  // ============================================================================
  await setDocument('medical_areas/anatomia/topics/cardiovascular_corazon_pericardio', {
    areaId: 'anatomia',
    title: 'Aparato Cardiovascular: Corazón y Pericardio',
    description: 'Cámaras cardíacas, aparato valvular, irrigación coronaria, sistema de conducción y pericardio.',
    order: 9,
    cheatsheetsCount: 3,
    quizzesCount: 0
  });

  await setDocument('medical_areas/anatomia/topics/cardiovascular_corazon_pericardio/cheatsheets/morfologia_camaras_valvulas', {
    areaId: 'anatomia',
    topicId: 'cardiovascular_corazon_pericardio',
    title: 'Morfología Cardíaca: Cámaras y Válvulas',
    summary: 'Aurículas, ventrículos, esqueleto fibroso, válvulas auriculoventriculares y semilunares.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 2 (Tronco)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Aurícula Derecha: Desembocadura de VCS (sin válvula), VCI (válvula de Eustaquio), seno coronario (válvula de Tebesio) y fosa oval en el tabique interauricular.',
      'Ventrículo Derecho: Pared delgada, válvula tricúspide (3 cúspides), trabécula septomarginal (banda moderadora) que conduce la rama derecha del haz de His.',
      'Ventrículo Izquierdo: Pared 3 veces más gruesa que el derecho, válvula mitral (bicúspide) y cono aórtico.',
      'Válvulas Semilunares (Aórtica y Pulmonar): 3 valvas en nido de golondrina con nódulos centrales (de Arancio en la aorta y de Morgagni en la pulmonar).'
    ],
    mnemonics: [
      'Válvula Tricúspide = Corazón derecho (3 valvas) | Válvula Mitral = Corazón izquierdo (2 valvas).'
    ],
    contentMarkdown: `### Arquitectura de las Cuatro Cavidades Cardíacas
El corazón se dispone de forma oblicua en el mediastino medio, con su vértice (ápex) orientado hacia adelante, abajo y a la izquierda (5.° espacio intercostal línea medioclavicular).`
  });

  await setDocument('medical_areas/anatomia/topics/cardiovascular_corazon_pericardio/cheatsheets/arterias_coronarias_conduccion', {
    areaId: 'anatomia',
    topicId: 'cardiovascular_corazon_pericardio',
    title: 'Arterias Coronarias y Sistema de Conducción',
    summary: 'Origen en senos de Valsalva, arterias coronarias derecha e izquierda, nodo SA, nodo AV y haz de His.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 2 (Tronco)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Arteria Coronaria Izquierda: Nace del seno aórtico izquierdo; se bifurca rápidamente en Arteria Descendente Anterior (interventricular anterior) y Arteria Circunfleja.',
      'Arteria Coronaria Derecha: Nace del seno aórtico derecho; discurre por el surco coronario, emite la arteria para el nodo SA (60%) y da la Descendente Posterior (dominancia derecha en 85%).',
      'Nodo Sinoauricular (SA, de Keith-Flack): Marcapasos fisiológico en la unión de la VCS y la aurícula derecha.',
      'Nodo Auriculoventricular (AV, de Aschoff-Tawara): Situado en el vértice del triángulo de Koch en la aurícula derecha.',
      'Haz de His y Red de Purkinje: Conduce el estímulo despolarizante hacia el miocardio ventricular.'
    ],
    mnemonics: [
      'Triángulo de Koch (localización del nodo AV): Válvula de Tebesio, tendón de Todaro y valva septal tricúspide.'
    ],
    contentMarkdown: `### Perfusión y Electrofisiología Cardíaca
El flujo coronario ocurre predominantemente durante la **diástole ventricular**, cuando el miocardio se relaja y cesa la compresión extravascular de los capilares.`
  });

  await setDocument('medical_areas/anatomia/topics/cardiovascular_corazon_pericardio/cheatsheets/pericardio_senos_transverso', {
    areaId: 'anatomia',
    topicId: 'cardiovascular_corazon_pericardio',
    title: 'Pericardio: Seno Transverso y Seno Oblicuo',
    summary: 'Saco fibroseroso, fondo de saco de Haller, seno transverso de Theile y taponamiento cardíaco.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 2 (Tronco)',
    readMinutes: 2,
    isPremium: false,
    keyPoints: [
      'Pericardio Fibroso: Capa externa inelástica que se fija al diafragma (ligamento pericardiofrénico) y esternón.',
      'Pericardio Seroso: Dos hojas (parietal y visceral/epicardio) que delimitan la cavidad pericárdica con 15-50 ml de líquido.',
      'Seno Transverso de Theile: Pasaje transversal que separa los grandes pedículos arteriales (aorta y tronco pulmonar anteriores) de los venosos (aurículas y VCS posteriores).',
      'Seno Oblicuo de Haller: Fondo de saco ciego detrás de la aurícula izquierda, delimitado por las cuatro venas pulmonares.',
      'Taponamiento Cardíaco: Acumulación rápida de líquido en la cavidad pericárdica que colapsa las cavidades derechas (Tríada de Beck).'
    ],
    mnemonics: [
      'Tríada de Beck en taponamiento: Hipotensión arterial, Ruidos cardíacos apagados e Ingurgitación yugular.'
    ],
    contentMarkdown: `### Anatomía Pericárdica Quirúrgica
El seno transverso permite rodear y pinzar la aorta y la arteria pulmonar durante cirugías con circulación extracorpórea.`
  });

  // ============================================================================
  // TEMA 10: PARED ABDOMINAL Y CONDUCTO INGUINAL
  // ============================================================================
  await setDocument('medical_areas/anatomia/topics/pared_abdominal_conducto_inguinal', {
    areaId: 'anatomia',
    title: 'Pared Abdominal y Conducto Inguinal',
    description: 'Músculos anchos del abdomen, vaina de los rectos, conducto inguinal y hernias de la pared.',
    order: 10,
    cheatsheetsCount: 3,
    quizzesCount: 0
  });

  await setDocument('medical_areas/anatomia/topics/pared_abdominal_conducto_inguinal/cheatsheets/conducto_inguinal_paredes_anillos', {
    areaId: 'anatomia',
    topicId: 'pared_abdominal_conducto_inguinal',
    title: 'Conducto Inguinal: Paredes, Anillos y Contenido',
    summary: 'Trayecto oblicuo de 4 cm sobre el ligamento inguinal; paso del cordón espermático o ligamento redondo.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 2 (Tronco)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Pared Anterior: Formada por la aponeurosis del músculo oblicuo externo (mayor) y fibras del oblicuo interno lateralmente.',
      'Pared Posterior: Formada por la fascia transversalis, reforzada medialmente por el tendón conjunto (hoz inguinal) y ligamento de Henle.',
      'Techo (Pared Superior): Fibras arqueadas de los músculos oblicuo interno y transverso del abdomen.',
      'Suelo (Pared Inferior): Ligamento inguinal (arco crural de Poupart) y ligamento lacunar (de Gimbernat).',
      'Contenido: Varón: Cordón espermático (conducto deferente, arteria testicular, plexo pampiniforme); Mujer: Ligamento redondo del útero; Ambos: Nervio ilioinguinal.'
    ],
    mnemonics: [
      'Techo: Oblicuo interno y Transverso | Suelo: Ligamento Inguinal.'
    ],
    contentMarkdown: `### Túnel Inguinal
Comunica la cavidad peritoneal interna con el escroto/labios mayores, permitiendo el descenso gonadal ontogénico.`
  });

  await setDocument('medical_areas/anatomia/topics/pared_abdominal_conducto_inguinal/cheatsheets/hernias_inguinales_directas_indirectas', {
    areaId: 'anatomia',
    topicId: 'pared_abdominal_conducto_inguinal',
    title: 'Hernias Inguinales: Directas vs Indirectas',
    summary: 'Triángulo de Hesselbach, relación con los vasos epigástricos inferiores y fisiopatología herniaria.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 2 (Tronco)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Punto de Referencia Anatómico: Arteria y vena epigástricas inferiores.',
      'Hernia Inguinal Indirecta (Lateral): Congénita por persistencia del conducto peritoneovaginal; entra por el anillo inguinal profundo, lateral a los vasos epigástricos, y puede descender al escroto.',
      'Hernia Inguinal Directa (Medial): Adquirida por debilidad de la fascia transversalis; protruye a través del triángulo de Hesselbach, medial a los vasos epigástricos.',
      'Límites del Triángulo de Hesselbach: Borde lateral del músculo recto abdominal (medial), Vasos epigástricos inferiores (lateral) y Ligamento inguinal (inferior).'
    ],
    mnemonics: [
      '"MD": Medial a epigástricos = Directa | Lateral a epigástricos = Indirecta.'
    ],
    contentMarkdown: `### Diagnóstico Topográfico de Hernias de la Ingle
La relación con los vasos epigástricos inferiores determina el mecanismo quirúrgico y la técnica de hernioplastia.`
  });

  await setDocument('medical_areas/anatomia/topics/pared_abdominal_conducto_inguinal/cheatsheets/vaina_rectos_linea_arcuata', {
    areaId: 'anatomia',
    topicId: 'pared_abdominal_conducto_inguinal',
    title: 'Vaina de los Rectos y Línea Arqueada de Douglas',
    summary: 'Organización aponeurótica anterolateral por encima y por debajo del arco de Douglas.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 2 (Tronco)',
    readMinutes: 2,
    isPremium: false,
    keyPoints: [
      'Músculo Recto del Abdomen: Envuelto en un estuche aponeurótico formado por los tres músculos anchos (oblicuo externo, oblicuo interno y transverso).',
      'Por encima de la Línea Arqueada: La hoja anterior está formada por la aponeurosis del oblicuo externo y la hoja anterior del oblicuo interno; la hoja posterior está formada por la hoja posterior del oblicuo interno y el transverso.',
      'Línea Arqueada (de Douglas): Transición a nivel del tercio inferior del abdomen (entre ombligo y sínfisis púbica).',
      'Por debajo de la Línea Arqueada: Todas las aponeurosis de los tres músculos pasan por DELANTE del recto; la cara posterior del músculo queda en contacto directo con la fascia transversalis y el peritoneo.'
    ],
    mnemonics: [
      'Por debajo de Douglas, la pared posterior del recto es pura fascia transversalis (sin capa aponeurótica tendinosa).'
    ],
    contentMarkdown: `### Arquitectura Aponeurótica de la Línea Media
La línea alba es la fusión central avascular de todas las vainas; la línea arcuata representa el punto de penetración de los vasos epigástricos inferiores en la vaina del recto.`
  });

  // ============================================================================
  // TEMA 11: APARATO DIGESTIVO ABDOMINAL Y PERITONEO
  // ============================================================================
  await setDocument('medical_areas/anatomia/topics/digestivo_abdominal_peritoneo', {
    areaId: 'anatomia',
    title: 'Aparato Digestivo Abdominal y Peritoneo',
    description: 'Estómago, duodeno, yeyuno-íleon, colon, mesoapéndice y transcavidad de los epiplones.',
    order: 11,
    cheatsheetsCount: 3,
    quizzesCount: 0
  });

  await setDocument('medical_areas/anatomia/topics/digestivo_abdominal_peritoneo/cheatsheets/estomago_curvaturas_vascularizacion', {
    areaId: 'anatomia',
    topicId: 'digestivo_abdominal_peritoneo',
    title: 'Estómago: Morfología y Círculos Arteriales',
    summary: 'Curvaturas mayor y menor, fondo gástrico, piloro y aporte arterial por el tronco celíaco.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 2 (Tronco)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Porciones Anatómicas: Cardias (esfínter anatómico funcional), Fundus (bolsa de aire gástrica), Cuerpo, Antro pilórico y Conducto pilórico con esfínter esfinteriano.',
      'Círculo Arterial de la Curvatura Menor: Formado por la anastomosis de la Arteria Gástrica Izquierda (del tronco celíaco) y Arteria Gástrica Derecha (de la hepática propia).',
      'Círculo Arterial de la Curvatura Mayor: Formado por la Arteria Gastroepiploica Izquierda (de la esplénica) y Arteria Gastroepiploica Derecha (de la gastroduodenal).',
      'Fundus Gástrico: Irrigado por las arterias gástricas cortas (ramos de la arteria esplénica).'
    ],
    mnemonics: [
      'Toda la irrigación gástrica se origina de las 3 ramas del Tronco Celíaco (Gástrica Izquierda, Hepática Común y Esplénica).'
    ],
    contentMarkdown: `### Anatomía Gástrica
Órgano en forma de 'J' intraperitoneal situado en el hipocondrio izquierdo y epigastrio con gran capacidad de distensión.`
  });

  await setDocument('medical_areas/anatomia/topics/digestivo_abdominal_peritoneo/cheatsheets/duodeno_pancreas_ampolla_vater', {
    areaId: 'anatomia',
    topicId: 'digestivo_abdominal_peritoneo',
    title: 'Duodeno y Complejo Biliopancreático',
    summary: 'Las 4 porciones duodenales, pinza aortomesentérica, ampolla de Vater y esfínter de Oddi.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 2 (Tronco)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Cuatro Porciones: 1.ª (superior/bulbo, móvil e intraperitoneal), 2.ª (descendente, retroperitoneal), 3.ª (horizontal/prevertebral), 4.ª (ascendente hacia el ángulo duodenoyeyunal de Treitz).',
      'Segunda Porción: Desembocan el conducto colédoco y el conducto pancreático principal (de Wirsung) en la ampolla hepatopancreática (de Vater) rodeada por el esfínter de Oddi.',
      'Carúncula Menor: Situada 2 cm por encima de la papila mayor; drena el conducto pancreático accesorio (de Santorini).',
      'Pinza Aortomesentérica: La 3.ª porción duodenal queda comprimida entre la Aorta Abdominal (posterior) y la Arteria Mesentérica Superior (anterior).'
    ],
    mnemonics: [
      'Síndrome de Wilkie: Compresión de la 3.ª porción duodenal en la pinza aorto-mesentérica.'
    ],
    contentMarkdown: `### La Encrucijada Duodenopancreática
El marco duodenal abraza la cabeza del páncreas constituyendo una unidad anatómica, vascular y quirúrgica indivisible.`
  });

  await setDocument('medical_areas/anatomia/topics/digestivo_abdominal_peritoneo/cheatsheets/peritoneo_bolsa_omental_winslow', {
    areaId: 'anatomia',
    topicId: 'digestivo_abdominal_peritoneo',
    title: 'Peritoneo: Bolsa Omental y Foramen de Winslow',
    summary: 'Epiplón mayor, epiplón menor, hiato de Winslow y límites de la transcavidad.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 2 (Tronco)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Foramen Epiploico (Hiato de Winslow): Única comunicación natural entre la gran cavidad peritoneal y la bolsa omental (transcavidad).',
      'Límites del Hiato de Winslow: Anterior (ligamento hepatoduodenal con la tríada portal: Vena porta, Arteria hepática propia y Colédoco); Posterior (Vena Cava Inferior); Superior (Lóbulo caudado de Spiegel); Inferior (1.ª porción del duodeno).',
      'Omento Menor (Epiplón Gastrohepático): Comprende el ligamento hepatogástrico y el ligamento hepatoduodenal.',
      'Omento Mayor (Delantal de los Epiplones): Pende de la curvatura mayor gástrica y colon transverso, cubriendo las asas delgadas.'
    ],
    mnemonics: [
      'Maniobra de Pringle: Clampeo digital o vascular del ligamento hepatoduodenal en el hiato de Winslow para detener hemorragias hepáticas.'
    ],
    contentMarkdown: `### Compartimentos Peritoneales
La transcavidad de los epiplones se ubica por detrás del estómago y por delante del páncreas, actuando como espacio de deslizamiento gástrico.`
  });

  // ============================================================================
  // TEMA 12: VÍSCERAS ANEXAS, RETROPERITONEO Y VÍA URINARIA
  // ============================================================================
  await setDocument('medical_areas/anatomia/topics/visceras_retroperitoneo_rinones', {
    areaId: 'anatomia',
    title: 'Vísceras Anexas, Retroperitoneo y Vía Urinaria',
    description: 'Hígado, segmentación de Couinaud, bazo, riñones, uréteres, aorta abdominal y vena cava inferior.',
    order: 12,
    cheatsheetsCount: 3,
    quizzesCount: 0
  });

  await setDocument('medical_areas/anatomia/topics/visceras_retroperitoneo_rinones/cheatsheets/higado_segmentacion_couinaud', {
    areaId: 'anatomia',
    topicId: 'visceras_retroperitoneo_rinones',
    title: 'Hígado: Segmentación Funcional de Couinaud',
    summary: 'División en 8 segmentos hepáticos autónomos según la distribución de la tríada portal y venas suprahepáticas.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 2 (Tronco)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Concepto de Segmento: Cada segmento posee una rama de la vena porta, una rama de la arteria hepática y un conducto biliar propio, y es drenado por las venas hepáticas.',
      'Lóbulo Caudado (Segmento I): Autónomo, recibe flujo de ambas ramas portales y drena directamente en la VCI sin pasar por las suprahepáticas.',
      'Hemi-hígado Izquierdo: Segmentos II (lateral post), III (lateral ant) y IV (medial / cuadrado).',
      'Hemi-hígado Derecho: Segmentos V (anterior inf), VI (posterior inf), VII (posterior sup) y VIII (anterior sup).',
      'Tríada Portal (Pedículo Hepático): Vena porta (plano posterior), Arteria hepática propia (anterior izquierda) y Conducto colédoco (anterior derecha).'
    ],
    mnemonics: [
      'Disposición de la Tríada Portal: "V-A-C" = Vena porta (atrás), Arteria (adelante izquierda), Colédoco (adelante derecha).'
    ],
    contentMarkdown: `### Anatomía Quirúrgica Hepática
La fisura portal principal (línea de Cantlie) se extiende desde la fosa cística hasta la VCI y divide el hígado en lóbulos funcionales derecho e izquierdo.`
  });

  await setDocument('medical_areas/anatomia/topics/visceras_retroperitoneo_rinones/cheatsheets/rinon_aparato_urinario_retroperitoneal', {
    areaId: 'anatomia',
    topicId: 'visceras_retroperitoneo_rinones',
    title: 'Riñones, Cápsula de Gerota y Trayecto Ureteral',
    summary: 'Celda renal, fascia propia, hilio renal (VAP) y los 3 estrechamientos fisiológicos del uréter.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 2 (Tronco)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Situación: Espacio retroperitoneal primario (T12 a L3); el riñón derecho se ubica 1-2 cm más abajo por la presencia del lóbulo hepático derecho.',
      'Fascia Renal (de Gerota): Hoja anterior de Toldt y hoja posterior de Zuckerkandl, abiertas inferiormente en dirección a la pelvis.',
      'Hilio Renal de anterior a posterior: Vena Renal, Arteria Renal y Pelvis Renal (regla mnemotécnica "VAP").',
      'Uréteres y sus 3 Estrechamientos: 1. Unión pieloureteral; 2. Cruce anterior a los vasos ilíacos (sobre la línea terminal de la pelvis); 3. Porción intramural al atravesar la pared de la vejiga urinaria.'
    ],
    mnemonics: [
      'Hilio Renal en corte sagital: "V-A-P" (Vena, Arteria, Pelvis de adelante hacia atrás).'
    ],
    contentMarkdown: `### Anatomía Renal y Vías Excretoras
Los riñones filtran aproximadamente 180 litros de plasma al día; su rica vascularización proviene directamente de las arterias renales procedentes de la aorta a nivel L1-L2.`
  });

  await setDocument('medical_areas/anatomia/topics/visceras_retroperitoneo_rinones/cheatsheets/aorta_abdominal_tronco_celiaco', {
    areaId: 'anatomia',
    topicId: 'visceras_retroperitoneo_rinones',
    title: 'Aorta Abdominal y Ramas Viscerales',
    summary: 'Aorta desde T12 a L4, ramas impares anteriores (celíaco, mesentéricas) y pares laterales.',
    sourceBook: 'Rouvière - Delmas: Anatomía Humana Tomo 2 (Tronco)',
    readMinutes: 3,
    isPremium: false,
    keyPoints: [
      'Trayecto: Inicia en el hiato aórtico diafragmático (T12) y termina bifurcándose en las dos arterias ilíacas comunes a nivel de L4.',
      'Tronco Celíaco (T12): Irriga el intestino anterior embrionario (estómago, hígado, bazo, vesícula y parte del páncreas/duodeno).',
      'Arteria Mesentérica Superior (L1): Irriga el intestino medio embrionario (duodeno distal, yeyuno, íleon, ciego, apéndice, colon ascendente y 2/3 proximales del colon transverso).',
      'Arteria Mesentérica Inferior (L3): Irriga el intestino posterior embrionario (1/3 distal del colon transverso, colon descendente, sigmoides y recto superior).',
      'Arterias Renales (L1-L2): Ramas pares laterales; la arteria renal derecha es más larga y pasa por detrás de la Vena Cava Inferior.'
    ],
    mnemonics: [
      'Niveles de las 3 arterias digestivas impares: T12 (Celíaco) | L1 (Mesentérica Superior) | L3 (Mesentérica Inferior).'
    ],
    contentMarkdown: `### Eje Vascular Abdominal Mayor
La aorta abdominal desciende apoyada sobre los cuerpos vertebrales, a la izquierda de la vena cava inferior, dando origen a la totalidad del flujo sanguíneo abdominal y pélvico.`
  });

  console.log('\n=================================================================');
  console.log('¡CARGA DEL TOMO 2 DE ROUVIÈRE (TRONCO) EN FIRESTORE FINALIZADA!');
  console.log('Nuevos temas: 7 al 12 | Nuevas chuletas: 16 adicionales.');
  console.log('Total en Anatomía: 12 Temas y 34 Chuletas de Alto Rendimiento.');
  console.log('Tomo 1 intacto sin alteraciones.');
  console.log('=================================================================');
}

main().catch(err => {
  console.error('Error durante la carga:', err);
  process.exit(1);
});
