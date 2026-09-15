// Quizzes Clínicos de Anatomía Humana - Rouvière Tomo 3 (Miembros: Miembro Inferior)
// 3 Temas x 20 Quizzes = 60 Quizzes
import { uploadQuizzesBatch } from './seed_quizzes_common.mjs';

const tomo3Part2Quizzes = [
  // =========================================================================
  // TEMA 4: cadera_muslo_triangulo_femoral (20 QUIZZES)
  // =========================================================================
  {
    id: 'quiz_t3_cad_01',
    topicId: 'cadera_muslo_triangulo_femoral',
    type: 'single_choice',
    question: 'El triángulo femoral (triángulo de Scarpa) está delimitado por:',
    options: ['Ligamento inguinal (superior), músculo sartorio (lateral) y músculo aductor largo (medial)', 'Músculo recto femoral, grácil y pectíneo', 'Músculo tensor de la fascia lata y glúteo mayor'],
    correctIndex: 0,
    rationale: 'El trígono femoral de Scarpa lo limitan el ligamento inguinal (base superior), el músculo sartorio (borde lateral) y el aductor largo (borde medial).',
    sourceBook: 'Rouvière - Delmas: Tomo 3 (Miembros), Triángulo Femoral de Scarpa',
    order: 1
  },
  {
    id: 'quiz_t3_cad_02',
    topicId: 'cadera_muslo_triangulo_femoral',
    type: 'single_choice',
    question: '¿Cuál es el principal flexor de la articulación de la cadera (coxofemoral) que se inserta en el trocánter menor del fémur?',
    options: ['Músculo iliopsoas (psoas ilíaco)', 'Músculo cuádriceps femoral', 'Músculo glúteo medio'],
    correctIndex: 0,
    rationale: 'El músculo iliopsoas es el flexor más potente de la cadera; sus fibras convergen y terminan en el trocánter menor de la cara medial del fémur.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Músculo Iliopsoas',
    order: 2
  },
  {
    id: 'quiz_t3_cad_03',
    topicId: 'cadera_muslo_triangulo_femoral',
    type: 'case_study',
    question: 'Paciente adulto mayor presenta marcha de Trendelenburg con caída de la hemipelvis contralateral al apoyar la pierna afectada al caminar. ¿Qué músculo abductor de cadera está denervado o debilitado?',
    options: ['Músculo glúteo medio (inervado por el nervio glúteo superior)', 'Músculo glúteo mayor', 'Músculo obturador externo'],
    correctIndex: 0,
    rationale: 'El signo de Trendelenburg es la caída de la pelvis contralateral debido a insuficiencia de los abductores de la cadera en apoyo monopodal (glúteo medio y menor).',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Músculos Glúteos y Biomecánica',
    order: 3
  },
  {
    id: 'quiz_t3_cad_04',
    topicId: 'cadera_muslo_triangulo_femoral',
    type: 'single_choice',
    question: 'El ligamento iliofemoral (ligamento de Bertin o en Y de Bigelow) tiene como función principal:',
    options: ['Limitar la hiperextensión de la articulación coxofemoral en bipedestación', 'Limitar la flexión', 'Impedir la rotación interna'],
    correctIndex: 0,
    rationale: 'El ligamento iliofemoral es el más resistente del cuerpo humano; se tensa fuertemente en extensión sosteniendo el peso del tronco sin esfuerzo muscular.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Articulación Coxofemoral',
    order: 4
  },
  {
    id: 'quiz_t3_cad_05',
    topicId: 'cadera_muslo_triangulo_femoral',
    type: 'matching',
    question: 'Relaciona la disposición anatómica de los elementos en el triángulo femoral de lateral a medial (mnemotecnia NAVEL):',
    matchingPairs: [
      { left: 'Elemento más lateral', right: 'Nervio femoral (crural)' },
      { left: 'Elemento intermedio vascular lateral', right: 'Arteria femoral común' },
      { left: 'Elemento medial vascular', right: 'Vena femoral y conducto femoral (ganglio de Cloquet)' }
    ],
    options: ['Disposición neurovascular del triángulo femoral'],
    correctIndex: 0,
    rationale: 'De lateral a medial: Nervio femoral -> Arteria femoral -> Vena femoral -> Espacio femoral (canal y ganglio de Cloquet).',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Conducto y Triángulo Femoral',
    order: 5
  },
  {
    id: 'quiz_t3_cad_06',
    topicId: 'cadera_muslo_triangulo_femoral',
    type: 'ordering',
    question: 'Ordena de anterior a posterior los músculos adductores del muslo en el compartimento medial:',
    orderingItems: [
      'Músculo pectíneo y aductor largo (primer plano)',
      'Músculo aductor corto (segundo plano)',
      'Músculo aductor mayor (tercer plano más profundo)'
    ],
    options: ['Planos de los músculos aductores'],
    correctIndex: 0,
    rationale: 'Los aductores se disponen: plano superficial (pectíneo y aductor largo), plano medio (aductor corto), plano profundo (aductor mayor).',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Músculos del Muslo',
    order: 6
  },
  {
    id: 'quiz_t3_cad_07',
    topicId: 'cadera_muslo_triangulo_femoral',
    type: 'single_choice',
    question: 'El conducto de los aductores (conducto de Hunter) comunica el triángulo femoral con:',
    options: ['La fosa poplítea a través del hiato del aductor mayor', 'El compartimento anterior de la pierna', 'La cavidad pélvica'],
    correctIndex: 0,
    rationale: 'El conducto de Hunter es un canal aponeurótico anteromedial que transmite los vasos femorales hacia la fosa poplítea por el hiato aductor.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Conducto de los Aductores de Hunter',
    order: 7
  },
  {
    id: 'quiz_t3_cad_08',
    topicId: 'cadera_muslo_triangulo_femoral',
    type: 'single_choice',
    question: '¿Qué nervio sensitivo acompaña a la arteria femoral en el conducto de los aductores sin atravesar el hiato tendinoso?',
    options: ['Nervio safeno (rama del nervio femoral)', 'Nervio ciático', 'Nervio obturador'],
    correctIndex: 0,
    rationale: 'El nervio safeno desciende con los vasos femorales en el conducto de Hunter pero lo abandona perforando la fascia para hacerse superficial en la cara medial de la rodilla.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Nervio Safeno',
    order: 8
  },
  {
    id: 'quiz_t3_cad_09',
    topicId: 'cadera_muslo_triangulo_femoral',
    type: 'case_study',
    question: 'Un paciente sufre fractura subcapital del cuello del fémur intracapsular. Presenta necrosis avascular progresiva de la cabeza femoral. ¿Qué aporte arterial vital fue seccionado por la fractura?',
    options: ['Ramas retinaculares de las arterias circunflejas femorales medial y lateral', 'Arteria obturatriz exclusivamente', 'Arteria ilíaca interna'],
    correctIndex: 0,
    rationale: 'La cabeza femoral recibe su irrigación primaria a través de las ramas retinaculares del anillo arterial de las circunflejas femorales; la fractura del cuello femoral intracapsular rasga estas arterias causando necrosis.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Vascularización del Cuello y Cabeza Femoral',
    order: 9
  },
  {
    id: 'quiz_t3_cad_10',
    topicId: 'cadera_muslo_triangulo_femoral',
    type: 'single_choice',
    question: 'El foramen ciático mayor está dividido en dos espacios (suprapiriforme e infrapiriforme) por el músculo:',
    options: ['Músculo piriforme (piramidal de la pelvis)', 'Músculo obturador interno', 'Músculo cuadrado femoral'],
    correctIndex: 0,
    rationale: 'El músculo piriforme emerge de la pelvis por el agujero ciático mayor dividiéndolo en un espacio suprapiriforme (vasos y nervio glúteos superiores) e infrapiriforme (nervio ciático, vasos glúteos inferiores, pudendos).',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Espacios Suprapiriforme e Infrapiriforme',
    order: 10
  },
  {
    id: 'quiz_t3_cad_11',
    topicId: 'cadera_muslo_triangulo_femoral',
    type: 'single_choice',
    question: 'El nervio ciático (isquiático), el nervio más voluminoso del cuerpo, sale de la pelvis a través de:',
    options: ['El espacio infrapiriforme del foramen ciático mayor', 'El foramen ciático menor', 'El conducto obturador'],
    correctIndex: 0,
    rationale: 'El nervio ciático emerge de la cavidad pélvica por el foramen ciático mayor pasando inferior al músculo piriforme (espacio infrapiriforme).',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Nervio Ciático',
    order: 11
  },
  {
    id: 'quiz_t3_cad_12',
    topicId: 'cadera_muslo_triangulo_femoral',
    type: 'single_choice',
    question: '¿Qué músculo del muslo flexiona la cadera y extiende la rodilla al mismo tiempo por ser biarticular?',
    options: ['Músculo recto femoral (recto anterior del cuádriceps)', 'Músculo vasto lateral', 'Músculo vasto medial'],
    correctIndex: 0,
    rationale: 'El recto femoral nace en la espina ilíaca anteroinferior (tendón directo) y ceja cotiloidea (tendón reflejo), cruzando la cadera y la rodilla.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Músculo Cuádriceps Femoral',
    order: 12
  },
  {
    id: 'quiz_t3_cad_13',
    topicId: 'cadera_muslo_triangulo_femoral',
    type: 'matching',
    question: 'Empareja los músculos pelvitrocantéreos con su acción biomecánica común:',
    matchingPairs: [
      { left: 'Piriforme, obturadores, gemelos y cuadrado femoral', right: 'Rotación lateral (externa) de la cadera' },
      { left: 'Glúteo medio y glúteo menor', right: 'Abducción y rotación medial de la cadera' },
      { left: 'Glúteo mayor', right: 'Extensor más potente de la cadera (subir escaleras)' }
    ],
    options: ['Músculos glúteos y pelvitrocantéreos'],
    correctIndex: 0,
    rationale: 'Los pelvitrocantéreos son rotadores externos; los glúteos medio y menor son abductores; el glúteo mayor es el gran extensor.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Biomecánica Pelviana',
    order: 13
  },
  {
    id: 'quiz_t3_cad_14',
    topicId: 'cadera_muslo_triangulo_femoral',
    type: 'ordering',
    question: 'Ordena de proximal a distal las arterias del eje arterial del muslo:',
    orderingItems: [
      'Arteria ilíaca externa',
      'Arteria femoral común (bajo el ligamento inguinal)',
      'Arteria femoral profunda y femoral superficial',
      'Arteria poplítea (tras cruzar el hiato aductor)'
    ],
    options: ['Eje arterial femoral'],
    correctIndex: 0,
    rationale: 'Ilíaca externa -> Femoral común -> Femoral superficial -> Poplítea tras el anillo del 3.er aductor.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Arteria Femoral',
    order: 14
  },
  {
    id: 'quiz_t3_cad_15',
    topicId: 'cadera_muslo_triangulo_femoral',
    type: 'single_choice',
    question: 'La vena safena magna (safena interna) desemboca en la vena femoral atravesando la fascia cribiforme a través de:',
    options: ['El hiato safeno (fosa oval)', 'El anillo inguinal superficial', 'El conducto de Hunter'],
    correctIndex: 0,
    rationale: 'El cayado de la safena magna desemboca en la vena femoral común pasando por el hiato safeno (de Allan Burns) en la fascia cribiforme.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Vena Safena Magna',
    order: 15
  },
  {
    id: 'quiz_t3_cad_16',
    topicId: 'cadera_muslo_triangulo_femoral',
    type: 'single_choice',
    question: 'El ligamento de la cabeza del fémur (ligamento redondo) se inserta en:',
    options: ['La fosita de la cabeza femoral y el fondo acetabular', 'El trocánter mayor', 'La cresta intertrocantérea'],
    correctIndex: 0,
    rationale: 'El ligamento redondo contiene la arteria del ligamento de la cabeza del fémur (rama obturatriz) y va de la fovea capitis al fondo acetabular.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Ligamento de la Cabeza Femoral',
    order: 16
  },
  {
    id: 'quiz_t3_cad_17',
    topicId: 'cadera_muslo_triangulo_femoral',
    type: 'case_study',
    question: 'Durante una inyección intramuscular en la región glútea, ¿en qué cuadrante anatómico se debe puncionar de forma estricta para evitar la lesión del nervio ciático?',
    options: ['Cuadrante superoexterno (superolateral)', 'Cuadrante inferointerno', 'Cuadrante superointerno'],
    correctIndex: 0,
    rationale: 'El cuadrante superoexterno de la nalga está libre del nervio ciático, el cual desciende centrado por los cuadrantes inferiores.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Región Glútea y Nervio Ciático',
    order: 17
  },
  {
    id: 'quiz_t3_cad_18',
    topicId: 'cadera_muslo_triangulo_femoral',
    type: 'single_choice',
    question: '¿Qué músculo se origina en la espina ilíaca anterosuperior y cruza oblicuamente el muslo ("músculo de los sastres")?',
    options: ['Músculo sartorio', 'Músculo grácil', 'Músculo tensor de la fascia lata'],
    correctIndex: 0,
    rationale: 'El sartorio es el músculo más largo del cuerpo; flexiona, abduce y rota lateralmente la cadera y flexiona la rodilla.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Músculo Sartorio',
    order: 18
  },
  {
    id: 'quiz_t3_cad_19',
    topicId: 'cadera_muslo_triangulo_femoral',
    type: 'single_choice',
    question: 'El tracto iliotibial (cintilla de Maissiat) es una condensación fibrosa lateral que recibe las inserciones de:',
    options: ['Músculo tensor de la fascia lata y fibras anteriores del glúteo mayor', 'Músculo sartorio', 'Músculo bíceps femoral'],
    correctIndex: 0,
    rationale: 'El tracto iliotibial refuerza la fascia lata por fuera y termina distalmente en el tubérculo de Gerdy de la tibia.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Fascia Lata y Tracto Iliotibial',
    order: 19
  },
  {
    id: 'quiz_t3_cad_20',
    topicId: 'cadera_muslo_triangulo_femoral',
    type: 'single_choice',
    question: 'El nervio obturador inerva la mayoría de los músculos del compartimento:',
    options: ['Compartimento medial (aductores del muslo)', 'Compartimento anterior', 'Compartimento posterior'],
    correctIndex: 0,
    rationale: 'El nervio obturador (L2-L4) sale por el conducto obturador e inerva a los aductores corto, largo, mitad del mayor y al grácil.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Nervio Obturador',
    order: 20
  },

  // =========================================================================
  // TEMA 5: rodilla_pierna_fosa_poplitea (20 QUIZZES)
  // =========================================================================
  {
    id: 'quiz_t3_rod_01',
    topicId: 'rodilla_pierna_fosa_poplitea',
    type: 'single_choice',
    question: '¿Qué ligamento cruzado de la rodilla previene el desplazamiento anterior de la tibia respecto al fémur (signo del cajón anterior)?',
    options: ['Ligamento cruzado anterior (LCA)', 'Ligamento cruzado posterior (LCP)', 'Ligamento rotuliano'],
    correctIndex: 0,
    rationale: 'El ligamento cruzado anterior (inserción tibial anteromedial hacia el cóndilo lateral femoral) frena el cajón anterior.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Articulación de la Rodilla',
    order: 1
  },
  {
    id: 'quiz_t3_rod_02',
    topicId: 'rodilla_pierna_fosa_poplitea',
    type: 'single_choice',
    question: 'La fosa poplítea (hueco poplíteo) tiene en su vértice superior los límites musculares formados por:',
    options: ['Músculo bíceps femoral (superolateral) y semitendinoso/semimembranoso (superomedial)', 'Músculos gastrocnemios', 'Sartorio y grácil'],
    correctIndex: 0,
    rationale: 'El triángulo superior del rombo poplíteo lo delimitan lateralmente el bíceps femoral y medialmente los músculos semitendinoso y semimembranoso.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Fosa Poplítea',
    order: 2
  },
  {
    id: 'quiz_t3_rod_03',
    topicId: 'rodilla_pierna_fosa_poplitea',
    type: 'case_study',
    question: 'Futbolista sufre torsión violenta en valgo y rotación de rodilla presentando la "Tríada terrible de O\'Donoghue". ¿Cuáles son las tres estructuras lesionadas?',
    options: ['Ligamento colateral medial (tibial), menisco medial y ligamento cruzado anterior', 'Ambos ligamentos cruzados y rótula', 'Ligamento colateral lateral, menisco lateral y LCP'],
    correctIndex: 0,
    rationale: 'La tríada clásica de O\'Donoghue consiste en la rotura combinada del ligamento colateral medial, el menisco medial (adherido al LCM) y el ligamento cruzado anterior.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Lesiones Traumáticas de la Rodilla',
    order: 3
  },
  {
    id: 'quiz_t3_rod_04',
    topicId: 'rodilla_pierna_fosa_poplitea',
    type: 'single_choice',
    question: 'El menisco medial de la rodilla tiene forma de:',
    options: ['Semiluna abierta en forma de letra "C"', 'Anillo casi cerrado en letra "O"', 'Triángulo equilátero'],
    correctIndex: 0,
    rationale: 'Regla mnemotécnica CITROEN (CITRO): el Menisco Medial o Interno tiene forma de C (más grande y menos móvil); el Menisco Lateral tiene forma de O.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Meniscos de la Rodilla',
    order: 4
  },
  {
    id: 'quiz_t3_rod_05',
    topicId: 'rodilla_pierna_fosa_poplitea',
    type: 'matching',
    question: 'Relaciona la disposición de las estructuras vasculonerviosas en la fosa poplítea de superficial a profundo (N-V-A):',
    matchingPairs: [
      { left: 'Elemento más superficial', right: 'Nervio tibial (ciático poplíteo interno)' },
      { left: 'Elemento intermedio', right: 'Vena poplítea' },
      { left: 'Elemento más profundo (adosado al suelo óseo)', right: 'Arteria poplítea' }
    ],
    options: ['Paquete poplíteo de superficial a profundo'],
    correctIndex: 0,
    rationale: 'En el eje poplíteo de superficial a profundo: Nervio tibial -> Vena poplítea -> Arteria poplítea (N-V-A).',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Eje Vasculonervioso Poplíteo',
    order: 5
  },
  {
    id: 'quiz_t3_rod_06',
    topicId: 'rodilla_pierna_fosa_poplitea',
    type: 'ordering',
    question: 'Ordena de superficial a profundo los tendones de la pata de ganso superficial (pes anserinus) en la cara anteromedial de la tibia:',
    orderingItems: [
      'Músculo sartorio',
      'Músculo grácil (recto interno)',
      'Músculo semitendinoso'
    ],
    options: ['Tendones de la pata de ganso'],
    correctIndex: 0,
    rationale: 'Mnemotecnia clásica SGS ("Sargento": Sartorio, Grácil, Semitendinoso); el sartorio cubre superficialmente al grácil y al semitendinoso.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Pata de Ganso Superficial',
    order: 6
  },
  {
    id: 'quiz_t3_rod_07',
    topicId: 'rodilla_pierna_fosa_poplitea',
    type: 'single_choice',
    question: '¿Qué nervio contornea el cuello del peroné (fíbula), donde es vulnerable a fracturas y compresión externa?',
    options: ['Nervio peroneo común (fibular común)', 'Nervio tibial', 'Nervio safeno'],
    correctIndex: 0,
    rationale: 'El nervio peroneo común rodea íntimamente el cuello del peroné; su lesión causa "pie caído" e incapacidad para la eversión y dorsiflexión.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Nervio Peroneo Común',
    order: 7
  },
  {
    id: 'quiz_t3_rod_08',
    topicId: 'rodilla_pierna_fosa_poplitea',
    type: 'single_choice',
    question: 'El músculo poplíteo es fundamental en la biomecánica de la rodilla debido a que:',
    options: ['"Destraba" la rodilla en extensión completa realizando rotación lateral del fémur sobre la tibia fija para iniciar la flexión', 'Es el principal extensor de la rodilla', 'Mantiene la rótula alineada'],
    correctIndex: 0,
    rationale: 'El poplíteo es un rotador interno de la tibia (o rotador externo del fémur con pie apoyado) indispensable para desbloquear el mecanismo de extensión de la rodilla.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Músculo Poplíteo',
    order: 8
  },
  {
    id: 'quiz_t3_rod_09',
    topicId: 'rodilla_pierna_fosa_poplitea',
    type: 'case_study',
    question: 'Un paciente joven tras fractura cerrada de diáfisis tibial desarrolla dolor desproporcionado, tensión leñosa en la pantorrilla anterior y parestesia en el 1.er espacio interdigital (síndrome compartimental agudo). ¿Qué compartimento fascial de la pierna requiere fasciotomía urgente?',
    options: ['Compartimento anterior de la pierna (arteria tibial anterior y nervio peroneo profundo)', 'Compartimento posterior superficial', 'Compartimento lateral'],
    correctIndex: 0,
    rationale: 'El compartimento anterior de la pierna es el más propenso al síndrome compartimental agudo; aloja al nervio peroneo profundo y vasos tibiales anteriores.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Compartimentos Fasciales de la Pierna',
    order: 9
  },
  {
    id: 'quiz_t3_rod_10',
    topicId: 'rodilla_pierna_fosa_poplitea',
    type: 'single_choice',
    question: 'El tendón rotuliano (ligamento rotuliano) se inserta distalmente en:',
    options: ['La tuberosidad anterior de la tibia', 'La cabeza del peroné', 'El maléolo medial'],
    correctIndex: 0,
    rationale: 'El ligamento rotuliano continúa la inserción del cuádriceps fijándose con fuerza en la tuberosidad tibial anterior.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Rótula y Aparato Extensor',
    order: 10
  },
  {
    id: 'quiz_t3_rod_11',
    topicId: 'rodilla_pierna_fosa_poplitea',
    type: 'single_choice',
    question: 'El tríceps sural está compuesto por los dos músculos gastrocnemios (gemelos) y el músculo:',
    options: ['Músculo sóleo', 'Músculo tibial posterior', 'Músculo flexor largo de los dedos'],
    correctIndex: 0,
    rationale: 'El tríceps sural reúne los gastrocnemios medial y lateral (superficiales) y el sóleo (profundo), confluyendo en el potente tendón de Aquiles.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Músculo Tríceps Sural',
    order: 11
  },
  {
    id: 'quiz_t3_rod_12',
    topicId: 'rodilla_pierna_fosa_poplitea',
    type: 'single_choice',
    question: 'La arteria tibial anterior cruza por delante de la membrana interósea hacia el compartimento anterior y se convierte a nivel del tobillo en:',
    options: ['Arteria dorsal del pie (arteria pedia)', 'Arteria plantar medial', 'Arteria peronea'],
    correctIndex: 0,
    rationale: 'Al pasar por debajo del retináculo extensor inferior del tobillo, la arteria tibial anterior pasa a denominarse arteria pedia dorsal del pie.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Arteria Tibial Anterior y Pedia',
    order: 12
  },
  {
    id: 'quiz_t3_rod_13',
    topicId: 'rodilla_pierna_fosa_poplitea',
    type: 'matching',
    question: 'Asocia cada músculo de la pata de ganso superficial con su nervio motor:',
    matchingPairs: [
      { left: 'Músculo sartorio', right: 'Nervio femoral (L2-L4)' },
      { left: 'Músculo grácil', right: 'Nervio obturador (L2-L4)' },
      { left: 'Músculo semitendinoso', right: 'Nervio tibial (componente del ciático)' }
    ],
    options: ['Inervación de la pata de ganso'],
    correctIndex: 0,
    rationale: 'Pata de ganso superficial recibe aportes de 3 nervios distintos: femoral (sartorio), obturador (grácil) y ciático/tibial (semitendinoso).',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Inervación de la Pata de Ganso',
    order: 13
  },
  {
    id: 'quiz_t3_rod_14',
    topicId: 'rodilla_pierna_fosa_poplitea',
    type: 'ordering',
    question: 'Ordena de medial a lateral los elementos en el compartimento anterior del tobillo bajo el retináculo extensor:',
    orderingItems: [
      'Tendón del músculo tibial anterior',
      'Tendón del extensor largo del dedo gordo',
      'Arteria tibial anterior y nervio peroneo profundo',
      'Tendones del extensor largo de los dedos y tercer peroneo'
    ],
    options: ['Disposición anterior del tobillo'],
    correctIndex: 0,
    rationale: 'De medial a lateral: Tibial anterior -> Extensor del hallux -> Paquete vasculonervioso -> Extensor de los dedos.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Región Anterior del Tobillo',
    order: 14
  },
  {
    id: 'quiz_t3_rod_15',
    topicId: 'rodilla_pierna_fosa_poplitea',
    type: 'single_choice',
    question: 'El ligamento poplíteo oblicuo (tendón recurrente de Winslow) es una expansión fibrosa procedente del tendón del músculo:',
    options: ['Músculo semimembranoso', 'Músculo bíceps femoral', 'Músculo gastrocnemio'],
    correctIndex: 0,
    rationale: 'El semimembranoso emite 3 tendones en la rodilla: directo, reflejo y recurrente (ligamento poplíteo oblicuo hacia el cóndilo lateral del fémur).',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Músculo Semimembranoso',
    order: 15
  },
  {
    id: 'quiz_t3_rod_16',
    topicId: 'rodilla_pierna_fosa_poplitea',
    type: 'single_choice',
    question: 'El quiste de Baker (quiste poplíteo) es una herniación de la bolsa sinovial articular hacia la fosa poplítea situada entre:',
    options: ['La cabeza medial del gastrocnemio y el tendón del semimembranoso', 'El bíceps femoral y el fémur', 'Los dos gemelos'],
    correctIndex: 0,
    rationale: 'La bolsa de la cabeza medial del gemelo y semimembranoso comunica comúnmente con la cavidad articular de la rodilla acumulando líquido sinovial.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Bolsas Serosas Poplíteas',
    order: 16
  },
  {
    id: 'quiz_t3_rod_17',
    topicId: 'rodilla_pierna_fosa_poplitea',
    type: 'case_study',
    question: 'Paciente con dolor en la cara externa de la rodilla al correr ("síndrome de fricción de la cintilla iliotibial"). ¿Sobre qué eminencia ósea roza repetitivamente este tracto fibroso?',
    options: ['Epicóndilo lateral del fémur', 'Tubérculo de Gerdy', 'Cabeza del peroné'],
    correctIndex: 0,
    rationale: 'La fricción del borde posterior del tracto iliotibial ocurre contra el epicóndilo lateral femoral durante la flexión y extensión repetida a 30 grados.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Tracto Iliotibial en la Rodilla',
    order: 17
  },
  {
    id: 'quiz_t3_rod_18',
    topicId: 'rodilla_pierna_fosa_poplitea',
    type: 'single_choice',
    question: 'El compartimento lateral de la pierna contiene a los músculos:',
    options: ['Peroneo largo y peroneo corto (inervados por el nervio peroneo superficial)', 'Tibial anterior y sóleo', 'Gastrocnemios'],
    correctIndex: 0,
    rationale: 'Los músculos peroneos largo y corto son eversores del pie y están inervados por el nervio peroneo superficial (fibular superficial).',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Compartimento Lateral de la Pierna',
    order: 18
  },
  {
    id: 'quiz_t3_rod_19',
    topicId: 'rodilla_pierna_fosa_poplitea',
    type: 'single_choice',
    question: '¿Qué nervio proporciona inervación a los músculos extensores de los dedos y dorsiflexores del pie en la pierna?',
    options: ['Nervio peroneo profundo (tibial anterior)', 'Nervio tibial', 'Nervio peroneo superficial'],
    correctIndex: 0,
    rationale: 'El nervio peroneo profundo inerva los músculos del compartimento anterior: tibial anterior, extensor largo de los dedos y extensor largo del pulgar.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Nervio Peroneo Profundo',
    order: 19
  },
  {
    id: 'quiz_t3_rod_20',
    topicId: 'rodilla_pierna_fosa_poplitea',
    type: 'single_choice',
    question: 'La arteria poplítea termina a nivel del arco tendinoso del músculo sóleo bifurcándose en:',
    options: ['Arteria tibial anterior y tronco tibioperoneo', 'Arteria peronea y femoral', 'Arterias plantares'],
    correctIndex: 0,
    rationale: 'Bajo el anillo del sóleo, la arteria poplítea da la arteria tibial anterior y el tronco tibioperoneo (que luego se divide en tibial posterior y peronea).',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Terminación de la Arteria Poplítea',
    order: 20
  },

  // =========================================================================
  // TEMA 6: tobillo_pie_arcos_plantares (20 QUIZZES)
  // =========================================================================
  {
    id: 'quiz_t3_pie_01',
    topicId: 'tobillo_pie_arcos_plantares',
    type: 'single_choice',
    question: 'En los esguinces de tobillo por inversión forzada, ¿cuál es el ligamento lateral que se rompe con mayor frecuencia?',
    options: ['Ligamento talofibuloar anterior (peroneoastragalino anterior)', 'Ligamento calcaneofibular (peroneocalcáneo)', 'Ligamento deltoideo'],
    correctIndex: 0,
    rationale: 'El ligamento peroneoastragalino anterior (LPAA) es el estabilizador anterolateral principal y el elemento más frecuentemente desgarrado en el esguince de tobillo en inversión.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Articulación Talocrural',
    order: 1
  },
  {
    id: 'quiz_t3_pie_02',
    topicId: 'tobillo_pie_arcos_plantares',
    type: 'single_choice',
    question: 'El ligamento deltoideo (ligamento colateral medial del tobillo) se fija superiormente en:',
    options: ['El maléolo medial de la tibia', 'El maléolo lateral del peroné', 'El calcáneo'],
    correctIndex: 0,
    rationale: 'El ligamento deltoideo es un potente abanico fibroso medial que nace del maléolo medial tibial y se extiende hacia el astrágalo, calcáneo y navicular.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Ligamento Deltoideo',
    order: 2
  },
  {
    id: 'quiz_t3_pie_03',
    topicId: 'tobillo_pie_arcos_plantares',
    type: 'case_study',
    question: 'Corredor sufre chasquido audible en la parte posterior del talón ("signo de la pedrada") con impotencia funcional para la flexión plantar y prueba de Thompson positiva (ausencia de flexión plantar al comprimir la pantorrilla). ¿Qué estructura se desgarró?',
    options: ['Tendón calcáneo (tendón de Aquiles)', 'Tendón del tibial anterior', 'Ligamento plantar largo'],
    correctIndex: 0,
    rationale: 'La rotura del tendón de Aquiles anula la flexión plantar activa del pie; la maniobra de Thompson es la prueba patognomónica clínica.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Tendón Calcáneo',
    order: 3
  },
  {
    id: 'quiz_t3_pie_04',
    topicId: 'tobillo_pie_arcos_plantares',
    type: 'single_choice',
    question: 'El túnel del tarso (canal retromaleolar medial) está delimitado por el maléolo medial, el calcáneo y:',
    options: ['El retináculo flexor del tobillo', 'El retináculo extensor', 'El ligamento deltoideo'],
    correctIndex: 0,
    rationale: 'El túnel tarsiano osteofibroso lo cierra el retináculo de los flexores sobre la cara medial del calcáneo y astrágalo.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Túnel del Tarso',
    order: 4
  },
  {
    id: 'quiz_t3_pie_05',
    topicId: 'tobillo_pie_arcos_plantares',
    type: 'matching',
    question: 'Relaciona los huesos del tarso con su fila y posición anatómica:',
    matchingPairs: [
      { left: 'Astrágalo (talus)', right: 'Recibe el peso corporal desde la tibia en la tróclea astragalina' },
      { left: 'Calcáneo', right: 'Hueso más voluminoso del pie que forma la eminencia del talón' },
      { left: 'Navicular (escafoides del pie)', right: 'Interpuesto entre la cabeza astragalina y las tres cuñas' }
    ],
    options: ['Huesos del tarso'],
    correctIndex: 0,
    rationale: 'Astrágalo soporta el eje tibial; calcáneo forma el talón; navicular es la piedra angular medial.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Esqueleto del Pie',
    order: 5
  },
  {
    id: 'quiz_t3_pie_06',
    topicId: 'tobillo_pie_arcos_plantares',
    type: 'ordering',
    question: 'Ordena de medial a lateral los elementos en el canal retromaleolar medial del tobillo (túnel del tarso):',
    orderingItems: [
      'Tendón del músculo tibial posterior',
      'Tendón del músculo flexor largo de los dedos',
      'Arteria tibial posterior y nervio tibial',
      'Tendón del músculo flexor largo del dedo gordo'
    ],
    options: ['Túnel tarsiano retromaleolar medial'],
    correctIndex: 0,
    rationale: 'Mnemotecnia clásica: Ti-Di-Va-N-Go (Tibial posterior, flexor largo de los Dedos, Vasos tibiales, Nervio tibial y flexor de Gorila/gordo).',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Contenido del Túnel del Tarso',
    order: 6
  },
  {
    id: 'quiz_t3_pie_07',
    topicId: 'tobillo_pie_arcos_plantares',
    type: 'single_choice',
    question: 'El sustentaculum tali (apófisis menor del calcáneo) es una repisa ósea medial del calcáneo que sirve de apoyo a:',
    options: ['La cabeza y cuerpo del astrágalo y polea del tendón flexor largo del hallux', 'El maléolo peroneo', 'El tendón de Aquiles'],
    correctIndex: 0,
    rationale: 'El sustentáculo del astrágalo sobresale medialmente del calcáneo, soportando la carilla articular media astragalina.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Calcáneo y Sustentaculum Tali',
    order: 7
  },
  {
    id: 'quiz_t3_pie_08',
    topicId: 'tobillo_pie_arcos_plantares',
    type: 'single_choice',
    question: 'La articulación talocrural (tibioperoneoastragalina) se clasifica funcionalmente como:',
    options: ['Gínglimo (tróclea pura en bisagra para flexo-extensión)', 'Enartrosis', 'Condílea'],
    correctIndex: 0,
    rationale: 'La mortaja tibioperonea con la tróclea del astrágalo forma una articulación troclear pura que permite dorsiflexión y flexión plantar.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Articulación Talocrural',
    order: 8
  },
  {
    id: 'quiz_t3_pie_09',
    topicId: 'tobillo_pie_arcos_plantares',
    type: 'case_study',
    question: 'Paciente obeso presenta dolor punzante e intenso en la cara plantar del talón al dar el primer paso matutino al levantarse de la cama (fascitis plantar). ¿En qué punto del calcáneo se inserta esta aponeurosis?',
    options: ['Tuberosidad medial del calcáneo', 'Sustentaculum tali', 'Tróclea peroneal'],
    correctIndex: 0,
    rationale: 'La fascia plantar se origina en la tubérculo medial de la tuberosidad del calcáneo y se tensa durante la marcha soportando el arco longitudinal.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Aponeurosis Plantar y Calcáneo',
    order: 9
  },
  {
    id: 'quiz_t3_pie_10',
    topicId: 'tobillo_pie_arcos_plantares',
    type: 'single_choice',
    question: 'El arco longitudinal medial del pie está mantenido activamente por el tendón dinámico principal de:',
    options: ['Músculo tibial posterior', 'Músculo peroneo largo', 'Músculo sóleo'],
    correctIndex: 0,
    rationale: 'El tendón del tibial posterior se inserta en la tuberosidad del navicular y en todos los huesos del tarso y metatarso (excepto astrágalo), siendo el principal sostén del arco plantar medial.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Arcos y Bóveda Plantar',
    order: 10
  },
  {
    id: 'quiz_t3_pie_11',
    topicId: 'tobillo_pie_arcos_plantares',
    type: 'single_choice',
    question: 'El ligamento calcaneonavicular plantar (ligamento en resorte o spring ligament) sostiene la cabeza del astrágalo y se extiende entre:',
    options: ['El sustentaculum tali del calcáneo y la cara inferior del navicular', 'El peroné y el cuboides', 'Los metatarsianos'],
    correctIndex: 0,
    rationale: 'El ligamento spring (calcaneonavicular plantar) es una lámina fibrocartilaginosa resistente que impide el colapso de la cabeza astragalina hacia el suelo.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Ligamento Calcaneonavicular Plantar',
    order: 11
  },
  {
    id: 'quiz_t3_pie_12',
    topicId: 'tobillo_pie_arcos_plantares',
    type: 'single_choice',
    question: '¿Qué nervio se divide dentro del túnel tarsiano en los nervios plantar medial y plantar lateral para la inervación de la planta del pie?',
    options: ['Nervio tibial', 'Nervio peroneo superficial', 'Nervio femoral'],
    correctIndex: 0,
    rationale: 'El nervio tibial desciende detrás del maléolo medial dividiéndose en los nervios plantar medial y lateral (homólogos al mediano y cubital en la mano).',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Inervación de la Planta del Pie',
    order: 12
  },
  {
    id: 'quiz_t3_pie_13',
    topicId: 'tobillo_pie_arcos_plantares',
    type: 'matching',
    question: 'Empareja los movimientos del pie con las articulaciones donde primariamente ocurren:',
    matchingPairs: [
      { left: 'Dorsiflexión y flexión plantar', right: 'Articulación talocrural (tobillo propiamente dicho)' },
      { left: 'Inversión y eversión', right: 'Articulaciones subtalar (astragalocalcánea) y transversa del tarso (Chopart)' },
      { left: 'Pronación y supinación de antepié', right: 'Articulación tarsometatarsiana (Lisfranc)' }
    ],
    options: ['Cinemática del complejo articular del pie'],
    correctIndex: 0,
    rationale: 'Talocrural hace flexoextensión sagital; subtalar y Chopart hacen inversión/eversión coronal/transversa.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Biomecánica del Pie',
    order: 13
  },
  {
    id: 'quiz_t3_pie_14',
    topicId: 'tobillo_pie_arcos_plantares',
    type: 'ordering',
    question: 'Ordena de lateral a medial los tres huesos cuneiformes (cuñas) del tarso distal:',
    orderingItems: [
      'Cuneiforme lateral (tercera cuña)',
      'Cuneiforme intermedio (segunda cuña)',
      'Cuneiforme medial (primera cuña)'
    ],
    options: ['Huesos cuneiformes'],
    correctIndex: 0,
    rationale: 'De lateral a medial: Cuña 3 (lateral), Cuña 2 (intermedia), Cuña 1 (medial más voluminosa).',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Fila Distal del Tarso',
    order: 14
  },
  {
    id: 'quiz_t3_pie_15',
    topicId: 'tobillo_pie_arcos_plantares',
    type: 'single_choice',
    question: 'La articulación transversa del tarso (línea articular de Chopart) une:',
    options: ['El astrágalo y calcáneo con el navicular y cuboides', 'El tarso con los metatarsianos', 'La tibia con el astrágalo'],
    correctIndex: 0,
    rationale: 'La línea de Chopart está formada por dos articulaciones en S itálica: la talonavicular medialmente y la calcaneocuboidea lateralmente.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Articulación de Chopart',
    order: 15
  },
  {
    id: 'quiz_t3_pie_16',
    topicId: 'tobillo_pie_arcos_plantares',
    type: 'single_choice',
    question: 'La articulación tarsometatarsiana (de Lisfranc) se caracteriza porque la base del segundo metatarsiano está:',
    options: ['Encastrada en una "mortaja" entre las cuñas medial y lateral, siendo la más estable', 'Totalmente libre sin ligamentos', 'Soldada al calcáneo'],
    correctIndex: 0,
    rationale: 'La base del 2.° metatarsiano se retrae proximalmente encastrada entre la 1.ª y 3.ª cuña, funcionando como llave de la bóveda de Lisfranc.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Articulación de Lisfranc',
    order: 16
  },
  {
    id: 'quiz_t3_pie_17',
    topicId: 'tobillo_pie_arcos_plantares',
    type: 'case_study',
    question: 'Mujer joven consulta por dolor quemante en el tercer espacio intermetatarsiano al usar calzado estrecho (neuroma de Morton). ¿Qué estructura nerviosa está engrosada y comprimida contra el ligamento intermetatarsiano transverso profundo?',
    options: ['Nervio digital plantar común del tercer espacio interdigital', 'Nervio safeno', 'Nervio sural'],
    correctIndex: 0,
    rationale: 'El neuroma de Morton es una neuropatía compresiva del nervio digital plantar común entre las cabezas del 3.er y 4.° metatarsianos.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Nervios Plantares y Neuroma de Morton',
    order: 17
  },
  {
    id: 'quiz_t3_pie_18',
    topicId: 'tobillo_pie_arcos_plantares',
    type: 'single_choice',
    question: '¿Qué tendón muscular cruza oblicuamente toda la planta del pie en un surco bajo el hueso cuboides para insertarse en la primera cuña y base del 1.er metatarsiano?',
    options: ['Tendón del músculo peroneo largo', 'Tendón del tibial anterior', 'Tendón del flexor largo de los dedos'],
    correctIndex: 0,
    rationale: 'El tendón del peroneo largo entra a la planta por el surco del cuboides cruzando de lateral a medial para insertarse en la base del primer metatarsiano.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Tendón del Peroneo Largo',
    order: 18
  },
  {
    id: 'quiz_t3_pie_19',
    topicId: 'tobillo_pie_arcos_plantares',
    type: 'single_choice',
    question: 'El pulso de la arteria dorsal del pie (arteria pedia) se palpa habitualmente entre:',
    options: ['El tendón del extensor largo del dedo gordo y el tendón del extensor largo de los dedos', 'El maléolo medial y el tendón de Aquiles', 'La base del 5.° metatarsiano'],
    correctIndex: 0,
    rationale: 'El pulso pedio se palpa sobre los huesos del tarso inmediatamente lateral al tendón del extensor largo del hallux en el dorso del pie.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Pulso Pedio',
    order: 19
  },
  {
    id: 'quiz_t3_pie_20',
    topicId: 'tobillo_pie_arcos_plantares',
    type: 'single_choice',
    question: 'El músculo cuadrado plantar (carnoso de Silvio) cumple la función mecánica indispensable de:',
    options: ['Corregir la tracción oblicua del tendón del flexor largo de los dedos alineándolo con el eje longitudinal del pie', 'Extender los dedos', 'Abducir el quinto dedo'],
    correctIndex: 0,
    rationale: 'El cuadrado plantar nace en el calcáneo y se inserta en el tendón del flexor largo de los dedos, rectificando su vector oblicuo para lograr una flexión axial de los dedos.',
    sourceBook: 'Rouvière - Delmas: Tomo 3, Músculo Cuadrado Plantar',
    order: 20
  }
];

export async function run() {
  await uploadQuizzesBatch(tomo3Part2Quizzes, 'Rouvière Tomo 3 (Bloque B: Temas 4 a 6)');
}
