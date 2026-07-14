# Mapa de arquitetura

## Cliente

Flutter com Riverpod apresenta perfil, missoes pessoais, atributos e ruptura semanal. Isar e cache local; o estado autoritativo vem da API Java.

## Servidor

Spring Boot organiza os casos de uso por dominio: perfil, quests, sessao e boss pessoal. Firebase Auth identifica o usuario. PostgreSQL armazena todos os dados de jogo e Flyway controla o schema.

## Regras

- O backend decide XP, level, atributos, conclusao, revogacao e resgate semanal.
- Quests sao exclusivamente pessoais e manuais na V1.
- A ruptura semanal exige quatro dias ativos e pode ser resgatada uma vez por semana.
- Nao existem contratos, tabelas ou endpoints para competitivo, ranking ou temporadas.
