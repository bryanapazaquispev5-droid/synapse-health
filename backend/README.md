# Synapse Health AWS backend

AWS is mandatory in the target architecture. This module is prepared and tested locally; it has not been deployed. Firestore remains the source of academic history during the transition. No mock data is loaded by the production handler.

## Local verification

Use Node.js 22, the selected Lambda runtime:

```sh
cd backend
npm ci --ignore-scripts
npm run typecheck
npm run build
npm test
npm run test:health
```

From the repository root, with Java 21+ and the security test dependencies installed:

```sh
JAVA_HOME=/path/to/jdk security/node_modules/.bin/firebase emulators:exec \
  --config firebase.backend.emulators.json --project demo-synapse-health \
  --only auth,firestore 'npm run test:emulator --prefix backend'
```

The integration script refuses non-loopback emulators. Fixture accounts and records exist only in the demo project. Emulator tokens do not prove production JWT signing or deployed IAM; valid production-token verification remains a staging acceptance check.

## AWS Part 1 verification

The base and health route are reused from the existing backend. This part adds no authentication, quiz or progress migration and makes no Flutter changes. Cognito and DynamoDB remain future transition work; earlier authorized endpoints are preserved.

`npm run test:health` builds the TypeScript entry and tests the compiled Lambda through a temporary loopback HTTP server. It verifies HTTP200 JSON without Firebase/AWS credentials,405 for unsupported methods,400 for query parameters and the exact-origin CORS restriction. The server closes after the tests. This is local verification, not a deployed AWS URL or database readiness check.

SAM CLI1.168.0 was installed in an isolated temporary tooling environment and executed with telemetry disabled:

```sh
SAM_CLI_TELEMETRY=0 AWS_EC2_METADATA_DISABLED=true \
  sam validate --lint --template-file backend/template.yaml --region us-east-1
```

Run that validation from the repository root. The actual SAM transform detected invalid flattened gateway response headers left in the earlier template. They now use nested `ResponseParameters.Headers`, as required by [AWS SAM response configuration](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-controlling-access-to-apis-customize-response.html). The corrected template passes SAM CLI validation. Prior cfn-lint results alone did not detect this error.

Verification:78 backend regression tests plus4 compiled health HTTP tests passed on Node.js22; TypeScript typecheck/build passed; Flutter analyze had no issues and all166 Flutter tests passed. Runtime dependencies, Firebase services and Flutter code remain unchanged. No AWS deployment or migration was executed.

## REST endpoints

Paths below are relative to the API Gateway stage URL, such as `/dev/`:

| Method | Path | Authentication | Result |
| --- | --- | --- | --- |
| GET | `/api/v1/health` | Public | Process liveness, not database readiness |
| GET | `/api/v1/history` | Firebase ID token | `{items,nextCursor}` |
| GET | `/api/v1/history/{id}` | Firebase ID token | Saved answer in a retained attempt |
| GET | `/v1/me/profile` | Firebase ID token | Whitelisted own profile |
| PATCH | `/v1/me/profile` | Firebase ID token | Existing preparation; name/career/gender only |

Success: `{data,requestId}`. Errors: `{error:{code,message},requestId}`. Backend status codes include 400, 401, 403, 404, 405, 409, 413, 415, 429, 500 and 503. No internal exception text reaches the response. API Gateway default errors remain managed gateway responses; throttling is configured separately.

History accepts `limit` (1–50, default20) and optional `cursor`. Other query keys are rejected. IDs are canonical unpadded Base64URL JSON `[areaId,topicId,attemptNumber,quizId]`; knowing an ID does not grant access. The token UID selects the owner path, never a body/query userId.

A cursor is linked to the owner and last returned entry. Deletion of that entry returns409 and requires refresh. Pages are fresh bounded snapshots, not a frozen export: new concurrent records appear after refresh. The nested Firestore model cannot be globally paginated chronologically by query. The adapter reads at most201 topic documents; more than200 returns an explicit503, with no silent truncation. A date-indexed DynamoDB model is the planned scalable replacement.

## Security and configuration

- Admin SDK verifies Firebase ID tokens with `checkRevoked=true`, including disabled users. Infrastructure failures are not reported as invalid credentials.
- Server libraries bypass Firestore rules. Repositories explicitly derive the owner from verified UID and whitelist profile fields. Public ranking writes are not implemented from client practice scores.
- `FIREBASE_PROJECT_ID` must match the service-account project in an existing AWS Secrets Manager secret. Only its ARN appears in the environment. No credential JSON is committed or embedded in Flutter.
- Production runtime rejects emulator environment variables. Local emulator integration injects the real emulator SDK explicitly.
- `USER_RATE_LIMIT=30`: one server-only hashed-owner Firestore counter per minute, atomic transaction,429 with Retry-After. Fixed windows can allow a burst across a boundary; this is not a sliding-window quota.
- API Gateway additionally has shared throttling10 requests/s and burst20; AWS throttling is best effort, not a spending cap. Lambda concurrency is5, timeout20s; logs retain14days.
- `ALLOWED_ORIGIN` is one exact HTTPS origin; mismatched browser origins receive403. Native requests without Origin remain supported. No wildcard CORS, token/UID/event/body logging or DataTrace.
- The Lambda role can read only the specified credential secret and write to its own log group. No DynamoDB permission is granted while that store is inactive.
- A Google service account needs Firebase Authentication read access for revocation checks and required Firestore read/transaction/write permissions for the limiter/profile. Scope it to the selected project/database; confirm least-privilege IAM in staging. If a customer KMS key protects the secret, a narrowly scoped kms:Decrypt grant must be reviewed before deployment.
- Rotate service-account keys through Secrets Manager and restart execution environments to clear credential caches. Workload Identity Federation is the preferred later replacement for long-lived keys; it is not configured here.

## Flutter rollout

`SYNAPSE_API_BASE_URL` is empty by default, so history uses existing live Firestore services. After an approved, validated deployment, provide its HTTPS stage base URL through dart-define. The history repository then calls the real REST list/detail endpoints. A configured backend failure never falls back to direct Firebase reads.

The client uses current Firebase ID tokens in memory, one forced refresh after401, UID checks across awaits, no redirects, bounded response size and request timeout. No AWS credentials are present in Flutter. Catalog names remain on existing Firestore streams. AWS history loads its first page immediately, then fetches additional pages only through Mostrar más; later errors keep loaded records with a safe notice. It is a refreshable paginated snapshot; it does not claim realtime/offline disk persistence. Existing profile editing remains in Firebase; prepared profile REST methods are not switched into that flow in this phase.

## Infrastructure and later deployment

`template.yaml` defines API Gateway REST, Lambda Node.js22/ARM64, IAM and CloudWatch. The optional encrypted/PITR DynamoDB table has `EnableDynamoHistory=false` by default. Turning it on creates a table but does not migrate records or switch the backend. Cognito now has a conditional User Pool/public client and a staged Flutter flow; Firebase remains active. Production activation and identity/data migration are not enabled. See ../docs/AWS_PARTE_2_COGNITO.md.

Initial phase5 validation used cfn-lint. AWS Part1 now also executed SAM CLI1.168.0 validate --lint after correcting gateway response header syntax. AWS CLI and Docker remain unavailable; no sam local/docker build or AWS account validation is claimed.

After explicit deployment authorization, a reproducible workflow is:

```sh
cd backend
npm ci --ignore-scripts
npm run build
sam validate --lint --template-file template.yaml
sam build --template-file template.yaml
sam deploy --guided
```

Supply the existing secret ARN, Firebase project and approved web origin during deployment. Keep DynamoDB disabled until its migration/store adapter is implemented and verified. Review region/account, existing resources, IAM/KMS, estimated API/Lambda/Firestore/Secrets Manager/log costs, budget alerts and staging token tests before confirming deployment. No deployment command was executed in this phase.

Data model, diagram, migration and verification results: `../docs/FASE_5_HISTORIAL_AWS.md`.

## Cognito / AWS Part 2

EnableCognitoAuth remains false. When a deployment is authorized, the template prepares email-based User Pool and public client, password policy, verification/recovery, short-lived tokens and refresh rotation. No mobile client secret or admin IAM grant is added.

GET /api/v1/auth/session uses COGNITO_USER_POOL_ID/COGNITO_CLIENT_ID and accepts Cognito access tokens only. aws-jwt-verify checks signature/JWKS/issuer/client/token_use/expiration/subject; GetUser checks revocation/disableduser and subject match. It never converts sub to a Firebase UID or uses the Firebase credential secret. Shared Gateway throttling applies; no per-user Cognito counter is added.

Firebase tokens still protect history/profile. Tests use local RSA keys/JWKS and simulated provider transport, not deployed Cognito. TypeScript build,119 backend tests,4 HTTP health and SAM validation passed; runtime dependency audit is clean. Flutter staging/production guards and rollout prerequisites: ../docs/AWS_PARTE_2_COGNITO.md.

## DynamoDB / AWS Part 3

Opt-in authenticated flashcard CRUD reuses the Lambda/API Gateway and existing Flutter REST transport. Firebase catalog and academic flows remain active. `EnableFlashcardCrud=false` by default, requires Cognito; no deployment performed. See [data model, endpoints, permissions and local verification](../docs/AWS_PARTE_3_DYNAMODB_CRUD.md). `npm test` now builds first; `DYNAMODB_LOCAL_ENDPOINT=http://127.0.0.1:8000 npm run test:dynamodb` verifies persistence, HTTP CRUD and distributed quota locally.

## Academic quizzes / AWS Part 4

`EnableQuizBackend=false` prepares Cognito-authenticated quiz reads, server-started attempts, grading, idempotent submissions, topic retries and personal progress. The shared academic table and previously prepared private table are reused; the same Lambda serves all routes. No deployment or Firebase/UI switch occurred. Safe quiz DTOs never become answer-bearing Flutter QuizModel objects.

The existing [DynamoDB/API document](../docs/AWS_PARTE_3_DYNAMODB_CRUD.md#aws-parte-4--quizzes-resultados-y-progreso-2026-10-12) now includes scoring rules, request bodies, private keys, the updated diagram and limits. `npm run test:dynamodb` includes quiz repository and actual HTTP/RSA/JWKS integrations. GetUser account status uses a local fixture; no real Cognito/AWS account is claimed. Catalog loading and staging deployment need separate authorization.
