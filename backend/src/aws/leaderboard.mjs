export function createLeaderboard(store) {
  const fields = ['userId', 'displayName', 'photoUrl', 'career', 'gender', 'totalStars',
    'totalQuizTimeSeconds', 'completedQuizzesCount', 'averageTimeSeconds', 'lastActiveAt'];
  return {async list(options) {
    const output = await store.list('LEADERBOARD', 'USER#', options);
    return {items: output.items.map(item => ({id: item.SK.slice(5),
      ...Object.fromEntries(fields.filter(key => Object.hasOwn(item.data, key)).map(key => [key, item.data[key]]))})),
    nextCursor: output.nextCursor};
  }};
}
