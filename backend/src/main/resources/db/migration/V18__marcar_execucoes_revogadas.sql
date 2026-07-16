alter table execucoes_atividades
  add column revogada_em timestamp with time zone;

create index idx_execucoes_atividades_progresso
  on execucoes_atividades(uid, activity_id, registrada_em desc)
  where revogada_em is null;
