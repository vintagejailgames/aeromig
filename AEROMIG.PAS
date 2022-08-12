program aeromig;

uses grafix,keyboard,motor2dv,utils,fi,the_end,
     mtravio,av_malos,intro_av,optimiza,how;

type t_nom=string[7];

     t_puntuacio=record
           pos:byte;
           nom:t_nom;
           punts:word;
         end;

     t_taula_records=array [1..5] of t_puntuacio;


{------------------------------------------------------------------------}
var vscr,vscr2,vga2,vscr4,vscr_mort,vscr_missatges,vscr_misio,vfont:ptr_pantalla;
    vaddr,vaddr2,virt_vga,vaddr4,i,vaddr_mort,vaddr_missatges,vaddr_misio,vaddr_font:word;
    avio,avio_malo,avio_malo2:avio_obj;
    explosio:t_explosions;
    ammo,ammo_mala:t_municio;
    tecla,defeated,k_barco,pos_sprite:byte;
    kills,vides,life_boss,life_boss2:word;
    fase_kills:word;
    off_avio,off_boss,v_scroll1,v_scroll2:word;
    num_fase,ultima_tecla,color,mode_auto,no_pintar,inv:byte;
    first_temps,temps,linies:word;
    timer,punts:word;
    vector:pointer;
    off_avio_bo,avio_ample,avio_alt,total_malos,maxim_malos:word;
    tipo_avio,flag_conte_maxim,flag_nou_malo,flag_cel:byte;
    puntuacio:t_numero;
{====================== Informacio ========================}
procedure pinta_marcador;
begin
  pinta(virt_vga,vaddr_font,11,8,puntuacio.uni,0,50,120,8);
  pinta(virt_vga,vaddr_font,11,8,puntuacio.dec,0,40,120,8);
  pinta(virt_vga,vaddr_font,11,8,puntuacio.cent,0,30,120,8);
  pinta(virt_vga,vaddr_font,11,8,puntuacio.duni,0,20,120,8);
  pinta(virt_vga,vaddr_font,11,8,puntuacio.ddec,0,10,120,8);
  put_sprite(vaddr2,virt_vga,320*42+231,89,19,96,3);{elipse}
end;


procedure init_punts(var puntuacio:t_numero);
begin
 puntuacio.uni:=0;
 puntuacio.dec:=0;
 puntuacio.cent:=0;
 puntuacio.duni:=0;
 puntuacio.ddec:=0;
end;

procedure pinta_escut;
const off_escut1=85*320;
      ample_escut1=27;
      alt_escut1=27;

      off_escut2=112*320;
      ample_escut2=21;
      alt_escut2=31;
var  off_escut,ample_escut,alt_escut:word;
begin
     case tipo_avio of
      1:begin
        off_escut:=off_escut1;
        ample_escut:=ample_escut1;
        alt_escut:=alt_escut1;
        end;
      2:begin
        off_escut:=off_escut2;
        ample_escut:=ample_escut2;
        alt_escut:=alt_escut2;
        end;
     end;

     put_sprite(vaddr2,virt_vga,off_escut,ample_escut,alt_escut,avio.x,avio.y);
end;

procedure pinta_bombes;
var cont:byte;
const off_bomba=27;
      ample_bomba=13;
      alt_bomba=13;
begin
    if avio.bombes>0 then
    for cont:=1 to avio.bombes do
     put_sprite(vaddr2,virt_vga,off_bomba,ample_bomba,alt_bomba,0+(cont*4),186);
end;

procedure pinta_vides;
const off_vida1=320*13+27;
      ample_vida1=14;
      alt_vida1=13;
      off_vida2=320*11+41;
      ample_vida2=11;
      alt_vida2=15;
var cont:byte;
    off_vida,ample_vida,alt_vida:word;
begin
    if vides>=0 then
    begin
     case tipo_avio of
      1:begin
         off_vida:=off_vida1;
         ample_vida:=ample_vida1;
         alt_vida:=alt_vida1;
        end;
      2:begin
         off_vida:=off_vida2;
         ample_vida:=ample_vida2;
         alt_vida:=alt_vida2;
        end;
     end;
     for cont:=0 to vides-1 do
     put_sprite(vaddr2,virt_vga,off_vida,ample_vida,alt_vida,0+(cont*10),10);
    end;
end;

procedure auto_mode(var avio:avio_obj;var auto:byte);
begin
    avio.y:=avio.y-2;
    if avio.y<=100 then auto:=0 else auto:=1;
end;
{==========================HI SCORE========================}

procedure obtindre_nom(var cadena:t_nom;var pos:byte);
var tecla:byte;
    i:byte;

begin
   if qteclapuls then tecla:=agarrartecla;

   case tecla of
    keya:if pos<8 then
          if (ord(cadena[pos])-1)=64 then cadena[pos]:='`'
            else if (ord(cadena[pos])-1)>64 then cadena[pos]:=chr((ord(cadena[pos])-1));
    keyd:if pos<8 then
          if (ord(cadena[pos])+1)=97 then cadena[pos]:='A'
            else if (ord(cadena[pos])+1)<97 then cadena[pos]:=chr(ord(cadena[pos])+1);
    keyspace:begin inc(pos);if pos>8 then pos:=8;end;
    keybackspace:begin dec(pos);if pos<1 then pos:=1;end;
   end;
   for i:=1 to 7 do espera_vga;
end;

procedure indica_lletra(pos:byte;ranking:byte);
var x,y,i:word;
begin
   case pos of
    1:x:=60;
    2:x:=70;
    3:x:=80;
    4:x:=90;
    5:x:=100;
    6:x:=110;
    7:x:=120;
    8:x:=130;
   end;
   case ranking of
    1:y:=55;
    2:y:=85;
    3:y:=115;
    4:y:=145;
    5:y:=175;
   end;
   for i:=0 to 9 do putpixel(x+i,y,3,virt_vga);
end;

procedure seleccionar_fila_per_escriure(ranking:byte;var y:word);
begin
   case ranking of
    1:y:=55;
    2:y:=85;
    3:y:=115;
    4:y:=145;
    5:y:=175;
   end;
end;

procedure test_fitxer_hi;
var f:file of t_puntuacio;
    records:t_puntuacio;
begin
  assign(f, 'hiscore.dat');
  {$I-}
  reset(f);
  {$I+}
  if ioresult <> 0 then
  begin
   assign(f, 'hiscore.dat');
   rewrite(f);
   records.pos:=1;
   records.punts:=2000;
   records.nom:='AAAAAAA';
   while records.pos<=5 do
   begin
     write(f,records);
     inc(records.pos);
     records.punts:=records.punts div 2;
   end;
   close(f);
  end
  else close(f);
end;

procedure llegir_fitxer_hi(var taula:t_taula_records);
var f:file of t_puntuacio;
    records:t_puntuacio;

begin
   assign(f,'hiscore.dat');
   reset(f);
   while (not EOF(f)) do
   begin
     read(f,records);
     taula[records.pos]:=records;
   end;
   close(f);
end;

procedure pinta_puntuacio(orig,dest,punts:word;fila:word);
var mdec,muni,cent,dec,uni:byte;

begin
   mdec:=punts div 10000;
   muni:=(punts mod 10000) div 1000;
   cent:=((punts mod 10000) mod 1000) div 100;
   dec:=(((punts mod 10000) mod 1000) mod 100) div 10;
   uni:=(((punts mod 10000) mod 1000) mod 100) mod 10;
   pinta(dest,orig,130,10,mdec,0,0,190,fila-11);
   pinta(dest,orig,130,10,muni,0,10,190,fila-11);
   pinta(dest,orig,130,10,cent,0,20,190,fila-11);
   pinta(dest,orig,130,10,dec,0,30,190,fila-11);
   pinta(dest,orig,130,10,uni,0,40,190,fila-11);
end;

procedure actualitza_fitxer_hi(nous_records:t_taula_records);
var count:byte;
    f:file of t_puntuacio;
begin
   count:=1;
   assign(f,'hiscore.dat');
   rewrite(f);
   while count<=5 do
   begin
     write(f,nous_records[count]);
     inc(count);
   end;
   close(f);
end;

procedure actualitza_taula_records(punts:word;var taula:t_taula_records;var ranking:byte);
var i,num:byte;
    menor:boolean;
begin
    i:=0;
    repeat
     inc(i);
     menor:=punts<=taula[i].punts
    until (menor=false) or (i=5);
    if menor=true then inc(i);
    ranking:=i;

    if ranking<=5 then
     if ranking=5 then
      begin
       taula[5].punts:=punts;
      end
     else for i:=4 downto ranking do
     begin
      taula[i+1].nom:=taula[i].nom;
      taula[i+1].punts:=taula[i].punts;
     end;
    if ranking<=4 then
    begin
     taula[ranking].punts:=punts;
     taula[ranking].nom:='AAAAAAA'
    end;
end;


procedure hiscore(punts:word);
var pos_x,pos_y,time:word;
    pos,rank,i:byte;
    taula_records:t_taula_records;

begin
    load_pcx('font_6.pcx',vaddr2);
    load_pcx('hs.pcx',vaddr);
    time:=0;
    pos:=1;{posicio del cursor}
    test_fitxer_hi;
    llegir_fitxer_hi(taula_records);
    actualitza_taula_records(punts,taula_records,rank);
    if rank<=5 then
    repeat
     volcar_pantalla(vaddr,virt_vga);
     obtindre_nom(taula_records[rank].nom,pos);
     indica_lletra(pos,taula_records[rank].pos);

     for i:=1 to 5 do
     begin
      seleccionar_fila_per_escriure(taula_records[i].pos,pos_y);
      pinta_cadena(virt_vga,taula_records[i].nom,vaddr2,120,60,pos_y-11,10);
      pinta_puntuacio(vaddr2,virt_vga,taula_records[i].punts,pos_y);
     end;

     volcar_pantalla(virt_vga,$a000);
    until teclapuls(keyenter)
    else
     repeat
      volcar_pantalla(vaddr,virt_vga);
      for i:=1 to 5 do
      begin
       seleccionar_fila_per_escriure(taula_records[i].pos,pos_y);
       pinta_cadena(virt_vga,taula_records[i].nom,vaddr2,120,60,pos_y-11,10);
       pinta_puntuacio(vaddr2,virt_vga,taula_records[i].punts,pos_y);
      end;
      volcar_pantalla(virt_vga,$a000);
      espera_vga;
      inc(time);
     until time=240;
    actualitza_fitxer_hi(taula_records);
end;

procedure mostra_hiscore;
var pos_y,time:word;
    pos,i:byte;
    taula_records:t_taula_records;
    p1,p2,p3:word;
    v_p1,v_p2,v_p3:ptr_pantalla;
begin
    setup_virtual(v_p1,p1);
    setup_virtual(v_p2,p2);
    setup_virtual(v_p3,p3);
    load_pcx('font_6.pcx',p2);
    load_pcx('hs.pcx',p1);
    time:=0;
    pos:=1;{posicio del cursor}
    test_fitxer_hi;
    llegir_fitxer_hi(taula_records);
    volcar_pantalla(p1,p3);
    for i:=1 to 5 do
     begin
      seleccionar_fila_per_escriure(taula_records[i].pos,pos_y);
      pinta_cadena(p3,taula_records[i].nom,p2,120,60,pos_y-11,10);
      pinta_puntuacio(p2,p3,taula_records[i].punts,pos_y);
     end;
    volcar_pantalla(p3,$a000);
    tancar_virtual(v_p1);
    tancar_virtual(v_p2);
    tancar_virtual(v_p3);
end;


{============================bales=========================}
procedure gestiona_bales(var muni:t_municio;sentit:integer);
{pinta i mou les bales que hi ha en pantalla}
var cont:byte;
begin
   for cont:=1 to max_bales do
   case sentit of
   -1:
    begin
    if (muni.bales[cont].y>0) and (muni.bales[cont].activa=1) then
    begin
       case tipo_avio of
        1:begin
           moure_bala(muni.bales[cont],sentit);
           put_sprite(vaddr2,virt_vga,off_bala1,bala1_ample,bala1_alt,muni.bales[cont].x,muni.bales[cont].y);
          end;
        2:begin
           moure_bala(muni.bales[cont],sentit);
           put_sprite(vaddr2,virt_vga,off_bala2,bala2_ample,bala2_alt,muni.bales[cont].x,muni.bales[cont].y);
          end;
       end;
    end;
    end;
   1:begin
     if (muni.bales[cont].y<199) and (muni.bales[cont].activa=1) then begin
         moure_bala(muni.bales[cont],sentit);
         put_sprite(vaddr2,virt_vga,off_bala_malo,bala_ample_malo,bala_alt_malo,muni.bales[cont].x,muni.bales[cont].y);
         end;
    end;
   end;
end;

{========================explosions======================}
procedure gestiona_explosions;
{pinta i actualitza en pantalla les explosions i les elimina si ha pasat el temps de durada}
const ample_expl=40;
      alt_expl=41;
var cont:byte;
    off_explosio:word;
begin
   for cont:=1 to max_explosions do
   begin
    if explosio.cadena_expl[cont].activa=1 then
    begin
      case explosio.cadena_expl[cont].time of
        30,29,28,27,26,25,24,23,22,21:off_explosio:=(320*43)+83;
        20,19,18,17,16,15,14,13,12,11:off_explosio:=(320*43)+123;
        10,9,8,7,6,5,4,3,2,1,0:off_explosio:=(320*43)+163
      end;
        put_sprite(vaddr2,virt_vga,off_explosio,ample_expl,alt_expl,explosio.cadena_expl[cont].x,explosio.cadena_expl[cont].y);
      dec(explosio.cadena_expl[cont].time);
      if explosio.cadena_expl[cont].time=0 then explosio.cadena_expl[cont].activa:=0;
    end;
   end;
end;


{----------- Avions ----- malos------------------------------------}
procedure gestiona_mort_malos(var avio_m:avio_obj);
{gestio mort malos i "eliminacio" de bales}
var cont:byte;mort:byte;
begin
    gestiona_mort_avio(avio_malo,ammo,explosio,mort);
    if mort=1 then
    begin
     inc(kills);
     inc(total_malos);
     inc(puntuacio.uni);
    end;
end;

{----------- Boss -----------------------------------------}

procedure dispara_boss(var ammo_mala:t_municio;plane:avio_obj;tipus:byte);
begin
    case tipus of
    1:begin
      if (ammo_mala.bales[ammo_mala.n_bala].activa=0) and
       (ammo_mala.bales[ammo_mala.n_bala+1].activa=0) then
       begin
        crea_bala(ammo_mala.bales[ammo_mala.n_bala],plane.x+6,plane.y+plane.maxy-10);
        crea_bala(ammo_mala.bales[ammo_mala.n_bala+1],plane.x+plane.maxx-6,plane.y+plane.maxy-10);
        ammo_mala.n_bala:=(ammo_mala.n_bala+2) mod max_bales_malos;
       end;
      end;
    2:begin
      if (ammo_mala.bales[ammo_mala.n_bala].activa=0) and
       (ammo_mala.bales[ammo_mala.n_bala+1].activa=0) then
       begin
        crea_bala(ammo_mala.bales[ammo_mala.n_bala],plane.x+21,plane.y+plane.maxy+1);
        crea_bala(ammo_mala.bales[ammo_mala.n_bala+1],plane.x+40,plane.y+plane.maxy+1);
        crea_bala(ammo_mala.bales[ammo_mala.n_bala+2],plane.x,plane.y+plane.maxy+1);
        crea_bala(ammo_mala.bales[ammo_mala.n_bala+3],plane.x+avio_ample,plane.y+plane.maxy+1);
        ammo_mala.n_bala:=(ammo_mala.n_bala+4) mod max_bales_malos;
       end;
      end;
    3:begin
       if (ammo_mala.bales[ammo_mala.n_bala].activa=0) and
       (ammo_mala.bales[ammo_mala.n_bala+1].activa=0) then
       begin
        crea_bala(ammo_mala.bales[ammo_mala.n_bala],plane.x+160,plane.y+plane.maxy-10);
        crea_bala(ammo_mala.bales[ammo_mala.n_bala+1],plane.x+42,plane.y+plane.maxy-10);
        crea_bala(ammo_mala.bales[ammo_mala.n_bala+2],plane.x+50,plane.y+plane.maxy-10);
        crea_bala(ammo_mala.bales[ammo_mala.n_bala+3],plane.x+168,plane.y+plane.maxy-10);

        crea_bala(ammo_mala.bales[ammo_mala.n_bala+4],plane.x+193,plane.y+plane.maxy-10);
        crea_bala(ammo_mala.bales[ammo_mala.n_bala+5],plane.x+201,plane.y+plane.maxy-10);
        crea_bala(ammo_mala.bales[ammo_mala.n_bala+6],plane.x+10,plane.y+plane.maxy-10);
        crea_bala(ammo_mala.bales[ammo_mala.n_bala+7],plane.x+18,plane.y+plane.maxy-10);

        crea_bala(ammo_mala.bales[ammo_mala.n_bala+8],plane.x+74,plane.y+plane.maxy-10);
        crea_bala(ammo_mala.bales[ammo_mala.n_bala+9],plane.x+96,plane.y+plane.maxy-10);
        crea_bala(ammo_mala.bales[ammo_mala.n_bala+10],plane.x+136,plane.y+plane.maxy-10);
        crea_bala(ammo_mala.bales[ammo_mala.n_bala+11],plane.x+116,plane.y+plane.maxy-10);
        ammo_mala.n_bala:=(ammo_mala.n_bala+12) mod max_bales_malos;
       end;
      end;
    4:begin
       if (ammo_mala.bales[ammo_mala.n_bala].activa=0) and
       (ammo_mala.bales[ammo_mala.n_bala+1].activa=0) then
       begin
        crea_bala(ammo_mala.bales[ammo_mala.n_bala],plane.x+11,plane.y+plane.maxy-22);
        crea_bala(ammo_mala.bales[ammo_mala.n_bala+1],plane.x+36,plane.y+plane.maxy-28);
        crea_bala(ammo_mala.bales[ammo_mala.n_bala+2],plane.x+56,plane.y+plane.maxy-16);
        crea_bala(ammo_mala.bales[ammo_mala.n_bala+3],plane.x+78,plane.y+plane.maxy-16);

        crea_bala(ammo_mala.bales[ammo_mala.n_bala+4],plane.x+100,plane.y+plane.maxy-16);
        crea_bala(ammo_mala.bales[ammo_mala.n_bala+5],plane.x+120,plane.y+plane.maxy-28);
        crea_bala(ammo_mala.bales[ammo_mala.n_bala+6],plane.x+143,plane.y+plane.maxy-22);

        ammo_mala.n_bala:=(ammo_mala.n_bala+8) mod max_bales_malos;
       end;
      end;
    end;
end;

procedure moure_boss(var plane:avio_obj;bo:avio_obj;var bales_malo:t_municio;inteligencia:byte;dispar:byte);
var sentit:integer;
begin
   case inteligencia of
   1:begin
      if (plane.x<309-plane.maxx) and (plane.sentit_x=2) then plane.sentit_x:=2
      else plane.sentit_x:=-2;
      if (plane.x<=0) and (plane.sentit_x=-2) then plane.sentit_x:=2;
      if (plane.x>bo.x) and (plane.sentit_x>0) then plane.sentit_x:=-2;

      if (plane.y<plane.maxy) and (plane.sentit_y=1) then plane.sentit_y:=1
        else plane.sentit_y:=-1;
      if (plane.y<=0) and (plane.sentit_y=-1) then plane.sentit_y:=1;
      dispara_boss(bales_malo,plane,dispar);
     end;
   2:begin
      if (plane.x<309-plane.maxx) and (plane.sentit_x=2) then plane.sentit_x:=2
      else plane.sentit_x:=-2;
      if (plane.x<=10) and (plane.sentit_x=-2) then plane.sentit_x:=2;
      dispara_boss(bales_malo,plane,dispar);
      plane.sentit_y:=0;
     end;
   3:begin
      if (plane.x<309-plane.maxx) and (plane.sentit_x=2) then plane.sentit_x:=2
      else plane.sentit_x:=-2;
      if (plane.x<=0) and (plane.sentit_x=-2) then plane.sentit_x:=2;
      if (plane.x>bo.x) and (plane.sentit_x>0) then plane.sentit_x:=-2;
      plane.sentit_y:=0;
      dispara_boss(bales_malo,plane,dispar);
     end;
   4:begin
      plane.sentit_x:=0;
      plane.sentit_y:=0;
      dispara_boss(bales_malo,plane,dispar);
     end;
   5:begin
      if (plane.x<309-plane.maxx) and (plane.sentit_x=2) then plane.sentit_x:=2
      else plane.sentit_x:=-2;
      if (plane.x<=0) and (plane.sentit_x=-2) then plane.sentit_x:=2;
      if (plane.x>bo.x) and (plane.sentit_x>0) then plane.sentit_x:=-2;

      if (plane.y<150) and (plane.sentit_y=1) then plane.sentit_y:=1
        else plane.sentit_y:=-1;
      if (plane.y<=0) and (plane.sentit_y=-1) then plane.sentit_y:=1;
      dispara_boss(bales_malo,plane,dispar);
     end;
   end;
    plane.x:=plane.x+(plane.sentit_x);
    plane.y:=plane.y+(plane.sentit_y);
end;


procedure pintar_boss(var avio_m:avio_obj;z_mem,offset:word);
{pinta boss}
begin
    if avio_m.y<200-30 then
    put_sprite(z_mem,virt_vga,offset,avio_m.maxx,avio_m.maxy,avio_m.x,avio_m.y);
    if avio_m.y>200 then elimina_malo(avio_m);
end;


procedure gestiona_mort_boss(var avio_m:avio_obj;var vida:word);
{gestio mort boss i bales}
var cont:byte;
begin
    for cont:=1 to max_bales do
    if ammo.bales[cont].activa=1 then
    if
     test_colisio(ammo.bales[cont].x,ammo.bales[cont].y,2,2,avio_m.x,avio_m.y,avio_m.maxx,avio_m.maxy) then
     begin
      explosio.n_explosio:=(explosio.n_explosio mod max_explosions)+1;
      explosio.cadena_expl[explosio.n_explosio].x:=ammo.bales[cont].x-9;
      if ammo.bales[cont].y-9>=0 then
       explosio.cadena_expl[explosio.n_explosio].y:=ammo.bales[cont].y-9
      else explosio.cadena_expl[explosio.n_explosio].y:=ammo.bales[cont].y;
      explosio.cadena_expl[explosio.n_explosio].time:=temps_explosio;
      explosio.cadena_expl[explosio.n_explosio].activa:=1;
      vida:=vida-(avio.power);;
     if vida<=0 then
     begin
      elimina_malo(avio_m);
      defeated:=1;
     end;
      elimina_bala(ammo.bales[cont]);
     end;
end;

procedure select_boss;
begin
   case num_fase of
      1:begin
          crea_avio_m(avio_malo,0,0,41{122},42);
          avio_malo.sentit_x:=2;
          avio_malo.sentit_y:=1;

          crea_avio_m(avio_malo2,0,0,41,42);
          avio_malo2.sentit_x:=2;
          avio_malo2.sentit_y:=0;
        end;
      2:begin
          crea_avio_m(avio_malo,0,0,84,37);
          avio_malo.sentit_x:=2;
          avio_malo.sentit_y:=1;
      end;
      3:begin
          crea_avio_m(avio_malo,50,30,217,33);
          avio_malo.sentit_x:=2;
          avio_malo.sentit_y:=1;
          k_barco:=0;
      end;
      4:begin
          crea_avio_m(avio_malo,0,0,75,41);
          avio_malo.sentit_x:=2;
          avio_malo.sentit_y:=1;
        end;
      5:begin
            crea_avio_m(avio_malo,80,0,160,100);
            avio_malo.sentit_x:=2;
            avio_malo.sentit_y:=1;
        end;
     end;
end;

procedure gestiona_mort_boss_fase;
begin
    case num_fase of
      1:begin
         if life_boss>0 then
          begin
           gestiona_mort_boss(avio_malo,life_boss);
           if life_boss2>0 then defeated:=0;
          end;
         if life_boss2>0 then
          begin
           gestiona_mort_boss(avio_malo2,life_boss2);
           if life_boss>0 then defeated:=0;
          end;
        end;
      2:begin
         gestiona_mort_boss(avio_malo,life_boss);
        end;
      3:begin
         gestiona_mort_boss(avio_malo,life_boss);
        end;
      4:begin
         gestiona_mort_boss(avio_malo,life_boss);
        end;
      5:begin
         gestiona_mort_boss(avio_malo,life_boss);
        end;
      end;
end;

procedure moure_boss_fase;
begin
     case num_fase of
       1:begin
          if life_boss>0 then
          begin
           moure_boss(avio_malo,avio,ammo_mala,1,1);
           pintar_boss(avio_malo,vaddr2,off_boss);
          end;
          if life_boss2>0 then
          begin
           moure_boss(avio_malo2,avio,ammo_mala,2,1);
           pintar_boss(avio_malo2,vaddr2,320*126+252);
          end;
         end;
       2:begin
          moure_boss(avio_malo,avio,ammo_mala,1,1);
          pintar_boss(avio_malo,vaddr2,off_boss);
         end;
       3:begin
          moure_boss(avio_malo,avio,ammo_mala,4,3);
          case k_barco of
           0..30:pintar_boss(avio_malo,vaddr,0);
           31..60:pintar_boss(avio_malo,vaddr,320*35);
          end;
         inc(k_barco);
         k_barco:=k_barco mod 60;
         end;
       4:begin
          moure_boss(avio_malo,avio,ammo_mala,5,2);
          pintar_boss(avio_malo,vaddr2,off_boss);
         end;
       5:begin
          moure_boss(avio_malo,avio,ammo_mala,4,4);
          pintar_boss(avio_malo,vaddr,0);
          end;
      end;
end;


procedure anima_boss_3;
begin
     put_sprite(vaddr,virt_vga,320*34,217,33,50,30);
       case pos_sprite of
         0..15:begin
                  put_sprite(vaddr,virt_vga,320*102+61,90,32,50,32);
                  put_sprite(vaddr,virt_vga,320*102+183,92,32,202,33);
                 end;
         16..30:begin
                   put_sprite(vaddr,virt_vga,320*70+89,57,29,50,32);
                   put_sprite(vaddr,virt_vga,320*71+150,63,28,202,33);
                  end;
         31..45:begin
                   put_sprite(vaddr,virt_vga,320*71,39,27,50,33);
                   put_sprite(vaddr,virt_vga,320*71+41,40,27,227,32);
                  end;
         46..60:begin
                   put_sprite(vaddr,virt_vga,320*107,27,23,50,35);
                   put_sprite(vaddr,virt_vga,320*107+31,29,23,237,34);
                  end;
         61..75:begin
                   put_sprite(vaddr,virt_vga,320*143,15,19,50,37);
                   put_sprite(vaddr,virt_vga,320*143+17,18,19,249,36);
                  end;
      end;
      inc(pos_sprite);
end;

procedure anima_boss_5;
begin
   case pos_sprite of
    0..24:put_sprite(vaddr,virt_vga,320*100+160,160,100,80,0);
    25..49:put_sprite(vaddr,virt_vga,320*100,160,100,80,0);
    50..74:put_sprite(vaddr,virt_vga,160,160,100,80,0);
    75..99:put_sprite(vaddr,virt_vga,0,160,100,80,0);
    end;
    inc(pos_sprite);
end;

{----------------- Avio -- bo ---------------------------------}
procedure gestiona_mort(var mode:byte);
{gestio mort del bo}
var cont,mort:byte;
begin
    if avio.invencible=0 then
    if
     test_colisio(avio.x,avio.y,avio.maxx,avio.maxy,avio_malo.x,
     avio_malo.y,avio_malo.maxx,avio_malo.maxy) then
     begin
      explosio.n_explosio:=(explosio.n_explosio mod max_explosions)+1;
      explosio.cadena_expl[explosio.n_explosio].x:=avio.x;
      explosio.cadena_expl[explosio.n_explosio].y:=avio.y;
      explosio.cadena_expl[explosio.n_explosio].time:=temps_explosio;
      explosio.cadena_expl[explosio.n_explosio].activa:=1;
      dec(vides);
      avio.x:=100;
      avio.y:=160;
      avio.bombes:=max_bombes;
      posar_invencible(avio);
      auto_mode(avio,mode);
     end;

    if avio.invencible=0 then gestiona_mort_avio(avio,ammo_mala,explosio,mort);

    if mort=1 then
    begin
     dec(vides);
     avio.x:=100;
     avio.y:=160;
     avio.bombes:=max_bombes;
     posar_invencible(avio);
     auto_mode(avio,mode);
    end;

    if mode=1 then
     begin
      if (explosio.cadena_expl[explosio.n_explosio].activa=0)
      and (explosio.cadena_expl[explosio.n_explosio].time=0) then
      begin
      auto_mode(avio,mode);
      posar_invencible(avio);
      no_pintar:=0;
      end
      else no_pintar:=1;
     end;

    if avio.temps_invencible>0 then dec(avio.temps_invencible);
    if avio.temps_invencible=0 then avio.invencible:=0;
end;

{===============Procediments sobre l'scroll i iniciar joc i fases=========}
procedure gestio_pantalla;
var vf,v1,ratio1:word;
begin
    if flag_cel=1 then ratio1:=200 div (v_scroll1 div velocitat_fons);
    vf:=((velocitat_fons*linies) mod 64000);
    if flag_cel=1 then v1:=((v_scroll1*(linies mod ratio1)) mod 64000);
    scroll(vaddr4,virt_vga,vf);
    if flag_cel=1 then parallax_scroll(vaddr,virt_vga,v1);
    if no_pintar=0 then put_sprite(vaddr2,virt_vga,off_avio_bo,avio_ample,avio_alt,avio.x,avio.y);
end;

procedure gestio_pantalla_boss;
var vf,v1,ratio1:word;
begin
    if flag_cel=1 then ratio1:=200 div (v_scroll1 div velocitat_fons);
    vf:=((velocitat_fons*2*linies) mod 64000);
    if flag_cel=1 then v1:=((v_scroll1*(linies mod ratio1)) mod 64000);
    scroll(vaddr4,virt_vga,vf);
    if flag_cel=1 then parallax_scroll(vaddr,virt_vga,v1);
    if no_pintar=0 then put_sprite(vaddr2,virt_vga,off_avio_bo,avio_ample,avio_alt,avio.x,avio.y);
end;

procedure setup_fase1;
begin
    cls(0,vaddr);
    {load_pcx('cel_s1.pcx',vaddr);}
    {cls(0,vaddr3);
    load_pcx('avions_f.pcx',vaddr3);}
    cls(0,vaddr4);
    load_pcx('stage1.pcx',vaddr4);
    cls(0,vaddr2);
    load_pcx('model2.pcx',vaddr2);
    cls(0,virt_vga);

    maxim_malos:=fase1_kills;
    off_avio:=off_avio_m1;
    crea_avio_m(avio_malo,0,0,ample_m1,alt_m1);
    off_boss:=off_boss3;
    life_boss:=200;
    life_boss2:=200;
    flag_cel:=0;
    v_scroll1:=640;
    {v_scroll2:=1280;}
end;

procedure setup_fase2;
begin
    cls(0,vaddr);
    load_pcx('cel_s2.pcx',vaddr);
    {cls(0,vaddr3);
    load_pcx('tanks1.pcx',vaddr3);}
    cls(0,vaddr4);
    load_pcx('stage2.pcx',vaddr4);
    cls(0,vaddr2);
    load_pcx('model2.pcx',vaddr2);
    cls(0,virt_vga);

    maxim_malos:=fase2_kills;
    life_boss:=400;
    off_boss:=off_boss2;
    off_avio:=off_avio_m2;
    crea_avio_m(avio_malo,0,0,ample_m2,alt_m2);
    v_scroll1:=640;
    flag_cel:=1;
    {v_scroll2:=640;}
end;

procedure setup_fase3;
begin
    cls(0,vaddr);
    load_pcx('barco.pcx',vaddr);
    {load_pcx('cel_s3.pcx',vaddr);}
    {cls(0,vaddr3);
    load_pcx('barcos.pcx',vaddr3);}
    cls(0,vaddr4);
    load_pcx('stage3.pcx',vaddr4);
    cls(0,vaddr2);
    load_pcx('model2.pcx',vaddr2);
    cls(0,virt_vga);

    maxim_malos:=fase3_kills;
    off_avio:=off_avio_m3;
    crea_avio_m(avio_malo,0,0,ample_m3,alt_m3);
    life_boss:=800;
    off_boss:=off_boss3;
    v_scroll1:=640;
    flag_cel:=0;
    pos_sprite:=0;
    {v_scroll2:=320;}
end;

procedure setup_fase4;
begin
    cls(0,vaddr);
    load_pcx('cel_s4.pcx',vaddr);
    {cls(0,vaddr3);
    load_pcx('cel_s4b.pcx',vaddr3);}
    cls(0,vaddr4);
    load_pcx('stage4.pcx',vaddr4);
    cls(0,vaddr2);
    load_pcx('model2.pcx',vaddr2);
    cls(0,virt_vga);

    maxim_malos:=fase4_kills;
    off_avio:=off_avio_m4;
    crea_avio_m(avio_malo,0,0,ample_m4,alt_m4);
    life_boss:=1600;
    off_boss:=off_boss4;
    v_scroll1:=640;
    flag_cel:=1;
    {v_scroll2:=640;}
end;

procedure setup_fase5;
begin
    cls(0,vaddr);
    load_pcx('base4.pcx',vaddr);
    {load_pcx('cel_s5.pcx',vaddr);}
    {cls(0,vaddr3);
    load_pcx('nuvols.pcx',vaddr3);}
    cls(0,vaddr4);
    load_pcx('stage5.pcx',vaddr4);
    cls(0,vaddr2);
    load_pcx('model2.pcx',vaddr2);
    cls(0,virt_vga);

    maxim_malos:=fase5_kills;
    off_avio:=off_avio_m5;
    crea_avio_m(avio_malo,0,0,ample_m5,alt_m5);
    life_boss:=3200;
    off_boss:=off_boss5;
    v_scroll1:=960;
    flag_cel:=0;
    pos_sprite:=0;
    {v_scroll2:=640;}
end;



procedure setup_fase(n_fase:byte);
var bombes:byte;
begin
     case n_fase of
      1:setup_fase1;
      2:setup_fase2;
      3:setup_fase3;
      4:setup_fase4;
      5:setup_fase5;
      6:;
     end;
     inicia_municio(ammo);
     inicia_municio(ammo_mala);
     inicia_explosions(explosio);
     bombes:=avio.bombes;
     case tipo_avio of
     1:begin
        crea_avio(avio,100,160,avio1_ample,avio1_alt,2,2);
        off_avio_bo:=off_avio1;
        avio_ample:=avio1_ample;
        avio_alt:=avio1_alt;
       end;
     2:begin
        crea_avio(avio,100,160,avio2_ample,avio2_alt,3,1);
        off_avio_bo:=off_avio2;
        avio_ample:=avio2_ample;
        avio_alt:=avio2_alt;
       end;
     end;
     mode_auto:=0;
     defeated:=0;
     kills:=0;
     {inc(vides);}
     posar_invencible(avio);
     temps:=100;
     avio.bombes:=bombes;
     total_malos:=0;
     posar_bombes(avio)
end;

function select_avio:word;
const vga=$a000;
      x1=75;
      x2=178;
      y=67;

var vscr,vscr2,vscr3:ptr_pantalla;
    vaddr,vaddr2,vga2,x,tipo_avio:word;

begin
    instalarkb;
    setmode($13);
    setup_virtual(vscr,vaddr);
    setup_virtual(vscr2,vaddr2);
    setup_virtual(vscr3,vga2);
    load_pcx('select.pcx',vaddr);
    load_pcx2('cercle.pcx',vaddr2);
    volcar_pantalla(vaddr,vga2);
    put_sprite(vaddr2,vga2,0,62,62,x1,y);
    volcar_pantalla(vga2,vga);
    x:=x1;
    repeat
    volcar_pantalla(vaddr,vga2);
    if teclapuls(keyd) then x:=x2;
    if teclapuls(keya) then x:=x1;
    put_sprite(vaddr2,vga2,0,62,62,x,y);
    volcar_pantalla(vga2,vga);
    until teclapuls(keyenter) or teclapuls(keyspace);
    if x=x1 then select_avio:=1 else select_avio:=2;
    tancar_virtual(vscr);
    tancar_virtual(vscr2);
    tancar_virtual(vscr3);
    desinstalarkb;
end;

procedure setup_game;
begin
   setup_virtual(vscr,vaddr);
   setup_virtual(vscr2,vaddr2);
   setup_virtual(vscr4,vaddr4);
   setup_virtual(vga2,virt_vga);
   setup_virtual(vfont,vaddr_font);
   cls(0,vaddr_font);
   load_pcx('font_6.pcx',vaddr_font);
   init_punts(puntuacio);
   vides:=3;
   setup_fase(num_fase);
   ultima_tecla:=$00;
   no_pintar:=0;
   linies:=0;
   flag_conte_maxim:=0;
end;

procedure fi_joc;
begin
    tancar_virtual(vscr);
    tancar_virtual(vscr2);
    tancar_virtual(vga2);
    tancar_virtual(vfont);
    tancar_virtual(vscr4)
end;

procedure pinta_mission;
begin
    put_sprite(vaddr_font,virt_vga,320*10+100,103,18,100,80);
end;

procedure pinta_num_mission(num:byte);
begin
    put_sprite(vaddr_font,virt_vga,320*30+(20*(num-1)),20,20,140,100);
end;

procedure load_jailer(nom:integer);
begin
     case nom of
      1{jailgamer}:begin
                    load_pcx('jailers1.pcx',vaddr_missatges);
                    put_sprite(vaddr_missatges,vaddr_misio,0,84,128,16,6);
                   end;
      2{masterjail}:begin
                     load_pcx('jailers1.pcx',vaddr_missatges);
                     put_sprite(vaddr_missatges,vaddr_misio,85,84,128,16,6);
                    end;
      3{jaildoctor}:begin
                     load_pcx('jailers1.pcx',vaddr_missatges);
                     put_sprite(vaddr_missatges,vaddr_misio,170,84,128,16,6);
                    end;
      4{jailwebmaster}:begin
                        load_pcx('jailers2.pcx',vaddr_missatges);
                        put_sprite(vaddr_missatges,vaddr_misio,0,84,128,16,6);
                    end;
      5{jailsleeper}:begin
                      load_pcx('jailers2.pcx',vaddr_missatges);
                      put_sprite(vaddr_missatges,vaddr_misio,85,84,128,16,6);
                     end;
      6{jailprogramer}:begin
                        load_pcx('jailers2.pcx',vaddr_missatges);
                        put_sprite(vaddr_missatges,vaddr_misio,170,84,128,16,6);
                       end;
      7{jaildesigner}:begin
                       load_pcx('jailers3.pcx',vaddr_missatges);
                       put_sprite(vaddr_missatges,vaddr_misio,0,84,128,16,6);
                      end;
      8{jailmerchandiser}:begin
                           load_pcx('jailers3.pcx',vaddr_missatges);
                           put_sprite(vaddr_missatges,vaddr_misio,85,84,128,16,6);
                          end;
      9{jailarounder}:begin
                       load_pcx('jailers3.pcx',vaddr_missatges);
                       put_sprite(vaddr_missatges,vaddr_misio,170,84,128,16,6);
                      end;
      10{jailhardwarer}:begin
                         load_pcx('jailers4.pcx',vaddr_missatges);
                         put_sprite(vaddr_missatges,vaddr_misio,0,84,128,16,6);
                        end;
      11{jailhacker}:begin
                      load_pcx('jailers4.pcx',vaddr_missatges);
                      put_sprite(vaddr_missatges,vaddr_misio,85,84,128,16,6);
                     end;
      12{jailfriend}:begin
                      load_pcx('jailers4.pcx',vaddr_missatges);
                      put_sprite(vaddr_missatges,vaddr_misio,170,84,128,16,6);
                     end;
     end;
end;

procedure escriure_desde_fitxer(mem_dest,mem_orig,off_ini,x,y,tamany_font:word;fitxer:string);
var file_in:text;
    cadena:string;
    loop,new_length:word;

begin
   assign(file_in,fitxer);
    reset(file_in);
    while (not EOF(file_in)) do
    begin
     readln(file_in,cadena);
     if cadena[1]=chr(num_fase+48) then
     begin
      for loop:=1 to length(cadena)-1 do cadena[loop]:=cadena[loop+1];
      new_length:=ord(cadena[0])-1;
      cadena[0]:=char(new_length);
      pinta_cadena_ext(mem_dest,cadena,mem_orig,off_ini,x,y,tamany_font);
     end;
    end;
    close(file_in);
end;


procedure info_mission(fase:byte);
var pos_sprite:byte;
    pos_llum_x,pos_llum_y:word;
begin
   setup_virtual(vscr_misio,vaddr_misio);
   cls(0,vaddr_misio);
   load_pcx('missions.pcx',vaddr_misio);
   setup_virtual(vscr_missatges,vaddr_missatges);
   cls(0,vaddr_missatges);
   load_jailer(random(12)+1);
   cls(0,vaddr_missatges);
   load_pcx('missatge.pcx',vaddr_missatges);
   case fase of
    1:begin
       pos_llum_x:=260;
       pos_llum_y:=40;
      end;
    2:begin
       pos_llum_x:=210;
       pos_llum_y:=70;
      end;
    3:begin
       pos_llum_x:=240;
       pos_llum_y:=20;
      end;
    4:begin
       pos_llum_x:=270;
       pos_llum_y:=70;
      end;
    5:begin
       pos_llum_x:=210;
       pos_llum_y:=30;
      end;
    6:begin
       put_sprite(vaddr_missatges,vaddr_misio,off_misatge6,ample_misatge6,alt_misatge6,10,159);
       volcar_pantalla(vaddr_misio,$a000);
      end;
   end;
   pos_sprite:=0;
   repeat
   escriure_desde_fitxer(vaddr_misio,vaddr_missatges,0,7,157,8,'missatge.txt');
   case pos_sprite of
     0..14:put_sprite(vaddr_missatges,vaddr_misio,320*180,11,11,pos_llum_x,pos_llum_y);
     15..29:put_sprite(vaddr_missatges,vaddr_misio,320*180+11,11,11,pos_llum_x,pos_llum_y);
     30..44:put_sprite(vaddr_missatges,vaddr_misio,320*180+22,11,11,pos_llum_x,pos_llum_y);
     45..59:put_sprite(vaddr_missatges,vaddr_misio,320*180+11,11,11,pos_llum_x,pos_llum_y);
   end;
   espera_vga;
   volcar_pantalla(vaddr_misio,$a000);
   inc(pos_sprite);
   pos_sprite:=pos_sprite mod 59;
   until qteclapuls;
   tancar_virtual(vscr_misio);
   tancar_virtual(vscr_missatges);
end;

function percent_morts(morts,maxim_morts:word):integer;
begin
   percent_morts:=trunc((morts/maxim_morts)*100);
end;

procedure mostra_resum;
var percent:integer;
    cent,dec,uni,loop:byte;
    k:word;

procedure inc_puntuacio;
var total:byte;
    k:word;
begin
     total:=cent*100+dec*10+uni;
     if total>0 then
      for k:=1 to total*10 do
      begin
       inc(puntuacio.uni);
       comptador_bcd(flag_conte_maxim,puntuacio)
      end;
end;

begin
     k:=0;
     put_sprite(vaddr_font,virt_vga,320*50,67,67,5,50);
     percent:=percent_morts(kills,maxim_malos);
     cent:=percent div 100;
     dec:=(percent mod 100) div 10;
     uni:=(percent mod 100) mod 10;
     pinta(virt_vga,vaddr_font,10,8,uni,0,30,17,60);
     pinta(virt_vga,vaddr_font,10,8,dec,0,20,17,60);
     pinta(virt_vga,vaddr_font,10,8,cent,0,10,17,60);
     if cent=1 then
     begin
      inc(vides);
      repeat
       put_sprite(vaddr_font,virt_vga,320*20+65,29,9,25,100);
       volcar_pantalla(virt_vga,$a000);
       for loop:=1 to 30 do espera_vga;
       put_sprite(vaddr_font,virt_vga,320*90+20,29,9,25,100);
       volcar_pantalla(virt_vga,$a000);
       for loop:=1 to 30 do espera_vga;
       inc(k)
      until k=5;
     put_sprite(vaddr_font,virt_vga,320*20+65,29,9,25,100);
     end;
     inc_puntuacio;
     case num_fase of
      1:for k:=1 to 200 do
         begin
          inc(puntuacio.uni);
          comptador_bcd(flag_conte_maxim,puntuacio)
         end;
      2:for k:=1 to 400 do
         begin
          inc(puntuacio.uni);
          comptador_bcd(flag_conte_maxim,puntuacio)
         end;
      3:for k:=1 to 800 do
         begin
          inc(puntuacio.uni);
          comptador_bcd(flag_conte_maxim,puntuacio)
         end;
      4:for k:=1 to 1600 do
         begin
          inc(puntuacio.uni);
          comptador_bcd(flag_conte_maxim,puntuacio)
         end;
      5:for k:=1 to 3200 do
         begin
          inc(puntuacio.uni);
          comptador_bcd(flag_conte_maxim,puntuacio)
         end;
      6:;
     end;
     pinta_marcador;
     volcar_pantalla(virt_vga,$a000);
end;



{========================================================}
{                  Programa principal                    }
{========================================================}
begin
  setmode($13);
  randomize;
  instalarkb;
  intro;
  repeat
    temps:=0;
    repeat
     espera_vga;
     if temps=960 then temps:=0;
     if temps=0 then intro_mig;
     inc(temps);
     if temps=600 then
     begin
      mostra_hiscore;
     end;
     if qteclapuls then tecla:=agarrartecla;
    until (tecla=keyenter) or (tecla=keyesc);

    if tecla<>keyesc then
    begin
     espera(1);
     borrarkb;
     how_to_play;
     tipo_avio:=select_avio;
    end;
    num_fase:=1;
    if num_fase=1 then avio.bombes:=3;
    setup_game;
    if tecla<>keyesc then

    repeat
     info_mission(num_fase);
     espera(1);
     inv:=0;
     {----------------Pantalla general----------------}
     repeat
      tecla:=$00;
      gestio_pantalla;
      if temps>0 then
         begin
          pinta_mission;
          pinta_num_mission(num_fase);
          dec(temps)
         end
      else
       begin
        moure_malo(avio_malo,avio,ammo_mala);
        test_malo(avio_malo,flag_nou_malo);
        if flag_nou_malo=1 then inc(total_malos);
        pinta_malos(avio_malo,vaddr2,off_avio,virt_vga);
       end;
      gestiona_bales(ammo,-1);  {-1 les bales van cap amunt les del bo}
      gestiona_bales(ammo_mala,1); {1 les bales van cap abaix le dels malos}
      gestiona_explosions;
      if qteclapuls then tecla:=agarrartecla;
      if (avio.invencible=1) and (no_pintar=0) then pinta_escut;
      if mode_auto=0 then gestiona_avio(tecla,avio,ammo,ultima_tecla);
      test_bales(ammo,-1);   {-1 les bales van cap amunt les del bo}
      test_bales(ammo_mala,1); {1 les bales van cap abaix le dels malos}
      if temps=0 then gestiona_mort_malos(avio_malo);
      gestiona_mort(mode_auto);
      pinta_cadena(virt_vga,'SCORE',vaddr_font,5,100,10,6);
      comptador_bcd(flag_conte_maxim,puntuacio);
      pinta_marcador;
      pinta_bombes;
      pinta_vides;
      espera_vga;

      volcar_pantalla(virt_vga,$a000);
      timer:=0;
      ultima_tecla:=tecla;
      inc(linies);
      linies:=linies mod 200;
{-->} {avio.invencible:=1;}
{-->} if tecla=keyf9 then total_malos:=maxim_malos;
      {--------------Fi de pantalla general---------------------}
      if total_malos>=maxim_malos then
       begin
        v_scroll1:=v_scroll1*2;
        v_scroll2:=v_scroll2*2;

        select_boss;
        defeated:=0;
        inicia_municio(ammo);
        inicia_municio(ammo_mala);
        temps:=100;
      {-------------------Pantalla del Boss----------------------}
       repeat
         if tecla<>keyesc then tecla:=$00;
         gestio_pantalla_boss;
         if temps>0 then dec(temps) else moure_boss_fase;

         if (num_fase=3) and (pos_sprite<=75) and (temps<=75) then
             anima_boss_3;

         if (num_fase=5) and (pos_sprite<=100) and (temps<=100) then
             anima_boss_5;

         gestiona_bales(ammo,-1);
         gestiona_bales(ammo_mala,1); {1 les bales van cap abaix le dels malos}
         gestiona_explosions;
         if qteclapuls then tecla:=agarrartecla;

         if (avio.invencible=1) and (no_pintar=0) then pinta_escut;
         if mode_auto=0 then gestiona_avio(tecla,avio,ammo,ultima_tecla);
         test_bales(ammo,-1);
         test_bales(ammo_mala,1); {1 les bales van cap abaix le dels malos}
         if temps=0 then gestiona_mort_boss_fase;
         gestiona_mort(mode_auto);
         pinta_bombes;
         pinta_vides;
         pinta_cadena(virt_vga,'SCORE',vaddr_font,5,100,10,6);
         comptador_bcd(flag_conte_maxim,puntuacio);
         pinta_marcador;
         espera_vga;

         volcar_pantalla(virt_vga,$a000);
         ultima_tecla:=tecla;
{-->}    if tecla=keynumlock then inv:=1;
         if inv=1 then avio.invencible:=1;
         if (num_fase<>3) and (num_fase<>5) then inc(linies);
         linies:=linies mod 100;
        until (vides<=0) or (defeated=1) or (tecla=keyesc);
     {--------------------Fi de pantalla del boss--------------------}
      end;
     until (tecla=keyesc) or (total_malos>=maxim_malos) or (vides<=0);
     no_pintar:=0;

     if vides>0 then
     begin
      if tecla<>keyesc then
      begin
       mostra_resum;
       espera(2);
       out;
       inc(num_fase);
       if (num_fase>5) and (defeated=1) then
       begin
        case tipo_avio of
          1:final2;
          2:final1;
        end;
        final;
        espera(2);
       end;
       if (num_fase>5) then
       begin
        punts:=10000*puntuacio.ddec+1000*puntuacio.duni+100*puntuacio.cent+10*puntuacio.dec+puntuacio.uni;
        hiscore(punts);
       end;
       setup_fase(num_fase);
       inicia_municio(ammo);
       inicia_municio(ammo_mala);
      end;
     end
     else
        begin
         cls(0,virt_vga);
         load_pcx('mort.pcx',virt_vga);
         volcar_pantalla(virt_vga,$a000);
         espera(2);
         punts:=10000*puntuacio.ddec+1000*puntuacio.duni+100*puntuacio.cent+10*puntuacio.dec+puntuacio.uni;
         hiscore(punts);
        end;

    until (tecla=keyesc) or (vides<=0) or (num_fase>5);
    fi_joc;
  until tecla=keyesc;
  setmode($3);
  desinstalarkb;
end.