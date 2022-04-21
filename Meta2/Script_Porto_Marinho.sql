/*==============================================================*/
/* DBMS name:      ORACLE Version 11g                           */
/* Created on:     21/04/2022 01:13:09                          */
/*==============================================================*/


alter table ACOES
   drop constraint FK_ACOES_HA_MOVIMENT;

alter table ACOES
   drop constraint FK_ACOES_REQUER_AUTORIZA;

alter table AUTORIZACOES
   drop constraint FK_AUTORIZA_CONSULTA_MOVIMENT;

alter table AUTORIZACOES
   drop constraint FK_AUTORIZA_PEDE_PEDIDOS_;

alter table CHEGADAS
   drop constraint FK_CHEGADAS_CONTEM_VIAGENS;

alter table EMBARCACOES
   drop constraint FK_EMBARCAC_ESTA_ZONAS;

alter table EMBARCACOES
   drop constraint FK_EMBARCAC_PERTENCE_ARMADOR;

alter table EMBARCACOES
   drop constraint FK_EMBARCAC_POSSUI_OPERADOR;

alter table HISTORICO_DE_LOCALIZACOES
   drop constraint FK_HISTORIC_DETEM_ZONAS;

alter table HISTORICO_DE_LOCALIZACOES
   drop constraint FK_HISTORIC_TEM_EMBARCAC;

alter table INCLUI
   drop constraint FK_INCLUI_INCLUI_MOVIMENT;

alter table INCLUI
   drop constraint FK_INCLUI_INCLUI2_ZONAS;

alter table PEDIDOS_DE_PASSAGEM
   drop constraint FK_PEDIDOS__CORRESPON_MOVIMENT;

alter table PEDIDOS_DE_PASSAGEM
   drop constraint FK_PEDIDOS__FAZ_VIAGENS;

alter table PEDIDOS_DE_PASSAGEM
   drop constraint FK_PEDIDOS__REFERE_ZONAS;

alter table VIAGENS
   drop constraint FK_VIAGENS_CHEGA_PORTOS;

alter table VIAGENS
   drop constraint FK_VIAGENS_EFETUA_EMBARCAC;

alter table VIAGENS
   drop constraint FK_VIAGENS_PARTE_PORTOS;

drop index HA_FK;

drop index REQUER_FK;

drop table ACOES cascade constraints;

drop table ARMADOR cascade constraints;

drop index CONSULTA_FK;

drop index PEDE_FK;

drop table AUTORIZACOES cascade constraints;

drop index CONTEM_FK;

drop table CHEGADAS cascade constraints;

drop index ESTA_FK;

drop index PERTENCE_FK;

drop index POSSUI_FK;

drop table EMBARCACOES cascade constraints;

drop index DETEM_FK;

drop index TEM_FK;

drop table HISTORICO_DE_LOCALIZACOES cascade constraints;

drop index INCLUI2_FK;

drop index INCLUI_FK;

drop table INCLUI cascade constraints;

drop table MOVIMENTO cascade constraints;

drop table OPERADOR cascade constraints;

drop index CORRESPONDE_FK;

drop index REFERE_FK;

drop index FAZ_FK;

drop table PEDIDOS_DE_PASSAGEM cascade constraints;

drop table PORTOS cascade constraints;

drop index CHEGA_FK;

drop index PARTE_FK;

drop index EFETUA_FK;

drop table VIAGENS cascade constraints;

drop table ZONAS cascade constraints;

/*==============================================================*/
/* Table: ACOES                                                 */
/*==============================================================*/
create table ACOES 
(
   COD_ACAO             NUMBER(8)            not null,
   COD_MOVIMENTO        NUMBER(8)            not null,
   COD_REGISTO          NUMBER(8)            not null,
   DATA_INICIO_ORDEM    DATE                 not null,
   DATA_FIM             DATE,
   DURACAO              DATE,
   constraint PK_ACOES primary key (COD_ACAO)
);

/*==============================================================*/
/* Index: REQUER_FK                                             */
/*==============================================================*/
create index REQUER_FK on ACOES (
   COD_REGISTO ASC
);

/*==============================================================*/
/* Index: HA_FK                                                 */
/*==============================================================*/
create index HA_FK on ACOES (
   COD_MOVIMENTO ASC
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
   COD_MOVIMENTO        NUMBER(8)            not null,
   COD_PASSAGEM         NUMBER(8)            not null,
   DATA_ORDEM           DATE,
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
/* Index: CONSULTA_FK                                           */
/*==============================================================*/
create index CONSULTA_FK on AUTORIZACOES (
   COD_MOVIMENTO ASC
);

/*==============================================================*/
/* Table: CHEGADAS                                              */
/*==============================================================*/
create table CHEGADAS 
(
   COD_CHEGADA          NUMBER(8)            not null,
   COD_VIAGEM           NUMBER(8)            not null,
   DATA_CHEGADA         DATE,
   constraint PK_CHEGADAS primary key (COD_CHEGADA)
);

/*==============================================================*/
/* Index: CONTEM_FK                                             */
/*==============================================================*/
create index CONTEM_FK on CHEGADAS (
   COD_VIAGEM ASC
);

/*==============================================================*/
/* Table: EMBARCACOES                                           */
/*==============================================================*/
create table EMBARCACOES 
(
   COD_EMBARQUE         NUMBER(8)            not null,
   COD_ZONA             NUMBER(8)            not null,
   COD_OPERADOR         NUMBER(8),
   COD_ARMADOR          NUMBER(8)            not null,
   MATRICULA            VARCHAR2(8)          not null,
   COMPRIMENTO          FLOAT(10)            not null,
   LARGURA              FLOAT(10)            not null,
   TONELAGEM            FLOAT(10)            not null,
   TIPO                 VARCHAR2(25)         not null,
   CATEGORIA            VARCHAR2(25)         not null,
   PROFUN_CALADO        FLOAT(10)            not null,
   CALLSIGN             VARCHAR2(25)         not null,
   PAIS_REGISTO         VARCHAR2(25),
   constraint PK_EMBARCACOES primary key (COD_EMBARQUE)
);

/*==============================================================*/
/* Index: POSSUI_FK                                             */
/*==============================================================*/
create index POSSUI_FK on EMBARCACOES (
   COD_OPERADOR ASC
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
/* Table: HISTORICO_DE_LOCALIZACOES                             */
/*==============================================================*/
create table HISTORICO_DE_LOCALIZACOES 
(
   COD_LOCALIZACAO      NUMBER(8)            not null,
   COD_EMBARQUE         NUMBER(8)            not null,
   COD_ZONA             NUMBER(8)            not null,
   LONGITUDE            FLOAT(10)            not null,
   LATITUDE             FLOAT(10)            not null,
   INTERVALO            NUMBER(10),
   VELOCIDADE           FLOAT(10),
   DIRECAO              VARCHAR2(25)         not null,
   DATA_HORA            DATE                 not null,
   constraint PK_HISTORICO_DE_LOCALIZACOES primary key (COD_LOCALIZACAO)
);

/*==============================================================*/
/* Index: TEM_FK                                                */
/*==============================================================*/
create index TEM_FK on HISTORICO_DE_LOCALIZACOES (
   COD_EMBARQUE ASC
);

/*==============================================================*/
/* Index: DETEM_FK                                              */
/*==============================================================*/
create index DETEM_FK on HISTORICO_DE_LOCALIZACOES (
   COD_ZONA ASC
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
   IDADE                NUMBER(3)            not null,
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
   COD_MOVIMENTO        NUMBER(8)            not null,
   COD_VIAGEM           NUMBER(8)            not null,
   COD_ZONA             NUMBER(8)            not null,
   TIPO_ORDEM           VARCHAR2(25)         not null,
   DATA_PEDIDO          DATE                 not null,
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
/* Index: REFERE_FK                                             */
/*==============================================================*/
create index REFERE_FK on PEDIDOS_DE_PASSAGEM (
   COD_ZONA ASC
);

/*==============================================================*/
/* Index: CORRESPONDE_FK                                        */
/*==============================================================*/
create index CORRESPONDE_FK on PEDIDOS_DE_PASSAGEM (
   COD_MOVIMENTO ASC
);

/*==============================================================*/
/* Table: PORTOS                                                */
/*==============================================================*/
create table PORTOS 
(
   COD_PORTO            NUMBER(8)            not null,
   NOME                 VARCHAR2(25)         not null,
   REGIAO               VARCHAR2(25)         not null,
   PAIS                 VARCHAR2(25)         not null,
   PROFUNDIDADE         VARCHAR2(25)         not null,
   TIPO_PORTO           VARCHAR2(25),
   constraint PK_PORTOS primary key (COD_PORTO)
);

/*==============================================================*/
/* Table: VIAGENS                                               */
/*==============================================================*/
create table VIAGENS 
(
   COD_VIAGEM           NUMBER(8)            not null,
   COD_PORTO            NUMBER(8)            not null,
   COD_EMBARQUE         NUMBER(8)            not null,
   POR_COD_PORTO        NUMBER(8)            not null,
   DATA_PARTIDA         DATE                 not null,
   URGENCIA             NUMBER(10)           not null,
   ESTADO               VARCHAR2(25)         not null,
   QUANT_CONTENTORES    NUMBER(10)           not null,
   QUANT_RECEBEU        NUMBER(10)           not null,
   QUANT_DESCARREGOU    NUMBER(10)           not null,
   DATA_PREVISAO        DATE                 not null,
   constraint PK_VIAGENS primary key (COD_VIAGEM)
);

/*==============================================================*/
/* Index: EFETUA_FK                                             */
/*==============================================================*/
create index EFETUA_FK on VIAGENS (
   COD_EMBARQUE ASC
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
   TL_LONG              NUMBER(10)           not null,
   TL_LAT               NUMBER(10)           not null,
   BR_LONG              NUMBER(10)           not null,
   BR_LAT               NUMBER(10)           not null,
   QUANT_EMBARCACOES    NUMBER(10)           not null,
   VELOCIDADE           FLOAT(10),
   TEMPO_ESTIMADO       FLOAT(10),
   constraint PK_ZONAS primary key (COD_ZONA)
);

alter table ACOES
   add constraint FK_ACOES_HA_MOVIMENT foreign key (COD_MOVIMENTO)
      references MOVIMENTO (COD_MOVIMENTO);

alter table ACOES
   add constraint FK_ACOES_REQUER_AUTORIZA foreign key (COD_REGISTO)
      references AUTORIZACOES (COD_REGISTO);

alter table AUTORIZACOES
   add constraint FK_AUTORIZA_CONSULTA_MOVIMENT foreign key (COD_MOVIMENTO)
      references MOVIMENTO (COD_MOVIMENTO);

alter table AUTORIZACOES
   add constraint FK_AUTORIZA_PEDE_PEDIDOS_ foreign key (COD_PASSAGEM)
      references PEDIDOS_DE_PASSAGEM (COD_PASSAGEM);

alter table CHEGADAS
   add constraint FK_CHEGADAS_CONTEM_VIAGENS foreign key (COD_VIAGEM)
      references VIAGENS (COD_VIAGEM);

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
   add constraint FK_HISTORIC_DETEM_ZONAS foreign key (COD_ZONA)
      references ZONAS (COD_ZONA);

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
   add constraint FK_PEDIDOS__CORRESPON_MOVIMENT foreign key (COD_MOVIMENTO)
      references MOVIMENTO (COD_MOVIMENTO);

alter table PEDIDOS_DE_PASSAGEM
   add constraint FK_PEDIDOS__FAZ_VIAGENS foreign key (COD_VIAGEM)
      references VIAGENS (COD_VIAGEM);

alter table PEDIDOS_DE_PASSAGEM
   add constraint FK_PEDIDOS__REFERE_ZONAS foreign key (COD_ZONA)
      references ZONAS (COD_ZONA);

alter table VIAGENS
   add constraint FK_VIAGENS_CHEGA_PORTOS foreign key (COD_PORTO)
      references PORTOS (COD_PORTO);

alter table VIAGENS
   add constraint FK_VIAGENS_EFETUA_EMBARCAC foreign key (COD_EMBARQUE)
      references EMBARCACOES (COD_EMBARQUE);

alter table VIAGENS
   add constraint FK_VIAGENS_PARTE_PORTOS foreign key (POR_COD_PORTO)
      references PORTOS (COD_PORTO);

