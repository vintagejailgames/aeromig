unit the_end;

interface
procedure final1;
procedure final2;


implementation
uses grafix,keyboard,motor2dv,utils;
procedure scroll_byte(mem_orig,mem_dest,desp:word);
var i,j:word;
begin
    for j:=0 to (199) do
     for i:=0 to (319-desp  div 2)do
      memw[mem_dest:(320*j)+i]:=memw[mem_orig:(320*j)+i+desp];
    if desp>0 then
    for j:=0 to (199)do
     for i:=0 to (desp-1  div 2)do
      mem[mem_dest:(320*j)+319-(desp-i)]:=mem[mem_orig:(320*j)+i];
end;

procedure final1;
var vscr,virt_vga:ptr_pantalla;
    vaddr,vga2,linies:word;
    mov:word;
    movs:array [1..12] of integer;
    ret,exit:byte;


begin
    setup_virtual(vscr,vaddr);
    setup_virtual(virt_vga,vga2);
    load_pcx('final1.pcx',vaddr);
    linies:=1;
    ret:=0;
    mov:=1;
    exit:=0;
    movs[1]:=1;movs[2]:=1;movs[3]:=2;movs[4]:=2;movs[5]:=3;movs[6]:=3;
    movs[7]:=2;movs[8]:=2;movs[9]:=1;movs[10]:=1;movs[11]:=0;movs[12]:=0;
    repeat
     scroll_byte(vaddr,vga2,linies);
     inc(linies);
     linies:=linies mod 320;
     if linies=0 then inc(exit);
     put_sprite(vaddr,vga2,320*130,84,29,80,70+movs[mov]);
     crear_finestra(91,40,220,128,87,vga2);
     espera_vga;
     volcar_pantalla(vga2,$a000);
     if ret=3 then inc(mov);
     mov:=mov mod 12;
     inc(ret);
     ret:=ret mod 4;
     espera_vga;
    until (exit=1);
    fadedown(0,0,0,1);
    cls(0,vaddr);
    cls(0,vga2);
    cls(0,$a000);
    load_pcx2('final1b.pcx',vaddr);
    repeat
     put_sprite(vaddr,vga2,0,129,98,91,40);
     crear_finestra(91,40,220,128,240,vga2);
     espera_vga;
     volcar_pantalla(vga2,$a000);
     if ret=3 then inc(mov);
     mov:=mov mod 12;
     inc(ret);
     ret:=ret mod 4;
     espera_vga;
    until (qteclapuls);
    fadedown(0,0,0,1);
    tancar_virtual(vscr);
    tancar_virtual(virt_vga);
end;

procedure final2;
var vscr,virt_vga:ptr_pantalla;
    vaddr,vga2,linies:word;
    mov:word;
    movs:array [1..12] of integer;
    ret,exit,num_sprite:byte;

begin
    setup_virtual(vscr,vaddr);
    setup_virtual(virt_vga,vga2);
    load_pcx('final2.pcx',vaddr);
    linies:=1;
    ret:=0;
    mov:=1;
    exit:=0;
    num_sprite:=0;
    movs[1]:=1;movs[2]:=1;movs[3]:=2;movs[4]:=2;movs[5]:=3;movs[6]:=3;
    movs[7]:=2;movs[8]:=2;movs[9]:=1;movs[10]:=1;movs[11]:=0;movs[12]:=0;
    repeat
     scroll_byte(vaddr,vga2,linies);
     inc(linies);
     linies:=linies mod 320;
     if linies=0 then inc(exit);
     if linies>=295 then
     begin
      num_sprite:=linies mod 270;
      num_sprite:=num_sprite div 10;
     end;
     put_sprite(vaddr,vga2,30*num_sprite,26,27,110+(num_sprite*6),70+movs[mov]+(num_sprite*3));
     crear_finestra(91,40,220,128,87,vga2);
     espera_vga;
     volcar_pantalla(vga2,$a000);
     if ret=3 then inc(mov);
     mov:=mov mod 12;
     inc(ret);
     ret:=ret mod 4;
     espera_vga;
    until (exit=1);
    fadedown(0,0,0,1);
    cls(0,vaddr);
    cls(0,vga2);
    cls(0,$a000);
    load_pcx2('final2b.pcx',vaddr);
    repeat
     put_sprite(vaddr,vga2,0,129,98,91,40);
     crear_finestra(91,40,220,128,240,vga2);
     espera_vga;
     volcar_pantalla(vga2,$a000);
     if ret=3 then inc(mov);
     mov:=mov mod 12;
     inc(ret);
     ret:=ret mod 4;
     espera_vga;
    until (qteclapuls);
    fadedown(0,0,0,1);
    tancar_virtual(vscr);
    tancar_virtual(virt_vga);
end;

begin
  instalarkb;
end.