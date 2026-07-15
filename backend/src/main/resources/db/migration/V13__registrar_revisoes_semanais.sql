create table revisoes_semanais_usuario (
  uid varchar(128) not null references usuarios(uid) on delete cascade,
  inicio_semana date not null,
  confirmada_em timestamp with time zone not null default current_timestamp,
  primary key (uid, inicio_semana)
);
