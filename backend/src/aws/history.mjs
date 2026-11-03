import {createHistoryRepository} from '../history-repository.mjs';
// Reuse the current FIFO3 derivation and owner-bound history cursor contract.
export function createAwsHistory(store) {
  return createHistoryRepository({collection() { return {doc(subject) { return {collection() {
    return {limit(limit) { return {async get() {
      const docs = [];
      let cursor = null;
      do {
        const page = await store.list(`USER#${subject}`, 'TOPIC#', {limit: Math.min(100, limit - docs.length), cursor});
        docs.push(...page.items.map(item => ({data: () => item.data})));
        cursor = page.nextCursor;
      } while (cursor && docs.length < limit);
      return {docs};
    } }; } };
  } }; } }; }});
}
