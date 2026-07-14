insert into capitulos_jornada (id, jornada_id, titulo, indice_ordem)
select md5(j.id || ':capitulo-inicial'), j.id, 'Primeiro avanço', 0
from jornadas j
where not exists (
  select 1 from capitulos_jornada c where c.jornada_id = j.id
);
