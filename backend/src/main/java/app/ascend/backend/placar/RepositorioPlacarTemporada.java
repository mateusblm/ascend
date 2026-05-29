package app.ascend.backend.placar;

import java.util.List;

public interface RepositorioPlacarTemporada {

  List<RegistroPlacarTemporada> buscarPorTemporadaEFaixa(String chaveTemporada, String faixaRank);
}
