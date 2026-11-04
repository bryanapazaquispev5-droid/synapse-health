import { test } from "node:test";
import assert from "node:assert/strict";
import { maxStars, score } from "../../backend/src/aws/scoring.mjs";

const options = ["A", "B", "C", "D"];
const matchingPairs = [
  { left: "Heart", right: "Pumps blood" },
  { left: "Lung", right: "Exchanges gases" },
];
const single = (overrides = {}, answer = { selectedOptionText: "A" }) =>
  score({ type: "single_choice", options, correctIndex: 0, ...overrides }, answer);
const expectApiError = (operation, status, code) =>
  assert.throws(operation, (error) => error.status === status && error.code === code);

// PRUEBAS UNITARIAS — BE (25)


// Prueba 1: El backend recibe la opción correcta, A. Debe indicar que fue respondida
// correctamente y dar una estrella.
test("UNIT-BE-01 | single choice validation case 01", () => {
  const result = single();
  assert.deepEqual(result, {
    isAnswered: true,
    isCorrect: true,
    earnedStars: 1,
    maxStars: 1,
    selectedOptionIndex: null,
  });
});


// Prueba 2: El backend recibe la opción B, que existe pero no es la correcta. Debe guardar que
// hubo respuesta, sin acierto ni estrellas.
test("UNIT-BE-02 | single choice validation case 02", () => {
  const result = single({}, { selectedOptionText: "B" });
  assert.equal(result.isAnswered, true);
  assert.equal(result.isCorrect, false);
  assert.equal(result.earnedStars, 0);
});


// Prueba 3: El catálogo no indica el tipo de pregunta. El backend lo trata como opción simple y
// califica correctamente la respuesta A.
test("UNIT-BE-03 | single choice validation case 03", () => {
  const result = single({ type: undefined });
  assert.equal(result.isCorrect, true);
  assert.equal(result.maxStars, 1);
});


// Prueba 4: La pregunta es un caso de estudio y la opción C es la correcta. El backend debe
// aceptarla y asignar una estrella.
test("UNIT-BE-04 | single choice validation case 04", () => {
  const result = single(
    { type: "case_study", correctIndex: 2 },
    { selectedOptionText: "C" },
  );
  assert.equal(result.isCorrect, true);
  assert.equal(result.earnedStars, 1);
});


// Prueba 5: La respuesta incluye el índice numérico 0, que apunta a la opción A. El backend
// debe conservar ese índice.
test("UNIT-BE-05 | single choice validation case 05", () => {
  const result = single({}, { selectedOptionText: "A", selectedOptionIndex: 0 });
  assert.equal(result.selectedOptionIndex, 0);
});


// Prueba 6: El índice llega como texto "0", no como número. El backend debe responder HTTP 400
// y explicar que la solicitud tiene un dato inválido.
test("UNIT-BE-06 | single choice validation case 06", () => {
  expectApiError(
    () => single({}, { selectedOptionText: "A", selectedOptionIndex: "0" }),
    400,
    "invalid_request",
  );
});


// Prueba 7: La respuesta usa el índice -1, que no señala ninguna opción. El backend debe
// rechazarla con HTTP 400.
test("UNIT-BE-07 | single choice validation case 07", () => {
  expectApiError(
    () => single({}, { selectedOptionText: "A", selectedOptionIndex: -1 }),
    400,
    "invalid_request",
  );
});


// Prueba 8: El índice coincide con la cantidad de opciones, por lo que queda fuera de rango. El
// backend debe rechazarlo con HTTP 400.
test("UNIT-BE-08 | single choice validation case 08", () => {
  expectApiError(
    () => single({}, { selectedOptionText: "A", selectedOptionIndex: options.length }),
    400,
    "invalid_request",
  );
});


// Prueba 9: La respuesta no incluye el texto de la opción elegida. Sin ese dato el backend no
// puede calificarla y debe responder HTTP 400.
test("UNIT-BE-09 | single choice validation case 09", () => {
  expectApiError(() => single({}, { selectedOptionIndex: 0 }), 400, "invalid_request");
});


// Prueba 10: La solicitud incluye un campo password que esta operación no admite. El backend
// debe rechazar el campo extra con HTTP 400.
test("UNIT-BE-10 | single choice validation case 10", () => {
  expectApiError(
    () => single({}, { selectedOptionText: "A", password: "secret" }),
    400,
    "invalid_request",
  );
});


// Prueba 11: La respuesta elige la opción E, que no aparece en la pregunta. El backend debe
// rechazar la opción con HTTP 400.
test("UNIT-BE-11 | single choice validation case 11", () => {
  expectApiError(() => single({}, { selectedOptionText: "E" }), 400, "invalid_request");
});


// Prueba 12: El catálogo no tiene opciones para mostrar. El backend debe responder HTTP 400
// porque no puede calificar la pregunta.
test("UNIT-BE-12 | single choice validation case 12", () => {
  expectApiError(() => single({ options: [] }), 400, "invalid_request");
});


// Prueba 13: Una opción del catálogo es el número 2 en vez de texto. El backend debe avisar con
// HTTP 400 que la solicitud no cumple el formato.
test("UNIT-BE-13 | single choice validation case 13", () => {
  expectApiError(() => single({ options: ["A", 2, "C"] }), 400, "invalid_request");
});


// Prueba 14: El catálogo guarda correctIndex como texto "0". El backend detecta que la
// configuración de la pregunta no es válida y responde HTTP 503.
test("UNIT-BE-14 | single choice validation case 14", () => {
  expectApiError(() => single({ correctIndex: "0" }), 503, "invalid_catalog");
});


// Prueba 15: El catálogo usa -1 como índice correcto, que no señala una opción válida. El
// backend responde HTTP 503 por configuración incorrecta.
test("UNIT-BE-15 | single choice validation case 15", () => {
  expectApiError(() => single({ correctIndex: -1 }), 503, "invalid_catalog");
});


// Prueba 16: La pregunta tiene un tipo que el backend no reconoce. Debe responder HTTP 503 e
// indicar que el catálogo necesita corregirse.
test("UNIT-BE-16 | single choice validation case 16", () => {
  expectApiError(() => single({ type: "audio_question" }), 503, "invalid_catalog");
});


// Prueba 17: La pregunta para relacionar tiene dos parejas. El cálculo debe indicar que el
// máximo posible es dos estrellas.
test("UNIT-BE-17 | matching validation case 17", () => {
  assert.equal(maxStars({ type: "matching", matchingPairs }), 2);
});


// Prueba 18: La respuesta relaciona correctamente las dos parejas. El backend debe marcarla
// correcta y entregar dos estrellas.
test("UNIT-BE-18 | matching validation case 18", () => {
  const result = score({ type: "matching", matchingPairs }, { pairs: matchingPairs });
  assert.equal(result.isCorrect, true);
  assert.equal(result.earnedStars, 2);
});


// Prueba 19: En tres parejas, una relación es correcta y dos están cruzadas. El backend debe
// contar solo la correcta y dar una estrella.
test("UNIT-BE-19 | matching validation case 19", () => {
  const pairs = [...matchingPairs, { left: "Bone", right: "Supports body" }];
  const result = score(
    { type: "matching", matchingPairs: pairs },
    {
      pairs: [
        { left: "Heart", right: "Pumps blood" },
        { left: "Lung", right: "Supports body" },
        { left: "Bone", right: "Exchanges gases" },
      ],
    },
  );
  assert.equal(result.isCorrect, false);
  assert.equal(result.earnedStars, 1);
});


// Prueba 20: Las dos parejas usan elementos existentes, pero están cruzadas. El backend debe
// dar cero estrellas, sin tratar la solicitud como error.
test("UNIT-BE-20 | matching validation case 20", () => {
  const result = score(
    { type: "matching", matchingPairs },
    {
      pairs: [
        { left: "Heart", right: "Exchanges gases" },
        { left: "Lung", right: "Pumps blood" },
      ],
    },
  );
  assert.equal(result.earnedStars, 0);
});


// Prueba 21: La respuesta repite el elemento Heart y deja fuera Lung. El backend debe
// rechazarla con HTTP 400 porque falta una pareja distinta.
test("UNIT-BE-21 | matching validation case 21", () => {
  expectApiError(
    () =>
      score(
        { type: "matching", matchingPairs },
        {
          pairs: [
            { left: "Heart", right: "Pumps blood" },
            { left: "Heart", right: "Exchanges gases" },
          ],
        },
      ),
    400,
    "invalid_request",
  );
});


// Prueba 22: La respuesta solo incluye una de las dos parejas requeridas. El backend debe
// responder HTTP 400 por estar incompleta.
test("UNIT-BE-22 | matching validation case 22", () => {
  expectApiError(
    () =>
      score(
        { type: "matching", matchingPairs },
        { pairs: [{ left: "Heart", right: "Pumps blood" }] },
      ),
    400,
    "invalid_request",
  );
});


// Prueba 23: Los tres pasos llegan en el orden correcto. El backend debe dar una estrella por
// paso y marcar la respuesta correcta.
test("UNIT-BE-23 | ordering validation case 23", () => {
  const items = ["A", "B", "C"];
  const result = score({ type: "ordering", orderingItems: items }, { items });
  assert.equal(result.earnedStars, 3);
  assert.equal(result.isCorrect, true);
});


// Prueba 24: Los pasos llegan en orden inverso. Solo el elemento del medio conserva su lugar,
// así que el backend debe dar una estrella.
test("UNIT-BE-24 | ordering validation case 24", () => {
  const result = score(
    { type: "ordering", orderingItems: ["A", "B", "C"] },
    { items: ["C", "B", "A"] },
  );
  assert.equal(result.earnedStars, 1);
  assert.equal(result.isCorrect, false);
});


// Prueba 25: La respuesta repite el paso A y omite B. El backend debe rechazarla con HTTP 400
// por no incluir cada paso una sola vez.
test("UNIT-BE-25 | ordering validation case 25", () => {
  expectApiError(
    () =>
      score(
        { type: "ordering", orderingItems: ["A", "B", "C"] },
        { items: ["A", "A", "C"] },
      ),
    400,
    "invalid_request",
  );
});

