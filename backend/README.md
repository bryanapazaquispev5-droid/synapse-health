# Synapse Health AWS API

El servicio predeterminado usa Lambda/API Gateway, Cognito y una tabla DynamoDB nueva y vacía. No accede a Firestore ni migra datos existentes. Consulte [AWS.md](AWS.md) para contratos, configuración, costos y límites. Las dependencias del backend no contienen Firebase Admin ni módulos de Google Cloud.

## Verificación local

Requiere Node.js 22 o posterior:

```sh
cd backend
npm ci
npm test
npm run build
```

Los endpoints protegidos usan Cognito; `AWS_REGION`, `SYNAPSE_TABLE_NAME`, `COGNITO_USER_POOL_ID` y `COGNITO_CLIENT_ID` configuran el runtime AWS. `ALLOWED_ORIGIN` debe ser un origen HTTPS exacto. `npm start` inicia el servidor AWS local; salud no necesita credenciales.

## API

| Método | Ruta | Acceso |
| --- | --- | --- |
| GET | `/health` o `/api/v1/health` | Público |
| GET | `/api/v1/history` | Token Cognito |
| GET | `/api/v1/history/{id}` | Token Cognito |
| GET/PATCH | `/v1/me/profile` | Token Cognito |

El propietario se toma exclusivamente del token Cognito verificado. La app usa `SYNAPSE_API_BASE_URL` con el endpoint HTTPS de API Gateway; no hace fallback hacia Firestore. El resto de rutas está documentado en AWS.md.

## Contenedor y despliegue

Construir localmente:

```sh
docker build -t synapse-health-api .
```

Lambda usa su rol IAM de ejecución y credenciales temporales; no se guardan claves AWS en el repositorio ni en la app. `npm run package:aws` produce `dist/synapse-health-aws.zip` sin Firebase Admin, pruebas ni datos.

La infraestructura se genera con `npm run build` en `template.json`. `DeploymentApproved=false` impide crear recursos por defecto. Revisar saldo/créditos, costos y seguridad antes de habilitar el despliegue. No se ejecutaron operaciones en Google Cloud ni se importaron datos.
