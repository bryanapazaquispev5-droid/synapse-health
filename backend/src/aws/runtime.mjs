import {createCognitoRuntime} from '../cognito-runtime.mjs';
import {createStore} from './store.mjs';
import {createCatalog} from './catalog.mjs';
import {createProfiles} from './profiles.mjs';
import {createProgress} from './progress.mjs';
import {createAwsHistory} from './history.mjs';
import {createLeaderboard} from './leaderboard.mjs';
import {createAuthRepository} from './auth-repository.mjs';
export function createAwsRuntime({env = process.env, client} = {}) {
  // Lambda inyecta los nombres de tablas desde CloudFormation; el backend los usa para crear cada acceso.
  const table = name => createStore({env, client, tableName: env[name]});
  const areas = table('MEDICAL_AREAS_TABLE_NAME');
  const topics = table('TOPICS_TABLE_NAME');
  const quizzes = table('QUIZZES_TABLE_NAME');
  const studyNotes = table('STUDY_NOTES_TABLE_NAME');
  const profilesStore = table('USER_PROFILES_TABLE_NAME');
  const progressStore = table('USER_PROGRESS_TABLE_NAME');
  const leaderboardStore = table('LEADERBOARD_TABLE_NAME');
  const rateLimits = table('RATE_LIMITS_TABLE_NAME');
  const catalog = createCatalog({areas, topics, quizzes, studyNotes});
  const authRepo = createAuthRepository({profilesStore, secret: env.JWT_SECRET});
  return {identity: createCognitoRuntime({env}), store: rateLimits, catalog, authRepo,
    profiles: createProfiles(profilesStore), progress: createProgress(progressStore, catalog, undefined, {profilesStore, leaderboardStore}),
    history: createAwsHistory(progressStore),
    leaderboard: createLeaderboard(leaderboardStore)};
}
