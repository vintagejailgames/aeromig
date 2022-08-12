UNIT intro_av;

interface
procedure intro;
procedure intro_mig;
procedure espera(seg:byte);

implementation
uses grafix,motor2dv,keyboard,utils;

const temps=65;
      color=205;

type t_bomba=record
          x,y:word;
     end;

var vscr,vscr2,virt_vga:ptr_pantalla;
    vaddr,vaddr2,vga2,cont:word;
    i,line:word;
    red,green,blue:byte;


procedure espera(seg:byte);
begin
    for i:=1 to seg*temps do espera_vga;
end;

procedure brillo;
var i:word;
    r,g,b:byte;
begin
    setup_virtual(virt_vga,vga2);
    for i:=174 downto 74 do
    begin
     volcar_pantalla(vaddr,vga2);
     putpixel(i,2,215,vga2);
     putpixel(73,i-72,215,vga2);
     espera_vga;
     volcar_pantalla(vga2,$a000);
    end;
    putpixel(72,3,215,$a000);
    putpixel(71,4,215,$a000);

    putpixel(75,4,215,$a000);
    putpixel(74,3,215,$a000);

    putpixel(71,0,215,$a000);
    putpixel(72,1,215,$a000);

    putpixel(75,0,215,$a000);
    putpixel(74,1,215,$a000);

    putpixel(75,2,215,$a000);
    putpixel(74,2,215,$a000);

    putpixel(73,4,215,$a000);
    putpixel(73,3,215,$a000);

    putpixel(73,2,215,$a000);

    putpixel(73,1,215,$a000);
    putpixel(73,0,215,$a000);

    putpixel(72,2,215,$a000);
    putpixel(71,2,215,$a000);

    get_color(2,r,g,b);
    fadedown_C(215,r,g,b,0);
    volcar_pantalla(vaddr,$a000);
    tancar_virtual(virt_vga);
end;

procedure brillo2;
var linia,nova_linia:array[0..319] of byte;
    x,y,i:word;
    r,g,b:byte;
begin
    for y:=190 downto 125 do
    begin
     for x:=0 to 319 do
     begin
       linia[x]:=mem[$a000:320*y+x];
       if linia[x]<>0 then nova_linia[x]:=238
         else nova_linia[x]:=0;
     end;
    for x:=0 to 319 do
       mem[$a000:320*y+x]:=nova_linia[x];
    espera_vga;
    for x:=0 to 319 do
       mem[$a000:320*y+x]:=linia[x];
    end;
    for y:=124 downto 123 do
    begin
     for x:=0 to 319 do
     begin
       linia[x]:=mem[$a000:320*y+x];
       if linia[x]<>0 then nova_linia[x]:=255
         else nova_linia[x]:=0;
     end;
    for x:=0 to 319 do
       mem[$a000:320*y+x]:=nova_linia[x];
    espera_vga;
    for x:=0 to 319 do
       mem[$a000:320*y+x]:=linia[x];
    end;
    begin
     for x:=0 to 319 do
     begin
       linia[x]:=mem[$a000:320*122+x];
       if linia[x]<>0 then nova_linia[x]:=255
         else nova_linia[x]:=0;
     end;
    for x:=0 to 319 do
       mem[$a000:320*122+x]:=nova_linia[x];
    espera_vga
    end;
    get_color(249,r,g,b);
    fadedown_c(255,r,g,b,0);
end;

procedure gaviota;
var paleta:t_paleta;
    y:word;
    pas,exit:byte;

begin
    setup_virtual(vscr,vaddr);
    setup_virtual(vscr2,vaddr2);
    setup_virtual(virt_vga,vga2);
    load_pcx('gaviota.pcx',vaddr);
    load_pcx('jg.pcx',vaddr2);
    get_paleta(paleta);
    set_color(1,0,0,0);
    set_color(249,0,0,0);
    y:=100;
    pas:=1;
    exit:=0;
    repeat
    cls(0,vga2);
    volcar_pantalla(vaddr2,vga2);
    put_sprite(vaddr,vga2,320*5+110,100,95,108,y);
    crear_finestra(0,0,319,100,0,vga2);
    espera_vga;
    volcar_pantalla(vga2,$a000);
    y:=y-pas;
    if y=5 then
    begin
     volcar_pantalla(vaddr2,vga2);
     put_sprite(vaddr,vga2,320*5+110,100,95,108,y);
     put_sprite(vaddr,vga2,320*122+90,130,64,90,122);
     pas:=0;
     exit:=1;
     volcar_pantalla(vga2,$a000);
     fadeup(paleta,1);
    end;
    until exit=1;
    brillo2;
    fadedown(0,0,0,1);
    tancar_virtual(vscr);
    tancar_virtual(vscr2);
    tancar_virtual(virt_vga);
end;

procedure jail_gamer;
var paleta:t_paleta;
begin
    setup_virtual(vscr,vaddr);
    load_pcx('intro1.pcx',vaddr);
    get_paleta(paleta);
    blackout;
    volcar_pantalla(vaddr,$a000);
    fadeup(paleta,1);
    brillo;
    espera(1);
    fadedown(0,0,0,1);
    tancar_virtual(vscr);
end;

procedure intro;
begin
    gaviota;
    cls(0,$a000);
    jail_gamer;
end;

procedure intro_mig;
var paleta1:t_paleta;
    vscr:ptr_pantalla;
    vaddr,i:word;

begin
    setup_virtual(vscr,vaddr);
    cls(0,vaddr);
    load_pcx('titol.pcx',vaddr);
    get_paleta(paleta1);
    set_color(16,0,0,0);
    set_color(214,0,0,0);
    volcar_pantalla(vaddr,$a000);
    for i:=1 to 60 do espera_vga;
    fadeup(paleta1,1);
    tancar_virtual(vscr);
end;

end.