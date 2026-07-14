create table recorrencias_quest (
  id varchar(36) primary key,
  uid varchar(128) not null references usuarios(uid) on delete cascade,
  titulo varchar(140) not null,
  atributo_recompensa varchar(24) not null,
  xp_recompensa integer not null,
  jornada_id varchar(36) references jornadas(id) on delete set null,
  dias_semana smallint[] not null,
  ativa boolean not null default true,
  criado_em timestamp with time zone not null default current_timestamp,
  atualizado_em timestamp with time zone not null default current_timestamp
);
create index idx_recorrencias_quest_uid_ativa on recorrencias_quest(uid, ativa);

alter table quests add column recorrencia_id varchar(36) references recorrencias_quest(id) on delete set null;
alter table quests add column ocorrencia_em date;
create unique index uq_ocorrencia_recorrente_por_dia on quests(recorrencia_id, ocorrencia_em)
  where recorrencia_id is not null;
