import {ApiError} from '../http.mjs';
import {identifier} from './validation.mjs';

function partition(path) {
  const parts = path.split('/');
  if (parts[0] !== 'medical_areas' || !parts[1]) throw new ApiError(404, 'not_found', 'Catalog collection is unavailable.');
  if (parts.length === 3 && parts[2] === 'quizzes') return {areaId: parts[1], topicId: null, collection: 'quizzes'};
  if (parts[2] === 'topics' && parts.length === 3) return {areaId: parts[1], topicId: null, collection: null};
  if (parts[2] === 'topics' && parts.length === 5 && ['study-notes', 'quizzes'].includes(parts[4])) {
    return {areaId: parts[1], topicId: parts[3], collection: parts[4]};
  }
  throw new ApiError(404, 'not_found', 'Catalog collection is unavailable.');
}

export function createCatalog({areas, topics, quizzes: quizStore, studyNotes}) {
  async function list(path, options, requestedTopic = null) {
    if (path === 'medical_areas') {
      const result = await areas.list('AREAS', 'AREA#', options);
      return pageResult(result, 'AREA#');
    }
    const {areaId, topicId, collection} = partition(path);
    if (collection === null) {
      const result = await topics.list(`AREA#${areaId}`, 'TOPIC#', options);
      return pageResult(result, 'TOPIC#');
    }
    if (collection === 'study-notes') {
      const prefix = `TOPIC#${topicId}#STUDY_NOTE#`;
      return pageResult(await studyNotes.list(`AREA#${areaId}`, prefix, options), prefix);
    }
    if (collection === 'quizzes') {
      const selectedTopic = requestedTopic ?? topicId;
      const prefix = selectedTopic ? `TOPIC#${identifier(selectedTopic)}#QUIZ#` : 'TOPIC#';
      return quizResult(await quizStore.list(`AREA#${areaId}`, prefix, options));
    }
    throw new ApiError(404, 'not_found', 'Catalog collection is unavailable.');
  }

  async function quizzesForTopic(areaId, topicId) {
    identifier(areaId); identifier(topicId);
    const prefix = `TOPIC#${topicId}#QUIZ#`;
    const items = [];
    let cursor = null;
    do {
      const result = await quizStore.list(`AREA#${areaId}`, prefix, {limit: 100, cursor});
      items.push(...result.items.map(item => ({...item.data, id: item.SK.slice(prefix.length)})));
      cursor = result.nextCursor;
    } while (cursor);
    return items;
  }

  return {list, quizzes: quizzesForTopic, async quiz(areaId, topicId, quizId) {
    identifier(areaId); identifier(topicId); identifier(quizId);
    const prefix = `TOPIC#${topicId}#QUIZ#`;
    const item = await quizStore.get(`AREA#${areaId}`, `${prefix}${quizId}`);
    if (!item) throw new ApiError(404, 'not_found', 'Question is unavailable.');
    return {...item.data, id: quizId};
  }};
}

function pageResult(result, prefix) {
  return {items: result.items.map(item => ({...item.data, id: item.SK.slice(prefix.length)})), nextCursor: result.nextCursor};
}

function quizResult(result) {
  return {items: result.items.map(item => ({...item.data, id: item.SK.slice(item.SK.lastIndexOf('#QUIZ#') + 6)})),
    nextCursor: result.nextCursor};
}
