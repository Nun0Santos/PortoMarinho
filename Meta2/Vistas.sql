
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
         to_char(Data_Hora,'DD-MM-YYYY') as "DataChegada", nome as "PortoDestino"
  
  From Zonas, Embarcacoes, Armador, Historico_De_Localizacoes hdl, Portos, Viagens
  Where Embarcacoes.Cod_Armador = Armador.Cod_Armador and
        Zonas.Cod_Zona = hdl.Cod_Zona and
        Portos.Cod_Porto = Viagens.Cod_Porto and
        Embarcacoes.Cod_Embarque = Viagens.Cod_Embarque and
        upper(Embarcacoes.Tipo) = 'PETROLEIRO';
 
--c)
Create View VIEW_C AS 
  Select Zonas.tipo as "Zonas", tipo_mov as "OTTYPE", count(Cod_Embarque) as "Num Embarcações"
  From Zonas, Movimento, Embarcacoes
  Group by Zonas.tipo, tipo_mov
  Order By count(Cod_Embarque) DESC;


--d)
Create View VIEW_D AS
  Select nome_zona as "Porta", nome_embarcacao as "nomeEmbarcação",
         to_char(Data_Hora, 'DD-MM-YYYY') as "DataEntrada",
         hld.velocidade, direcao as "Direção"
  From Zonas, Embarcacoes, Historico_De_Localizacoes hld
  Where Embarcacoes.Cod_Embarque = hld.Cod_Embarque and
        Zonas.Cod_Zona = hld.Cod_Zona and
        upper(nome_zona) = 'ESTREITO'
  Order by 1,4;













  
