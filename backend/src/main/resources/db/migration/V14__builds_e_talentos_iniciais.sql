create table builds_usuario (
  uid varchar(128) primary key references usuarios(uid) on delete cascade,
  build_id varchar(40) not null,
  selecionada_em timestamp with time zone not null default current_timestamp
);

create table talentos_usuario (
  uid varchar(128) not null references usuarios(uid) on delete cascade,
  talento_id varchar(80) not null,
  desbloqueado_em timestamp with time zone not null default current_timestamp,
  primary key (uid, talento_id)
);
