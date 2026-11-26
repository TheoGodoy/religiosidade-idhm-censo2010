# religiosidade-idhm-censo2010
Código e dados para replicação do artigo sobre religiosidade e IDHM nos municípios brasileiros (Censo 2010).
# Religiosidade e desenvolvimento socioeconômico nos municípios brasileiros: evidências do Censo Demográfico 2010

**Autores:** Caio Benetti do Amaral Maciel e Theodoro da Fonseca Pereira Tavares de Godoy  
**Instituição:** Escola de Economia de São Paulo — Fundação Getulio Vargas (FGV EESP), 2026

## Descrição do repositório

Este repositório contém a base de dados tratada e o script em R necessários para reproduzir todas as estatísticas descritivas, tabelas, regressões, diagnósticos econométricos, testes de robustez e figuras do artigo.

## Estrutura dos arquivos

* `analise.R` *(ajustar para o nome exato do arquivo)*: script principal que carrega a base, instala/carrega os pacotes necessários (`lmtest`, `car`, `sf`), cria os diretórios de saída (`tabelas/` e `figuras/`) e gera todos os resultados do artigo.
* `base_final_v5.csv`: base municipal em corte transversal referente ao Censo Demográfico de 2010 (5.565 municípios e 28 variáveis), construída a partir das tabelas 202, 1378 e 2094 do SIDRA/IBGE (2012) e do Atlas do Desenvolvimento Humano no Brasil (PNUD; IPEA; FJP, 2013).
* `tabelas/` *(gerada automaticamente ao rodar o script)*: arquivos `.csv` correspondentes às tabelas descritivas, por região, correlações, modelos aninhados (M1–M6), decomposição e extensões.
* `figuras/` *(gerada automaticamente ao rodar o script)*: arquivos `.png` das figuras apresentadas no trabalho.

## Como reproduzir os resultados

1. Baixe ou clone este repositório mantendo o script `.R` e o arquivo `base_final_v5.csv` na **mesma pasta**.
2. Abra o script no R ou RStudio e execute-o integralmente (`source()`).
3. Caso algum pacote obrigatório (`lmtest`, `car` ou `sf`) não esteja instalado, o próprio script realizará a instalação automaticamente.
4. Para gerar a Figura 2 (mapas municipais), é necessária conexão com a internet na primeira execução para baixar a malha municipal simplificada (`geojs-100-mun.json`), caso o arquivo ainda não esteja na pasta.

## Principais variáveis de `base_final_v5.csv`

* `cod`: código IBGE do município.
* `regiao`: grande região geográfica (`Sudeste`, `Norte`, `Nordeste`, `Sul`, `Centro-Oeste`).
* `trel`: taxa de filiação religiosa (% da população total com alguma religião declarada).
* `idhm`, `idhm_renda`, `idhm_long`, `idhm_educ`: Índice de Desenvolvimento Humano Municipal e seus três subíndices (2010).
* `pop_total` e `log_pop`: população total do município e seu logaritmo natural.
* `p_branca`: proporção da população de cor ou raça branca (%).
* `urb`: taxa de urbanização (%).
* `p_menor15` e `p_65mais`: proporção da população de 0 a 14 anos e de 65 anos ou mais (%).
* `gini` e `pmpob`: índice de Gini da renda domiciliar per capita e proporção de pobres (%).
