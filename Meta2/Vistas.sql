
--a)
Create or Replace View VIEW_A AS
  Select e.nome_embarcacao as "Nome_embarcacao", to_char(v.data_partida,'YYYY') as "Ano", count(pdp.cod_passagem) as "Total_contentores", avg(c.data_chegada - v.data_partida) as "Tempo_medio"
  From Embarcacoes e, Viagens v, Pedidos_de_Passagem pdp, Chegadas c
  Where e.COD_EMBARQUE = v.COD_EMBARQUE and v.COD_VIAGEM = c.COD_VIAGEM and v.COD_VIAGEM = pdp.COD_VIAGEM
  Group by e.nome_embarcacao,to_char(v.data_partida,'YYYY')
  Order by 3, 2 Desc;
        
        
--b)
Create or replace View VIEW_B AS
  Select nome_zona as "Porta", nome_embarcacao as "nomeEmbarcação", nome_armador as "Armador", to_char(Data_Hora,'DD-MM-YYYY') as "DataChegada",
  (sysdate - data_pedido) * 24 * 60 as "TempoEspera(min)", p.nome as "PortoDestino"
  From Zonas z, Embarcacoes e, Armador a, Historico_De_Localizacoes hdl, Portos p, Viagens v, PEDIDOS_DE_PASSAGEM pdp
  Where e.cod_armador = a.cod_armador and
        e.cod_embarque = v.cod_embarque and
        e.cod_embarque = hdl.cod_embarque and
        hdl.cod_zona = z.cod_zona and
        v.COD_PORT_PART = p.COD_PORTO and 
        v.cod_viagem = pdp.cod_viagem and
        upper(e.tipo) = 'PETROLEIRO' and 
        upper(p.NOME) like '%OMÃ%' and 
        upper(v.estado) = 'PARADO' and 
        upper(z.nome_zona) like '%PORTA%';
 
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
         to_char(Data_Hora, 'DD-MM-YYYY') as "DataEntrada",(sysdate - data_hora) as " Tempo",
         hld.velocidade, direcao as "Direção"
  From Zonas z, Embarcacoes e, Historico_De_Localizacoes hld
  Where e.cod_zona = z.cod_zona and z.COD_ZONA = hld.COD_ZONA and
        upper(nome_zona) like '%ESTREITO%'
  Order by 1,4;
  
--e)

Create or Replace VIEW VIEW_E as
  Select to_char(v.data_partida,'DD-MM-YYYY') as "Data", e.nome_embarcacao as "nomeEmbarcação", p.nome "Porto de Origem", v.quant_contentores as "numContentoresTranspViagem"
  From Embarcacoes e,Viagens v, Portos p
  Where e.COD_EMBARQUE = v.COD_EMBARQUE and v.COD_PORT_PART = p.COD_PORTO and to_char(v.data_partida,'YYYY') = to_char(sysdate,'YYYY') and 
  Order by 1 DESC;
  
--f)

Create or Replace VIEW VIEW_F as
  Select distinct  pp.nome as "PortoOrigem", pc.nome as "PortoDestino", count(v.cod_viagem) as "NumViagens", count(e.cod_embarque) as "NumEmbarcações", sum(quant_contentores) as "TotalContTransportados"
  From Embarcacoes e, Viagens v, Portos pp, Portos pc
  Where e.COD_EMBARQUE = v.COD_EMBARQUE and v.COD_PORT_PART = pp.COD_PORTO and v.COD_PORT_CHEG =pc.COD_PORTO and
  upper(e.tipo) = 'CARGUEIRO' and e.COMPRIMENTO > 100 and to_char(v.data_partida,'YYYY') = TO_CHAR(sysdate,'YYYY') - 1 and v.QUANT_CONTENTORES > (Select v.quant_contentores + 20
                                                                                                                                                  From Viagens, Embarcacoes
                                                                                                                                                  Where VIAGENS.COD_EMBARQUE = embarcacoes.cod_embarque)                                                                                                                                                 
  Group by pp.nome, pc.nome
  Order by 3 DESC
  FETCH FIRST 10 ROWS only;
  
--g)

Create or Replace VIEW VIEW_G as
  Select to_char(v.data_partida,'MM') as "Mes", count(v.cod_viagem) as "NumViagens", avg(c.data_chegada - v.data_partida) as "TempoMedio", tab.NumViagensANT as "NumViagenMesAntes",
  TempoMedioAnt as "TempoMedioMesAntes", ((avg(c.data_chegada - v.data_partida)) - TempoMedioAnt) as "VariaçãoTempo"
  From Viagens v, Chegadas c, (Select to_char(vi.data_partida,'MM') mesant,count(v.cod_viagem) NumViagensANT, avg(ch.data_chegada - vi.data_partida) TempoMedioAnt
                               From Viagens vi, Chegadas ch
                               Where vi.cod_viagem = ch.cod_viagem
                               Group by to_char(vi.data_partida,'MM'))tab
  Where v.cod_viagem = c.cod_viagem and to_char(v.data_partida,'YYYY') = to_char(sysdate,'YYYY') and tab.mesant = to_char(v.data_partida,'MM') - 1
  Group by to_char(v.data_partida,'MM');













  
