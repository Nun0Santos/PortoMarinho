
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
   CODE NUMBER;
   
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
                                                                                           Where em.Cod_Embarque = vi.Cod_Embarque and vi.Cod_Embarque = CODE)
    Order by 1 ASC;
  
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
  
Create or Replace Function d_zona_atual_da_embarcacao (shipid in number) Return number IS

idZona Zonas.Cod_Zona%type;
CODE Number;
   
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

Create Function e_tempo_que_esta_na_zona (shipid number, zoneID number) Return Number IS
    
    CODE NUMBER;
    CODZ NUMBER;
    tempo_zona_min Number;
    
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
        Select z.cod_zona into CODZ
        From Zonas
        Where z.cod_zona = zoneID;
        
    Exception
        When NO_DATA_FOUND then
              RAISE_APPLICATION_ERROR(-20502,'A Zona com id ' || zoneID || ' não existe.');    
    End;
    
    --Se podemos usar o outside, senão como usar as coordenadas de cima
    
    
    Select (sysdate - min(hdl.data_hora)) * 24 * 60 into tempo_zona_min
    From Embarcacoes e, Zonas z, HISTORICO_DE_LOCALIZACOES hdl
    Where e.cod_zona = z.cod_zona and z.cod_zona = hdl.cod_zona and e.cod_embarque = CODE and z.cod_zona = CODZ
    ;
        
    return tempo_zona_min;
End;
/
show erros;

Create Function f_num_embarcacoes_na_zona(zoneID number) Return Number IS
    
     CODZ NUMBER;
     NEmbarcacoes Number;
     
Begin

    Begin
        Select z.cod_zona into CODZ
        From Zonas z
        Where z.cod_zona = zoneID;
    
    Exception
        When NO_DATA_FOUND then
            RAISE_APPLICATION_ERROR(-20502,'A Zona com id ' || zoneID || ' não existe.');
    End;
    
    Select count(e.cod_embarque) into NEmbarcacoes
    From Embarcacoes e, Zonas z
    Where e.cod_zona = z.cod_zona and z.cod_zona = CODZ;
    
    return NEmbarcacoes;
--O que é areas de influência do canal

End;
/
show erros;

Create Function g_proxima_ordem_a_executar (shipId number) Return Number;

Begin

End;
/
show erros;

  
  