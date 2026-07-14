create table jornadas (
  id varchar(36) primary key,
  uid varchar(128) not null references usuarios(uid) on delete cascade,
  titulo varchar(100) not null,
  objetivo varchar(240) not null,
  motivacao varchar(320),
  status varchar(20) not null default 'ativa',
  dados jsonb not null default '{}'::jsonb,
  criada_em timestamp with time zone not null default current_timestamp,
  atualizada_em timestamp with time zone not null default current_timestamp
);

create index idx_jornadas_uid_status on jornadas(uid, status, criada_em desc);
