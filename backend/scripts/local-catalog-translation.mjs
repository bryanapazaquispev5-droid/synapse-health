import {pipeline} from '@huggingface/transformers';

const modelId = 'Xenova/opus-mt-es-en';
const maxChunkLength = 520;
const translationSlot = Symbol('localTranslationSlot');
const terminology = [
  ['fisura orbitaria superior', 'superior orbital fissure'], ['arteria meníngea media', 'middle meningeal artery'],
  ['vena meníngea media', 'middle meningeal vein'], ['foramen espinoso', 'foramen spinosum'],
  ['foramen redondo', 'foramen rotundum'], ['foramen oval', 'foramen ovale'],
  ['hueso esfenoides', 'sphenoid bone'], ['fosa infratemporal', 'infratemporal fossa'],
  ['base de cráneo', 'skull base'], ['nervio mandibular', 'mandibular nerve'],
  ['nervio maxilar', 'maxillary nerve'], ['nervio oftálmico', 'ophthalmic nerve'],
  ['nervio oculomotor', 'oculomotor nerve'], ['nervio troclear', 'trochlear nerve'],
  ['nervio abducens', 'abducens nerve'], ['nervio trigémino', 'trigeminal nerve'],
  ['médula espinal', 'spinal cord'], ['líquido cefalorraquídeo', 'cerebrospinal fluid'],
  ['conducto inguinal', 'inguinal canal'], ['fosa poplítea', 'popliteal fossa'],
  ['túnel carpiano', 'carpal tunnel'], ['sistema límbico', 'limbic system'],
  ['tronco encefálico', 'brainstem'], ['pares craneales', 'cranial nerves'],
  ['nervios craneales', 'cranial nerves'], ['vértebras cervicales', 'cervical vertebrae'],
  ['vértebra cervical', 'cervical vertebra'], ['esfenoides', 'sphenoid'],
  ['cráneo', 'skull'], ['meninges', 'meninges'],
];
let translatorPromise;
const translator = () => translatorPromise ??= pipeline('translation', modelId, {dtype: 'q8'});

export async function translateCatalogText(value) {
  const prepared = await translateTexts([value]);
  return prepared[0];
}

export async function translateCatalogData(value) {
  const chunks = [];
  const leaves = [];
  const template = collect(value, '', chunks, leaves);
  const translations = await translateChunks(chunks);
  const textLeaves = leaves.map(leaf => leaf.restore(translations.slice(leaf.start, leaf.start + leaf.count).join('')));
  return hydrate(template, textLeaves);
}

function collect(value, key, chunks, leaves) {
  if (typeof value === 'string') {
    if (!shouldTranslate(key) || !value.trim()) return value;
    const leaf = protectText(value);
    const slot = leaves.push({...leaf, start: chunks.length, count: leaf.chunks.length}) - 1;
    chunks.push(...leaf.chunks);
    return {[translationSlot]: slot};
  }
  if (Array.isArray(value)) return value.map(item => collect(item, key, chunks, leaves));
  if (value && typeof value === 'object') {
    return Object.fromEntries(Object.entries(value).map(([childKey, child]) =>
      [childKey, collect(child, childKey, chunks, leaves)]));
  }
  return value;
}

function protectText(value) {
  const replacements = [];
  let text = value.replace(/```[\s\S]*?```|`[^`\n]+`|https?:\/\/\S+/g, match => addToken(match, replacements));
  for (const [spanish, english] of [...terminology].sort((a, b) => b[0].length - a[0].length)) {
    text = text.replace(new RegExp(`(?<![\\p{L}])${escapeRegex(spanish)}(?![\\p{L}])`, 'giu'), match =>
      addToken(capitalizeLike(match, english), replacements));
  }
  return {chunks: splitText(text), restore: translated => replacements.reduce((result, replacement, index) =>
    result.replaceAll(`ZXQMEDTERM${index}QXZ`, replacement), translated)};
}

function addToken(replacement, entries) {
  return `ZXQMEDTERM${entries.push(replacement) - 1}QXZ`;
}

async function translateTexts(texts) {
  const prepared = texts.map(protectText);
  const chunks = prepared.flatMap(item => item.chunks);
  const translated = await translateChunks(chunks);
  let offset = 0;
  return prepared.map(item => {
    const text = translated.slice(offset, offset + item.chunks.length).join('');
    offset += item.chunks.length;
    return item.restore(text);
  });
}

async function translateChunks(chunks) {
  if (!chunks.length) return [];
  const model = await translator();
  const output = [];
  for (let offset = 0; offset < chunks.length; offset += 12) {
    const translated = await model(chunks.slice(offset, offset + 12));
    output.push(...translated.map(item => item.translation_text));
  }
  return output;
}

function hydrate(value, strings) {
  if (value && typeof value === 'object' && Object.hasOwn(value, translationSlot)) return strings[value[translationSlot]];
  if (Array.isArray(value)) return value.map(item => hydrate(item, strings));
  if (value && typeof value === 'object') return Object.fromEntries(Object.entries(value).map(([key, child]) => [key, hydrate(child, strings)]));
  return value;
}

function splitText(value) {
  const chunks = [];
  let start = 0;
  while (start < value.length) {
    let end = Math.min(start + maxChunkLength, value.length);
    if (end < value.length) {
      const boundary = Math.max(value.lastIndexOf('\n', end), value.lastIndexOf(' ', end));
      if (boundary > start + 120) end = boundary + 1;
    }
    chunks.push(value.slice(start, end)); start = end;
  }
  return chunks;
}

function shouldTranslate(key) {
  return !/^(?:id|.*Id|code|type|version|correctIndex|order(?:Index)?|maxStars|.*(?:URL|Uri|Base64|Hash|Token))$/i.test(key);
}
function escapeRegex(value) { return value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'); }
function capitalizeLike(source, target) { return source[0] === source[0].toUpperCase() ? target[0].toUpperCase() + target.slice(1) : target; }
