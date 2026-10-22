import { encodeLocator } from '../dist/quizzes/keys.js';
export const uuid = index => `00000000-0000-4000-8000-${String(index).padStart(12, '0')}`;
export const fixtureQuiz = (index = 1, type = 'single_choice', topicId = 'fixture-topic') => ({
  id: encodeLocator(['fixture-area', uuid(index)]), areaId: 'fixture-area', topicId, version: 1,
  type, question: 'Local test fixture', options: ['Fixture A', 'Fixture B'], correctIndex: 0,
  rationale: 'Private fixture explanation', sourceBook: '', orderIndex: index,
  matchingPairs: [{ left: 'L1', right: 'R1' }, { left: 'L2', right: 'R2' }], orderingItems: ['First', 'Second'],
});
export const contentItem = quiz => ({ ...quiz, PK: `AREA#${quiz.areaId}`, SK: `QUIZ#${JSON.parse(Buffer.from(quiz.id, 'base64url'))[1]}`, entityType: 'QUIZ' });
const itemKey = (table, key) => `${table}:${JSON.stringify(Object.entries(key).filter(([name]) => ['PK', 'SK', 'userKey', 'entryKey'].includes(name)).sort())}`;
export class MemoryAcademicClient {
  records = new Map(); calls = [];
  seed(table, item) { this.records.set(itemKey(table, item), structuredClone(item)); }
  async send(command) {
    const input = command.input; this.calls.push(command);
    if (command.constructor.name === 'GetCommand') return { Item: structuredClone(this.records.get(itemKey(input.TableName, input.Key))) };
    if (command.constructor.name === 'QueryCommand') {
      const values = input.ExpressionAttributeValues;
      const all = [...this.records.entries()].filter(([key, item]) => key.startsWith(`${input.TableName}:`) &&
        (values[':area'] ? item.PK === values[':area'] && item.SK.startsWith(values[':prefix']) : item.userKey === values[':user'] && item.entryKey.startsWith(values[':prefix'])))
        .map(([, item]) => item).sort((a, b) => (a.SK ?? a.entryKey).localeCompare(b.SK ?? b.entryKey));
      if (input.ScanIndexForward === false) all.reverse();
      const offset = input.ExclusiveStartKey ? all.findIndex(item => itemKey(input.TableName, item) === itemKey(input.TableName, input.ExclusiveStartKey)) + 1 : 0;
      const evaluated = all.slice(offset, offset + input.Limit);
      const last = evaluated.at(-1); const hasMore = offset + evaluated.length < all.length;
      return { Items: structuredClone(evaluated.filter(item => !values[':topic'] || item.topicId === values[':topic'])),
        LastEvaluatedKey: hasMore ? (last.PK ? { PK: last.PK, SK: last.SK } : { userKey: last.userKey, entryKey: last.entryKey }) : undefined };
    }
    if (command.constructor.name === 'TransactWriteCommand') {
      for (const { Put: put } of input.TransactItems) {
        const existing = this.records.get(itemKey(put.TableName, put.Item));
        const valid = put.ConditionExpression === 'attribute_not_exists(entryKey)' ? !existing
          : put.ConditionExpression === '#version = :version' ? existing?.version === put.ExpressionAttributeValues[':version']
          : existing?.status === put.ExpressionAttributeValues[':status'];
        if (!valid) {
          const error = new Error('Conditional write rejected'); error.name = 'TransactionCanceledException';
          error.CancellationReasons = [{ Code: 'ConditionalCheckFailed' }]; throw error;
        }
      }
      for (const { Put } of input.TransactItems) this.seed(Put.TableName, Put.Item);
      return {};
    }
    throw new Error(`Unsupported fixture command ${command.constructor.name}`);
  }
}
