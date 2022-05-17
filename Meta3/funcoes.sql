
--Function A
Create or Replace Function a_distancia_linear(lat1 in number, long1 in number, lat2 in number, long2 in number, Radius in number Default 3963) Return number IS
  
  DegToRad number := 57.29577951;
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
      select Max(Data_Partida), Cod_Viagem into dataPartida,idViagem
      From Viagens v,Embarcacoes e
      Where e.shipId = v.Cod_Embarque
      Group by cod_viagem
      Order by 1 ASC;
      
   Exception
      Where NO_DATA_FOUND then
          RAISE_APPLICATION_ERROR(-20501,'A Embarcação com id' + shipId + 'não existe.');
  
      return idViagem;
  End;
  /
  show erros;
  
  
--Function C
Create or Replace Function c_zona_da_localizacao (lati number, longi in number) Return number IS

   idZona Zonas.Cod_Zona%type;
   
  Begin
      select Zonas.Cod_Zona into idZona
      From Historico_De_localizacoes hdl, Zonas z
      Where hdl.Cod_Zona = z.Cod_Zona and hdl.latitude = lati and hdl.longitude = longi;
     
      return idZona;
  End;
  /
  show erros;

  
  