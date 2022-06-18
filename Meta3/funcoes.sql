
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
            and upper(a.estado) != 'COMPLETO'; --Caso vá buscar a última ordem e esteja completa entra na exceção
        Exception
            When NO_DATA_FOUND then
                RAISE_APPLICATION_ERROR(-20511,'A Embarcação com id ' || CODE || ' não tem novas ordens');
        End;
        
    END IF;
    
    return CODP;
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

--FUNCTION AUXILIAR 5

Create or Replace Function verificar_viagem(CODE NUMBER) RETURN VARCHAR2 IS

tem_viagem viagens.estado%type;

BEGIN
      
      Select upper(v.estado) into tem_viagem
      FROM embarcacoes e, viagens v
      Where v.cod_embarque = e.cod_embarque and e.cod_embarque = CODE;
      
      return tem_viagem;   
END;
/


/* ##################################################################################### */

--Função N Nuno

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

--Função Auxiliar Nuno

Create Or Replace Function chk3_func2_2019110035(codV in Number) return number IS

  codOperador Operador.Cod_operador%type;

Begin
    Select o.Cod_Operador into codOperador    
    From Operador o, Embarcacoes e, Viagens v
    Where v.Cod_Viagem = codV and e.Cod_Operador = o.Cod_Operador and v.Cod_Embarque = e.Cod_Embarque;
    
    return codOperador;
End;
/
show erros;


/* ##################################################################################### */

--Function N do Paulo

Create or Replace Function n_FUNC_A2020121705(CODZONA NUMBER) RETURN NUMBER IS
   
CODZ Zonas.cod_zona%type;
CODP Pedidos_de_Passagem.cod_passagem%type;
Begin

	Begin
        Select z.cod_zona into CODZ
        From Zonas z
        Where cod_zona = CODZONA;
    
    Exception
        When NO_DATA_FOUND THEN
             RAISE_APPLICATION_ERROR(-20502,'A zona com código ' || CODZ || ' não existe.');
    End;
    
     Select pdp.cod_passagem into CODP
     From pedidos_de_passagem pdp
     Where pdp.grau_urgencia = (Select max(pdp.grau_urgencia)
                                From pedidos_de_passagem pdp, Embarcacoes e,Viagens v, Zonas z
                                Where e.cod_embarque = v.cod_embarque and e.cod_zona = z.cod_zona
                                and pdp.cod_viagem = v.cod_viagem and z.cod_zona = CODZONA and upper(v.estado) != 'DOCK');
  
    return CODP;
  
END;
/