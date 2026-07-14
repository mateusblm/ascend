# Deploy do backend no Railway

O Railway substitui o Cloud Run como ambiente remoto de staging do backend
Java. O aplicativo continua usando Firebase Auth para identidade, PostgreSQL
para dados de jogo e Flyway para versionar o banco.

## Componentes

Crie um projeto Railway com dois servicos:

1. `Postgres`: banco gerenciado do Railway.
2. `ascend-backend`: servico ligado ao repositorio GitHub `mateusblm/ascend`,
   branch `main`, com Root Directory `backend` e Config as Code em
   `/backend/railway.toml`.

O servico Java usa o `backend/Dockerfile` multiestagio e responde em
`/health`. Gere um dominio publico em **Settings > Networking**.

## Variaveis do backend

No servico `ascend-backend`, configure as variaveis abaixo. As referencias
`Postgres` devem apontar para o nome real do servico de banco no projeto.

| Variavel | Valor Railway |
| --- | --- |
| `ASCEND_DATABASE_URL` | `jdbc:postgresql://${{Postgres.PGHOST}}:${{Postgres.PGPORT}}/${{Postgres.PGDATABASE}}` |
| `ASCEND_DATABASE_USERNAME` | `${{Postgres.PGUSER}}` |
| `ASCEND_DATABASE_PASSWORD` | `${{Postgres.PGPASSWORD}}` |
| `ASCEND_DATABASE_DRIVER` | `org.postgresql.Driver` |
| `FIREBASE_SERVICE_ACCOUNT_JSON` | Conteudo JSON da service account do Firebase Admin |

`PORT` e fornecida automaticamente pelo Railway. Nao defina
`GOOGLE_APPLICATION_CREDENTIALS` no Railway: ela e uma configuracao local via
ADC e nao existe como arquivo no container remoto.

Conceda a service account o acesso necessario para verificar tokens Firebase.
A chave JSON deve ser criada e armazenada apenas na area de Variables/Secrets
do Railway, nunca no repositorio.

## Automacao

Ao conectar o repositorio ao Railway, cada push na `main` cria um deploy novo
do backend. Depois de gerar o dominio publico, copie a URL HTTPS para a
variavel de repositorio GitHub `ASCEND_JAVA_BACKEND_URL`; o workflow de App
Distribution a injeta no APK de staging distribuido pelas tags `vX.Y.Z`.

O repositorio tambem possui o workflow
`.github/workflows/deploy-railway-backend.yml`, que publica alteracoes em
`backend/` sem depender da integracao visual do Railway com GitHub. Cadastre no
GitHub:

| Tipo | Nome | Valor |
| --- | --- | --- |
| Secret | `RAILWAY_TOKEN` | Project Token gerado no ambiente staging do Railway |
| Variable | `RAILWAY_BACKEND_SERVICE` | Nome do servico, por exemplo `ascend-backend` |
| Variable | `RAILWAY_ENVIRONMENT` | Nome do ambiente, por exemplo `staging` |

Com essas tres configuracoes, cada push na `main` que alterar o backend inicia
o deploy no Railway. O token de projeto e restrito ao ambiente, adequado para
este pipeline de CI.

## Verificacao

Depois do primeiro deploy, abra:

```text
https://SEU-DOMINIO-RAILWAY/health
```

A resposta esperada e um JSON com `status` igual a `ok`. Em seguida, gere uma
tag nova e instale o APK de staging distribuido pelo Firebase App Distribution.
