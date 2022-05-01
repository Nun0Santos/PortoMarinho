
--a)
Create View VIEW_A AS
  Select  Nome_embarcacao, to_char(Data_pedido,'YYYY') as "Ano", 
  count(cod_Passagem) as "N_pedidos", sum(Quant_Contentores) as "Total_contentores",
  Avg(TEMPO_ESTIMADO) as "Tempo_medio"
 
  From Embarcacoes, Viagens, Pedidos_De_Passagem pdp, Zonas
  Where Viagens.Cod_Viagem = pdp.Cod_Viagem and
        Embarcacoes.Cod_Embarque = Viagens.Cod_Embarque and
        Embarcacoes.Cod_Zona = Zonas.Cod_Zona 
        
  Group by  Nome_embarcacao, to_char(Data_pedido,'YYYY')
  Order by 3, 2 DESC;
        
        
--b)
Create or replace View VIEW_B AS
  Select nome_zona as "Porta", nome_embarcacao as "nomeEmbarcação", nome_armador as "Armador",
         to_char(Data_Hora,'DD-MM-YYYY') as "DataChegada",
         (sysdate - data_pedido) * 24 * 60 as "TempoEspera(min)",                                                     
         p.nome as "PortoDestino"
  From Zonas z, Embarcacoes e, Armador a, Historico_De_Localizacoes hdl, Portos p, Viagens v, PEDIDOS_DE_PASSAGEM pdp
  Where e.cod_armador = a.cod_armador and
        e.cod_embarque = v.cod_embarque and
        e.cod_embarque = hdl.cod_embarque and
        hdl.cod_zona = z.cod_zona and
        v.cod_porto = p.cod_porto and 
        v.cod_viagem = pdp.cod_viagem and
        upper(e.tipo) = 'PETROLEIRO' and 
        upper(nome_zona) like '%OMÃ%' and 
        upper(v.estado) = 'PARADO';
 
--c)
Create or Replace View VIEW_C AS 
  Select z.nome_zona as "Zonas", m.tipo_mov as "OTTYPE", count(Cod_Embarque) as "Num Embarcações"
  From Zonas z, Movimento m, Embarcacoes e,Inclui i
  Where e.COD_ZONA = z.COD_ZONA and z.COD_ZONA = i.COD_ZONA and i.COD_MOVIMENTO = m.COD_MOVIMENTO
  Group by z.nome_zona,m.tipo_mov
  Order by 3 DESC;


--d)
Create View VIEW_D AS
  Select z.nome_zona as "Porta", e.nome_embarcacao as "nomeEmbarcação",
         to_char(Data_Hora, 'DD-MM-YYYY') as "DataEntrada",
         hld.velocidade, direcao as "Direção"
  From Zonas z, Embarcacoes e, Historico_De_Localizacoes hld
  Where e.cod_zona = z.cod_zona and z.COD_ZONA = hld.COD_ZONA and
        upper(nome_zona) like '%ESTREITO%'
  Order by 1,4;













  
