# Religiosidade e desenvolvimento socioeconômico nos municípios brasileiros

Código e dados do artigo "Religiosidade e desenvolvimento socioeconômico nos municípios brasileiros: evidências do Censo Demográfico 2010", trabalho final de Econometria I (FGV EESP, 2026).

Autores: Caio Benetti do Amaral Maciel e Theodoro da Fonseca Pereira Tavares de Godoy

## Arquivos

- `analise.R`: script que gera as tabelas e figuras do artigo.
- `base_final.csv`: base dos 5.565 municípios brasileiros em 2010 (28 colunas).

## Como rodar

1. Coloque `analise.R` e `base_final.csv` na mesma pasta.
2. Abra o `analise.R` no RStudio e rode o script inteiro (Source).
3. O script usa a pasta onde está salvo. Se não achar a base, pede para você selecionar o arquivo.
4. Os pacotes que faltarem (`lmtest`, `car` e `sf`) são instalados automaticamente. Versão do R usada: 4.5.1.

Figura 2: usa a malha municipal do geodata-br (`geojs-100-mun.json`), baixada na primeira execução, então precisa de internet. Sem o pacote `sf`, o script gera tudo, menos essa figura.

## O que o script gera

As tabelas ficam em `tabelas/` (arquivos `.csv`) e as figuras em `figuras/` (arquivos `.png`), criadas ao rodar o script. Os testes de especificação (Breusch-Pagan, White, testes F robustos e forma funcional) aparecem no console.

## Dados

Censo Demográfico 2010 (IBGE), pelo SIDRA: tabelas 2094 (religião e cor ou raça), 202 (população e urbanização) e 1378 (idade). Atlas do Desenvolvimento Humano no Brasil (PNUD, IPEA e FJP): IDHM e seus componentes, Gini e pobreza.

As tabelas do SIDRA foram unidas pelo código do município, e o IDHM, pelo nome e UF.

Principais variáveis:

- `trel`: taxa de filiação religiosa, 100 × (1 − `sem_relig` / `pop_total`). É a variável dependente.
- `idhm`, `idhm_renda`, `idhm_long`, `idhm_educ`: IDHM e seus componentes.
- `regiao`: grande região (referência: Sudeste).
- `log_pop`: logaritmo da população total.
- `p_branca`, `p_preta`, `p_amarela`, `p_parda`, `p_indigena`: % da população por cor ou raça.
- `urb`: % da população em área urbana.
- `p_menor15`, `p_65mais`: % da população com menos de 15 anos e com 65 anos ou mais.
- `gini`: índice de Gini da renda domiciliar per capita.
- `pmpob`: % de pobres (renda domiciliar per capita de até R$ 140).

## Uso de inteligência artificial

Usamos IA (Claude) como apoio no trabalho, sobretudo no script em R, na junção das bases e na revisão do texto. O relato completo está na seção "Uso de inteligência artificial" do artigo.

Conversas com a IA:
- Theodoro: [colar o link]
- Caio: [colar o link]
