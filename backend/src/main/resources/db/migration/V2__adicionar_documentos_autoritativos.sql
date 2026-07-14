alter table perfis_jogador
  add column dados jsonb not null default '{}'::jsonb;

alter table quests
  add column dados jsonb not null default '{}'::jsonb;

alter table conclusoes_quest
  add column dados jsonb not null default '{}'::jsonb;

alter table resgates_boss_pessoal_semanal
  add column dados jsonb not null default '{}'::jsonb;

create table resgates_boss_semanais_legados (
  id varchar(180) primary key,
  uid varchar(128) not null references usuarios(uid) on delete cascade,
  boss_id varchar(140) not null,
  dados jsonb not null default '{}'::jsonb,
  criado_em timestamp with time zone not null default current_timestamp,
  unique(uid, boss_id)
);

create index idx_resgates_boss_legados_uid on resgates_boss_semanais_legados(uid);
