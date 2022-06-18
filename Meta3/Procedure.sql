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
    
    Begin
        Select max(a.cod_registo) into maxRegisto --Vai buscar a última ação das embarcações termina-as e dá update para ficar consistente com o resto da tabela
        From Autorizacoes a;
     
        execute immediate 'alter sequence max_Registo start with '||maxRegisto;
    End;
    
    Begin
        Select max(a.cod_acao) into MAXACAO
        From Acoes a;
        
        execute immediate 'alter sequence max_Acao start with '||MAXACAO;
    End;
    
    FOR PARADAS in embarcacoesParadas
    LOOP
           
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
        (max_Acao.nextval,CODM,max_Registo.nextval,sysdate,NULL,NULL);
        
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

--Create sequence para maxRegisto
Create sequence max_Registo START WITH 1;

--Create sequence para maxAcao
Create sequence max_Acao START WITH 1;

--Procedimento O NUNO

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

--Procedimento O PAULO

Create or Replace Procedure o_PROC_A2020121705(IDADE VARCHAR2) IS

cursor c1 is
    Select cod_operador
    From Operador
    Where Estado != 'DISPONIVEL'
    ORDER BY IDADE DESC;
    
maxCODV viagens.cod_viagem%type;
CODE embarcacoes.cod_embarque%type;
CODEM embarcacoes.cod_embarque%type;
Estado_Viagem viagens.estado%type;
Begin
    
  for CODO in c1
  loop
    CODE := &codigo_embarque;
    
    BEGIN
        Select cod_embarque into CODEM 
        From embarcacoes
        Where cod_embarque = CODE;
    Exception
        When NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20501,'A Embarcação com id ' || CODEM || ' não existe.');       
    END;
    
    Begin
        Estado_Viagem:=verificar_viagem(CODEM);
        
        IF (Estado_Viagem != 'SEM OPERADOR') THEN
            RAISE_APPLICATION_ERROR(-20521,'A Embarcação com id ' || CODEM || ' tem operador.');
        ELSE
            UPDATE EMBARCACOES
            SET COD_OPERADOR = CODO.cod_operador
            Where cod_embarque = CODEM;
        END IF;
    END;
  end loop;

END;
/
