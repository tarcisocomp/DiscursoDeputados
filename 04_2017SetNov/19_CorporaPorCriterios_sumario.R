# pacotes
if(!require(stringr)) { install.packages('stringr') }
if(!require(stringi)) { install.packages('stringi') }

source("..\\02_2017MaiJun\\05_EncodeDecode.R")

corpora_sumario <- function(ini, fim, partido){
  print(sprintf("Partido: %s (%d - %d)", partido, ini, fim))
  
  # l� arquivo com todos os discursos do corpora
  pastaorig <- "..\\CorporaRDS\\"
  discursos <- readRDS(paste0(pastaorig, "discurso_2000_2017.rds"))
  names(discursos)[1] <- "seq"
  
  
  ### Verifica frequ�ncia de [sess�es](http://www2.camara.leg.br/comunicacao/assessoria-de-imprensa/sessoes-do-plenario) por tipo e restringe �s sess�es relevantes
  # frequ�ncia por tipo de sessao
  tipo_sessao <- table(discursos$tipoSessao)
  # filtra sess�es relevantes
  tipo_sessao <- as.character(levels(as.factor(discursos$tipoSessao)))
  tipo_sessao <- tipo_sessao[c(3:8, 12, 14:15, 18:19)]
  discursos <- discursos[discursos$tipoSessao %in% tipo_sessao, ]
  print('Tipos de sess�o')
  print(tipo_sessao)
  
  ### L� arquivo de discursos e aplica crit�rios iniciais de filtragem
  pastadest <- "..\\CorpusRDS\\"
  arquivo <- paste0(pastadest, "corpus_", partido, "_", ini, "_", fim, ".rds")
  discursos <- discursos[  str_sub(discursos$dataSessao,7,10) >= ini 
                           & str_sub(discursos$dataSessao,7,10) <= fim 
                           & discursos$partidoOrador == partido
                           , 
                           ]
  print(paste('Dimens�es do arquivo de discurso:', stri_c_list(list(dim(discursos)), sep=" ")))
  

  vdisc <- discursos[ , "sumario"]
  vdisc <- vdisc[vdisc != ""]
  vdisc <- vdisc[!is.na(vdisc)]
    
  saveRDS(vdisc, arquivo)
}

# remove todas as vari�veis, menos os par�metros ini, fim e partido
# rm(list = ls(all = TRUE)[!(ls(all = TRUE) %in% c("ini", "fim", "partido"))])

