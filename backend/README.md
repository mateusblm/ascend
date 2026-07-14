# Backend Ascend

Backend Java 21 com Spring Boot, PostgreSQL e Flyway para o escopo pessoal da V1.

## Executar localmente

```powershell
docker compose up --build
```

O serviço responde em `http://localhost:8080/health`. O PostgreSQL e iniciado pelo mesmo compose.

## Persistencia

Firebase Auth autentica o usuario. O estado de jogo fica exclusivamente no PostgreSQL: perfil, quests pessoais, conclusoes, sessoes ativas e ruptura semanal pessoal. As migracoes ficam em `src/main/resources/db/migration`.
