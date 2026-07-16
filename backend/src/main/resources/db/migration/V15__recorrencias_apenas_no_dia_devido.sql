-- As ocorrencias recorrentes sao criadas no dia em que se tornam disponiveis.
-- Remove apenas copias futuras automaticas e ainda pendentes da antiga janela de 30 dias.
delete from quests
where recorrencia_id is not null
  and concluida = false
  and ocorrencia_em > current_date;
