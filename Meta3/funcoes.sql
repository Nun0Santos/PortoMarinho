
--Function A
Create or Replace Function a_distancia_linear(lat1 in number, long1 in number, lat2 in number, long2 in number, Radius in number Default 3963) Return FLOAT IS

  DegToRad float := 57.29577951;
  
Begin
     return  (NVL(Radius,0) * ACOS((sin(NVL(lat1,0) / DegToRad) * SIN(NVL(lat2,0) / DegToRad)) +
             (COS(NVL(lat1,0) / DegToRad) * COS(NVL(lat2,0) / DegToRad) *
              COS(NVL(long2,0) / DegToRad - NVL(long1,0)/ DegToRad))));
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
    Where e.Cod_Embarque = v.Cod_Embarque and upper(v.estado) != 'DOCK' and  v.Cod_Embarque = CODE and  v.data_partida = (Select Max(vi.Data_Partida)
                                                                                           From Viagens vi,Embarcacoes em
                                                                                           Where em.Cod_Embarque = vi.Cod_Embarque and vi.Cod_Embarque = CODE);
    Exception
        When NO_DATA_FOUND then
              RAISE_APPLICATION_ERROR(-20516,'A Embarcação com id ' || shipId || ' não tem viagem a decorrer.');    
     
    return idViagem; 
End;
/

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
        Where e.cod_zona = z.cod_zona and e.cod_Embarque = hdl.cod_Embarque and e.cod_embarque = CODE and z.cod_zona = CODZ;
    END IF;
    
    return tempo_zona_min;
End;
/

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
        Select Quant_Embarcacoes into NEmbarcacoes
        From Zonas z
        Where  z.cod_zona = zoneID;
    
    END IF;
   
    return NEmbarcacoes;
End;
/

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
            From Embarcacoes e, PEDIDOS_DE_PASSAGEM pdp, Viagens v, Autorizacoes a
            Where e.cod_embarque =v.cod_embarque and v.cod_viagem = pdp.cod_viagem and e.cod_embarque = CODE and  a.Cod_Passagem = pdp.Cod_Passagem and
            pdp.data_pedido = (Select max(pdp.data_pedido) --Buscar o último pedido a embarcação
                               From Embarcacoes e, PEDIDOS_DE_PASSAGEM pdp, Viagens v
                               Where e.cod_embarque =v.cod_embarque and v.cod_viagem = pdp.cod_viagem and e.cod_embarque = CODE)
            and upper(a.estado) != 'COMPLETO'; --Caso vá buscar a última ordem e estja completa entra na exceção
        Exception
            When NO_DATA_FOUND then
                RAISE_APPLICATION_ERROR(-20511,'A Embarcação com id ' || CODE || ' não tem novas ordens');
        End;
        
    END IF;
    
    return CODP;
End;
/

--Procedure H
Create or Replace Procedure h_emite_ordem(shipId NUMBER, orderType NUMBER, execDate DATE) IS
    CODE Embarcacoes.cod_embarque%type;
    CODM movimento.cod_movimento%type;
    CODT inclui.cod_movimento%type;
    CODZ zonas.cod_zona%type;
    CODV viagens.cod_viagem%type;
    MAXCODP pedidos_de_passagem.cod_passagem%type;
    MAXCODA autorizacoes.cod_registo%type;
    MOV movimento.tipo_mov%type;
    URGENCIA NUMBER(10);
    
Begin
    URGENCIA := &grau_de_urgencia; --Para não ser um valor random
    
    Select max(cod_passagem) into MAXCODP
    From pedidos_de_passagem;
    
    Select max(cod_registo) into MAXCODA
    From autorizacoes;
    
    Begin
        Select e.cod_embarque, e.cod_zona into CODE,CODZ
        From Embarcacoes e
        Where e.cod_embarque = shipid;
        
    Exception
        When NO_DATA_FOUND then
              RAISE_APPLICATION_ERROR(-20501,'A Embarcação com id ' || shipId || ' não existe.');    
    End;
    
    Begin
        Select m.cod_movimento into CODM
        From Movimento m
        Where m.cod_movimento = orderType;
        
    Exception
        When NO_DATA_FOUND then
              RAISE_APPLICATION_ERROR(-20508,'O movimento com código' || orderType || ' não existe.');    
    End;
    
     Begin
        Select i.cod_movimento into CODT --Verifica se o movimneto que recebemos é válido naquele tipo de zona
        From Movimento m,Inclui i
        Where i.cod_movimento = m.cod_movimento and m.cod_movimento = orderType and i.cod_zona = CODZ;
        
    Exception
        When NO_DATA_FOUND then
              RAISE_APPLICATION_ERROR(-20512,'O movimento com código' || orderType || ' é inválido para a Zona ' || CODZ || '.');    
    End;
    
    Select v.cod_viagem into CODV --Vai buscar a última viagem da embarcação
    From Viagens v
    Where v.cod_embarque = CODE and data_partida = (Select max(data_partida)
                                                    From Viagens v
                                                    Where v.cod_embarque = CODE);
    MOV := buscar_tipo_mov(CODM); --Função auxiliar para ir buscar o tipo de movimento a partir do código de movimento
    
    INSERT INTO PEDIDOS_DE_PASSAGEM VALUES
    (MAXCODP + 1,CODM,CODV,CODZ,MOV,sysdate,URGENCIA);
    
    INSERT INTO AUTORIZACOES VALUES
    (MAXCODA + 1,CODM,MAXCODP + 1,sysdate,NULL,'PENDING');
    
End;
/
show erros;


--Procedure I
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
    (MAXCODL + 1,CODE,CODZ,longitude,latitude,NULL,NULL,'',sysdate);
    
    UPDATE EMBARCACOES
    Set Latitude = latitude,
    Longitude = longitude
    Where cod_embarque = CODE;
  
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
    
    Select count(*), v.cod_viagem, v.cod_port_part,v.cod_port_cheg into DOCK, CODV, CODPARTIDA, CODCHEGADA --Verificar se a embarcação está DOCKED (atracada) num porto se estiver devolve 1 caso contrário devolve 0
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

--Procedure K
Create or Replace Procedure K_emite_autorizacao_n_ships (zoneId in Number, n in Number) IS

  CODZ Zonas.Cod_Zona%Type;
  tipoZona Zonas.Nome_Zona%Type;
  countEmbarcacoes Zonas.Quant_Embarcacoes%Type;
  maxRegisto Autorizacoes.cod_registo%Type;
  counter Number;
  CODM Movimento.cod_movimento%Type;
  MAXACAO ACOES.cod_acao%Type;
  
  cursor embarcacoesParadas is
    Select e.cod_embarque, (sysdate - pdp.data_pedido), a.cod_registo, v.cod_viagem 
    From Embarcacoes e, Zonas z, Viagens v, PEDIDOS_DE_PASSAGEM pdp, Autorizacoes a
    Where e.cod_zona = z.cod_zona and e.cod_embarque = v.cod_embarque and pdp.cod_viagem = v.cod_viagem and pdp.cod_passagem = a.cod_passagem
    and z.cod_zona = zoneID and upper(v.estado) = 'PARADO' and upper(a.estado) = 'PENDING'
    Order by 2 DESC;
    
  cursor embarcacoesNavegar is
    Select e.cod_embarque, e.comprimento, a.Cod_Registo
    From Embarcacoes e, Zonas z, Viagens v, pedidos_de_Passagem pdp, Autorizacoes a
    Where e.cod_zona = z.cod_zona and z.cod_zona = zoneID and e.cod_embarque = v.cod_embarque and v.Cod_Viagem = pdp.Cod_Viagem and pdp.Cod_Passagem = a.Cod_Passagem
    and upper(v.estado) = 'NAVEGAR'
    Order by 2 DESC;
    
-- No caso das navegações a navegar como dar a autorização se não existe pedido de passagem -> Dar autorização a todas as que estão NA GATE sempre que entrar na zona a embarcacao tem que emitir um pedido esta no enunciados

Begin
counter := n;
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
  
     CODM := buscar_cod_mov('NAVEGAR');
  
  Begin
    select Quant_Embarcacoes into countEmbarcacoes --Conta embarcações de uma determianda zona
    From Embarcacoes e, Zonas z
    Where e.Cod_Zona = z.Cod_Zona and
          z.Cod_Zona = ZoneId;
    
    if countEmbarcacoes = 0 then
      RAISE_APPLICATION_ERROR(-20514,'A Zona com id ' || zoneID || ' não tem embarcações.');
      
    End if;

    FOR PARADAS in embarcacoesParadas
    LOOP
        
        Select max(a.cod_registo) into maxRegisto --Vai buscar a última ação das embarcações termina-as e dá update para ficar consistente com o resto da tabela
        From Autorizacoes a;
        
        Select max(a.cod_acao) into MAXACAO
        From Acoes a;
        
        UPDATE ACOES
        Set DATA_FIM = sysdate,
        DURACAO = sysdate - data_inicio_ordem
        WHERE cod_registo = PARADAS.cod_registo;
        
        UPDATE AUTORIZACOES
        Set Estado = 'ACEITE',
        data_execucao = sysdate
        Where cod_registo = PARADAS.cod_registo;
        
        UPDATE VIAGENS
        SET Estado = 'NAVEGAR'
  
        WHERE cod_viagem = PARADAS.cod_viagem;
        
        INSERT INTO ACOES VALUES
        (MAXACAO + 1,CODM,maxRegisto+1,sysdate,NULL,NULL);
        
        counter := counter - 1;
              
        EXIT When counter < 0;
        
    END LOOP;
    
    IF (counter > 0) then 
    
        FOR NAVEGAR in embarcacoesNavegar
        LOOP
        
           UPDATE AUTORIZACOES
           SET DATA_EXECUCAO = sysdate,
               ESTADO = 'ACEITE'
           Where Cod_Registo = Navegar.Cod_Registo; 
                
           counter := counter - 1;
            
          EXIT When counter < 0;
        END LOOP;   
    END IF;
    
    End;  
End;
/

--TRIGGER l
Create or Replace Trigger l_update_voyage_position 
After UPDATE  OF LATITUDE,LONGITUDE on EMBARCACOES
For each Row
Declare
distancia_nautica FLOAT;
velocidade FLOAT;
dir VARCHAR2(2);
Begin
  distancia_nautica := a_distancia_linear(:new.latitude,:new.longitude,:old.latitude,:old.longitude);
  velocidade := (distancia_nautica * 60) / (5/60); --Para ficar em horas
  dir := obter_direcao(:new.latitude,:new.longitude,:old.latitude,:old.longitude);
  INSERT INTO Historico_de_Localizacoes VALUES
  (obter_cod_localizacao() + 1,:new.cod_embarque,:new.cod_zona,:new.longitude,:new.latitude,5,velocidade,dir,sysdate);
  
End;
/


--Trigger M
Create or Replace Trigger m_update_orderStatus
After Insert on ACOES
For each row

Begin
    
    UPDATE AUTORIZACOES
    Set ESTADO = 'ACEITE',
    DATA_EXECUCAO = sysdate
    Where cod_registo = :new.cod_registo;
    
    UPDATE VIAGENS
    SET ESTADO = buscar_tipo_mov(:new.cod_movimento)
    Where cod_viagem = 
    (Select pdp.cod_viagem
     From PEDIDOS_DE_PASSAGEM pdp,AUTORIZACOES a
     WHERE pdp.cod_passagem = a.cod_passagem and a.cod_registo = :new.cod_registo 
     );

End;
/

--FUNCTION AUXILIAR 1

CREATE or Replace Function buscar_tipo_mov (CODM NUMBER) RETURN VARCHAR2 IS

TIPOMOV movimento.tipo_mov%type;
CODMOV movimento.cod_movimento%type;

BEGIN

    BEGIN
    Select cod_movimento,tipo_mov into CODMOV,TIPOMOV
    From movimento
    Where cod_movimento = CODM;
    
    EXCEPTION 
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20508,'O movimento com código ' || CODMOV || ' não existe.');
    
    END;
    
    return TIPOMOV;
    
    
END;
/

--FUNCTION AUXILIAR 2
Create or Replace Function buscar_cod_mov(tipoMovimento IN VARCHAR2) RETURN NUMBER IS

  CODM  Movimento.Cod_Movimento%type;
  
BEGIN
      Select cod_movimento into CODM 
      From movimento m
      Where upper(tipo_mov) = tipoMovimento;  
      
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
          RAISE_APPLICATION_ERROR(-20517,'O tipo de movimento ' || tipoMovimento || ' não existe.');
          
      return CODM;
END;
/

--FUNCTION AUXILIAR 3
Create or Replace Function obter_direcao(lat1 in number, long1 in number, lat2 in number, long2 in number) RETURN VARCHAR2 IS


BEGIN
      
      IF (lat1 - lat2 > 0 and long1 - long2 = 0) THEN
        return 'N'; 
      ELSIF (lat1 - lat2 < 0 and long1 - long2 = 0) THEN
        return 'S';
      ELSIF (lat1 - lat2 = 0 and long1 - long2 > 0) THEN
        return 'E';
      ELSIF (lat1 - lat2 = 0 and long1 - long2 < 0) THEN
        return 'W';
      ELSIF (lat1 - lat2 > 0 and long1- long2 > 0) THEN
        return 'NE';
      ELSIF (lat1 - lat2 < 0 and long1- long2 < 0) THEN
        return 'SW';
      ELSIF (lat1 - lat2 > 0 and long1- long2 < 0) THEN
        return 'NW';
      ELSIF (lat1 - lat2 < 0 and long1- long2 > 0) THEN
        return 'SE';
      END IF;
          
END;
/

--FUNCTION AUXILIAR 4
Create or Replace Function obter_cod_localizacao RETURN NUMBER IS

CODL HISTORICO_DE_LOCALIZACOES.COD_LOCALIZACAO%type;

BEGIN
      
      Select max(cod_localizacao) into CODL
      FROM Historico_de_Localizacoes hdl;
      
      return CODL;   
END;
/

--ALINEA Q

/*
Tabela ACOES
  - O mecanismo necessário seria verificar se a DATA_INICIO_ORDEM é inferiror à DATA_FIM para garantir a consistência dos dados;
  - DURACAO ser >= 0
  
Tabela ARMADOR
  - Sem mecanismos a implementar

Tabela AUTORIZACOES
  - O mecanismo necessário seria validar se a DATA_ORDEM é inferior à DATA_EXECUCAO;
  
Tabela CHEGADAS
  - O mecanismo necessário seria validar se a DATA_CHEGADA é superior à DATA_PARTIDA da tabela VIAGENS

Tabela EMBARCACOES
  - Comprimento, largura, tonelagem positivos;
  - Matricula no formato correto
  - Consideramos que quando inserimos uma embarcação a mesma está associada a uma zona
  

Tabela HISTORICI_DE_LOCALIZACOES
  - Velocidade, intervalo positiva
  

Tabela INCLUI
  - Sem mecanismos a implementar


Tabela MOVIMENTO
  - Sem mecanismos a implementar


Tabela OPERADOR
  - Sem mecanismos a implementar


Tabela PEDIDOS_DE_PASSAGEM
  - Sem mecanismos a implementar
  

Tabela PORTOS
  - Sem mecanismos a implementar


Tabela VIAGENS
  - QUANT_CONTENTORES, QUANT_RECEBEU, QUANT_DESCARREGOU ser positivo


Tabela ZONAS
  - QUANT_EMARCACOES, VELOCIDADE, TEMPO_ESTIMADO positivos

*/


/* ##################################################################################### */

Create Or Replace Function chk3_func_2019110035(codEmbarque in Number) return Varchar2 IS --Considerando que sempre que existir uma embarcação há um operador
                                                                                          --Dado um codigo de embarcacao diz me se esta está em viagem ou nao e se estiver diz me o nome de operador
  nomeOperador Operador.Nome%type;
  idViagem Viagens.Cod_Viagem%type;
  idEmbarque Embarcacoes.Cod_Embarque%type;
  
Begin
    Begin
      Select Cod_Embarque into idEmbarque
      From Embarcacoes e
      Where e.Cod_Embarque = codEmbarque;
      
      Exception
        When NO_DATA_FOUND then
          RAISE_APPLICATION_ERROR(-20501,'Embarcação com o código ' || CodEmbarque || ' não existe.');
     
    End;
    
    Begin
      Select v.Cod_Viagem into idViagem
      From Viagens v,Embarcacoes e
      Where e.Cod_Embarque = v.Cod_Embarque and upper(v.estado) != 'DOCK' and  v.Cod_Embarque = codEmbarque and  v.data_partida = (Select Max(vi.Data_Partida)
                                                                                                                            From Viagens vi,Embarcacoes em
                                                                                                                            Where em.Cod_Embarque = vi.Cod_Embarque and vi.Cod_Embarque = codEmbarque);
      Exception
        When NO_DATA_FOUND then
             RAISE_APPLICATION_ERROR(-20516,'A Embarcação com id ' || CodEmbarque || ' não tem viagem a decorrer.');    
     
      End;
      
      Begin
        
        Select Nome into nomeOperador
        From Embarcacoes e, Operador o
        Where e.Cod_Embarque = codEmbarque and o.Cod_Operador = e.Cod_Operador; --Não era necessário a tabela das embarcações
        
     End;
     
    return nomeOperador;

End;
/


Create Or Replace Procedure ck3_proc_2019110035(codOperador in Number) IS --Dado um codigo de operador diz me a embarcação em que ele está a drigir naquele momento

  idOperador Operador.Cod_Operador%type;
  codEmbarque Embarcacoes.Cod_Embarque%type;
  
Begin
    Begin
      Select Cod_Operador into idOperador
      From Operador o
      Where o.Cod_Operador = codOperador;
    
      Exception
        When NO_DATA_FOUND then
          RAISE_APPLICATION_ERROR(-20501,'O operador com o código ' || CodOperador || ' não existe.');
    End;
      
      Select e.Cod_Embarque into codEmbarque
      From Embarcacoes e, Viagens v, Operador o
      Where v.Cod_Embarque = e.Cod_Embarque and upper(v.estado) = 'DOCK' and v.data_partida = (Select Max(vi.Data_Partida)
                                                                                                From Viagens vi,Embarcacoes em
                                                                                                Where em.Cod_Embarque = vi.Cod_Embarque);                                                                                               
End;
/

Create Or Replace Trigger P_Trig_A2019110035
  After insert on Chegadas
  For each row
  
  codOperador Operador.Cod_Operador%type;
Begin
    codOperador = chk3_func2_2019110035(Chegadas.Cod_Viagem);
    Update Operador set upper(estado) = 'DISPONIVEL'
    Where operador.Cod_Operador = codOperador;

End;
/
show erros;

--Função Auxiliar Nuno

Create Or Replace Function chk3_func2_2019110035(codViagem in Number) return number IS

  codOperador Operador.Cod_operador%type;

Begin
    Select Cod_Operador into codOperador    
    From Operador o, Embarcacoes e, Viagens v
    Where v.Cod_Viagem = codViagem and e.Cod_Operador = o.Cod_Operador and v.Cod_Embarque = e.Cod_Embarque;
    
    return codOperador;
End;
/
show erros;
