// Master Seeder: Ejecuta la carga secuencial de los 500 Quizzes Clínicos (20 por tema para los 25 temas)
import { run as runTomo1Part1 } from './seed_quizzes_tomo1_part1.mjs';
import { run as runTomo1Part2 } from './seed_quizzes_tomo1_part2.mjs';
import { run as runTomo2Part1 } from './seed_quizzes_tomo2_part1.mjs';
import { run as runTomo2Part2 } from './seed_quizzes_tomo2_part2.mjs';
import { run as runTomo3Part1 } from './seed_quizzes_tomo3_part1.mjs';
import { run as runTomo3Part2 } from './seed_quizzes_tomo3_part2.mjs';
import { run as runTomo4Part1 } from './seed_quizzes_tomo4_part1.mjs';
import { run as runTomo4Part2 } from './seed_quizzes_tomo4_part2.mjs';
import { setDocument } from './seed_quizzes_common.mjs';

async function main() {
  console.log('========================================================================');
  console.log('CARGA MAESTRA DE 500 QUIZZES CLÍNICOS EN FIRESTORE (20 POR CADA TEMA)');
  console.log('SYNAPSE HEALTH - ANATOMÍA HUMANA (ROUVIÈRE TOMOS 1 AL 4)');
  console.log('========================================================================\n');

  // Tomo 1: Cabeza y Cuello (140 Quizzes)
  await runTomo1Part1();
  await runTomo1Part2();

  // Tomo 2: Tronco (120 Quizzes)
  await runTomo2Part1();
  await runTomo2Part2();

  // Tomo 3: Miembros (120 Quizzes)
  await runTomo3Part1();
  await runTomo3Part2();

  // Tomo 4: Sistema Nervioso Central (120 Quizzes)
  await runTomo4Part1();
  await runTomo4Part2();

  // Actualizar el área médica general con el total global de quizzes (500)
  await setDocument(
    'medical_areas/anatomia',
    { quizzesCount: 500 },
    ['quizzesCount']
  );

  console.log('\n========================================================================');
  console.log('¡CARGA MAESTRA EXITOSA! 500 QUIZZES GUARDADOS.');
  console.log('Cada uno de los 25 temas cuenta con exactamente 20 quizzes clínicos.');
  console.log('========================================================================\n');
}

main().catch(err => {
  console.error('Error fatal durante la carga maestra:', err);
  process.exit(1);
});
