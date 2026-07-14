alter table quests add column arquivada boolean not null default false;
alter table quests add column planejada_para date;
create index idx_quests_uid_ativas_planejadas on quests(uid, arquivada, planejada_para, indice_ordem);

create table retomadas_usuario (
  uid varchar(128) not null references usuarios(uid) on delete cascade,
  chave_periodo date not null,
  escolha varchar(24) not null,
  escolhida_em timestamp with time zone not null default current_timestamp,
  primary key (uid, chave_periodo),
  constraint ck_retomadas_usuario_escolha check (escolha in ('leve', 'manter_plano', 'reorganizar_jornada'))
);
