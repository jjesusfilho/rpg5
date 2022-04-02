library(stf)
library(tidyverse)

sequencia <- seq(3810647, length.out = 200)

stf_download_information(sequencia, dir = "data-raw/informacoes")

informacoes <- read_stf_information(path = "data-raw/informacoes")

informacoes <- informacoes |>
     drop_na(assunto1)

stf_download_details(informacoes$incidente, dir = "data-raw/detalhes")

detalhes <- read_stf_details(path = "data-raw/detalhes")

stf_download_parties(detalhes$incidente, "data-raw/partes")

partes <- stf_read_parties(path = "data-raw/partes")

stf_download_sheet(detalhes$incidente, "data-raw/andamento")

andamento <- read_stf_docket_sheet(path = "data-raw/andamento")

