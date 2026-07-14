alter table capitulos_jornada add column concluido boolean not null default false;
alter table capitulos_jornada add column concluido_em timestamp with time zone;
