unit av_malos;

interface
uses mtravio,motor2dv;

procedure pinta_malos(var avio_m:avio_obj;z_mem_or,offset,z_mem_dest:word);
procedure test_malo(var avio_m:avio_obj;var nou_av:byte);
procedure elimina_malo(var plane:avio_obj);
procedure moure_malo(var plane:avio_obj;bo:avio_obj;var bales_malo:t_municio);
procedure inicia_malos(var avio_m:t_avio_malo);
procedure gestiona_mort_avio(var avio:avio_obj;var bales:t_municio;var explosio:t_explosions;var mort:byte);

implementation
{------------------------------------------------------------------------}
procedure pinta_malos(var avio_m:avio_obj;z_mem_or,offset,z_mem_dest:word);
{pinta i mou malos}
begin
    if avio_m.y<200-30 then
    put_sprite(z_mem_or,z_mem_dest,offset,avio_m.maxx,avio_m.maxy,avio_m.x,avio_m.y);
end;

{------------------------------------------------------------------------}
procedure test_malo(var avio_m:avio_obj;var nou_av:byte);
begin
   {Esta en la pantalla?}
    if (avio_m.y>200) or (avio_m.x>300) or (avio_m.x<0) then
    begin
       elimina_malo(avio_m);
       nou_av:=1
    end
    else nou_av:=0;
end;

{------------------------------------------------------------------------}
procedure elimina_malo(var plane:avio_obj);
{coloca al malo en un altra posicio}
begin
     plane.x:=random(7)*42;
     plane.y:=0;
end;

{------------------------------------------------------------------------}
procedure moure_malo(var plane:avio_obj;bo:avio_obj;var bales_malo:t_municio);
var sentit:integer;
begin
    if plane.x>bo.x then plane.x:=plane.x-1 else plane.x:=plane.x+1;
    plane.x:=plane.x;
    plane.y:=plane.y+2;
    if (plane.x>=bo.x) and (plane.x<bo.x+42) then dispara(bales_malo,plane);
end;

{------------------------------------------------------------------------}
procedure inicia_malos(var avio_m:t_avio_malo);
{inicialitza el vector dels malos}
var cont:byte;
begin
    crea_avio_m(avio_m.vect_avio[cont],0,0,41,42);
end;

{------------------------------------------------------------------------}
procedure gestiona_mort_avio(var avio:avio_obj;var bales:t_municio;var explosio:t_explosions;var mort:byte);
var cont:byte;
begin
   mort:=0;
   for cont:=1 to max_bales do
   if bales.bales[cont].activa=1 then
    if
     test_colisio(bales.bales[cont].x,bales.bales[cont].y,2,2,avio.x,
     avio.y,avio.maxx,avio.maxy) then
     begin
      explosio.n_explosio:=(explosio.n_explosio mod max_explosions)+1;
      explosio.cadena_expl[explosio.n_explosio].x:=avio.x;
      explosio.cadena_expl[explosio.n_explosio].y:=avio.y;
      explosio.cadena_expl[explosio.n_explosio].time:=temps_explosio;
      explosio.cadena_expl[explosio.n_explosio].activa:=1;
      elimina_bala(bales.bales[cont]);
      elimina_malo(avio);
      mort:=1;
     end;
end;

end.