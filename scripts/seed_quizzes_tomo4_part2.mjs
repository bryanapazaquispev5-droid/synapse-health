// Quizzes Clínicos de Anatomía Humana - Rouvière Tomo 4 (SNC: Parte 2: Temas 4 a 6)
// 3 Temas x 20 Quizzes = 60 Quizzes
import { uploadQuizzesBatch } from './seed_quizzes_common.mjs';

const tomo4Part2Quizzes = [
  // =========================================================================
  // TEMA 4: diencefalo_sistema_limbico (20 QUIZZES)
  // =========================================================================
  {
    id: 'quiz_t4_die_01',
    topicId: 'diencefalo_sistema_limbico',
    type: 'single_choice',
    question: 'El tálamo es la gran estación de relevo sensorial del cerebro. ¿Cuál es el único sentido que NO hace escala sináptica obligatoria en el tálamo antes de llegar a la corteza cerebral primaria?',
    options: ['Sentido del olfato', 'Sentido de la vista', 'Sentido del gusto'],
    correctIndex: 0,
    rationale: 'La vía olfatoria es la única que proyecta directamente desde el bulbo olfatorio hacia la corteza piriforme temporal sin pasar previamente por un núcleo talámico.',
    sourceBook: 'Rouvière - Delmas: Tomo 4 (Sistema Nervioso Central), Tálamo y Vías Sensitivas',
    order: 1
  },
  {
    id: 'quiz_t4_die_02',
    topicId: 'diencefalo_sistema_limbico',
    type: 'single_choice',
    question: 'El núcleo ventral posterolateral (VPL) del tálamo recibe las aferencias de la sensibilidad somatosensorial procedentes de:',
    options: ['El tronco y las extremidades (lemnisco medial y haz espinotalámico)', 'La cabeza y la cara (lemnisco trigeminal)', 'La retina ocular'],
    correctIndex: 0,
    rationale: 'El VPL recibe la información del cuerpo y miembros. El núcleo ventral posteromedial (VPM) recibe las sensaciones de la cara (vía trigémino) y el gusto.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Núcleos Específicos del Tálamo',
    order: 2
  },
  {
    id: 'quiz_t4_die_03',
    topicId: 'diencefalo_sistema_limbico',
    type: 'single_choice',
    question: 'Paciente con dolor talámico insoportable y alodinia tras infarto lacunar en el tálamo posterior (Síndrome de Déjerine-Roussy). ¿Qué territorio vascular talámico fue lesionado?',
    options: ['Arterias tálamo-geniculadas (ramas de la arteria cerebral posterior)', 'Arteria comunicante anterior', 'Arteria coroidea anterior'],
    correctIndex: 0,
    rationale: 'El síndrome de Déjerine-Roussy se debe a isquemia en el territorio de las arterias tálamogeniculadas que irrigan los núcleos VPL y pulvinar.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Vascularización del Tálamo',
    order: 3
  },
  {
    id: 'quiz_t4_die_04',
    topicId: 'diencefalo_sistema_limbico',
    type: 'single_choice',
    question: 'El cuerpo geniculado lateral (metatálamo) forma parte fundamental de la vía:',
    options: ['Vía visual (recibe el tracto óptico y proyecta a la corteza visual calcarina)', 'Vía auditiva', 'Vía vestibular'],
    correctIndex: 0,
    rationale: 'El cuerpo geniculado lateral (CGL) procesa la información visual; el cuerpo geniculado medial (CGM) procesa los estímulos auditivos.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Metatálamo',
    order: 4
  },
  {
    id: 'quiz_t4_die_05',
    topicId: 'diencefalo_sistema_limbico',
    type: 'matching',
    question: 'Relaciona cada núcleo hipotalámico con su función endocrina o vegetativa primordial:',
    matchingPairs: [
      { left: 'Núcleos supraóptico y paraventricular', right: 'Síntesis de oxitocina y hormona antidiurética (vasopresina)' },
      { left: 'Núcleo supraquiasmático', right: 'Marcapasos maestro de los ritmos circadianos' },
      { left: 'Hipotálamo lateral y ventromedial', right: 'Centros del hambre (lateral) y de la saciedad (ventromedial)' }
    ],
    options: ['Núcleos hipotalámicos'],
    correctIndex: 0,
    rationale: 'Supraóptico/paraventricular producen ADH/oxitocina; supraquiasmático regula el reloj biológico; lateral/ventromedial regulan apetito.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Hipotálamo',
    order: 5
  },
  {
    id: 'quiz_t4_die_06',
    topicId: 'diencefalo_sistema_limbico',
    type: 'ordering',
    question: 'Ordena el recorrido del circuito de la memoria y las emociones de Papez:',
    orderingItems: [
      'Formación del hipocampo (corteza entorrinal y subículo)',
      'Fórnix (trígono cerebral)',
      'Cuerpos mamilares del hipotálamo',
      'Tracto mamilotalámico (de Vicq d\'Azyr) y núcleo anterior del tálamo hacia el giro del cíngulo'
    ],
    options: ['Circuito de Papez'],
    correctIndex: 0,
    rationale: 'Hipocampo -> Fórnix -> Cuerpos mamilares -> Fascículo mamilotalámico -> Núcleo anterior del tálamo -> Corteza cingular.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Sistema Límbico y Circuito de Papez',
    order: 6
  },
  {
    id: 'quiz_t4_die_07',
    topicId: 'diencefalo_sistema_limbico',
    type: 'single_choice',
    question: 'La glándula pineal (epífisis cerebral) se localiza en el epitálamo y secreta melatonina. Reposa inmediatamente por encima de:',
    options: ['Los colículos superiores del mesencéfalo', 'El quiasma óptico', 'La hipófisis'],
    correctIndex: 0,
    rationale: 'La glándula pineal se sitúa en la pared posterior del 3.er ventrículo, descansando sobre el surco cruciforme entre los dos colículos superiores.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Epitálamo y Glándula Pineal',
    order: 7
  },
  {
    id: 'quiz_t4_die_08',
    topicId: 'diencefalo_sistema_limbico',
    type: 'single_choice',
    question: 'El tercer ventrículo se comunica lateralmente con cada uno de los ventrículos laterales a través de:',
    options: ['Los forámenes interventriculares (agujeros de Monro)', 'El acueducto de Silvio', 'El foramen de Magendie'],
    correctIndex: 0,
    rationale: 'Los orificios de Monro comunican los ventrículos laterales con la cavidad impar medial del 3.er ventrículo.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Tercer Ventrículo',
    order: 8
  },
  {
    id: 'quiz_t4_die_09',
    topicId: 'diencefalo_sistema_limbico',
    type: 'single_choice',
    question: 'Paciente con encefalopatía de Wernicke y psicosis de Korsakoff (déficit de tiamina / B1) presenta amnesia anterógrada severa y confabulación. La resonancia muestra atrofia y hemorragias petequiales en:',
    options: ['Los cuerpos mamilares del hipotálamo', 'La corteza motora primaria', 'El bulbo raquídeo'],
    correctIndex: 0,
    rationale: 'El síndrome de Wernicke-Korsakoff produce degeneración bilateral de los cuerpos mamilares y núcleos dorsomediales del tálamo destruyendo el circuito de consolidación mnemónica.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Cuerpos Mamilares y Memoria',
    order: 9
  },
  {
    id: 'quiz_t4_die_10',
    topicId: 'diencefalo_sistema_limbico',
    type: 'single_choice',
    question: 'La amígdala cerebral (complejo nuclear amigdalino) se sitúa en la profundidad del lóbulo temporal y desempeña un papel clave en:',
    options: ['El procesamiento del miedo, respuestas de amenaza y condicionamiento emocional', 'El control de la motricidad voluntaria fina', 'La coordinación de la deglución'],
    correctIndex: 0,
    rationale: 'El núcleo amigdalino, situado en el polo temporal rostral al hipocampo, modula las respuestas de alarma, agresividad y memoria emocional.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Complejo Amigdalino',
    order: 10
  },
  {
    id: 'quiz_t4_die_11',
    topicId: 'diencefalo_sistema_limbico',
    type: 'single_choice',
    question: 'La estría terminal es la principal vía eferente que conecta la amígdala cerebral con:',
    options: ['El hipotálamo y los núcleos del tabique (septum pellucidum)', 'La médula espinal directamente', 'El lóbulo occipital'],
    correctIndex: 0,
    rationale: 'La estría terminal contornea el tálamo en el surco optoestriado transmitiendo la actividad emocional de la amígdala hacia el hipotálamo.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Vías Límbicas',
    order: 11
  },
  {
    id: 'quiz_t4_die_12',
    topicId: 'diencefalo_sistema_limbico',
    type: 'single_choice',
    question: 'El quiasma óptico reposa inmediatamente por delante de qué estructura hipotalámica:',
    options: ['El tallo hipofisario (infundíbulo) y el tuber cinereum', 'Los cuerpos mamilares', 'La glándula pineal'],
    correctIndex: 0,
    rationale: 'El quiasma óptico se apoya en el surco prequiasmático por delante del tallo de la hipófisis; adenomas hipofisarios en expansión superior comprimen el centro del quiasma provocando hemianopsia bitemporal.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Quiasma Óptico e Hipotálamo',
    order: 12
  },
  {
    id: 'quiz_t4_die_13',
    topicId: 'diencefalo_sistema_limbico',
    type: 'matching',
    question: 'Asocia las partes del hipocampo y giro parahipocampal con sus características anatómicas:',
    matchingPairs: [
      { left: 'Asta de Ammón (hipocampo propio)', right: 'Estructura arquicortical trilaminar enrollada en el cuerno temporal' },
      { left: 'Giro dentado', right: 'Banda aserrada de sustancia gris donde ocurre neurogénesis adulta' },
      { left: 'Subículo', right: 'Zona de transición entre la arquicorteza y el neocórtex entorrinal' }
    ],
    options: ['Formación hipocampal'],
    correctIndex: 0,
    rationale: 'La formación hipocampal comprende: asta de Ammón, giro dentado y subículo.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Formación del Hipocampo',
    order: 13
  },
  {
    id: 'quiz_t4_die_14',
    topicId: 'diencefalo_sistema_limbico',
    type: 'ordering',
    question: 'Ordena de anterior a posterior las estructuras de la cara inferior del diencéfalo en la base del encéfalo:',
    orderingItems: [
      'Quiasma óptico y cintillas ópticas',
      'Tuber cinereum e infundíbulo hipofisario',
      'Cuerpos mamilares',
      'Sustancia perforada posterior (en la fosa interpeduncular)'
    ],
    options: ['Suelo del diencéfalo'],
    correctIndex: 0,
    rationale: 'Quiasma óptico -> Tuber cinereum -> Cuerpos mamilares -> Espacio perforado posterior.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Suelo del Tercer Ventrículo',
    order: 14
  },
  {
    id: 'quiz_t4_die_15',
    topicId: 'diencefalo_sistema_limbico',
    type: 'single_choice',
    question: 'El núcleo subtalámico (de Luys) pertenece anatómicamente al diencéfalo y su lesión vascular produce:',
    options: ['Hemibalismo contralateral (movimientos involuntarios violentos de lanzamiento)', 'Temblor en reposo', 'Corea de Huntington bilateral'],
    correctIndex: 0,
    rationale: 'El hemibalismo es consecuencia casi exclusiva del infarto o hemorragia en el núcleo subtalámico de Luys contralateral, al perderse el control inhibitorio subtálamo-palidal.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Subtálamo y Hemibalismo',
    order: 15
  },
  {
    id: 'quiz_t4_die_16',
    topicId: 'diencefalo_sistema_limbico',
    type: 'single_choice',
    question: 'La adhesión intertalámica (comisura gris) es un puente de sustancia gris que cruza la luz de:',
    options: ['El tercer ventrículo comunicando ambos tálamos', 'El cuarto ventrículo', 'Los ventrículos laterales'],
    correctIndex: 0,
    rationale: 'La masa intermedia o adhesión intertalámica cruza transversalmente el 3.er ventrículo uniendo las caras mediales de ambos tálamos en un 70% de los individuos.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Masa Intermedia Talámica',
    order: 16
  },
  {
    id: 'quiz_t4_die_17',
    topicId: 'diencefalo_sistema_limbico',
    type: 'single_choice',
    question: 'Paciente con síndrome de Klüver-Bucy (hiperoralidad, hipersexualidad, pérdida del miedo / docilidad extrema y agnosia visual). ¿Qué estructura del sistema límbico fue destruida bilateralmente?',
    options: ['Amígdalas cerebrales y polos temporales anteriores', 'Bulbos olfatorios', 'Hipotálamo posterior'],
    correctIndex: 0,
    rationale: 'El síndrome de Klüver-Bucy ocurre por lobectomía temporal bilateral o encefalitis por herpes simple con necrosis bilateral de los núcleos amigdalinos.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Síndrome de Klüver-Bucy',
    order: 17
  },
  {
    id: 'quiz_t4_die_18',
    topicId: 'diencefalo_sistema_limbico',
    type: 'single_choice',
    question: 'El haz mamilotegmentario (de Gudden) comunica los cuerpos mamilares con:',
    options: ['La formación reticular del tegmento del tronco del encéfalo', 'La corteza visual', 'El cerebelo'],
    correctIndex: 0,
    rationale: 'El fascículo mamilotegmentario desciende desde los cuerpos mamilares a los núcleos reticulares de la calota mesencefálica.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Conexiones Mamilares',
    order: 18
  },
  {
    id: 'quiz_t4_die_19',
    topicId: 'diencefalo_sistema_limbico',
    type: 'single_choice',
    question: 'La lámina terminal cierra rostralmente el tercer ventrículo extendiéndose desde:',
    options: ['El quiasma óptico hasta el pico (rostrum) del cuerpo calloso', 'El fórnix al tálamo', 'La epífisis al mesencéfalo'],
    correctIndex: 0,
    rationale: 'La lámina terminalis representa el remanente embriológico del extremo cefálico del tubo neural primitivo, cerrando la cara anterior del 3.er ventrículo.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Lámina Terminal',
    order: 19
  },
  {
    id: 'quiz_t4_die_20',
    topicId: 'diencefalo_sistema_limbico',
    type: 'single_choice',
    question: 'El núcleo reticular del tálamo forma una coraza neuronal en su cara lateral cuya función principal es:',
    options: ['Modular y filtrar las señales tálamo-corticales mediante inhibición gabaérgica', 'Transmitir la vía del dolor somático', 'Generar dopamina'],
    correctIndex: 0,
    rationale: 'El núcleo reticular no proyecta a la corteza; sus neuronas gabaérgicas proyectan hacia los otros núcleos talámicos funcionando como una compuerta reguladora.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Núcleo Reticular del Tálamo',
    order: 20
  },

  // =========================================================================
  // TEMA 5: telencefalo_corteza_ganglios_base (20 QUIZZES)
  // =========================================================================
  {
    id: 'quiz_t4_tel_01',
    topicId: 'telencefalo_corteza_ganglios_base',
    type: 'single_choice',
    question: 'El área motora primaria (área 4 de Brodmann) donde reside el homúnculo motor de Penfield se localiza en:',
    options: ['El giro precentral (circunvolución frontal ascendente)', 'El giro poscentral', 'El lóbulo de la ínsula'],
    correctIndex: 0,
    rationale: 'El área motora primaria ocupa el giro precentral en el lóbulo frontal, inmediatamente anterior al surco central (cisura de Rolando).',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Corteza Motora Primaria',
    order: 1
  },
  {
    id: 'quiz_t4_tel_02',
    topicId: 'telencefalo_corteza_ganglios_base',
    type: 'single_choice',
    question: 'El área sensitiva primaria (áreas 1, 2 y 3 de Brodmann) se ubica en:',
    options: ['El giro poscentral (circunvolución parietal ascendente)', 'El giro temporal superior', 'El polo occipital'],
    correctIndex: 0,
    rationale: 'El giro poscentral aloja la corteza somatosensorial primaria encargada de la percepción táctil, térmica y dolorosa consciente del hemicuerpo contralateral.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Corteza Somatosensorial',
    order: 2
  },
  {
    id: 'quiz_t4_tel_03',
    topicId: 'telencefalo_corteza_ganglios_base',
    type: 'single_choice',
    question: 'Paciente con ictus isquémico de la arteria cerebral media izquierda presenta afasia motora expresiva: comprende perfectamente el lenguaje pero no puede articular palabras ni oraciones con fluidez (habla telegráfica). ¿Qué área cortical de Brodmann está dañada?',
    options: ['Área de Broca (áreas 44 y 45 en la porción opercular y triangular del giro frontal inferior)', 'Área de Wernicke (área 22)', 'Área visual primaria (área 17)'],
    correctIndex: 0,
    rationale: 'El área de Broca coordina los programas motores articulatorios del lenguaje y se localiza en la circunvolución frontal inferior del hemisferio dominante.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Áreas del Lenguaje y Afasias',
    order: 3
  },
  {
    id: 'quiz_t4_tel_04',
    topicId: 'telencefalo_corteza_ganglios_base',
    type: 'single_choice',
    question: 'El cuerpo estriado (núcleos basales) está formado anatómicamente por:',
    options: ['Núcleo caudado y núcleo lenticular (putamen y globo pálido)', 'Amígdala y tálamo', 'Sustancia negra y núcleo rojo'],
    correctIndex: 0,
    rationale: 'El cuerpo estriado reúne al núcleo caudado y al núcleo lenticular (éste dividido en putamen lateral y globo pálido medial).',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Núcleos de la Base',
    order: 4
  },
  {
    id: 'quiz_t4_tel_05',
    topicId: 'telencefalo_corteza_ganglios_base',
    type: 'matching',
    question: 'Relaciona cada brazo o porción de la cápsula interna con los principales tractos de fibras que transmite:',
    matchingPairs: [
      { left: 'Brazo posterior de la cápsula interna', right: 'Fascículo corticoespinal (vía piramidal motora para miembros) y radiaciones ópticas' },
      { left: 'Rodilla de la cápsula interna', right: 'Fascículo corticonuclear (geniculado para núcleos de pares craneales)' },
      { left: 'Brazo anterior de la cápsula interna', right: 'Fibras frontopontinas y radiaciones talámicas anteriores' }
    ],
    options: ['Cápsula interna y somatotopía'],
    correctIndex: 0,
    rationale: 'Rodilla transmite corticonuclear (cara); brazo posterior transmite corticoespinal (miembros) y sensibilidad.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Cápsula Interna',
    order: 5
  },
  {
    id: 'quiz_t4_tel_06',
    topicId: 'telencefalo_corteza_ganglios_base',
    type: 'ordering',
    question: 'Ordena de medial a lateral los ganglios y láminas de sustancia blanca en un corte horizontal del cerebro (corte de Flechsig):',
    orderingItems: [
      'Núcleo caudado y tálamo',
      'Cápsula interna',
      'Núcleo lenticular (globo pálido y putamen)',
      'Cápsula externa, claustro (antemuro), cápsula extrema y corteza insular'
    ],
    options: ['Corte transversal de los hemisferios cerebrales'],
    correctIndex: 0,
    rationale: 'Línea media ventricular -> Caudado/Tálamo -> Cápsula interna -> Lenticular -> Cápsula externa -> Claustro -> Cápsula extrema -> Ínsula.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Corte de Flechsig',
    order: 6
  },
  {
    id: 'quiz_t4_tel_07',
    topicId: 'telencefalo_corteza_ganglios_base',
    type: 'single_choice',
    question: 'La corteza visual primaria (área 17 de Brodmann o corteza estriada) se ubica en:',
    options: ['Los labios de la cisura calcarina en la cara medial del lóbulo occipital', 'El polo temporal', 'El lóbulo frontal'],
    correctIndex: 0,
    rationale: 'El área visual primaria se sitúa en los bordes superior (cuña) e inferior (giro lingual) de la fisura calcarina del lóbulo occipital medial.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Lóbulo Occipital y Corteza Visual',
    order: 7
  },
  {
    id: 'quiz_t4_tel_08',
    topicId: 'telencefalo_corteza_ganglios_base',
    type: 'single_choice',
    question: 'El lóbulo de la ínsula (de Reil) se encuentra oculto en el fondo de qué fisura cerebral:',
    options: ['Fisura lateral (cisura de Silvio)', 'Fisura central (de Rolando)', 'Fisura parietooccipital'],
    correctIndex: 0,
    rationale: 'La ínsula queda cubierta en la profundidad de la cisura lateral por los opérculos frontal, parietal y temporal.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Lóbulo de la Ínsula',
    order: 8
  },
  {
    id: 'quiz_t4_tel_09',
    topicId: 'telencefalo_corteza_ganglios_base',
    type: 'single_choice',
    question: 'Paciente de 62 años presenta afasia fluida con severa alteración de la comprensión del lenguaje y habla incomprensible con parafasias y neologismos (jergafasia). ¿Qué área cerebral está lesionada?',
    options: ['Área de Wernicke (área 22 en el tercio posterior del giro temporal superior)', 'Área de Broca', 'Corteza prefrontal'],
    correctIndex: 0,
    rationale: 'La afasia sensitiva de Wernicke compromete la comprensión auditiva y semántica del lenguaje residiendo en el giro temporal superior izquierdo.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Área de Wernicke',
    order: 9
  },
  {
    id: 'quiz_t4_tel_10',
    topicId: 'telencefalo_corteza_ganglios_base',
    type: 'single_choice',
    question: 'El cuerpo calloso es la comisura interhemisférica más voluminosa. ¿Cuáles son sus cuatro porciones anatómicas de anterior a posterior?',
    options: ['Pico (rostrum), rodilla (genu), cuerpo (tronco) y esplenio (rodete)', 'Cabeza, cuello, cuerpo y cola', 'Anterior, medio y posterior'],
    correctIndex: 0,
    rationale: 'Las partes anatómicas del cuerpo calloso son: rostrum (pico), rodilla, tronco o cuerpo y rodete o esplenio.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Cuerpo Calloso',
    order: 10
  },
  {
    id: 'quiz_t4_tel_11',
    topicId: 'telencefalo_corteza_ganglios_base',
    type: 'single_choice',
    question: 'La vía motora directa de los ganglios basales promueve el movimiento mediante la desinhibición talámica. Su neurotransmisor inhibitorio en el estriado es:',
    options: ['GABA', 'Dopamina', 'Noradrenalina'],
    correctIndex: 0,
    rationale: 'Las neuronas espinosas del estriado proyectan mediante GABA y sustancia P hacia el globo pálido interno para inhibirlo y permitir el disparo talámico.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Circuitos de los Ganglios de la Base',
    order: 11
  },
  {
    id: 'quiz_t4_tel_12',
    topicId: 'telencefalo_corteza_ganglios_base',
    type: 'single_choice',
    question: 'La corteza auditiva primaria (áreas 41 y 42 de Brodmann) se sitúa en:',
    options: ['Los giros temporales transversos (de Heschl) en el labio inferior de la cisura lateral', 'El polo occipital', 'El giro cingular'],
    correctIndex: 0,
    rationale: 'Los giros transversos de Heschl en la cara superior del lóbulo temporal corresponden a la corteza receptora auditiva tonotópica primaria.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Corteza Auditiva Primaria',
    order: 12
  },
  {
    id: 'quiz_t4_tel_13',
    topicId: 'telencefalo_corteza_ganglios_base',
    type: 'matching',
    question: 'Empareja los tipos de fibras de sustancia blanca subcortical con sus ejemplos anatómicos:',
    matchingPairs: [
      { left: 'Fibras comisurales', right: 'Cuerpo calloso y comisura blanca anterior (conectan ambos hemisferios)' },
      { left: 'Fibras de asociación', right: 'Fascículo longitudinal superior y uncinado (conectan áreas del mismo hemisferio)' },
      { left: 'Fibras de proyección', right: 'Cápsula interna y corona radiada (conectan corteza con tallo y médula)' }
    ],
    options: ['Fibras de la sustancia blanca telencefálica'],
    correctIndex: 0,
    rationale: 'Comisurales cruzan la línea media; asociación unen el mismo hemisferio; proyección van hacia núcleos subcorticales.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Sustancia Blanca Cerebral',
    order: 13
  },
  {
    id: 'quiz_t4_tel_14',
    topicId: 'telencefalo_corteza_ganglios_base',
    type: 'ordering',
    question: 'Ordena de anterior a posterior los lóbulos de la cara lateral del hemisferio cerebral:',
    orderingItems: [
      'Lóbulo frontal (hasta la cisura central de Rolando)',
      'Lóbulo parietal (desde el surco central hasta el surco parietooccipital)',
      'Lóbulo occipital (polo posterior)'
    ],
    options: ['Lóbulos cerebrales'],
    correctIndex: 0,
    rationale: 'Frontal (anterior) -> Parietal (medio-superior) -> Occipital (posterior). El temporal queda inferior a la cisura lateral.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Morfología Externa de los Hemisferios',
    order: 14
  },
  {
    id: 'quiz_t4_tel_15',
    topicId: 'telencefalo_corteza_ganglios_base',
    type: 'single_choice',
    question: 'El núcleo caudado acompaña la curvatura ventricular del ventrículo lateral. Su cola termina en relación íntima con:',
    options: ['El cuerpo amigdalino en el cuerno temporal', 'El cerebelo', 'El bulbo'],
    correctIndex: 0,
    rationale: 'La cola del núcleo caudado contornea el borde inferior del tálamo y termina rostralmente en el complejo amigdalino del lóbulo temporal.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Núcleo Caudado',
    order: 15
  },
  {
    id: 'quiz_t4_tel_16',
    topicId: 'telencefalo_corteza_ganglios_base',
    type: 'single_choice',
    question: 'El claustro (antemuro) es una delgada lámina de sustancia gris situada entre:',
    options: ['La cápsula externa y la cápsula extrema', 'La cápsula interna y el tálamo', 'El fórnix y el cuerpo calloso'],
    correctIndex: 0,
    rationale: 'El claustro separa la cápsula externa (que lo separa del putamen) de la cápsula extrema (que lo separa de la ínsula).',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Claustro',
    order: 16
  },
  {
    id: 'quiz_t4_tel_17',
    topicId: 'telencefalo_corteza_ganglios_base',
    type: 'single_choice',
    question: 'Un paciente presenta síndrome de desconexión del cuerpo calloso tras cirugía de callosotomía (apraxia ideomotora de la mano izquierda al comando verbal). ¿Por qué ocurre esta apraxia?',
    options: ['Porque el hemisferio derecho no recibe la instrucción verbal decodificada en el hemisferio izquierdo', 'Por parálisis del nervio radial', 'Por daño talámico'],
    correctIndex: 0,
    rationale: 'Al seccionar el cuerpo calloso, la información lingüística del hemisferio dominante (izquierdo) no puede cruzar hacia la corteza motora derecha que mueve la mano izquierda.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Síndrome de Desconexión Callosa',
    order: 17
  },
  {
    id: 'quiz_t4_tel_18',
    topicId: 'telencefalo_corteza_ganglios_base',
    type: 'single_choice',
    question: 'El fascículo arcuato (arcuato de Dejerine) es el tracto asociativo blanco fundamental que interconecta:',
    options: ['El área de Wernicke con el área de Broca', 'La corteza visual con el tálamo', 'La médula con el cerebelo'],
    correctIndex: 0,
    rationale: 'El fascículo arqueado une la corteza temporal sensitiva (Wernicke) con la frontal motora (Broca); su lesión produce afasia de conducción.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Fascículo Arqueado',
    order: 18
  },
  {
    id: 'quiz_t4_tel_19',
    topicId: 'telencefalo_corteza_ganglios_base',
    type: 'single_choice',
    question: 'La corteza orbitofrontal (área prefrontal) participa críticamente en:',
    options: ['La toma de decisiones, control inhibitorio social y conducta moral', 'La motilidad ocular', 'La audición de tonos puros'],
    correctIndex: 0,
    rationale: 'La corteza prefrontal orbitofrontal y ventromedial modula las emociones y la conducta social inhibitoria (lesión clásica de Phineas Gage).',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Corteza Prefrontal',
    order: 19
  },
  {
    id: 'quiz_t4_tel_20',
    topicId: 'telencefalo_corteza_ganglios_base',
    type: 'single_choice',
    question: 'Las neuronas piramidales gigantes de Betz de la capa V de la corteza cerebral se localizan preferentemente en:',
    options: ['Área 4 de Brodmann (corteza motora primaria)', 'Corteza somatosensorial', 'Área 17 visual'],
    correctIndex: 0,
    rationale: 'Las células de Betz son las mayores neuronas del encéfalo y se encuentran exclusivamente en la capa piramidal interna (capa V) del área 4 motora.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Células de Betz',
    order: 20
  },

  // =========================================================================
  // TEMA 6: vias_nerviosas_lcr_meninges (20 QUIZZES)
  // =========================================================================
  {
    id: 'quiz_t4_via_01',
    topicId: 'vias_nerviosas_lcr_meninges',
    type: 'single_choice',
    question: 'El polígono arterial cerebral (polígono de Willis) en la base del cráneo se forma por la anastomosis entre los sistemas:',
    options: ['Carotídeo interno y vértebro-basilar', 'Carotídeo externo y vertebral', 'Subclavio y yugular'],
    correctIndex: 0,
    rationale: 'El polígono de Willis interconecta la circulación carotídea anterior con la vértebro-basilar posterior mediante las arterias comunicantes posteriores y anterior.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Círculo Arterial Cerebral de Willis',
    order: 1
  },
  {
    id: 'quiz_t4_via_02',
    topicId: 'vias_nerviosas_lcr_meninges',
    type: 'single_choice',
    question: '¿Qué arteria cerebral irriga la cara medial de los lóbulos frontal y parietal (área del miembro inferior en el homúnculo motor)?',
    options: ['Arteria cerebral anterior', 'Arteria cerebral media (silviana)', 'Arteria cerebral posterior'],
    correctIndex: 0,
    rationale: 'La arteria cerebral anterior contornea el cuerpo calloso e irriga toda la cara medial del hemisferio; su infarto causa hemiparesia crural predominante.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Arteria Cerebral Anterior',
    order: 2
  },
  {
    id: 'quiz_t4_via_03',
    topicId: 'vias_nerviosas_lcr_meninges',
    type: 'single_choice',
    question: 'Un paciente joven con aneurisma sacular en la arteria comunicante anterior presenta cefalea súbita y holocraneana "en trueno" (la peor de su vida) con rigidez de nuca. ¿Qué cuadro meníngeo agudo presenta?',
    options: ['Hemorragia subaracnoidea espontánea', 'Hematoma epidural', 'Hematoma subdural crónico'],
    correctIndex: 0,
    rationale: 'La rotura de un aneurisma del polígono de Willis vierte sangre arterial al espacio subaracnoideo, causando síndrome meníngeo hiperagudo con LCR xantocrómico.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Espacio Subaracnoideo y Hemorragia Subaracnoidea',
    order: 3
  },
  {
    id: 'quiz_t4_via_04',
    topicId: 'vias_nerviosas_lcr_meninges',
    type: 'single_choice',
    question: 'El líquido cefalorraquídeo (LCR) es producido mayoritariamente (70%) por:',
    options: ['Los plexos coroideos de los ventrículos cerebrales', 'Las granulaciones aracnoideas', 'Los astrocitos'],
    correctIndex: 0,
    rationale: 'Los plexos coroideos de los ventrículos laterales, tercero y cuarto ventrículo secretan activamente entre 400 y 500 ml de LCR al día.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Plexos Coroideos y Producción de LCR',
    order: 4
  },
  {
    id: 'quiz_t4_via_05',
    topicId: 'vias_nerviosas_lcr_meninges',
    type: 'matching',
    question: 'Relaciona las colecciones hemáticas intracraneales con el vaso y espacio anatómico implicado:',
    matchingPairs: [
      { left: 'Hematoma epidural', right: 'Arteria meníngea media en el espacio entre la calota y la duramadre' },
      { left: 'Hematoma subdural', right: 'Venas puente emisarias en el espacio entre la duramadre y la aracnoides' },
      { left: 'Hemorragia subaracnoidea', right: 'Aneurismas de los vasos del polígono de Willis en el espacio del LCR' }
    ],
    options: ['Hemorragias intracraneales'],
    correctIndex: 0,
    rationale: 'Epidural: arteria meníngea media (biconvexa); Subdural: venas puente (semiluna); Subaracnoidea: arterias de Willis.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Meninges y Patología Vascular',
    order: 5
  },
  {
    id: 'quiz_t4_via_06',
    topicId: 'vias_nerviosas_lcr_meninges',
    type: 'ordering',
    question: 'Ordena el recorrido de la circulación del líquido cefalorraquídeo desde su origen hasta su reabsorción:',
    orderingItems: [
      'Plexos coroideos de los ventrículos laterales',
      'Forámenes interventriculares (de Monro) hacia el tercer ventrículo',
      'Acueducto mesencefálico (de Silvio) hacia el cuarto ventrículo',
      'Orificios de Magendie y Luschka hacia el espacio subaracnoideo y granulaciones de Pacchioni'
    ],
    options: ['Dinámica de circulación del LCR'],
    correctIndex: 0,
    rationale: 'Ventrículos laterales -> Monro -> 3.er ventrículo -> Acueducto de Silvio -> 4.° ventrículo -> Magendie/Luschka -> Espacio subaracnoideo -> Granulaciones aracnoideas.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Circulación del LCR',
    order: 6
  },
  {
    id: 'quiz_t4_via_07',
    topicId: 'vias_nerviosas_lcr_meninges',
    type: 'single_choice',
    question: 'La reabsorción del líquido cefalorraquídeo hacia la sangre venosa se lleva a cabo en:',
    options: ['Las granulaciones aracnoideas (vellosidades de Pacchioni) del seno sagital superior', 'Los plexos coroideos', 'La cisterna magna'],
    correctIndex: 0,
    rationale: 'Las granulaciones aracnoideas de Pacchioni funcionan como válvulas unidireccionales de drenaje del LCR hacia la luz del seno venoso sagital superior.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Granulaciones Aracnoideas',
    order: 7
  },
  {
    id: 'quiz_t4_via_08',
    topicId: 'vias_nerviosas_lcr_meninges',
    type: 'single_choice',
    question: 'La arteria cerebral media (arteria silviana) irriga:',
    options: ['La mayor parte de la cara lateral del hemisferio cerebral (áreas motoras de cara, brazo y áreas del lenguaje)', 'La cara medial occipital', 'El cerebelo'],
    correctIndex: 0,
    rationale: 'La cerebral media es la continuación directa de la carótida interna e irriga casi toda la convexidad lateral cerebral.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Arteria Cerebral Media',
    order: 8
  },
  {
    id: 'quiz_t4_via_09',
    topicId: 'vias_nerviosas_lcr_meninges',
    type: 'single_choice',
    question: 'Lactante con estenosis congénita del acueducto de Silvio. ¿Qué cámaras ventriculares se encontrarán masivamente dilatadas en la neuroimagen?',
    options: ['Ventrículos laterales y tercer ventrículo exclusivamente (el cuarto ventrículo es normal)', 'Los cuatro ventrículos por igual', 'Únicamente el cuarto ventrículo'],
    correctIndex: 0,
    rationale: 'La estenosis del acueducto de Silvio bloquea la salida del 3.er ventrículo al 4.°, generando una hidrocefalia no comunicante triventricular.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Acueducto de Silvio e Hidrocefalia',
    order: 9
  },
  {
    id: 'quiz_t4_via_10',
    topicId: 'vias_nerviosas_lcr_meninges',
    type: 'single_choice',
    question: 'La hoz del cerebro (falx cerebri) se fija posteriormente en la tienda del cerebelo a lo largo de:',
    options: ['El seno recto', 'El seno transverso', 'El seno petroso'],
    correctIndex: 0,
    rationale: 'El seno recto discurre a lo largo de la línea de inserción de la hoz del cerebro en la cara superior de la tienda del cerebelo.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Repliegues de la Duramadre y Senos',
    order: 10
  },
  {
    id: 'quiz_t4_via_11',
    topicId: 'vias_nerviosas_lcr_meninges',
    type: 'single_choice',
    question: 'La vía corticoespinal lateral (piramidal) decusa sus fibras a nivel de:',
    options: ['La decusación piramidal en la parte inferior de la médula oblongada', 'El quiasma óptico', 'El mesencéfalo'],
    correctIndex: 0,
    rationale: 'El 85-90% de las fibras corticoespinales cruzan la línea media en la decusación de las pirámides del bulbo para formar el tracto corticoespinal lateral en el cordón lateral medular.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Vía Piramidal Corticoespinal',
    order: 11
  },
  {
    id: 'quiz_t4_via_12',
    topicId: 'vias_nerviosas_lcr_meninges',
    type: 'single_choice',
    question: 'La barrera hematoencefálica está constituida a nivel ultraestructural por:',
    options: ['Células endoteliales con uniones estrechas ocluyentes (tight junctions) y pies perivasculares de astrocitos', 'Músculo liso arterial', 'Ependimocitos'],
    correctIndex: 0,
    rationale: 'Las uniones herméticas interendoteliales capilares reforzadas por la membrana basal y los pies terminales astrocitarios forman la barrera hematoencefálica.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Barrera Hematoencefálica',
    order: 12
  },
  {
    id: 'quiz_t4_via_13',
    topicId: 'vias_nerviosas_lcr_meninges',
    type: 'matching',
    question: 'Empareja los senos durales con su desembocadura venosa principal:',
    matchingPairs: [
      { left: 'Seno sagital superior', right: 'Confluencia de los senos (presa de Herófilo)' },
      { left: 'Seno sigmoideo', right: 'Se continúa directamente con la vena yugular interna en el foramen yugular' },
      { left: 'Seno cavernoso', right: 'Drena a través de los senos petrosos hacia el seno sigmoideo y la yugular' }
    ],
    options: ['Drenaje de los senos durales'],
    correctIndex: 0,
    rationale: 'Sagital superior va a la presa de Herófilo; sigmoideo se continúa como yugular interna; cavernoso drena por petrosos.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Senos Venosos Intracraneales',
    order: 13
  },
  {
    id: 'quiz_t4_via_14',
    topicId: 'vias_nerviosas_lcr_meninges',
    type: 'ordering',
    question: 'Ordena de externo a interno las capas meníngeas del encéfalo:',
    orderingItems: [
      'Duramadre (paquimeninge adherida al periostio craneal)',
      'Aracnoides (leptomeninge avascular)',
      'Espacio subaracnoideo (con trabéculas y LCR)',
      'Piamadre (adherida a la pial-glial del parénquima cerebral)'
    ],
    options: ['Meninges craneales'],
    correctIndex: 0,
    rationale: 'Duramadre -> Aracnoides -> Espacio subaracnoideo con LCR -> Piamadre.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Meninges Craneales',
    order: 14
  },
  {
    id: 'quiz_t4_via_15',
    topicId: 'vias_nerviosas_lcr_meninges',
    type: 'single_choice',
    question: 'La cisterna magna (cisterna cerebelobulbar posterior) es el mayor ensanchamiento subaracnoideo y se sitúa entre:',
    options: ['La cara inferior del cerebelo y la cara posterior de la médula oblongada', 'Los dos hemisferios cerebrales', 'El quiasma óptico y el puente'],
    correctIndex: 0,
    rationale: 'La cisterna cerebelomedular (magna) se sitúa por debajo del cerebelo y detrás del bulbo comunicando con el 4.° ventrículo por el agujero de Magendie.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Cisternas Subaracnoideas',
    order: 15
  },
  {
    id: 'quiz_t4_via_16',
    topicId: 'vias_nerviosas_lcr_meninges',
    type: 'single_choice',
    question: 'La arteria cerebral posterior irriga el lóbulo occipital y se origina como rama terminal de:',
    options: ['La arteria basilar', 'La arteria carótida interna', 'La arteria vertebral'],
    correctIndex: 0,
    rationale: 'La arteria basilar asciende por el surco basilar del puente y en su extremo rostral se bifurca en las dos arterias cerebrales posteriores.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Arteria Cerebral Posterior',
    order: 16
  },
  {
    id: 'quiz_t4_via_17',
    topicId: 'vias_nerviosas_lcr_meninges',
    type: 'single_choice',
    question: 'Un paciente sufre una fractura de la escama del hueso temporal con un intervalo lúcido seguido de deterioro neurológico rápido y midriasis unilateral por herniación uncal. La TAC craneal muestra una masa hiperdensa biconvexa (en lente). ¿Qué vaso causó la hemorragia?',
    options: ['Arteria meníngea media (hematoma epidural)', 'Vena puente (hematoma subdural)', 'Arteria comunicante anterior'],
    correctIndex: 0,
    rationale: 'El hematoma epidural se forma por rotura de la arteria meníngea media bajo el pterion despegando la duramadre de la tabla interna ósea con forma biconvexa característica.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Arteria Meníngea Media y Hematoma Epidural',
    order: 17
  },
  {
    id: 'quiz_t4_via_18',
    topicId: 'vias_nerviosas_lcr_meninges',
    type: 'single_choice',
    question: 'La vena cerebral magna (de Galeno) se forma por la unión de:',
    options: ['Las dos venas cerebrales internas', 'Las venas yugulares', 'Los senos cavernosos'],
    correctIndex: 0,
    rationale: 'Las dos venas cerebrales internas confluyen por debajo del esplenio del cuerpo calloso formando la gran vena de Galeno, que se une al seno sagital inferior para formar el seno recto.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Venas Profundas del Encéfalo',
    order: 18
  },
  {
    id: 'quiz_t4_via_19',
    topicId: 'vias_nerviosas_lcr_meninges',
    type: 'single_choice',
    question: 'Las arterias comunicantes posteriores unen:',
    options: ['La arteria carótida interna con la arteria cerebral posterior ipsilateral', 'Las dos cerebrales anteriores', 'Las vertebrales con la basilar'],
    correctIndex: 0,
    rationale: 'La arteria comunicante posterior nace de la cara posterior de la carótida interna y se anastomosa con la arteria cerebral posterior cerrando el polígono de Willis.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Arteria Comunicante Posterior',
    order: 19
  },
  {
    id: 'quiz_t4_via_20',
    topicId: 'vias_nerviosas_lcr_meninges',
    type: 'single_choice',
    question: 'El signo meníngeo de Brudzinski consiste en:',
    options: ['Flexión involuntaria de caderas y rodillas al flexionar pasivamente el cuello del paciente', 'Imposibilidad de extender la rodilla a 90 grados con la cadera flexionada', 'Extensión del dedo gordo del pie'],
    correctIndex: 0,
    rationale: 'El signo de Brudzinski refleja irritación meníngea severa: la tracción de las meninges inflamadas al flexionar el cuello desencadena flexión refleja antálgica en ambos miembros inferiores.',
    sourceBook: 'Rouvière - Delmas: Tomo 4, Signos Meníngeos en Anatomía Clínica',
    order: 20
  }
];

export async function run() {
  await uploadQuizzesBatch(tomo4Part2Quizzes, 'Rouvière Tomo 4 (Bloque B: Temas 4 a 6)');
}
