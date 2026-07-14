alter table quests add column jornada_id varchar(36) references jornadas(id) on delete set null;
create index idx_quests_uid_jornada on quests(uid, jornada_id);

create table capitulos_jornada (
  id varchar(36) primary key,
  jornada_id varchar(36) not null references jornadas(id) on delete cascade,
  titulo varchar(120) not null,
  indice_ordem integer not null,
  criado_em timestamp with time zone not null default current_timestamp,
  unique(jornada_id, indice_ordem)
);
