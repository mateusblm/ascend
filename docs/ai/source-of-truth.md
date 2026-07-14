# Fonte de verdade do produto

## Escopo da V1

O Ascend e um aplicativo de progressao pessoal. A versao inicial contem autenticacao, perfil com atributos, missoes pessoais, sequencia diaria e uma ruptura semanal individual.

Nao existem Arena, ranking, temporadas, missões competitivas, placar, provas de promocao ou verificacao de evidencias na V1.

## Arquitetura atual

- Flutter e Riverpod formam o cliente mobile.
- Firebase Auth identifica o usuario. Firebase nao armazena dados de jogo.
- Spring Boot em Java e a fonte autoritativa das regras de negocio.
- PostgreSQL guarda perfis, quests, conclusoes, sessoes ativas e resgates do boss pessoal.
- Flyway versiona toda mudanca estrutural do banco.
- Isar e somente cache local para uma experiencia responsiva; o backend autoritativo prevalece.

## Regras de manutencao

- Recompensas, XP, atributos, revogacoes e resgates sao calculados no backend.
- Todo endpoint protegido recebe o token Firebase e registra a sessao ativa.
- Nomes, mensagens de erro e JavaDoc de regras relevantes permanecem em portugues.
- Nunca reintroduzir Firestore como persistencia de jogo ou fluxos competitivos sem uma decisao de produto documentada.
