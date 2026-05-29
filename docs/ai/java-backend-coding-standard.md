# Padrao De Codigo Java Backend

## Proposito

Manter a migracao Java consistente, legivel e facil de revisar.

Este padrao se aplica a todo novo endpoint Java em `backend/`.

## Idioma Do Codigo

- Use portugues nos nomes de dominio, classes, metodos e variaveis criadas para
  o Ascend.
- Use ASCII, sem acentos, cedilha ou caracteres especiais em identificadores.
- Use nomes claros em portugues, sem abreviacoes artificiais.
- Preserve termos de produto que ja sao parte da linguagem do app, como
  `Quest`, `XP`, `Rank`, `Boss` e `Firestore`.
- Preserve sufixos tecnicos reconheciveis quando eles melhoram a leitura em
  Java/Spring, como `Controller`, `Service`, `Repository`, `Mapper`, `Guard`,
  `Request` e `Response`.
- Evite misturar portugues e ingles dentro do mesmo conceito. Exemplo:
  prefira `SincronizacaoInventarioQuestService` em vez de
  `QuestInventorySincronizacaoService`.

Exemplos recomendados:
- `SincronizacaoInventarioQuestService`
- `ValidadorRequisicaoInventarioQuest`
- `MapeadorDocumentoInventarioQuest`
- `CatalogoQuestCompetitiva`
- `GuardaSessaoAtiva`

## Padrao De Endpoint

Use este fluxo, salvo quando uma fase documentar explicitamente outra
arquitetura:

```text
Controller -> Service -> Domain validators/mappers -> Repository
```

Responsabilidades:
- Controller: apenas mapeamento HTTP. Sem regra de negocio.
- Service: apenas orquestracao. Sem parse de payload e sem mapas de campos
  Firestore.
- Validator: converte payload nao confiavel em dados de dominio normalizados.
- Mapper: converte dados de dominio validados em DTOs/documentos de persistencia.
- Repository: acesso ao Firestore apenas. Sem regra de negocio.
- Guard: pre-condicoes transversais de negocio, como posse de sessao ativa.

## Padrao DDD

Organize o backend por contexto de dominio antes de pensar em detalhes
tecnicos. Exemplos de contextos atuais:
- `autenticacao`
- `conta`
- `placar`
- `quests`

Dentro de cada contexto, mantenha a separacao conceitual:
- `api`: controllers e DTOs de contrato HTTP.
- `aplicacao`: services, casos de uso, guards e validadores de orquestracao.
- `dominio`: regras puras, entidades, value objects, catalogos e interfaces de
  repositorio.
- `infraestrutura`: implementacoes Firestore, Secret Manager e demais detalhes
  externos.

Em contextos pequenos, os pacotes podem permanecer mais rasos durante a fase de
migracao, mas as classes ainda devem respeitar essas responsabilidades. Ao tocar
novamente em um contexto, prefira aproximar a estrutura fisica desse modelo.

## Regras SOLID

- Responsabilidade unica: separe validacao, mapeamento, acesso a repositorio e
  orquestracao em classes diferentes.
- Aberto/fechado: prefira adicionar um novo validator/mapper/metodo de service
  em vez de alterar codigo de endpoint sem relacao.
- Substituicao de Liskov: mantenha interfaces de repository pequenas e
  comportamentalmente claras para que fakes substituam Firestore em testes.
- Segregacao de interfaces: evite repositories amplos que atendem muitos
  dominios.
- Inversao de dependencia: services dependem de interfaces ou colaboradores
  focados, nao de APIs concretas do Firestore.

## Regras Clean Code

- Mantenha controllers finos.
- Mantenha metodos publicos curtos o bastante para leitura direta quando
  pratico.
- Nomeie classes pela responsabilidade.
- Nao esconda regras de recompensa, XP, rank ou sessao em helpers genericos.
- Prefira nomes de dominio explicitos a abreviacoes.
- Use records para DTOs imutaveis e value objects internos.
- Use records/classes package-private para dados internos de dominio quando
  possivel.
- Evite novas bibliotecas utilitarias quando JDK ou Spring ja bastam.

## Regras De Documentacao

- Adicione Javadocs concisos em novas classes de dominio, services, validators,
  mappers, guards e repositories.
- Adicione Javadocs em todo metodo publico que concentra regra de negocio
  importante, especialmente regras de XP, recompensa, rank, sessao,
  sincronizacao e validacao de payload nao confiavel.
- Escreva Javadocs e comentarios em portugues.
- Comente apenas intencao de negocio ou compatibilidade nao obvia com o backend
  TypeScript.
- Nao comente mecanica obvia de Java.

## Regras De Erro

- Endpoints protegidos devem retornar `401` quando Firebase Auth estiver
  ausente/invalido.
- Payloads invalidos devem usar `400` com codigo `error` estavel.
- Pre-condicoes de negocio devem usar `409` ou `412` com codigo `error`
  estavel.
- Toda resposta de erro exposta ao Flutter deve incluir uma mensagem humana em
  portugues no campo `message`.
- Use `ExcecaoApi` para regras de negocio que precisam combinar status HTTP,
  codigo estavel e mensagem humana em portugues.
- Nao exponha stack traces ou mensagens cruas de excecao ao Flutter.

## Regras De Teste

Todo endpoint migrado precisa de:
- teste de controller para auth e formato da resposta
- teste de service para orquestracao de negocio
- fixtures de validator ou service para payloads invalidos
- repository atras de interface para testes com fake

Para areas sensiveis, adicione testes de idempotencia e rollback antes de
trocar o trafego Flutter.
