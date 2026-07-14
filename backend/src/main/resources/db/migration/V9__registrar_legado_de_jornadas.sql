create table legado_jornadas (
  id varchar(36) primary key,
  uid varchar(128) not null references usuarios(uid) on delete cascade,
  jornada_id varchar(36) not null references jornadas(id) on delete cascade,
  titulo varchar(100) not null,
  concluida_em timestamp with time zone not null default current_timestamp,
  unique(jornada_id)
);

create index idx_legado_jornadas_uid_data on legado_jornadas(uid, concluida_em desc);
