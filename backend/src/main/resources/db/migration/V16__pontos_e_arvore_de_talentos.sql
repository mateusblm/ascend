create table pontos_talento_usuario (
  uid varchar(128) primary key references usuarios(uid) on delete cascade,
  disponiveis integer not null default 0 check (disponiveis >= 0)
);

create table concessoes_pontos_talento (
  uid varchar(128) not null references usuarios(uid) on delete cascade,
  origem varchar(80) not null,
  referencia varchar(80) not null,
  concedido_em timestamp with time zone not null default current_timestamp,
  primary key (uid, origem, referencia)
);
