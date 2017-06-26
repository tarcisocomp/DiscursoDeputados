
################################################
# Codifica e decodifica RTF
################################################

library(RCurl)
library(stringr)

# decodificacao do formato RTF - Base64 para txt
# https://www.base64decode.org/
decode_rtf <- function(txt) {
  txt %>%
    base64Decode %>%
    str_replace_all("\\\\'e0", "�") %>%
    str_replace_all("\\\\'e1", "�") %>%
    str_replace_all("\\\\'e2", "�") %>%
    str_replace_all("\\\\'e3", "�") %>%
    str_replace_all("\\\\'e9", "�") %>%
    str_replace_all("\\\\'e7", "�") %>%
    str_replace_all("\\\\'ed", "�") %>%
    str_replace_all("\\\\'f3", "�") %>%
    str_replace_all("\\\\'f5", "�") %>%
    str_replace_all("\\\\'f4", "�") %>%
    str_replace_all("\\\\'ea", "�") %>%
    str_replace_all("\\\\'fa", "�") %>%
    str_replace_all("(\\\\[[:alnum:]']+|[\\r\\n]|^\\{|\\}$)", "") %>%
    str_replace_all("\\{\\{[[:alnum:]; ]+\\}\\}", "") %>%
    str_trim
}

encode_rtf <- function(txt) {
  txt %>%
    str_replace_all("�", "\\\\'e0") %>%
    str_replace_all("�", "\\\\'e1") %>%
    str_replace_all("�", "\\\\'e2") %>%
    str_replace_all("�", "\\\\'e3") %>%
    str_replace_all("�", "\\\\'e9") %>%
    str_replace_all("�", "\\\\'e7") %>%
    str_replace_all("�", "\\\\'ed") %>%
    str_replace_all("�", "\\\\'f3") %>%
    str_replace_all("�", "\\\\'f5") %>%
    str_replace_all("�", "\\\\'f4") %>%
    str_replace_all("�", "\\\\'ea") %>%
    str_replace_all("�", "\\\\'fa") %>%
    str_trim %>%
    base64Encode 
}