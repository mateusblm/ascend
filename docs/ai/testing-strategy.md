# Estrategia de testes

- `flutter analyze` e `flutter test` protegem o cliente.
- `mvn clean test` protege os casos de uso Java.
- Validar em emulador: login, onboarding, criar/concluir/revogar quest, atributos, troca de foco e resgate do boss pessoal.
- Validar o backend com PostgreSQL via `docker compose up --build` e `GET /health`.
- Mudancas em modelos Isar exigem `dart run build_runner build --delete-conflicting-outputs`.
