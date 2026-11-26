# Econometria - projeto

# acha a pasta onde o script esta salvo e instala os pacotes que faltarem (a base tem que estar na mesma pasta) 
pasta_do_script <- function() {
  arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  if (length(arg) > 0) return(dirname(normalizePath(sub("^--file=", "", arg[1]))))
  ofile <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
  if (!is.null(ofile)) return(dirname(normalizePath(ofile)))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    caminho <- rstudioapi::getSourceEditorContext()$path
    if (nzchar(caminho)) return(dirname(caminho))
  }
  getwd()
}
setwd(pasta_do_script())
if (!file.exists("base_final.csv")) {
  if (interactive()) {
    message("Base nao encontrada. Selecione o arquivo base_final.csv.")
    setwd(dirname(file.choose()))
  } else stop("Coloque base_final.csv na mesma pasta deste script.")
}

if (is.na(getOption("repos")["CRAN"]) || getOption("repos")["CRAN"] == "@CRAN@")
  options(repos = c(CRAN = "https://cloud.r-project.org"))
for (p in c("lmtest", "car", "sf")) {
  if (!requireNamespace(p, quietly = TRUE))
    tryCatch(install.packages(p),
             error = function(e) message("Nao foi possivel instalar o pacote ", p))
}
library(lmtest)
library(car)

dir.create("figuras", showWarnings = FALSE)
dir.create("tabelas", showWarnings = FALSE)


#dados

base <- read.csv("base_final.csv", encoding = "UTF-8", stringsAsFactors = FALSE)
base$regiao <- factor(base$regiao,
                      levels = c("Sudeste", "Norte", "Nordeste", "Sul", "Centro-Oeste"))

stopifnot(nrow(base) == 5565, !anyNA(base))
ncol(base)
sum(base$pop_total)       # 190.755.799 (total do Censo 2010)
sum(base$trel == 100)     # 75 municipios no teto

rob <- function(m) coeftest(m, vcov = hccm(m, type = "hc1"))


#estatisticas descritivas Tabela 1, Tabela 2 e Figura 3

vars <- c("trel", "idhm", "idhm_renda", "idhm_long", "idhm_educ", "log_pop",
          "p_branca", "urb", "p_menor15", "p_65mais", "gini", "pmpob")

desc <- data.frame(
  variavel  = vars,
  n         = sapply(base[vars], length),
  media     = sapply(base[vars], mean),
  variancia = sapply(base[vars], var),
  dp        = sapply(base[vars], sd),
  minimo    = sapply(base[vars], min),
  mediana   = sapply(base[vars], median),
  maximo    = sapply(base[vars], max)
)
print(desc, digits = 4)
write.csv(desc, "tabelas/tab1_descritivas.csv", row.names = FALSE)

vars_cor <- c("trel", "idhm", "idhm_renda", "idhm_long", "idhm_educ", "log_pop",
              "p_branca", "urb", "p_menor15", "p_65mais", "gini", "pmpob")
correl <- cor(base[vars_cor])
print(round(correl, 2))
write.csv(round(correl, 3), "tabelas/correlacao_fig3.csv")

por_regiao <- do.call(rbind, lapply(split(base, base$regiao), function(d) data.frame(
  n = nrow(d), trel_media = mean(d$trel), trel_mediana = median(d$trel),
  trel_dp = sd(d$trel), idhm_media = mean(d$idhm), urb_media = mean(d$urb),
  branca_media = mean(d$p_branca), menor15_media = mean(d$p_menor15),
  mais65_media = mean(d$p_65mais), gini_media = mean(d$gini),
  pobres_media = mean(d$pmpob))))
print(por_regiao, digits = 3)
write.csv(por_regiao, "tabelas/tab2_por_regiao.csv")

quantile(base$trel, c(.01, .05, .10, .25, .50, .75))

#figuras descritivas

cor_ponto <- adjustcolor("#2B4C7E", alpha.f = 0.35)
cor_linha <- "#2B4C7E"
par_base  <- list(mar = c(4.2, 4.2, 1, 1), las = 1, bty = "l", cex.axis = 0.9,
                  family = "serif")

# Fig1: (a) histograma de Trel  (b) Trel x IDHM
options(OutDec = ",")   # virgula decimal nos eixos dos graficos
png("figuras/fig1_distribuicao.png", width = 2400, height = 1000, res = 300)
do.call(par, c(par_base, list(mfrow = c(1, 2))))
hist(base$trel, breaks = seq(45, 100, by = 1), col = "grey75", border = "white",
     main = "", xlab = "Trel (%)", ylab = "Número de municípios", xlim = c(45, 100))
mtext("(a)", side = 3, adj = 0, line = 0, font = 2)
plot(base$idhm, base$trel, pch = 16, cex = 0.35, col = cor_ponto,
     xlab = "IDHM 2010", ylab = "Trel (%)")
abline(lm(trel ~ idhm, data = base), col = cor_linha, lwd = 2)
legend("bottomright", "Reta de MQO", lty = 1, lwd = 2, col = cor_linha,
       bty = "n", cex = 0.8)
mtext("(b)", side = 3, adj = 0, line = 0, font = 2)
dev.off()
options(OutDec = ".")

# Fig2: mapas municipais de Trel e IDHM (quintis)

if (requireNamespace("sf", quietly = TRUE)) {
  arq <- "geojs-100-mun.json"
  if (!file.exists(arq)) download.file(
    "https://raw.githubusercontent.com/tbrugz/geodata-br/master/geojson/geojs-100-mun.json",
    arq, mode = "wb")
  malha <- sf::st_read(arq, quiet = TRUE)
  malha$cod <- as.numeric(malha$id)
  malha <- merge(malha, base[, c("cod", "trel", "idhm")], by = "cod")
  azuis <- c("#EAF0F8", "#C3D3EA", "#8DAED7", "#4F7FB8", "#1F4E8C")
  rotulo_q <- function(x, d) { q <- quantile(x, 0:5 / 5)
    f <- function(v) formatC(v, format = "f", digits = d, decimal.mark = ",")
    paste0(f(q[-6]), " a ", f(q[-1])) }
  png("figuras/fig2_mapas.png", width = 2400, height = 1150, res = 300)
  par(mfrow = c(1, 2), mar = c(0.5, 0.5, 1.2, 0.5), family = "serif")
  for (v in c("trel", "idhm")) {
    k <- cut(malha[[v]], quantile(malha[[v]], 0:5 / 5), include.lowest = TRUE)
    plot(sf::st_geometry(malha), col = azuis[as.integer(k)], border = NA, main = "")
    mtext(ifelse(v == "trel", "(a) Trel (%)", "(b) IDHM"), side = 3, adj = 0,
          line = 0, font = 2, cex = 0.85)
    legend("bottomleft", legend = rotulo_q(malha[[v]], ifelse(v == "trel", 1, 3)),
           fill = azuis, border = NA, bty = "n", cex = 0.6, title = "Quintis")
  }
  dev.off()
} else message("Pacote sf nao instalado: o mapa (Figura 2) nao foi gerado.")

# Fig3: matriz de correlacao 
rotulos_cor <- c("Trel", "IDHM", "IDHM Renda", "IDHM Longevidade", "IDHM Educação",
                 "Log da população", "Brancos (%)", "Urbanização (%)",
                 "Menores de 15 (%)", "65 anos ou mais (%)", "Gini", "Pobres (%)")
k <- length(vars_cor)
paleta <- colorRampPalette(c("#B2182B", "#F7F7F7", "#2B4C7E"))(201)
png("figuras/fig3_correlacao.png", width = 2300, height = 1450, res = 300)
par(mar = c(0.3, 9.2, 2.6, 3.6), family = "serif", xpd = NA)
plot(NA, xlim = c(0.5, k + 0.5), ylim = c(0.5, k + 0.5), axes = FALSE,
     xlab = "", ylab = "", asp = NA)
for (i in 1:k) for (j in 1:i) {           # linha i (de cima para baixo), coluna j
  r <- correl[i, j]; y <- k - i + 1
  rect(j - 0.5, y - 0.5, j + 0.5, y + 0.5,
       col = paleta[round((r + 1) * 100) + 1], border = "white", lwd = 1.5)
  text(j, y, sub("-", "\u2212", formatC(r, format = "f", digits = 2, decimal.mark = ",")),
       cex = 0.82, col = ifelse(abs(r) > 0.6, "white", "black"))
}
text(0.4, k:1, rotulos_cor, adj = 1, cex = 0.95)

text(1:k + 0.15, k:1 + 0.6, rotulos_cor, srt = 45, adj = c(0, 0.5), cex = 0.9)

yl <- seq(k - 4, k, length.out = 101)
for (m in 1:100) rect(k + 0.9, yl[m], k + 1.3, yl[m + 1], border = NA,
                      col = paleta[round((m / 100 * 2 - 1 + 1) * 100)])
text(k + 1.4, c(k - 4, k - 2, k), c("−1", "0", "1"), adj = 0, cex = 0.85)
dev.off()

#Modelos  

m1 <- lm(trel ~ idhm, data = base)
m2 <- lm(trel ~ idhm + regiao, data = base)
m3 <- lm(trel ~ idhm + regiao + log_pop, data = base)
m4 <- lm(trel ~ idhm + regiao + log_pop + p_branca, data = base)
m5 <- lm(trel ~ idhm + regiao + log_pop + p_branca + urb, data = base)
m6 <- lm(trel ~ idhm + regiao + log_pop + p_branca + urb + p_menor15 + p_65mais,
         data = base)
modelos <- list(M1 = m1, M2 = m2, M3 = m3, M4 = m4, M5 = m5, M6 = m6)
lapply(modelos, rob)

# Tab3: todos os coeficientes, EP robusto 
estrela <- function(p) ifelse(p < 0.01, "***", ifelse(p < 0.05, "**", ifelse(p < 0.1, "*", "")))
termos <- unique(unlist(lapply(modelos, function(m) names(coef(m)))))
tab4 <- data.frame(termo = termos)
for (nm in names(modelos)) {
  ct <- rob(modelos[[nm]])
  tab4[[nm]] <- sapply(termos, function(t) if (t %in% rownames(ct))
    sprintf("%.3f%s (%.3f)", ct[t, 1], estrela(ct[t, 4]), ct[t, 2]) else "")
}
tab4 <- rbind(tab4,
  c("R2", sapply(modelos, function(m) sprintf("%.3f", summary(m)$r.squared))),
  c("R2 ajustado", sapply(modelos, function(m) sprintf("%.3f", summary(m)$adj.r.squared))),
  c("N", sapply(modelos, nobs)))
print(tab4)
write.csv(tab4, "tabelas/tab3_modelos.csv", row.names = FALSE)

# IC 95% e magnitudes no M6
ct6 <- rob(m6)
b <- ct6["idhm", 1]; ep <- ct6["idhm", 2]
c(b = b, li = b - qt(.975, df.residual(m6)) * ep, ls = b + qt(.975, df.residual(m6)) * ep)
0.1 * b                         # efeito de +0,1 de IDHM (p.p.)
sd(base$idhm) * b               # efeito de +1 DP de IDHM (p.p.)
sd(base$idhm) * b / sd(base$trel)  # em DP de Trel

# mudanca de sinal: M4 + controle (Tabela 4 A)

f4 <- "trel ~ idhm + regiao + log_pop + p_branca"
decomp <- list(
  "M4"                       = f4,
  "M4 + urbanizacao"         = paste(f4, "+ urb"),
  "M4 + menores de 15"       = paste(f4, "+ p_menor15"),
  "M4 + 65 ou mais"          = paste(f4, "+ p_65mais"),
  "M4 + as duas faixas"      = paste(f4, "+ p_menor15 + p_65mais"),
  "M6 (urb + duas faixas)"   = paste(f4, "+ urb + p_menor15 + p_65mais"))
tab5 <- t(sapply(decomp, function(f) {
  ct <- rob(lm(as.formula(f), data = base)); ct["idhm", c(1, 2, 4)] }))
print(round(tab5, 3))
write.csv(tab5, "tabelas/tab4a_decomposicao.csv")


# desigualdade e pobreza (Tabela 4 B)

cor(base$idhm, base$pmpob); cor(base$idhm_renda, base$pmpob); cor(base$gini, base$pmpob)
m6_gini   <- update(m6, . ~ . + gini)
m6_pobres <- update(m6, . ~ . + pmpob)
m6_gp     <- update(m6, . ~ . + gini + pmpob)
m4_gini   <- update(m4, . ~ . + gini)
ext <- list("M6" = m6, "M6 + Gini" = m6_gini, "M6 + pobreza" = m6_pobres,
            "M6 + Gini e pobreza" = m6_gp)
tab5b <- t(sapply(ext, function(m) rob(m)["idhm", c(1, 2, 4)]))
print(round(tab5b, 3))
write.csv(tab5b, "tabelas/tab4b_gini_pobreza.csv")
lapply(list(m4_gini = m4_gini, m6_gini = m6_gini, m6_pobres = m6_pobres, m6_gp = m6_gp),
       function(m) round(rob(m)[intersect(c("idhm", "gini", "pmpob"),
                                          names(coef(m))), ], 3))
sapply(ext, function(m) summary(m)$r.squared)

linearHypothesis(m6_gp, c("gini = 0", "pmpob = 0"), white.adjust = "hc1")

#diagnosticos do M6 tabela 5

bptest(m6)
bptest(m6, ~ fitted(m6) + I(fitted(m6)^2))

linearHypothesis(m6, c("regiaoNorte = 0", "regiaoNordeste = 0", "regiaoSul = 0",
                       "regiaoCentro-Oeste = 0"), white.adjust = "hc1")

linearHypothesis(m6, c("p_menor15 = 0", "p_65mais = 0"), white.adjust = "hc1")

base$idhm_c <- base$idhm - mean(base$idhm)
m_cub <- update(m6, . ~ . + I(idhm_c^2) + I(idhm_c^3))
linearHypothesis(m_cub, c("I(idhm_c^2) = 0", "I(idhm_c^3) = 0"), white.adjust = "hc1")
rob(m_cub)[c("I(idhm_c^2)", "I(idhm_c^3)"), ]

#VIF
vif_mao <- function(m) {
  X <- model.matrix(m)[, -1, drop = FALSE]
  if (ncol(X) == 1) return(setNames(1, colnames(X)))
  sapply(colnames(X), function(v)
    1 / (1 - summary(lm(X[, v] ~ X[, colnames(X) != v]))$r.squared))
}
vif6 <- vif_mao(m6)
print(round(vif6, 2))
write.csv(data.frame(vif = round(vif6, 2)), "tabelas/vif_m6.csv")
round(sapply(c(modelos, list("M6 + pobreza" = m6_pobres)), function(m) vif_mao(m)["idhm"]), 2)
round(vif_mao(m6_pobres)["pmpob"], 2)

#residuos e valores ajustados fora do intervalo Figura 5
sum(fitted(m6) > 100); max(fitted(m6))
options(OutDec = ",")
png("figuras/fig5_residuos.png", width = 2000, height = 1100, res = 300)
do.call(par, par_base)
plot(fitted(m6), resid(m6), pch = 16, cex = 0.35, col = cor_ponto,
     xlab = "Valores ajustados do M6 (%)", ylab = "Resíduos (p.p.)")
abline(h = 0, col = "grey40", lty = 2)
abline(v = 100, col = "grey40", lty = 3)
dev.off()
options(OutDec = ".")


#especificacoes alternativas e robustez Tabela 6

m7 <- lm(trel ~ idhm_renda + idhm_long + idhm_educ + regiao + log_pop + p_branca +
           urb + p_menor15 + p_65mais, data = base)
rob(m7)
linearHypothesis(m7, c("idhm_renda = idhm_long", "idhm_long = idhm_educ"),
                 white.adjust = "hc1")

m8 <- lm(trel ~ idhm + regiao + log_pop + p_preta + p_parda + p_indigena + urb +
           p_menor15 + p_65mais, data = base)
rob(m8)

m9 <- lm(trel ~ idhm + I(idhm^2) + regiao + log_pop + p_branca + urb + p_menor15 +
           p_65mais, data = base)
ct9 <- rob(m9); ct9
ef_marg <- function(x) ct9["idhm", 1] + 2 * ct9["I(idhm^2)", 1] * x
sapply(c(0.5, mean(base$idhm), 0.8), ef_marg)
c(sum(base$idhm <= 0.5), sum(base$idhm > 0.8))

m10 <- lm(trel ~ idhm * regiao + log_pop + p_branca + urb + p_menor15 + p_65mais,
          data = base)
ct10 <- rob(m10)
linearHypothesis(m10, c("idhm:regiaoNorte = 0", "idhm:regiaoNordeste = 0",
                        "idhm:regiaoSul = 0", "idhm:regiaoCentro-Oeste = 0"),
                 white.adjust = "hc1")


V10 <- hccm(m10, type = "hc1")
incl <- t(sapply(levels(base$regiao), function(r) {
  w <- setNames(rep(0, length(coef(m10))), names(coef(m10)))
  w["idhm"] <- 1
  if (r != "Sudeste") w[paste0("idhm:regiao", r)] <- 1
  c(beta = sum(w * coef(m10)), ep = sqrt(as.numeric(t(w) %*% V10 %*% w))) }))
round(incl, 2)



m6a <- update(m6, data = subset(base, trel < 100))
rob6 <- list("M6 todos" = m6, "Sem Trel=100" = m6a, "Raca desagregada" = m8)
tab6 <- t(sapply(rob6, function(m) {
  ct <- rob(m); c(beta = ct["idhm", 1], ep = ct["idhm", 2], p = ct["idhm", 4],
                  r2 = summary(m)$r.squared, n = nobs(m)) }))
print(round(tab6, 3))
write.csv(tab6, "tabelas/tab6a_robustez.csv")

#heterogeneidade por porte: M6 estimado dentro de cada classe de tamanho da populacao usada pelo IBGE (as classes acima de 100 mil foram unidas)
base$porte <- cut(base$pop_total, c(0, 5e3, 1e4, 2e4, 5e4, 1e5, Inf),
                  labels = c("Até 5 mil", "5 a 10 mil", "10 a 20 mil", "20 a 50 mil",
                             "50 a 100 mil", "Mais de 100 mil"))
f6 <- formula(m6)
tab8 <- do.call(rbind, lapply(levels(base$porte), function(p) {
  d <- subset(base, porte == p); m <- lm(f6, data = d); ct <- rob(m)
  data.frame(porte = p, n = nrow(d), beta = ct["idhm", 1], ep = ct["idhm", 2],
             p = ct["idhm", 4], r2 = summary(m)$r.squared) }))
print(tab8, digits = 3)
write.csv(tab8, "tabelas/tab6b_porte.csv", row.names = FALSE)

m11 <- update(m6, . ~ . + idhm:log_pop)
rob(m11)[c("idhm", "log_pop", "idhm:log_pop"), ]
summary(m11)$r.squared

# Fig 4: coeficiente do IDHM (IC 95%, HC1) (a) por modelo e (b) por porte
coefs <- t(sapply(modelos, function(m) { ct <- rob(m); c(ct["idhm", 1], ct["idhm", 2]) }))
options(OutDec = ",")
png("figuras/fig4_coeficientes.png", width = 2400, height = 1000, res = 300)
do.call(par, par_base); par(mfrow = c(1, 2), mar = c(4.2, 4.6, 1, 0.8))
painel <- function(b, ep, rot, xlab) {
  li <- b - 1.96 * ep; ls <- b + 1.96 * ep; x <- seq_along(b)
  plot(x, b, ylim = range(li, ls, 0), xaxt = "n", pch = 16, cex = 1.1, col = cor_linha,
       xlab = xlab, ylab = expression(hat(beta)[IDHM]))
  axis(1, at = x, labels = rot, cex.axis = 0.75)
  abline(h = 0, col = "grey60", lty = 2)
  arrows(x, li, x, ls, angle = 90, code = 3, length = 0.04, col = cor_linha, lwd = 1.5)
}
painel(coefs[, 1], coefs[, 2], names(modelos), "Modelo")
mtext("(a)", side = 3, adj = 0, line = 0, font = 2)
painel(tab8$beta, tab8$ep, c("≤5", "5-10", "10-20", "20-50", "50-100", ">100"),
       "Porte do município (mil habitantes)")
mtext("(b)", side = 3, adj = 0, line = 0, font = 2)
dev.off()
options(OutDec = ".")



sessionInfo()
