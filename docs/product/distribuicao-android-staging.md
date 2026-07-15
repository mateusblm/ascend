# Distribuicao automatica do Android

Cada tag semantica `vX.Y.Z` publicada na `main` aciona o workflow
`.github/workflows/distribuir-android-staging.yml`.

O workflow valida o Flutter, gera o APK `staging` e o envia ao Firebase App
Distribution. Assim, um testador convidado recebe o convite ou a nova versao no
celular, mesmo sem acesso ao computador de desenvolvimento.

## Configuracao unica no GitHub

No repositorio `mateusblm/ascend`, em **Settings > Secrets and variables >
Actions**, cadastre:

| Tipo | Nome | Valor |
| --- | --- | --- |
| Secret | `FIREBASE_SERVICE_ACCOUNT_ASCEND` | JSON da conta de servico do projeto `ascend-b7c20` |
| Variable | `ASCEND_JAVA_BACKEND_URL` | URL pública HTTPS do backend no Railway |
| Variable | `FIREBASE_APP_DISTRIBUTION_TESTERS` | E-mail do testador, por exemplo `voce@email.com` |

Crie a conta de servico no Google Cloud do projeto `ascend-b7c20` com o papel
`Firebase App Distribution Admin`, gere uma chave JSON e armazene seu conteudo
somente no secret do GitHub. O Firebase recomenda esse mecanismo para CI e a
credencial nunca deve entrar no repositorio.

No console Firebase, abra **App Distribution**, selecione o app Android de
staging `com.ascend.mobile.staging` e conclua a ativacao inicial. Aceite o
convite no celular com o mesmo e-mail definido na variavel.

## Uso

Ao final de uma funcionalidade:

1. Publicar o commit na `main`.
2. Criar e publicar a tag, por exemplo `v0.1.2`.
3. Acompanhar o workflow na aba **Actions** do GitHub.
4. Abrir a notificacao do Firebase App Distribution no celular e instalar a
   nova versao de staging.

O APK recebe a URL remota pelo `ASCEND_JAVA_BACKEND_URL`; portanto, o backend
Railway precisa estar publicado antes de testar fora da rede local. O workflow
interrompe a distribuição quando essa variável está ausente ou não usa HTTPS,
para nunca entregar um APK com o cliente Java desabilitado.
