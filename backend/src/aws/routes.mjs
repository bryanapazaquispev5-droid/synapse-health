import {identifier, page} from './validation.mjs';

/**
 * Maps catalog URL patterns to storage paths after validating their IDs.
 * The cheatsheets alias preserves compatibility with older mobile clients.
 */
export function catalogRoute(path, query) {
  // GET /api/v1/areas
  if (path === '/api/v1/areas') return {path: 'medical_areas', options: page(query)};
  // GET /api/v1/areas/{areaId}/topics
  // GET /api/v1/areas/{areaId}/quizzes; topicId is an optional query filter.
  // GET /api/v1/areas/{areaId}/topics/{topicId}/quizzes
  // GET /api/v1/areas/{areaId}/topics/{topicId}/study-notes
  // The equivalent /cheatsheets path remains as a compatibility alias.
  const route = /^\/api\/v1\/areas\/([^/]+)\/(topics|quizzes)(?:\/([^/]+)\/(study-notes|cheatsheets|quizzes))?$/.exec(path);
  if (!route) return null;
  const area = identifier(route[1]);
  if (route[3]) {
    if (route[2] !== 'topics') return null;
    const topic = identifier(route[3]);
    const collection = route[4] === 'cheatsheets' ? 'study-notes' : route[4];
    return {path: `medical_areas/${area}/topics/${topic}/${collection}`, options: page(query)};
  }
  const options = page(query, route[2] === 'quizzes' ? ['topicId'] : []);
  const topicId = query?.topicId === undefined ? null : identifier(query.topicId);
  return {path: `medical_areas/${area}/${route[2]}`, options, topicId};
}
