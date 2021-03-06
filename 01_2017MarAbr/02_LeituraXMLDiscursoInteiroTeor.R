####################################################
# Carrega o inteiro teor dos discursos a partir
# do s�tio de dados abertos da C�mara dos Deputados
#
# Inteiro teor - discursos plen�rio
# http://www2.camara.leg.br/transparencia/dados-abertos/dados-abertos-legislativo/webservices/sessoesreunioes-2/obterinteiroteordiscursosplenario
####################################################

library(RCurl)
library(stringr)
library(magrittr)
library(XML)

trim <- function (x){
  x <- gsub("\n", "", x)
  str_trim(x)
}

# marca o momento do in�cio do algor�tmo
ptm <- proc.time()
print('In�cio')
print(ptm)

# define a quantidade de linhas a serem descarregadas
# no arquivo para otimiza��o da mem�ria 
gravarLinhas <- 500

# pasta para a grava��o dos arquivos
pasta <- "..\\..\\Dados\\"

for(ano in 2017:2017){

  discurso <- read.csv(paste0(pasta,"discurso_",ano,".csv"), sep=";", colClasses = "character")
  
  # ajusta campos para leitura da URL tirnado espa�os em branco
  names(discurso)[1]      <- "seq"
  discurso$codigoSessao   <- trim(discurso$codigoSessao)
  discurso$numeroQuarto   <- trim(discurso$numeroQuarto)
  discurso$numeroInsercao <- trim(discurso$numeroInsercao)
  discurso$numeroOrador   <- trim(discurso$numeroOrador)
  discurso$sumario        <- trim(discurso$sumario)
  
  inteiroTeor <- NULL
  
  linhas <- nrow(discurso)
  i <- 1

  while(i <= linhas){
    
    # monta o id com base no ano e no sequencial do discurso
    id <- paste0('00000',discurso$seq[i])
    id <- substr(id,str_length(id)-4,str_length(id))
    id <- paste0(ano,id)
    
    if(discurso$sumario[i] != ""){
      
      # monta a URL com base no ano e per�odo
      url <- paste0("http://www.camara.leg.br/SitCamaraWS/SessoesReunioes.asmx/obterInteiroTeorDiscursosPlenario",
                    "?codSessao=",discurso$codigoSessao[i],
                    "&numOrador=",discurso$numeroOrador[i],
                    "&numQuarto=",discurso$numeroQuarto[i],
                    "&numInsercao=",discurso$numeroInsercao[i])
      
      # tenta ler a URL ...
      data <- try(xmlParse(url, isURL=TRUE, asTree = TRUE, useInternalNodes = TRUE), TRUE)
      
      if(typeof(data) == "externalptr"){ # caso tenha conseguido ler o conte�do da URL ...
        
        # converte formato XML para lista do R
        xml_data <- xmlToList(data)
        
        # cria data.frame tempor�rio (df) com os dados lidos e adiciona a inteiroTeor
        df <- data.frame(id,
                         horaInicioDiscurso = trim(xml_data$horaInicioDiscurso),
                         discurso = xml_data$discursoRTFBase64)          
        inteiroTeor <- rbind(inteiroTeor, df)
        
        # informa no console
        print(paste0(ano,' - ',i,':',linhas))
        
      } else { # caso ocorra um erro ...
        
        if(grepl("huge text node",data)) { # verifica se � um texto longo
          
          # insere NA provisoriamente at� a inspe��o visual
          df <- data.frame(id, horaInicioDiscurso = NA, discurso = NA)          
          inteiroTeor <- rbind(inteiroTeor, df)
          
          # cria arquivo com lista dos discursos longos para inspe��o visual
          write.table(x=data.frame(ano, seq=discurso$seq[i], url),
                      sep=";",
                      file="TextoLongo.csv",
                      append=TRUE,
                      row.names=FALSE,
                      col.names=FALSE)
          
        }else {# se for outro erro, de conexao, por exemplo, tenta novamente

          print(paste0('Erro - ',i,':',linhas))
          i <- i - 1
          Sys.sleep(0.5)

        }
      }
    } else{ # caso n�o haja discurso dispon�vel, preenche com NA
      
        df <- data.frame(id, horaInicioDiscurso = NA, discurso = NA)          
        inteiroTeor <- rbind(inteiroTeor, df)      
    }
    
    # otimiza��o de mem�ria
    if(i == gravarLinhas){ # ao atingir a qtde de linhas a serem gravadas ...
      
      # grava as linhas com inteiro teor no arquivo ...
      write.table(x=inteiroTeor, sep=";",
                 file=paste0(pasta, "discurso_",ano,"_dit.csv"),
                 append=TRUE,
                 row.names=FALSE,
                 col.names=FALSE)
      
      # deduz do data.frame discurso as linhas gravadas
      discurso <- discurso[(gravarLinhas+1):linhas,]
      inteiroTeor <- NULL
      
      # recalcula o n�mero de linhas de discurso
      linhas <- nrow(discurso)
      
      # reinicia a contagem
      i <- 0
      
      print("Gravou")
    }
    
    i <- i + 1
  }

  # marca o momento final da execu��o do algor�tmo
  print(proc.time() - ptm)
  ptm <- proc.time()  
  
  # grava o �ltimo bloco de linhas no arquivo
  write.table(x=inteiroTeor, sep=";",
              file=paste0(pasta, "discurso_",ano,"_dit.csv"),
              append=TRUE,
              row.names=FALSE,
              col.names=FALSE)
}

