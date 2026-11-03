/** The API alone publishes these canonical totals; clients cannot choose ranking fields. */
export async function rankingWrite(profilesStore, leaderboardStore, subject, scored, now) {
  const PK = 'LEADERBOARD';
  const SK = `USER#${subject}`;
  const [current, profile] = await Promise.all([leaderboardStore.get(PK, SK), profilesStore.get(`USER#${subject}`, 'PROFILE')]);
  const previous = current?.data;
  return {expectedVersion: current?.version ?? null, item: {PK, SK, data: {
    userId: subject, displayName: profile?.data.name ?? 'Student',
    ...(profile?.data.photoUrl ? {photoUrl: profile.data.photoUrl} : {}),
    ...(profile?.data.career ? {career: profile.data.career} : {}),
    ...(profile?.data.gender ? {gender: profile.data.gender} : {}),
    totalStars: (previous?.totalStars ?? 0) + scored.earnedStars,
    completedQuizzesCount: (previous?.completedQuizzesCount ?? 0) + 1,
    // The current quiz contract has no trusted start clock. Unknown duration stays null.
    totalQuizTimeSeconds: null, averageTimeSeconds: null, lastActiveAt: now,
  }}, store: leaderboardStore};
}
