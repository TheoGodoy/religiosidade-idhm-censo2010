# Religiosidade e desenvolvimento socioeconômico nos municípios brasileiros

Código e dados do artigo *Religiosidade e desenvolvimento socioeconômico nos municípios brasileiros: evidências do Censo Demográfico 2010*, trabalho final de Econometria I (FGV EESP, 2026).

**Autores:** Caio Benetti do Amaral Maciel e Theodoro da Fonseca Pereira Tavares de Godoy

## Conteúdo

| Arquivo | Descrição |
|---|---|
| `analise.R` | Script que gera todas as tabelas e figuras do artigo |
| `base_final_v5.csv` | Base de dados: corte transversal dos 5.565 municípios brasileiros em 2010 (5.565 linhas e 28 colunas) |

## Como rodar

1. Coloque `analise.R` e `base_final_v5.csv` na mesma pasta.
2. Abra o `analise.R` no RStudio e rode o script inteiro (**Source**), ou rode pelo terminal com `Rscript analise.R`.
3. O script define a pasta de trabalho como a pasta onde ele está salvo. Se não encontrar a base, pede para selecionar o arquivo.
4. Os pacotes que faltarem são instalados automaticamente.

**Pacotes:** `lmtest` e `car` (estimação e testes com erros-padrão robustos HC1) e `sf` (mapas da Figura 2). Versão do R usada: 4.5.1.

**Internet:** a Figura 2 usa a malha municipal do repositório [geodata-br](https://github.com/tbrugz/geodata-br), baixada automaticamente na primeira execução (`geojs-100-mun.json`). Se o pacote `sf` não estiver disponível, o script roda normalmente e só a Figura 2 não é gerada. Nazária (PI) não consta dessa malha.

## Saídas

O script cria as pastas `tabelas/` e `figuras/` e salva:

**Tabelas (`tabelas/`)**
- `tab1_descritivas.csv`: estatísticas descritivas (Tabela 1)
- `tab2_por_regiao.csv`: médias por grande região (Tabela 2)
- `correlacao_fig3.csv`: matriz de correlação (Figura 3)
- `tab3_modelos.csv`: modelos aninhados M1 a M6 (Tabela 3)
- `tab4a_decomposicao.csv` e `tab4b_gini_pobreza.csv`: Painéis A e B da Tabela 4
- `tab6a_robustez.csv` e `tab6b_porte.csv`: Painéis A e B da Tabela 6

Os testes de especificação da Tabela 5 (Breusch–Pagan, White, testes F robustos e forma funcional) são impressos no console, assim como os componentes do IDHM, a interação IDHM × região e o termo quadrático da Tabela 6.

**Figuras (`figuras/`)**
- `fig1_distribuicao.png`: distribuição de Trel e relação com o IDHM
- `fig2_mapas.png`: mapas municipais de Trel e IDHM
- `fig3_correlacao.png`: matriz de correlação
- `fig4_coeficientes.png`: coeficiente do IDHM por modelo e por porte
- `fig5_residuos.png`: resíduos contra valores ajustados do M6

## Dados

A base combina:
- **Censo Demográfico 2010** (IBGE), obtido no SIDRA: tabelas 2094 (religião e cor ou raça), 202 (população e urbanização) e 1378 (idade);
- **Atlas do Desenvolvimento Humano no Brasil** (PNUD, IPEA e FJP): IDHM e seus componentes, índice de Gini e indicadores de pobreza.

As tabelas do SIDRA foram unidas pelo código municipal, e o IDHM, por nome do município e UF (25 pareamentos manuais). A população soma 190.755.799, o total do Censo, e a base não tem valores faltantes.

**Variáveis**

| Variável | Descrição |
|---|---|
| `cod`, `municipio`, `uf` | Código IBGE (7 dígitos), nome e unidade da federação |
| `regiao` | Grande região (referência: Sudeste) |
| `sem_relig` | População sem religião |
| `trel` | Taxa de filiação religiosa, 100 × (1 − `sem_relig` / `pop_total`): % da população com alguma religião (variável dependente) |
| `idhm` | Índice de Desenvolvimento Humano Municipal (variável de interesse) |
| `idhm_renda`, `idhm_long`, `idhm_educ` | Componentes do IDHM |
| `rank`, `nome_atlas` | Posição no ranking do IDHM e nome do município no Atlas (usado no pareamento) |
| `pop_total`, `log_pop` | População total e seu logaritmo natural |
| `pop_urb`, `pop_rur`, `urb` | População urbana, população rural e % da população em área urbana |
| `p_branca`, `p_preta`, `p_amarela`, `p_parda`, `p_indigena` | % da população por cor ou raça (`p_branca` é o controle principal; as demais entram na raça desagregada da Tabela 6) |
| `p_menor15`, `p_65mais` | % da população com menos de 15 anos e com 65 anos ou mais (referência: 15 a 64 anos) |
| `gini` | Índice de Gini da renda domiciliar per capita |
| `pmpob` | % de pobres (renda domiciliar per capita de até R$ 140) |
| `pind`, `ppob` | % de extremamente pobres (até R$ 70) e de vulneráveis à pobreza (até R$ 255); estão na base, mas não entram nos modelos |

## Uso de inteligência artificial

Usamos inteligência artificial (Claude) como ferramenta ao longo do trabalho: na montagem e correção do script em R, na junção e conferência das bases, nos gráficos, na revisão do texto e neste README. O tema, a pergunta, as escolhas de modelo e a decisão sobre o que entra no trabalho foram da dupla, e os números do artigo foram conferidos com a saída do R. O relato completo está na seção "Uso de inteligência artificial" do artigo.

**Links das conversas com a IA:**
- Conversa de Theodoro: *[colar o link]*
- Conversa de Caio: *[colar o link]*


