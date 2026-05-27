# Ascend Java Backend

Spring Boot backend created for the planned migration from Firebase Functions
TypeScript to Java on Cloud Run.

Current status:
- Maven project skeleton exists.
- `/health` is implemented.
- No production business rule has been migrated yet.
- TypeScript Functions remain authoritative.

## Local Commands

```powershell
cd backend
mvn test
mvn package
mvn spring-boot:run
```

Health check:

```text
GET http://localhost:8080/health
```

Expected response:

```json
{"status":"ok","service":"ascend-backend"}
```

## Migration Rules

Before migrating any endpoint:
- read `docs/ai/work-packages/java-backend-migration-plan.md`
- read `docs/ai/work-packages/java-backend-callable-inventory.md`
- inspect the current TypeScript callable
- add Java tests
- keep Flutter routing behind staging/debug config until parity is proven

## Environment

Planned runtime:
- Java 21
- Spring Boot
- Cloud Run
- Firebase Admin SDK
- Firestore
- Google Secret Manager

