
--a)
Create or Replace View VIEW_A AS
  Select e.nome_embarcacao as "Nome_embarcacao", to_char(v.data_partida,'YYYY') as "Ano", count(pdp.cod_passagem) as "N_pedidos" , v.quant_contentores as "Total_contentores", avg(c.data_chegada - v.data_partida) as "Tempo_medio"
  From Embarcacoes e, Viagens v, Pedidos_de_Passagem pdp, Chegadas c
  Where e.COD_EMBARQUE = v.COD_EMBARQUE and v.COD_VIAGEM = c.COD_VIAGEM and v.COD_VIAGEM = pdp.COD_VIAGEM and upper(tipo_ordem) like '%PASSAGEM%'
  Group by e.nome_embarcacao, to_char(v.data_partida,'YYYY'), v.quant_contentores
  Order by 3, 2 Desc;
        
        
--b)
Create or replace View VIEW_B AS
  Select nome_zona as "Porta", nome_embarcacao as "nomeEmbarcação", nome_armador as "Armador", min(to_char(Data_Hora,'DD-MM-YYYY')) as "DataChegada",
  (sysdate - data_pedido) * 24 * 60 as "TempoEspera(min)", p.nome as "PortoDestino"
  From Zonas z, Embarcacoes e, Armador a, Historico_De_Localizacoes hdl, Portos p, Viagens v, PEDIDOS_DE_PASSAGEM pdp
  Where e.cod_armador = a.cod_armador and
        e.cod_embarque = v.cod_embarque and
        e.cod_embarque = hdl.cod_embarque and
        hdl.cod_zona = z.cod_zona and
        v.COD_PORT_PART = p.COD_PORTO and 
        <v.cod_viagem = pdp.cod_viagem and
        upper(e.tipo) = 'PETROLEIRO' and 
        upper(p.NOME) like '%OMÃ%' and 
        upper(v.estado) = 'PARADO' and 
        upper(z.nome_zona) like '%PORTA%'
        group by nome_zona, nome_embarcacao, nome_armador,(sysdate - data_pedido) * 24 * 6.0, p.nome ;
        
 
--c)
Create or Replace View VIEW_C AS 
  Select z.nome_zona as "Zonas", m.tipo_mov as "OTTYPE", count(Cod_Embarque) as "Num Embarcações", avg(max(data_ordem) - min(data_ordem)) as "tempoMedio"
  From Zonas z, Movimento m, Embarcacoes e,Inclui i,Pedidos_De_Passagem pdp, Autorizacoes a
  Where e.COD_ZONA = z.COD_ZONA and z.COD_ZONA = i.COD_ZONA and i.COD_MOVIMENTO = m.COD_MOVIMENTO and a.cod_Passagem = pdp.cod_Passagem
  Group by z.nome_zona,m.tipo_mov
  Order by 3 DESC;


--d)
Create or Replace View VIEW_D AS
  Select z.nome_zona as "Porta", e.nome_embarcacao as "nomeEmbarcação",
         min(to_char(Data_Hora, 'DD-MM-YYYY')) as "DataEntrada",(sysdate - data_hora) as " Tempo",
         hld.velocidade as "velocidade", direcao as "Direção"
  From Zonas z, Embarcacoes e, Historico_De_Localizacoes hld
  Where e.cod_zona = z.cod_zona and z.COD_ZONA = hld.COD_ZONA and
        upper(nome_zona) like '%ESTREITO%' 
  Group by z.nome_zona, e.nome_embarcacao, (sysdate - data_hora), hld.velocidade, direcao
  Order by 1,4;
  
--e)

Create or Replace VIEW VIEW_E as
  Select to_char(v.data_partida,'DD-MM-YYYY') as "Data", e.nome_embarcacao as "nomeEmbarcação", p.nome "Porto de Origem", v.quant_contentores as "numContentoresTranspViagem"
  From Embarcacoes e,Viagens v, Portos p, 
  
  (Select em.cod_embarque barco, vi.cod_viagem viagem, a.data_fim data_dock
   From Embarcacoes em, Viagens vi, Acoes a, Movimento m, Autorizacoes au, pedidos_de_passagem pdp
   Where em.cod_embarque= vi.cod_embarque and vi.cod_viagem = pdp.cod_viagem and pdp.cod_passagem = au.cod_passagem and au.cod_registo = a.cod_registo and au.cod_movimento = m.cod_movimento
   and upper(au.estado) = 'ACEITE' and upper(m.tipo_mov) = 'DOCK')tab,
   
   (Select em.cod_embarque barco, vi.cod_viagem viagem, a.data_fim data_undock
   From Embarcacoes em, Viagens vi, Acoes a, Movimento m, Autorizacoes au, pedidos_de_passagem pdp
   Where em.cod_embarque= vi.cod_embarque and vi.cod_viagem = pdp.cod_viagem and pdp.cod_passagem = au.cod_passagem and au.cod_registo = a.cod_registo and au.cod_movimento = m.cod_movimento
   and upper(au.estado) = 'ACEITE' and upper(m.tipo_mov) = 'UNDOCK')tab2
   
  Where e.COD_EMBARQUE = v.COD_EMBARQUE and v.COD_PORT_PART = p.COD_PORTO and to_char(v.data_partida,'YYYY') = to_char(sysdate,'YYYY') and tab.barco = e.cod_embarque and tab.viagem = v.cod_viagem
  and tab2.barco = e.cod_embarque and tab2.viagem = v.cod_viagem and (tab2.data_undock - tab.data_dock) = 
  (Select max(tab2.data_undock - tab.data_dock)
   From 
   
   (Select em.cod_embarque barco, vi.cod_viagem viagem, a.data_fim data_dock
   From Embarcacoes em, Viagens vi, Acoes a, Movimento m, Autorizacoes au, pedidos_de_passagem pdp
   Where em.cod_embarque= vi.cod_embarque and vi.cod_viagem = pdp.cod_viagem and pdp.cod_passagem = au.cod_passagem and au.cod_registo = a.cod_registo and au.cod_movimento = m.cod_movimento
   and upper(au.estado) = 'ACEITE' and upper(m.tipo_mov) = 'DOCK')tab,
   
   (Select em.cod_embarque barco, vi.cod_viagem viagem, a.data_fim data_undock
    From Embarcacoes em, Viagens vi, Acoes a, Movimento m, Autorizacoes au, pedidos_de_passagem pdp
    Where em.cod_embarque= vi.cod_embarque and vi.cod_viagem = pdp.cod_viagem and pdp.cod_passagem = au.cod_passagem and au.cod_registo = a.cod_registo and au.cod_movimento = m.cod_movimento
    and upper(au.estado) = 'ACEITE' and upper(m.tipo_mov) = 'UNDOCK')tab2
    
    Where tab.barco = tab2.barco and tab.viagem = tab2.viagem)
    
     
  Group by to_char(v.data_partida,'DD-MM-YYYY'), e.nome_embarcacao, p.nome, v.quant_contentores
  Order by 1 DESC;
  
--f)

Create or Replace VIEW VIEW_F as
  Select *
  From(
    Select pp.nome as "PortoOrigem", pc.nome as "PortoDestino", count(v.cod_viagem) as "NumViagens", count(e.cod_embarque) as "NumEmbarcações", sum(quant_contentores) as "TotalContTransportados"
    From Embarcacoes e, Viagens v, Portos pp, Portos pc
    Where e.COD_EMBARQUE = v.COD_EMBARQUE and v.COD_PORT_PART = pp.COD_PORTO and v.COD_PORT_CHEG =pc.COD_PORTO and
    upper(e.tipo) = 'CARGUEIRO' and e.COMPRIMENTO > 100 and to_char(v.data_partida,'YYYY') = TO_CHAR(sysdate,'YYYY') - 1 and v.QUANT_CONTENTORES > (Select v.quant_contentores + 20
                                                                                                                                                  From Viagens, Embarcacoes
                                                                                                                                                  Where VIAGENS.COD_EMBARQUE = embarcacoes.cod_embarque)                                                                                                                                                 
  Group by pp.nome, pc.nome
  Order by 3 DESC)
  Where ROWNUM <= 10;
  
--g)

Create or Replace VIEW VIEW_G as
  Select tab.MesAtual as "Mes", tab.Numviagens as "NumViagens", tab.TempoMedio as "TempoMedio", tabant.NumViagensAnt as "NumViagenMesAntes", tabant.TempoMedioAnt as "TempoMedioMesAntes"
  ,(tab.TempoMedio - tabant.TempoMedioAnt) as "VariaçãoTempo"
  From
  
  (Select to_char(v.data_partida,'MM') MesAtual, count(v.cod_viagem) NumViagens, avg(c.data_chegada - v.data_partida) TempoMedio
   From Viagens v, Chegadas c
   Where v.cod_viagem = c.cod_viagem and to_char(v.data_partida,'YYYY') = to_char(sysdate,'YYYY')
   Group by to_char(v.data_partida,'MM'))tab,
   
  (Select to_char(v.data_partida,'MM') MesAtual, count(v.cod_viagem) NumViagensAnt, avg(c.data_chegada - v.data_partida) TempoMedioAnt
   From Viagens v, Chegadas c
   Where v.cod_viagem = c.cod_viagem and to_char(v.data_partida,'MM') = add_months(trunc(v.data_partida,'mm'), -1)
   Group by to_char(v.data_partida,'MM'))tabant
  
  Where tab.MesAtual = tabant.MesAtual
 Order by 6;  

--h)

Create or Replace VIEW VIEW_H as
  Select e.nome_embarcacao as "NomeEmbarcação", min(hdl.data_hora) as "DataEntrada", pc.nome as "PortoOrigem", hdl.velocidade as "Velocidade"
  From Embarcacoes e, Historico_de_Localizacoes hdl, Zonas z, Portos pp, Portos pc, Viagens v, 
  
  (Select em.cod_embarque CODE,count(vi.cod_viagem)
   From Embarcacoes em, Viagens vi                                               
   Where em.cod_embarque = vi.COD_EMBARQUE and vi.data_partida between add_months(trunc(sysdate,'mm'),-1) and last_day(add_months(trunc(sysdate,'mm'),-1))
   Group by em.cod_embarque) tab
   
  Where e.cod_embarque = v.COD_EMBARQUE and v.COD_PORT_PART = pp.COD_PORTO and v.COD_PORT_CHEG = pc.COD_PORTO and e.COD_EMBARQUE = hdl.COD_EMBARQUE and z.COD_ZONA = hdl.COD_ZONA
  and upper(z.tipo) = 'ENTRADA' and upper(pc.nome) like '%MEIO DO CANAL%' and e.COD_EMBARQUE = tab.CODE 
  group by e.nome_embarcacao, pc.nome, hdl.velocidade
  Order by 2;
  
--i)

Create or Replace VIEW VIEW_I as
Select *
From(
  Select e.nome_embarcacao as "Embarcação", tab.NUMVIAGES as "NumViagens", TAB2.Parado as "NumTotalParagens"
  From Embarcacoes e, (Select em.cod_embarque CODE, count(vi.cod_viagem) NUMVIAGES
                       From Embarcacoes em, Viagens vi
                       Where em.cod_embarque = vi.cod_embarque and months_between(sysdate, vi.data_partida) < 120
                       Group by em.cod_embarque) tab, (Select em.cod_embarque CODE, count(*) Parado
                                                       From Embarcacoes em, Viagens vi
                                                        Where em.cod_embarque = vi.cod_embarque and months_between(sysdate, vi.data_partida) < 120 and upper(vi.ESTADO) = 'PARADO'
                                                       Group by em.cod_embarque) tab2
  Where e.cod_embarque = tab.CODE and e.cod_embarque = tab2.CODE)
  Where ROWNUM <= 10;



Create View view_J_A2020121705 as




Create View view_K_A2019110035 as
  Select zonas.tipo as "nomeZona", zonas.velocidade as "velocidaMáxima", max(Quant_Contentores) as "maxContentores" 
  From Embarcacoes e, Zonas z, Historio_de_localizacoes hdl, Viagens v
  Where e.Cod_Zona = z.Cod_Zona and hdl.Cod_Zona = z.Cod_Zona and v.Cod_Embarque = e.Cod_Embarque and  velocidade = (select max(velocidade)
                                                                                                                    From Zonas z,Embarcacoes e
                                                                                                                    Where z.Cod_Zona = e.Cod_Zona);
 Group by  zonas.tipo, Zonas.velocidade;






--Funções

--Nuno:
  --Função que retorna o nome do Operador que está a navegar com determinada embarcação, recebe como parametro o cod_Embarque

--Paulo:


--Procedimento

--Nuno:
  --Um procedimnento que diz se um operador está ou não a nagevar uma embarcação naquele momento

--Paulo:

--Triggers

--Nuno:
  --Atualiza o estado do operador conforme este  está a navegar ou não






  
