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

--Trigger P NUNO

Create Or Replace Trigger P_Trig_A2019110035
After insert on Chegadas
For each row

Declare 
  codOperador Operador.Cod_Operador%type;
Begin
    codOperador := chk3_func2_2019110035(:new.Cod_Viagem);
    Update Operador 
    set estado = 'DISPONIVEL'
    Where operador.Cod_Operador = codOperador;

End;
/
show erros;

--Trigger P PAULO

Create Or Replace Trigger P_Trig_A2020121705
AFTER UPDATE OF COD_ZONA on EMBARCACOES
For each row

Begin

    UPDATE ZONAS
    SET quant_embarcacoes = quant_embarcacoes + 1
    Where cod_zona = :new.cod_zona;
    
    
    UPDATE ZONAS
    SET quant_embarcacoes = quant_embarcacoes - 1
    Where cod_zona = :old.cod_zona; 

End;
/