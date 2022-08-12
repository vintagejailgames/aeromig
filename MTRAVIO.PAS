unit mtravio;

interface
uses keyboard,motor2dv;

const bala1_alt=7;          {dimensio de la bala = 7x5}
      bala1_ample=5;
      off_bala1=40;
      bala2_alt=4;          {dimensio de la bala = 3x4}
      bala2_ample=3;
      off_bala2=45;
      off_bala_malo=48;
      bala_ample_malo=5;
      bala_alt_malo=5;
      avio1_alt=26;     {alt del avio bo = 27}
      avio1_ample=27;   {ample del avio bo = 26}
      off_avio1=0;

      avio2_alt=32;     {alt del avio bo = 32}
      avio2_ample=21;   {ample del avio bo = 21}
      off_avio2=320*53;

      max_bales=30;        {maxim de bales en pantalla}
      max_bales_malos=20;
      max_explosions=30;   {maxim de explosions a la vegada}
      max_avions=2;        {maxim d'avions a la vegada}
      fase1_kills=30;
      fase2_kills=40;
      fase3_kills=50;
      fase4_kills=60;
      fase5_kills=70;
      off_avio_m1=320*26;   {offset del dibuix del avio per a la 1¦ fase}
      ample_m1=26;
      alt_m1=27;
      off_avio_m2=320*26+26;{offset del dibuix del avio per a la 2¦ fase}
      ample_m2=31;
      alt_m2=32;
      off_avio_m3=320*26+57;{offset del dibuix del avio per a la 3¦ fase}
      ample_m3=25;
      alt_m3=30;
      off_avio_m4=54;{offset del dibuix del avio per a la 4¦ fase}
      ample_m4=27;
      alt_m4=26;
      off_avio_m5=81;{offset del dibuix del avio per a la 5¦ fase}
      ample_m5=29;
      alt_m5=34;
      off_boss1=122;
      off_boss2=110{320*84+82};
      off_boss3=320*84+252;
      off_boss4=245;
      off_boss5=320*84+167;
      off_escut=320*84;
      velocitat_fons=320;
      temps_invencible=150;
      temps_explosio=30;
      max_bombes=5;

      {off_misatge1=0;
      ample_misatge1=216;
      alt_misatge1=27;

      off_misatge2=320*29;
      ample_misatge2=142;
      alt_misatge2=12;

      off_misatge3=320*41;
      ample_misatge3=315;
      alt_misatge3=29;

      off_misatge4=320*74;
      ample_misatge4=262;
      alt_misatge4=14;

      off_misatge5=320*89;
      ample_misatge5=300;
      alt_misatge5=12;}

      off_misatge6=320*101;
      ample_misatge6=320;
      alt_misatge6=31;

type
     avio_obj=record       {objecte avio}
         x,y:word;         {coordenades del avio}
         maxx,maxy:word;   {tamany del avio}
         invencible:byte;
         temps_invencible:byte;
         bombes:byte;
         sentit_x,sentit_y:integer;
         velocitat:word;
         power:word;
     end;

     bala_obj=record       {objecte bala}
        x:word;          {coordenades de la bala}
        y:integer;
        activa:byte;       {bala en pantalla?}
     end;

     explosio_obj=record   {objecte explosio}
        x,y,time:word;     {coordenades de l'explosio i temps de durada}
        activa:byte;       {indica si l'explosio esta activa}
     end;

     t_malos=array[1..6] of avio_obj;   {vector per a guardar el malos}
     t_bala=array[1..max_bales] of bala_obj; {vector per a guardar le bales}
     t_explosio=array[1..max_explosions] of explosio_obj; {vector per a guardar les explosions}

     t_explosions=record       {tipus explosio}
       n_explosio:byte;        {numero de explosio dins el vector}
       cadena_expl:t_explosio; {vector d'explosions}
     end;

     t_municio=record          {tipus municio}
        n_bala:byte;           {numero de bala}
        bales:t_bala;          {vector de bales}
     end;

     t_avio_malo=record
        n_avio:byte;
        vect_avio:t_malos;
     end;

procedure crea_avio(var plane:avio_obj;posx,posy,ample,alt,velocitat,power:word);
procedure crea_avio_m(var plane:avio_obj;posx,posy,ample,alt:word);
procedure crea_bala(var bala:bala_obj;posx,posy:word);
procedure elimina_bala(var bala:bala_obj);
procedure moure_bala(var bala:bala_obj;sentit:integer);
procedure inicia_municio(var bales:t_municio);
procedure dispara(var ammo_mala:t_municio;plane:avio_obj);
procedure inicia_explosions(var explotion:t_explosions);
procedure test_bales(var bales:t_municio;tipus:integer);
procedure gestiona_avio(var pulsacio:byte;var plane:avio_obj;var bales:t_municio;last_tecla:byte);
procedure posar_invencible(var avio:avio_obj);
procedure posar_bombes(var avio:avio_obj);

implementation
{------------------------------------------------------------------------}
procedure crea_avio(var plane:avio_obj;posx,posy,ample,alt,velocitat,power:word);
begin
     plane.x:=posx;
     plane.y:=posy;
     plane.maxx:=ample;
     plane.maxy:=alt;
     plane.bombes:=0;
     plane.velocitat:=velocitat;
     plane.power:=power
end;

{------------------------------------------------------------------------}
procedure crea_avio_m(var plane:avio_obj;posx,posy,ample,alt:word);
begin
     plane.x:=posx;
     plane.y:=posy;
     plane.maxx:=ample;
     plane.maxy:=alt;
     plane.bombes:=0;
end;

{------------------------------------------------------------------------}
procedure crea_bala(var bala:bala_obj;posx,posy:word);
begin
    bala.x:=posx;
    bala.y:=posy;
    bala.activa:=1;
end;

{------------------------------------------------------------------------}
procedure elimina_bala(var bala:bala_obj);
begin
     bala.x:=0;
     bala.y:=0;
     bala.activa:=0;
end;

{------------------------------------------------------------------------}
procedure moure_bala(var bala:bala_obj;sentit:integer);
begin
    bala.x:=bala.x;
    bala.y:=bala.y+(3*sentit);
end;

{------------------------------------------------------------------------}
procedure inicia_municio(var bales:t_municio);
{inicialitza la municio}
var i:byte;
begin
     bales.n_bala:=1;
     for i:=1 to max_bales do
     begin
      bales.bales[i].x:=0;
      bales.bales[i].y:=0;
      bales.bales[i].activa:=0;
     end;
end;

{------------------------------------------------------------------------}
procedure dispara(var ammo_mala:t_municio;plane:avio_obj);
begin
    if (ammo_mala.bales[ammo_mala.n_bala].activa=0) and
       (ammo_mala.bales[ammo_mala.n_bala+1].activa=0) then
     begin
      crea_bala(ammo_mala.bales[ammo_mala.n_bala],plane.x+8,plane.y+plane.maxy+1);
      crea_bala(ammo_mala.bales[ammo_mala.n_bala+1],plane.x+41-8,plane.y+plane.maxy+1);
      ammo_mala.n_bala:=(ammo_mala.n_bala) mod max_bales;
     end;
end;

{------------------------------------------------------------------------}
procedure inicia_explosions(var explotion:t_explosions);
{inicialitza el vector de les explosions}
var cont:byte;
begin
    explotion.n_explosio:=1;
    for cont:=1 to max_explosions do
     begin
      explotion.cadena_expl[cont].x:=0;
      explotion.cadena_expl[cont].y:=0;
      explotion.cadena_expl[cont].time:=0;
      explotion.cadena_expl[cont].activa:=0;
     end;
end;

{------------------------------------------------------------------------}
procedure test_bales(var bales:t_municio;tipus:integer);
{comproba que les bales encara estan en la pantalla}
var cont:byte;
begin
   case tipus of
   -1:begin
      for cont:=1 to max_bales do
      begin
      if (bales.bales[cont].y<3) and (bales.bales[cont].activa=1) then begin
                        elimina_bala(bales.bales[cont]);
                        end;
      end;
     end;
   1:begin
      for cont:=1 to max_bales do
      begin
      if (bales.bales[cont].y>197) and (bales.bales[cont].activa=1) then begin
                        elimina_bala(bales.bales[cont]);
                        end;
      end;
     end;
   end;
end;

{------------------------------------------------------------------------}
procedure gestiona_avio(var pulsacio:byte;var plane:avio_obj;var bales:t_municio;last_tecla:byte);
{calcula la posicio del avio depenent de la tecla polsada o si ha de disparar}
begin
   if teclapuls(keya) then
     if plane.x>plane.velocitat then plane.x:=plane.x-plane.velocitat;
   if teclapuls(keys) then
     if plane.y<200-plane.maxy{avio_alt} then plane.y:=plane.y+plane.velocitat;
   if teclapuls(keyd) then
     if plane.x<319-plane.maxx{avio_ample} then plane.x:=plane.x+plane.velocitat;
   if teclapuls(keyw) then
     if plane.y>plane.velocitat then plane.y:=plane.y-plane.velocitat;
   if teclapuls(keyspace) then
        begin
          if (bales.bales[bales.n_bala].activa=0) and (bales.bales[bales.n_bala+1].activa=0)  then
          begin
             crea_bala(bales.bales[bales.n_bala],plane.x+3,plane.y+3);
             crea_bala(bales.bales[bales.n_bala+1],plane.x+plane.maxx-7,plane.y+3);
             bales.n_bala:=(bales.n_bala+2) mod max_bales;
          end;
        end;
   if teclapuls(keyb) then
        begin
          if (plane.bombes>0) and (last_tecla<>pulsacio) then
          begin
            plane.invencible:=1;
            plane.temps_invencible:=255;
            dec(plane.bombes);
          end;
        end;
    end;

{------------------------------------------------------------------------}
procedure posar_invencible(var avio:avio_obj);
begin
    avio.invencible:=1;
    avio.temps_invencible:=temps_invencible;
end;

{------------------------------------------------------------------------}
procedure posar_bombes(var avio:avio_obj);
begin
     avio.bombes:=2+avio.bombes;
end;

end.