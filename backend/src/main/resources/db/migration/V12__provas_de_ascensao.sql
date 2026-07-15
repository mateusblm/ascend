create table resgates_provas_ascensao (
  uid varchar(128) not null references usuarios(uid) on delete cascade,
  prova_id varchar(120) not null,
  talento_id varchar(120) not null,
  resgatado_em timestamp with time zone not null default current_timestamp,
  dados jsonb not null default '{}'::jsonb,
  primary key (uid, prova_id),
  unique (uid, talento_id)
);

create index idx_resgates_provas_ascensao_uid on resgates_provas_ascensao(uid);
