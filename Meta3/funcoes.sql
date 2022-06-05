
--Function A
Create or Replace Function a_distancia_linear(lat1 in number, long1 in number, lat2 in number, long2 in number, Radius in number Default 3963) Return FLOAT IS
  
  DegToRad float := 57.29577951;
  resMetros number;
  resMilhaNautica number;
  
Begin
    resMetros := (NVL(Radius,0) * ACOS((sin(NVL(lat1,0) / DegToRad) * SIN(NVL(lat2,0) / DegToRad)) +
                 (COS(NVL(lat1,0) / DegToRad) * COS(NVL(lat2,0) / DegToRad) *
                  COS(NVL(long2,0) / DegToRad - NVL(long1,0)/ DegToRad))));
    resMilhaNautica := resMetros * 1852; 
    
    return resMilhaNautica;
End;
/
  
  
--Function B
Create or Replace Function b_viagem_atual_da_embarcacao (shipId in number) Return number IS
  
   idViagem Viagens.Cod_Viagem%type;
   dataPartida Viagens.Data_partida%type;
   CODE Embarcacoes.cod_embarque%type;
   
Begin

    Begin
        Select e.cod_embarque into CODE
        From Embarcacoes e
        Where e.cod_embarque = shipid;
        
    Exception
        When NO_DATA_FOUND then
              RAISE_APPLICATION_ERROR(-20501,'A Embarcação com id ' || shipId || ' não existe.');    
    End;
    
    Select Cod_Viagem into idViagem
    From Viagens v,Embarcacoes e
    Where e.Cod_Embarque = v.Cod_Embarque and v.Cod_Embarque = CODE and  v.data_partida = (Select Max(vi.Data_Partida)
                                                                                           From Viagens vi,Embarcacoes em
                                                                                           Where em.Cod_Embarque = vi.Cod_Embarque and vi.Cod_Embarque = CODE);
   
    return idViagem; 
End;
/
show erros;

--Function C
Create or Replace Function c_zona_da_localizacao (lati number, longi in number) Return number IS

   idZona Zonas.Cod_Zona%type;
   
Begin
    select Z.Cod_Zona into idZona
    From Historico_De_localizacoes hdl, Zonas z
    Where hdl.Cod_Zona = z.Cod_Zona and hdl.latitude = lati and hdl.longitude = longi;
     
    return idZona;
End;
/
show erros;

--Function D
Create or Replace Function d_zona_atual_da_embarcacao (shipid in number) Return number IS

idZona Zonas.Cod_Zona%type;
CODE Embarcacoes.cod_embarque%type;
   
Begin

    Begin
        Select e.cod_embarque into CODE
        From Embarcacoes e
        Where e.cod_embarque = shipid;
        
    Exception
        When NO_DATA_FOUND then
              RAISE_APPLICATION_ERROR(-20501,'A Embarcação com id ' || shipId || ' não existe.');    
    End;
    
    Select z.Cod_Zona into idZona
    From Embarcacoes e, Zonas z
    Where e.Cod_Zona = z.Cod_Zona and e.cod_embarque = CODE;
     
    return idZona;
          
End;
/
show erros;

--Function E
Create or Replace Function e_tempo_que_esta_na_zona (shipid number, zoneID number) Return Number IS
    
    CODE Embarcacoes.cod_embarque%type;
    CODZ Zonas.Cod_Zona%type;
    tempo_zona_min Number;
    TIPOZ Zonas.tipo%type;
    
Begin

    Begin
        Select e.cod_embarque into CODE
        From Embarcacoes e
        Where e.cod_embarque = shipid;
        
    Exception
        When NO_DATA_FOUND then
              RAISE_APPLICATION_ERROR(-20501,'A Embarcação com id ' || shipId || ' não existe.');    
    End;
    
    Begin
        Select z.cod_zona,upper(z.tipo) into CODZ,TIPOZ
        From Zonas z
        Where z.cod_zona = zoneID;
        
    Exception
        When NO_DATA_FOUND then
              RAISE_APPLICATION_ERROR(-20502,'A Zona com id ' || zoneID || ' não existe.');    
    End;
    
    If (TIPOZ = 'OUTSIDE') then
        RAISE_APPLICATION_ERROR(-20506,'A Embarcação com id ' || shipId || ' está fora do canal.');
    Else
        Select (sysdate - min(hdl.data_hora)) * 24 * 60 into tempo_zona_min
        From Embarcacoes e, Zonas z, HISTORICO_DE_LOCALIZACOES hdl
        Where e.cod_zona = z.cod_zona and z.cod_zona = hdl.cod_zona and e.cod_embarque = CODE and z.cod_zona = CODZ
        ;
    END IF;
    
    return tempo_zona_min;
End;
/
show erros;

--Function F
Create or Replace Function f_num_embarcacoes_na_zona(zoneID number) Return Number IS
    
     CODZ Zonas.Cod_Zona%type;
     NEmbarcacoes Number;
     TIPOZ Zonas.tipo%type;
     
Begin

    Begin
        Select z.cod_zona,upper(z.tipo) into CODZ, TIPOZ
        From Zonas z
        Where z.cod_zona = zoneID;
    
    Exception
        When NO_DATA_FOUND then
            RAISE_APPLICATION_ERROR(-20502,'A Zona com id ' || zoneID || ' não existe.');
    End;
    
    IF (TIPOZ ='OUTSIDE') then
        RAISE_APPLICATION_ERROR(-20506,'Zona com ' || zoneID || ' está fora do canal.');
    
    ELSE
        Select count(e.cod_embarque) into NEmbarcacoes
        From Embarcacoes e, Zonas z
        Where e.cod_zona = z.cod_zona and z.cod_zona = CODZ;
    
    END IF;
    
    return NEmbarcacoes;
--O que é areas de influência do canal ->TODAS AS EMBARCACOES QUE NÃO ESTÃO EM OUTSIDE OU SEJA SO OS QUE ENTRATAM DENTRO DO CANAL

End;
/
show erros;

--Function G
Create or Replace Function g_proxima_ordem_a_executar (shipId number) Return Number IS
    
    CODE Embarcacoes.cod_embarque%type;
    CODP PEDIDOS_DE_PASSAGEM.cod_passagem%type;
    TIPOZ ZONAS.TIPO%type;
Begin
    
    Begin
        Select e.cod_embarque into CODE
        From Embarcacoes e
        Where e.cod_embarque = shipid;
        
    Exception
        When NO_DATA_FOUND then
              RAISE_APPLICATION_ERROR(-20501,'A Embarcação com id ' || shipId || ' não existe.');    
    End;
    
        Select upper(z.tipo) into TIPOZ
        From Embarcacoes e, Zonas z
        Where e.cod_zona = z.cod_zona and e.cod_embarque = shipid;
        

    IF (TIPOZ = 'OUTSIDE') then
        RAISE_APPLICATION_ERROR(-20506,'A Embarcação com id ' || shipId || ' está fora do canal.');
    ELSE
    
        Begin
            Select pdp.cod_passagem into CODP
            From Embarcacoes e, PEDIDOS_DE_PASSAGEM pdp, Viagens v
            Where e.cod_embarque =v.cod_embarque and v.cod_viagem = pdp.cod_viagem and e.cod_embarque = CODE and 
            pdp.data_pedido = (Select max(pdp.data_pedido)
                               From Embarcacoes e, PEDIDOS_DE_PASSAGEM pdp, Viagens v
                               Where e.cod_embarque =v.cod_embarque and v.cod_viagem = pdp.cod_viagem and e.cod_embarque = CODE);
        Exception
            When NO_DATA_FOUND then
                RAISE_APPLICATION_ERROR(-20511,'A Embarcação com id ' || CODE || ' não tem novas ordens');
        End;
    
    END IF;
    
    return CODP;
End;
/
show erros;

--Procedure H
Create or Replace Procedure h_emite_ordem(shipId NUMBER, orderType NUMBER, execDate DATE) IS
    CODE Embarcacoes.cod_embarque%type;
    CODT movimento.cod_movimento%type;
    CODZ zonas.cod_zona%type;
Begin
    
    Begin
        Select e.cod_embarque, e.cod_zona into CODE,CODZ
        From Embarcacoes e
        Where e.cod_embarque = shipid;
        
    Exception
        When NO_DATA_FOUND then
              RAISE_APPLICATION_ERROR(-20501,'A Embarcação com id ' || shipId || ' não existe.');    
    End;
    
    Begin
        Select m.cod_movimento into CODT
        From Movimento m
        Where m.cod_movimento = orderType;
        
    Exception
        When NO_DATA_FOUND then
              RAISE_APPLICATION_ERROR(-20508,'O movimento com código' || orderType || ' não existe.');    
    End;
    
     Begin
        Select i.cod_movimento into CODT
        From Movimento m,Inclui i
        Where i.cod_movimento = m.cod_movimento and m.cod_movimento = orderType and i.cod_zona = CODZ;
        
    Exception
        When NO_DATA_FOUND then
              RAISE_APPLICATION_ERROR(-20512,'O movimento com código' || orderType || ' é inválido para a Zona ' || CODZ || '.');    
    End;
End;
/
show erros;
--orderType Number? é o Cod_Movimento  associado ao tipo de ordem
--codigo associado ao tipo de ordem , para navega etc

Create or Replace Procedure i_updateGPS(shipID number, latitude number, longitude number) IS
    CODE Embarcacoes.cod_embarque%type;
    CODZ zonas.cod_zona%type;
    MAXCODL HISTORICO_DE_LOCALIZACOES.cod_localizacao%type;
Begin

    Begin
        Select e.cod_embarque,e.cod_zona into CODE,CODZ
        From Embarcacoes e
        Where e.cod_embarque = shipid;
        
    Exception
        When NO_DATA_FOUND then
              RAISE_APPLICATION_ERROR(-20501,'A Embarcação com id ' || shipId || ' não existe.');    
    End;
    
    Select max(hdl.cod_localizacao) into MAXCODL
    From HISTORICO_DE_LOCALIZACOES hdl;
        
    Insert into HISTORICO_DE_LOCALIZACOES Values
    (MAXCODL + 1,CODE,CODZ,longitude,latitude,NULL,NULL,'?',sysdate);
    
    
--perguntar ao prodessor se é preciso criar outro código hdl para registar a que está atualmente    
End;
/
show erros;

--Procedure J
Create or Replace Procedure j_cria_viagem_regresso(shipId number) IS
 CODE Embarcacoes.cod_embarque%type;
 DOCK NUMBER;
 CODV viagens.cod_viagem%type;
 MAXCODV NUMBER;
 CODPARTIDA viagens.cod_port_part%type;
 CODCHEGADA viagens.cod_port_part%type;
Begin
    Begin
        Select e.cod_embarque into CODE
        From Embarcacoes e
        Where e.cod_embarque = shipid;
        
    Exception
        When NO_DATA_FOUND then
              RAISE_APPLICATION_ERROR(-20501,'A Embarcação com id ' || shipId || ' não existe.');    
    End;
    
    Select count(*), v.cod_viagem, v.cod_port_part,v.cod_port_cheg into DOCK, CODV, CODPARTIDA, CODCHEGADA
    From embarcacoes e, viagens v, Zonas z, Portos p
    Where e.cod_embarque = v.cod_embarque and e.cod_zona = z.cod_zona and e.cod_embarque = CODE and upper(v.estado) = 'DOCK' 
    and upper(z.tipo) = 'PORTO' and
    v.data_partida = (Select max(v.data_partida)
                      From Embarcacoes e, Viagens v
                      Where e.cod_embarque = v.cod_embarque and e.cod_embarque = CODE) 
    Group by v.cod_viagem, v.cod_port_part, v.cod_port_cheg;
    
    If DOCK = 0 then
        RAISE_APPLICATION_ERROR(-20515,'A Embarcação com id ' || shipId || ' não está DOCKED num porto.');
    Else
        Select max(cod_viagem) into MAXCODV
        From viagens v;
        
        INSERT INTO VIAGENS VALUES(MAXCODV + 1,CODPARTIDA,CODE,CODCHEGADA,sysdate,0,'UNDOCK',0,0,0,sysdate);
    End if;
End;
/
show erros;

--Procedure K
Create or Replace Procedure K_emite_autorizacao_n_ships (zoneId in Number, n in Number) IS

  CODZ Zonas.Cod_Zona%Type;
  tipoZona Zonas.Nome_Zona%Type;
  countEmbarcacoes Zonas.Quant_Embarcacoes%Type;
  
  
  cursor embarcacoesParadas is
    Select e.cod_embarque, (sysdate - pdp.data_pedido), a.cod_registo 
    From Embarcacoes e, Zonas z, Viagens v, PEDIDOS_DE_PASSAGEM pdp, Autorizacoes a
    Where e.cod_zona = z.cod_zona and e.cod_embarque = v.cod_embarque and pdp.cod_viagem = v.cod_viagem and pdp.cod_passagem = a.cod_passagem
    and z.cod_zona = zoneID and upper(v.estado) = 'PARADO' and upper(a.estado) = 'PENDING'
    Group by e.cod_embarque, (sysdate - pdp.data_pedido), a.cod_registo
    Order by 2 DESC;
    
  cursor embarcacoesNavegar is
    Select e.cod_embarque, e.comprimento
    From Embarcacoes e, Zonas z, Viagens v
    Where e.cod_zona = z.cod_zona and z.cod_zona = zoneID and e.cod_embarque = v.cod_embarque
    and upper(v.estado) = 'NAVEGAR'
    Order by 2 DESC;
    
-- No caso das navegações a navegar como dar a autorização se não existe pedido de passagem -> Dar autorização a todas as que estão NA GATE sempre que entrar na zona a embarcacao tem que emitir um pedido esta no enunciados

Begin
  Begin
        Select z.cod_zona into CODZ
        From Zonas z
        Where z.cod_zona = zoneId;
    
    Exception
        When NO_DATA_FOUND then
            RAISE_APPLICATION_ERROR(-20502,'A Zona com id ' || zoneID || ' não existe.');
    End;
    
  
  Begin
      Select upper(z.tipo) into tipoZona
      From Zonas z
      Where z.cod_Zona = CODZ;
      
      if tipoZona <> 'GATE' then 
          RAISE_APPLICATION_ERROR(-20513,'A Zona com id ' || zoneID || ' não é do tipo GATE.');
      End if;
  End;
  
  Begin
    select Quant_Embarcacoes into countEmbarcacoes
    From Embarcacoes e, Zonas z
    Where e.Cod_Zona = z.Cod_Zona and
          z.Cod_Zona = ZoneId;
    
    if countEmbarcacoes = 0 then
      RAISE_APPLICATION_ERROR(-20514,'A Zona com id ' || zoneID || ' não tem embarcações.');
      
    End if;
    
    FOR PARADAS in embarcacoesParadas
    LOOP
      
      UPDATE ACOES
      Set DATA_FIM = sysdate,
          DURACAO = sysdate - data_inicio_ordem
      WHERE cod_registo = PARADAS.cod_registo;
      
      n := n - 1;
      
      EXIT When n < 0;
    END LOOP;
    
    IF (n > 0) then
    
        FOR NAVEGAR in embarcacoesNavegar
        LOOP    
            UPDATE ACOES
            Set DATA_FIM = sysdate,
            DURACAO = sysdate - data_inicio_ordem
            WHERE cod_registo = NAVEGAR.cod_registo;
          
          n := n - 1;
          
          EXIT When n < 0;
        END LOOP;
   
    END IF;
    
    End;  
End;
/
show erros;



ALTER TABLE ACOES
MODIFY DURACAO NUMBER(10);



--ALINEA Q
/*Identificar se o sistema permite por exemplo introduzir uma data de chegada de viagem superior à data de partida etc...

