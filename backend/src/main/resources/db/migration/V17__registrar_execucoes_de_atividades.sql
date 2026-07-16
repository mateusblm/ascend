create table execucoes_atividades (
  uid varchar(128) not null references usuarios(uid) on delete cascade,
  id varchar(80) not null,
  quest_id varchar(140) not null,
  activity_id varchar(100) not null,
  execution_type varchar(80) not null,
  schema_version integer not null,
  metricas jsonb not null default '{}'::jsonb,
  metricas_calculadas jsonb not null default '{}'::jsonb,
  observacao text,
  registrada_em timestamp with time zone not null default current_timestamp,
  primary key (uid, id)
);

create index idx_execucoes_atividades_quest on execucoes_atividades(uid, quest_id, registrada_em desc);
