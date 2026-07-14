drop table if exists resgates_boss_semanais_legados;

alter table conclusoes_quest
  drop constraint if exists uq_conclusoes_quest_pessoal;

drop index if exists idx_conclusoes_quest_uid_data;

alter table conclusoes_quest
  drop column if exists conta_para_competitivo;

create unique index uq_conclusoes_quest_uid_quest on conclusoes_quest(uid, quest_id);
