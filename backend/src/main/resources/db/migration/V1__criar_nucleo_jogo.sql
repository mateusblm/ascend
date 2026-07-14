create table usuarios (
  uid varchar(128) primary key,
  email varchar(320),
  nome_exibicao varchar(80),
  url_foto text,
  criado_em timestamp with time zone not null default current_timestamp,
  atualizado_em timestamp with time zone not null default current_timestamp
);

create table perfis_jogador (
  uid varchar(128) primary key references usuarios(uid) on delete cascade,
  nome varchar(80) not null,
  nivel integer not null default 1,
  xp integer not null default 0,
  xp_maximo integer not null default 100,
  pontos_atributo integer not null default 0,
  forca integer not null default 10,
  inteligencia integer not null default 10,
  vitalidade integer not null default 10,
  agilidade integer not null default 10,
  foco_principal varchar(40) not null default 'discipline',
  onboarding_concluido boolean not null default false,
  sequencia_atual integer not null default 0,
  melhor_sequencia integer not null default 0,
  ultima_conclusao_quest_em timestamp with time zone,
  ultimo_reset_em timestamp with time zone not null default current_timestamp,
  ultimo_resgate_boss_semanal_em timestamp with time zone,
  xp_autoritativo_quests integer not null default 0,
  xp_autoritativo_boss_semanal integer not null default 0,
  pontos_boss_semanal integer not null default 0,
  pontos_atributo_alocados integer not null default 0,
  versao_schema integer not null default 1,
  fonte_sincronizacao varchar(80) not null default 'postgres_authoritative',
  criado_em timestamp with time zone not null default current_timestamp,
  atualizado_em timestamp with time zone not null default current_timestamp
);

create table sessoes_ativas (
  uid varchar(128) primary key references usuarios(uid) on delete cascade,
  id_sessao_dispositivo varchar(160) not null,
  rotulo_dispositivo varchar(120) not null default 'device',
  expira_em timestamp with time zone not null,
  criada_em timestamp with time zone not null default current_timestamp,
  atualizada_em timestamp with time zone not null default current_timestamp
);

create table quests (
  id varchar(140) primary key,
  uid varchar(128) not null references usuarios(uid) on delete cascade,
  titulo varchar(140) not null,
  atributo_recompensa varchar(24) not null,
  xp_recompensa integer not null,
  categoria varchar(24) not null default 'personal',
  tipo_template varchar(40) not null default 'custom',
  modo_verificacao varchar(40) not null default 'manual',
  status_verificacao varchar(40) not null default 'none',
  duracao_alvo_minutos integer not null default 0,
  prompt_reflexao text,
  resposta_reflexao text,
  verificacao_iniciada_em timestamp with time zone,
  concluida_em timestamp with time zone,
  verificada_em timestamp with time zone,
  concluida boolean not null default false,
  indice_ordem integer not null default 0,
  nivel_pre_recompensa integer,
  xp_pre_recompensa integer,
  xp_maximo_pre_recompensa integer,
  pontos_atributo_pre_recompensa integer,
  forca_pre_recompensa integer,
  inteligencia_pre_recompensa integer,
  vitalidade_pre_recompensa integer,
  agilidade_pre_recompensa integer,
  versao_schema integer not null default 1,
  fonte_sincronizacao varchar(80) not null default 'postgres_authoritative',
  criado_em timestamp with time zone not null default current_timestamp,
  atualizado_em timestamp with time zone not null default current_timestamp
);

create index idx_quests_uid_concluida_ordem on quests(uid, concluida, indice_ordem);

create table conclusoes_quest (
  id varchar(180) primary key,
  uid varchar(128) not null references usuarios(uid) on delete cascade,
  quest_id varchar(140) not null references quests(id) on delete cascade,
  titulo varchar(140) not null,
  atributo_recompensa varchar(24) not null,
  xp_recompensa integer not null,
  conta_para_competitivo boolean not null default false,
  concluida_em timestamp with time zone not null,
  fonte_sincronizacao varchar(80) not null default 'postgres_authoritative',
  criado_em timestamp with time zone not null default current_timestamp
);

create index idx_conclusoes_quest_uid_data on conclusoes_quest(uid, concluida_em);
create unique index uq_conclusoes_quest_pessoal on conclusoes_quest(uid, quest_id)
  where conta_para_competitivo = false;

create table eventos_xp (
  id varchar(180) primary key,
  uid varchar(128) not null references usuarios(uid) on delete cascade,
  origem varchar(40) not null,
  origem_id varchar(180) not null,
  xp integer not null,
  atributo varchar(24),
  criado_em timestamp with time zone not null default current_timestamp
);

create index idx_eventos_xp_uid_data on eventos_xp(uid, criado_em);

create table resgates_boss_pessoal_semanal (
  id varchar(180) primary key,
  uid varchar(128) not null references usuarios(uid) on delete cascade,
  inicio_semana date not null,
  titulo varchar(120) not null,
  dias_ativos integer not null,
  dias_obrigatorios integer not null,
  xp_recompensa integer not null,
  pontos_atributo_recompensa integer not null,
  resgatado_em timestamp with time zone not null,
  fonte_sincronizacao varchar(80) not null default 'postgres_authoritative',
  criado_em timestamp with time zone not null default current_timestamp,
  unique(uid, inicio_semana)
);

create index idx_resgates_boss_pessoal_uid_semana on resgates_boss_pessoal_semanal(uid, inicio_semana);
