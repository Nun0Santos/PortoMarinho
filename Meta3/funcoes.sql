
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
  Begin
      select Cod_Viagem into idViagem
      From Viagens v,Embarcacoes e
      Where e.Cod_Embarque = v.Cod_Embarque and v.Cod_Embarque = shipId and  v.data_partida = (Select Max(vi.Data_Partida)
                                                                                               From Viagens vi,Embarcacoes em
                                                                                               Where em.Cod_Embarque = vi.Cod_Embarque and vi.Cod_Embarque = shipId)
      Order by 1 ASC;
      
   Exception
      When NO_DATA_FOUND then
          RAISE_APPLICATION_ERROR(-20501,'A Embarcação com id ' || shipId || ' não existe.');
  
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
   
Begin
      select z.Cod_Zona into idZona
      From Embarcacoes e, Zonas z
      Where e.Cod_Zona = z.Cod_Zona and e.cod_embarque = shipid;
     
      return idZona;
      
      Exception
      When NO_DATA_FOUND then
          RAISE_APPLICATION_ERROR(-20501,'A Embarcação com id ' || shipId || ' não existe.');
End;
/
show erros;

  
  