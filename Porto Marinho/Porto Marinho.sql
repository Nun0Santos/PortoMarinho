/*==============================================================*/
/* DBMS name:      ORACLE Version 11g                           */
/* Created on:     31/03/2022 23:41:26                          */
/*==============================================================*/


alter table ACOES
   drop constraint FK_ACOES_REQUERE_AUTORIZA;

alter table AUTORIZACOES
   drop constraint FK_AUTORIZA_PEDE_PEDIDOS_;

alter table EMBARCACOES
   drop constraint FK_EMBARCAC_ESTA_ZONAS;

alter table EMBARCACOES
   drop constraint FK_EMBARCAC_PERTENCE_ARMADOR;

alter table EMBARCACOES
   drop constraint FK_EMBARCAC_POSSUI_OPERADOR;

alter table HISTORICO_DE_LOCALIZACOES
   drop constraint FK_HISTORIC_TEM_EMBARCAC;

alter table INCLUI
   drop constraint FK_INCLUI_INCLUI_MOVIMENT;

alter table INCLUI
   drop constraint FK_INCLUI_INCLUI2_ZONAS;

alter table PEDIDOS_DE_PASSAGEM
   drop constraint FK_PEDIDOS__FAZ_VIAGENS;

alter table VIAGENS
   drop constraint FK_VIAGENS_CHEGA_PORTOS;

alter table VIAGENS
   drop constraint FK_VIAGENS_CONTEM_CHEGADAS;

alter table VIAGENS
   drop constraint FK_VIAGENS_EFETUA_EMBARCAC;

alter table VIAGENS
   drop constraint FK_VIAGENS_PARTE_PORTOS;

drop index REQUERE_FK;

drop table ACOES cascade constraints;

drop table ARMADOR cascade constraints;

drop index PEDE_FK;

drop table AUTORIZACOES cascade constraints;

drop table CHEGADAS cascade constraints;

drop index POSSUI_FK;

drop index ESTA_FK;

drop index PERTENCE_FK;

drop table EMBARCACOES cascade constraints;

drop index TEM_FK;

drop table HISTORICO_DE_LOCALIZACOES cascade constraints;

drop index INCLUI2_FK;

drop index INCLUI_FK;

drop table INCLUI cascade constraints;

drop table MOVIMENTO cascade constraints;

drop table OPERADOR cascade constraints;

drop index FAZ_FK;

drop table PEDIDOS_DE_PASSAGEM cascade constraints;

drop table PORTOS cascade constraints;

drop index CHEGA_FK;

drop index PARTE_FK;

drop index CONTEM_FK;

drop index EFETUA_FK;

drop table VIAGENS cascade constraints;

drop table ZONAS cascade constraints;

/*==============================================================*/
/* Table: ACOES                                                 */
/*==============================================================*/
create table ACOES 
(
   COD_ACAO             NUMBER(8)            not null,
   COD_REGISTO          NUMBER(8)            not null,
   TIPO_ACAO            VARCHAR2(25)         not null,
   DATA_DE_INICIO       DATE                 not null,
   DATA_DE_FIM          DATE,
   DURACAO              DATE,
   constraint PK_ACOES primary key (COD_ACAO)
);

/*==============================================================*/
/* Index: REQUERE_FK                                            */
/*==============================================================*/
create index REQUERE_FK on ACOES (
   COD_REGISTO ASC
);

/*==============================================================*/
/* Table: ARMADOR                                               */
/*==============================================================*/
create table ARMADOR 
(
   COD_ARMADOR          NUMBER(8)            not null,
   PAIS_REGISTO         VARCHAR2(25)         not null,
   constraint PK_ARMADOR primary key (COD_ARMADOR)
);

/*==============================================================*/
/* Table: AUTORIZACOES                                          */
/*==============================================================*/
create table AUTORIZACOES 
(
   COD_REGISTO          NUMBER(8)            not null,
   COD_PASSAGEM         NUMBER(8)            not null,
   DATA_REGISTO         DATE                 not null,
   DATA_EXECUCAO        DATE,
   ESTADO               VARCHAR2(25),
   constraint PK_AUTORIZACOES primary key (COD_REGISTO)
);

/*==============================================================*/
/* Index: PEDE_FK                                               */
/*==============================================================*/
create index PEDE_FK on AUTORIZACOES (
   COD_PASSAGEM ASC
);

/*==============================================================*/
/* Table: CHEGADAS                                              */
/*==============================================================*/
create table CHEGADAS 
(
   COD_CHEGADA          NUMBER(8)            not null,
   DATA_CHEGADA         DATE,
   constraint PK_CHEGADAS primary key (COD_CHEGADA)
);

/*==============================================================*/
/* Table: EMBARCACOES                                           */
/*==============================================================*/
create table EMBARCACOES 
(
   COD_EMBARQUE         NUMBER(8)            not null,
   COD_ARMADOR          NUMBER(8)            not null,
   COD_OPERADOR         NUMBER(8),
   COD_ZONA             NUMBER(8)            not null,
   MATRICULA            VARCHAR2(8)          not null,
   COMPRIMENTO          NUMBER(10)           not null,
   LARGURA              NUMBER(10)           not null,
   TONELAGEM            NUMBER(10)           not null,
   TIPO                 VARCHAR2(25)         not null,
   CATEGORIA            VARCHAR2(25)         not null,
   PROFUN_CALADO        NUMBER(10)           not null,
   CALLSIGN             VARCHAR2(25)         not null,
   PAIS_REGISTO_        VARCHAR2(25)         not null,
   constraint PK_EMBARCACOES primary key (COD_EMBARQUE)
);

/*==============================================================*/
/* Index: PERTENCE_FK                                           */
/*==============================================================*/
create index PERTENCE_FK on EMBARCACOES (
   COD_ARMADOR ASC
);

/*==============================================================*/
/* Index: ESTA_FK                                               */
/*==============================================================*/
create index ESTA_FK on EMBARCACOES (
   COD_ZONA ASC
);

/*==============================================================*/
/* Index: POSSUI_FK                                             */
/*==============================================================*/
create index POSSUI_FK on EMBARCACOES (
   COD_OPERADOR ASC
);

/*==============================================================*/
/* Table: HISTORICO_DE_LOCALIZACOES                             */
/*==============================================================*/
create table HISTORICO_DE_LOCALIZACOES 
(
   COD_HLOCALIZACACAO   NUMBER(8)            not null,
   COD_EMBARQUE         NUMBER(8)            not null,
   COORDENADAS          VARCHAR2(25)         not null,
   INTERVALO            NUMBER(10),
   DISTANCIA            NUMBER(10),
   VELOCIDADE_MED       FLOAT(10),
   DIRECAO              VARCHAR2(25)         not null,
   constraint PK_HISTORICO_DE_LOCALIZACOES primary key (COD_HLOCALIZACACAO)
);

/*==============================================================*/
/* Index: TEM_FK                                                */
/*==============================================================*/
create index TEM_FK on HISTORICO_DE_LOCALIZACOES (
   COD_EMBARQUE ASC
);

/*==============================================================*/
/* Table: INCLUI                                                */
/*==============================================================*/
create table INCLUI 
(
   COD_MOVIMENTO        NUMBER(8)            not null,
   COD_ZONA             NUMBER(8)            not null,
   constraint PK_INCLUI primary key (COD_MOVIMENTO, COD_ZONA)
);

/*==============================================================*/
/* Index: INCLUI_FK                                             */
/*==============================================================*/
create index INCLUI_FK on INCLUI (
   COD_MOVIMENTO ASC
);

/*==============================================================*/
/* Index: INCLUI2_FK                                            */
/*==============================================================*/
create index INCLUI2_FK on INCLUI (
   COD_ZONA ASC
);

/*==============================================================*/
/* Table: MOVIMENTO                                             */
/*==============================================================*/
create table MOVIMENTO 
(
   COD_MOVIMENTO        NUMBER(8)            not null,
   TIPO_MOV             VARCHAR2(25)         not null,
   constraint PK_MOVIMENTO primary key (COD_MOVIMENTO)
);

/*==============================================================*/
/* Table: OPERADOR                                              */
/*==============================================================*/
create table OPERADOR 
(
   COD_OPERADOR         NUMBER(8)            not null,
   NOME                 VARCHAR2(25)         not null,
   IDADE                NUMBER(10)           not null,
   PAIS                 VARCHAR2(25),
   N_CONTRIBUENTE       NUMBER(9)            not null,
   MORADA               VARCHAR2(25)         not null,
   TELEFONE             NUMBER(9),
   constraint PK_OPERADOR primary key (COD_OPERADOR)
);

/*==============================================================*/
/* Table: PEDIDOS_DE_PASSAGEM                                   */
/*==============================================================*/
create table PEDIDOS_DE_PASSAGEM 
(
   COD_PASSAGEM         NUMBER(8)            not null,
   COD_VIAGEM           NUMBER(8)            not null,
   TIPO_ORDEM           VARCHAR2(25)         not null,
   DATA_EMISSAO         DATE                 not null,
   GRAU_URGENCIA        NUMBER(10)           not null,
   constraint PK_PEDIDOS_DE_PASSAGEM primary key (COD_PASSAGEM)
);

/*==============================================================*/
/* Index: FAZ_FK                                                */
/*==============================================================*/
create index FAZ_FK on PEDIDOS_DE_PASSAGEM (
   COD_VIAGEM ASC
);

/*==============================================================*/
/* Table: PORTOS                                                */
/*==============================================================*/
create table PORTOS 
(
   COD_PORTO            NUMBER(8)            not null,
   NOME                 VARCHAR2(25)         not null,
   constraint PK_PORTOS primary key (COD_PORTO)
);

/*==============================================================*/
/* Table: VIAGENS                                               */
/*==============================================================*/
create table VIAGENS 
(
   COD_VIAGEM           NUMBER(8)            not null,
   COD_PORTO            NUMBER(8)            not null,
   POR_COD_PORTO        NUMBER(8)            not null,
   COD_EMBARQUE         NUMBER(8)            not null,
   COD_CHEGADA          NUMBER(8)            not null,
   DATA_PARTIDA         DATE                 not null,
   URGENCIA             NUMBER(10)           not null,
   ESTADO               VARCHAR2(25)         not null,
   QUANT_CONTENTORES    NUMBER(10)           not null,
   QUANT_RECEBEU        NUMBER(10)           not null,
   QUANT_DESCARREGOU    NUMBER(10)           not null,
   DATA_PREVISAO        CHAR(10)             not null,
   constraint PK_VIAGENS primary key (COD_VIAGEM)
);

/*==============================================================*/
/* Index: EFETUA_FK                                             */
/*==============================================================*/
create index EFETUA_FK on VIAGENS (
   COD_EMBARQUE ASC
);

/*==============================================================*/
/* Index: CONTEM_FK                                             */
/*==============================================================*/
create index CONTEM_FK on VIAGENS (
   COD_CHEGADA ASC
);

/*==============================================================*/
/* Index: PARTE_FK                                              */
/*==============================================================*/
create index PARTE_FK on VIAGENS (
   POR_COD_PORTO ASC
);

/*==============================================================*/
/* Index: CHEGA_FK                                              */
/*==============================================================*/
create index CHEGA_FK on VIAGENS (
   COD_PORTO ASC
);

/*==============================================================*/
/* Table: ZONAS                                                 */
/*==============================================================*/
create table ZONAS 
(
   COD_ZONA             NUMBER(8)            not null,
   TIPO                 VARCHAR2(25)         not null,
   TL                   NUMBER(10)           not null,
   BR                   NUMBER(10)           not null,
   QUANT_EMBARQUE       NUMBER(10)           not null,
   VELOCIDADE           FLOAT(10),
   TEMPO_ESTIMADO       FLOAT(10),
   constraint PK_ZONAS primary key (COD_ZONA)
);

alter table ACOES
   add constraint FK_ACOES_REQUERE_AUTORIZA foreign key (COD_REGISTO)
      references AUTORIZACOES (COD_REGISTO);

alter table AUTORIZACOES
   add constraint FK_AUTORIZA_PEDE_PEDIDOS_ foreign key (COD_PASSAGEM)
      references PEDIDOS_DE_PASSAGEM (COD_PASSAGEM);

alter table EMBARCACOES
   add constraint FK_EMBARCAC_ESTA_ZONAS foreign key (COD_ZONA)
      references ZONAS (COD_ZONA);

alter table EMBARCACOES
   add constraint FK_EMBARCAC_PERTENCE_ARMADOR foreign key (COD_ARMADOR)
      references ARMADOR (COD_ARMADOR);

alter table EMBARCACOES
   add constraint FK_EMBARCAC_POSSUI_OPERADOR foreign key (COD_OPERADOR)
      references OPERADOR (COD_OPERADOR);

alter table HISTORICO_DE_LOCALIZACOES
   add constraint FK_HISTORIC_TEM_EMBARCAC foreign key (COD_EMBARQUE)
      references EMBARCACOES (COD_EMBARQUE);

alter table INCLUI
   add constraint FK_INCLUI_INCLUI_MOVIMENT foreign key (COD_MOVIMENTO)
      references MOVIMENTO (COD_MOVIMENTO);

alter table INCLUI
   add constraint FK_INCLUI_INCLUI2_ZONAS foreign key (COD_ZONA)
      references ZONAS (COD_ZONA);

alter table PEDIDOS_DE_PASSAGEM
   add constraint FK_PEDIDOS__FAZ_VIAGENS foreign key (COD_VIAGEM)
      references VIAGENS (COD_VIAGEM);

alter table VIAGENS
   add constraint FK_VIAGENS_CHEGA_PORTOS foreign key (COD_PORTO)
      references PORTOS (COD_PORTO);

alter table VIAGENS
   add constraint FK_VIAGENS_CONTEM_CHEGADAS foreign key (COD_CHEGADA)
      references CHEGADAS (COD_CHEGADA);

alter table VIAGENS
   add constraint FK_VIAGENS_EFETUA_EMBARCAC foreign key (COD_EMBARQUE)
      references EMBARCACOES (COD_EMBARQUE);

alter table VIAGENS
   add constraint FK_VIAGENS_PARTE_PORTOS foreign key (POR_COD_PORTO)
      references PORTOS (COD_PORTO);

