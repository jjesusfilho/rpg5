# in the internal of postgres

# Base relacional em torno de tuplas
# Organizar os dados em torno de sequência ordenada de linhas
# PRÁTICO

## Use the index look (livro bastante famoso)

library(tidyverse)
library(stf)
library(DBI)
library(RPosgres)
library(dbx)

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

# snip

usethis::edit_rstudio_snippets()


conn <-dbConnect(RPostgres::Postgres(),host="localhost",user="user", password="senha",dbname="postgres")



dbExecute(conn, "create database projetos owner user")

dbDisconnect(conn)

conn <-dbConnect(RPostgres::Postgres(),
                 host="localhost",
                 user="user",
                 password="senha",
                 dbname="projetos")

dbExecute(conn, "create schema stf")

dbExecute(conn, "set search_path = stf") # ~setwd()

glimpse(informacoes)

# boa prática: incidente      <chr>

?dbWriteTable() # ~ dbCreateTable + dbxInsert (dbcreate e dbxinsert mais seguras)
dbCreateTable(conn, 'informacoes', informacoes)

dbListTables(conn)

dbGetQuery(conn, 'table informacoes')

dbxInsert(conn, 'informacoes', informacoes)

dbExecute(conn, 'create table teste (col1 text, col2 integer, col3 date)')

dbListTables(conn)

dbGetQuery(conn, 'table teste')

dbExecute(conn, 'drop table teste')

dbRemoveTable(conn, 'teste')

dbCreateTable(conn, 'detalhes', detalhes)
dbxInsert(conn, 'detalhes', detalhes)

dbCreateTable(conn, 'partes', partes)
dbxInsert(conn, 'partes', partes)

dbCreateTable(conn, 'andamentos', andamento)
dbxInsert(conn, 'andamentos', andamento)

dbListTables(conn)

#select

## selecionar todas as colunas

i <- dbGetQuery(conn, 'table informacoes')
rm(i)

i <- dbGetQuery(conn, 'select * from informacoes')

i <- dbGetQuery(conn, 'select incidente, origem, procedencia from informacoes')

id <- dbGetQuery(conn, 'select incidente, origem, sigilo, numero_unico, tipo_parte
                 from informacoes
                 inner join detalhes using(incidente)
                 inner join partes using(incidente)')

id <- dbGetQuery(conn, 'select informacoes.incidente,
            informacoes.origem,
            detalhes.sigilo,
            detalhes.numero_unico,
            partes.tipo_parte
                 from informacoes
                 inner join detalhes using(incidente)
                 inner join partes using(incidente)') #boa prática: qualificar colunas

id <- dbGetQuery(conn,
                 'select inf.incidente,
            inf.origem,
            detalhes.sigilo,
            detalhes.numero_unico,
            partes.tipo_parte
                from informacoes as inf
                inner join detalhes on detalhes.incidente = inf.incidente
                inner join partes on partes.incidente = inf.incidente')

id <- dbGetQuery(conn,
                 'select inf.incidente,
            inf.origem,
            detalhes.sigilo,
            detalhes.numero_unico,
            partes.tipo_parte
                from informacoes as inf
                inner join detalhes on detalhes.incidente = inf.incidente
                inner join partes on partes.incidente = inf.incidente')


id <- dbGetQuery(conn,
                 "select inf.incidente,
            inf.origem,
            detalhes.sigilo,
            detalhes.numero_unico,
            partes.tipo_parte,
            partes.parte
                from informacoes as inf
                inner join detalhes on detalhes.incidente = inf.incidente
                inner join partes on partes.incidente = inf.incidente
                 where inf.incidente = '3810658' --filter
                 and tipo_parte = 'ADV' --filter
                 ")

id <- dbGetQuery(conn,
                 "select inf.incidente,
            inf.origem,
            detalhes.sigilo,
            detalhes.numero_unico,
            partes.tipo_parte,
            partes.parte
                from informacoes as inf
                inner join detalhes on detalhes.incidente = inf.incidente
                inner join partes on partes.incidente = inf.incidente
                 where inf.incidente = '3810658' --filter
                 or tipo_parte = 'ADV' --filter
                 ")


id <- dbGetQuery(conn,
                 "select incidente,
            informacoes.origem,
            detalhes.sigilo,
            detalhes.numero_unico,
            partes.tipo_parte,
            partes.parte
                from informacoes
                inner join detalhes using(incidente)
                inner join partes using(incidente)
                 where incidente = '3810658' --filter
                 and (tipo_parte = 'ADV' or tipo_parte = 'RECTE') --filter
                 ")

dbGetQuery(conn, 'select distinct tipo_parte from partes')

dbGetQuery(conn, 'select count(*)::integer as n, tipo_parte
           from partes
           group by tipo_parte
           order by n desc
           ')
partes <- dbGetQuery(conn, 'table partes')

partes |>
  count(tipo_parte, sort = T)

tbl(conn, 'partes') |>
  count(tipo_parte, sort = T) |>
  collect()

?dbConnect

tbl(conn, 'partes') |> #dplyr -> dbplyr
  count(tipo_parte, sort = T) |>
  show_query()

infodb <- tbl_memdb(conn, 'informacoes')
q <- inner_join(informacoes, detalhes, by = )

?tbl_memdb

