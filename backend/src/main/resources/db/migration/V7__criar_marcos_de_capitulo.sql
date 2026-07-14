create table marcos_capitulo (
  id varchar(36) primary key,
  capitulo_id varchar(36) not null references capitulos_jornada(id) on delete cascade,
  titulo varchar(140) not null,
  quest_id varchar(140) references quests(id) on delete set null,
  concluido boolean not null default false,
  indice_ordem integer not null,
  criado_em timestamp with time zone not null default current_timestamp,
  unique(capitulo_id, indice_ordem)
);

-- A missao e a fonte autoritativa do estado de um marco vinculado.
create or replace function sincronizar_marcos_de_missao() returns trigger as $$
begin
  if new.concluida is distinct from old.concluida then
    update marcos_capitulo set concluido = new.concluida
    where quest_id = new.id;
  end if;
  return new;
end;
$$ language plpgsql;

create trigger quests_sincronizam_marcos
after update of concluida on quests
for each row execute function sincronizar_marcos_de_missao();
