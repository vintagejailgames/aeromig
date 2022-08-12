unit how;

interface
    procedure how_to_play;

implementation
uses grafix,keyboard,motor2dv;

type rgb=record
        red,green,blue:byte;
     end;

     pos=record
        x1,x2,y1,y2:word;
     end;

     t_avio=record
        x,y:word;
     end;

procedure supcase(var cadena:string);
var i:byte;
begin
     for i:=1 to length(cadena) do
     cadena[i]:=upcase(cadena[i]);
end;

procedure pinta_cadena(cadena:string;font_mem,x,y,tamany_font:word);
const base=65;

var i:byte;
    offset_lletra:word;
begin
    supcase(cadena);
    for i:=1 to length(cadena) do
    begin
       offset_lletra:=(ord(cadena[i])-base)*tamany_font;
       if ord(cadena[i])=32 then offset_lletra:=270;
       put_sprite(font_mem,$a000,offset_lletra,tamany_font,tamany_font,(i-1)*tamany_font+x,y);
    end;
end;

procedure pulsa(lletra:pos);
{var y,x:word;
begin
   for y:=lletra.y1 to lletra.y2 do
    for x:=lletra.x1 to lletra.x2 do
      mem[$a000:320*y+x]:=mem[$a000:320*y+x]+40;}
begin
asm
   mov ax,lletra.y1
   mov cx,lletra.y2

   mov bx,lletra.x2
   inc bx
   mov dx,lletra.x1

   sub cx,ax  {cx=y,rep. verticals}
   sub bx,dx  {bx=x,rep. horitzontals}

   mov ax,$a000
   mov es,ax
   inc cx
@bucley:
     push cx

 {bucle en x}
     mov   di,lletra.x1      {DI = X}
     mov   dx,lletra.y1      {DX = Y}
     dec   dx
     add   dx,cx
     shl   dx,8      {DX = 256*Y}
     add   di,dx     {DI = 256*Y+X}
     shr   dx,2      {DX = 64*Y}
     add   di,dx     {DI = 320*Y+X}
     mov   al,40  {Possem el color en AX}
     mov   ah,al
     mov cx,bx
     shr cx,1
     @canvia:
      add es:[di],ax
      inc di
      inc di
     loop @canvia
   pop cx
loop @bucley
 end;

end;


procedure solta(lletra:pos);
var y,x:word;
begin
   for y:=lletra.y1 to lletra.y2 do
    for x:=lletra.x1 to lletra.x2 do
      mem[$a000:320*(y)+x]:=mem[$a000:320*y+x]-40;

end;

procedure init_lletra(x1,x2,y1,y2:word;var lletra:pos);
begin
 lletra.x1:=x1;
 lletra.x2:=x2;
 lletra.y1:=y1;
 lletra.y2:=y2
end;

procedure clear_window(z_mem,x1,y1,x2,y2,color:word);
begin
 asm
   mov ax,y1
   dec ax
   mov cx,y2

   mov bx,x2
   inc bx
   mov dx,x1

   sub cx,ax  {cx=y,rep. verticals}
   sub bx,dx  {bx=x,rep. horitzontals}

   mov ax,z_mem
   mov es,ax

@bucley:
     push cx

 {bucle en x}
     mov   di,x1      {DI = X}
     mov   dx,y1      {DX = Y}
     add   dx,cx
     shl   dx,8      {DX = 256*Y}
     add   di,dx     {DI = 256*Y+X}
     shr   dx,2      {DX = 64*Y}
     add   di,dx     {DI = 320*Y+X}
     mov   ax,color  {Possem el color en AX}
     mov cx,bx
     shr cx,1
     rep stosw
   pop cx
loop @bucley
 end;
end;

procedure wait(time:real);
var temps,cont:word;

begin
    instalarkb;
    cont:=0;
    temps:=round(time*60);
    while (not qteclapuls) and (cont<temps) do
    begin
      espera_vga;
      inc(cont);
    end;
    desinstalarkb;
end;

procedure how_to_play;
var vscr,vscr2:ptr_pantalla;
    vaddr,vaddr2:word;
    color,i,rep:byte;
    a,s,w,d,b,space:pos;
    tecla:char;
    lletra:pos;
    avio,bala1,bala2:t_avio;

begin
     avio.x:=146;
     avio.y:=25;
     setup_virtual(vscr2,vaddr2);
     cls(0,vaddr2);
     load_pcx('font_10.pcx',vaddr2);
     setup_virtual(vscr,vaddr);
     load_pcx('model2.pcx',vaddr);
     tecla:=#13;
     init_lletra(152,169,113,127,a);
     init_lletra(182,199,113,127,s);
     init_lletra(212,229,113,127,d);
     init_lletra(174,191,94,108,w);
     init_lletra(275,292,138,152,b);
     init_lletra(150,289,165,179,space);
     setmode($13);
     load_pcx('howto.pcx',$a000);
     put_sprite(vaddr,$a000,0,27,26,avio.x,avio.y);

         if not qteclapuls then
          begin
           pulsa(a);
           pinta_cadena('left',vaddr2,15,150,10);
           for i:=0 to 39 do
            begin
             clear_window($a000,0,0,320,70,0);
             avio.x:=avio.x-2;
             put_sprite(vaddr,$a000,0,27,26,avio.x,avio.y);
             espera_vga;
            end;
           wait(0.5);
           solta(a);
           wait(1);
           clear_window($a000,6,139,117,188,0);
          end;

         if not qteclapuls then
          begin
          pulsa(d);
          for rep:=1 to 2 do
          begin
           pinta_cadena('right',vaddr2,15,150,10);
           for i:=0 to 39 do
            begin
             clear_window($a000,0,0,320,70,0);
             avio.x:=avio.x+2;
             put_sprite(vaddr,$a000,0,27,26,avio.x,avio.y);
             espera_vga;
            end;
          end;
          wait(0.5);
          solta(d);
          wait(1);
          clear_window($a000,6,139,117,188,0);
          end;

         if not qteclapuls then
          begin
           pulsa(a);
           pinta_cadena('left',vaddr2,15,150,10);
           for i:=0 to 39 do
            begin
             clear_window($a000,0,0,320,70,0);
             avio.x:=avio.x-2;
             put_sprite(vaddr,$a000,0,27,26,avio.x,avio.y);
             espera_vga;
            end;
           wait(0.5);
           solta(a);
           wait(1);
           clear_window($a000,6,139,117,188,0);
          end;

         if not qteclapuls then
          begin
           pulsa(w);
           pinta_cadena('up',vaddr2,15,150,10);
           for i:=0 to 9 do
            begin
             clear_window($a000,0,0,320,70,0);
             avio.y:=avio.y-2;
             put_sprite(vaddr,$a000,0,27,26,avio.x,avio.y);
             espera_vga;
            end;
           wait(0.5);
           solta(w);
           wait(1);
           clear_window($a000,6,139,117,188,0);
          end;

         if not qteclapuls then
          begin
          pulsa(s);
          for rep:=1 to 2 do
          begin
           pinta_cadena('down',vaddr2,15,150,10);
           for i:=0 to 9 do
            begin
             clear_window($a000,0,0,320,70,0);
             avio.y:=avio.y+2;
             put_sprite(vaddr,$a000,0,27,26,avio.x,avio.y);
             espera_vga;
            end;
          end;
          wait(0.5);
           solta(s);
           wait(1);
           clear_window($a000,6,139,117,188,0);
          end;

         if not qteclapuls then
          begin
           pulsa(b);
           pinta_cadena('shield',vaddr2,15,150,10);
           for i:=0 to 9 do
            begin
             clear_window($a000,0,0,320,70,0);
             put_sprite(vaddr,$a000,0,27,26,avio.x,avio.y);
             put_sprite(vaddr,$a000,85*320,27,27,avio.x,avio.y);
             espera_vga;
            end;
           wait(0.5);
           solta(b);
           wait(1);
           clear_window($a000,6,139,117,188,0);
          end;

         if not qteclapuls then
          begin
          for rep:=1 to 2 do
          begin
           pulsa(space);
           pinta_cadena('shot',vaddr2,15,150,10);
           bala1.x:=avio.x+2;
           bala2.x:=avio.x+20;
           bala1.y:=avio.y-1;
           bala2.y:=avio.y-1;
           put_sprite(vaddr,$a000,40,5,7,bala1.x,bala1.y);
           put_sprite(vaddr,$a000,40,5,7,bala2.x,bala2.y);
           for i:=1 to 12 do
           begin
            bala1.y:=bala1.y-3;
            bala2.y:=bala2.y-3;
            put_sprite(vaddr,$a000,40,5,7,bala1.x,bala1.y);
            put_sprite(vaddr,$a000,40,5,7,bala2.x,bala2.y);
            put_sprite(vaddr,$a000,0,27,26,avio.x,avio.y);
            espera_vga;
            clear_window($a000,0,0,320,70,0);
           end;
           put_sprite(vaddr,$a000,0,27,26,avio.x,avio.y);
           wait(0.5);
           solta(space);
           wait(1);
           clear_window($a000,6,139,117,188,0);
          end;
          end;

       espera_vga;
       clear_window($a000,6,139,117,188,0);
       clear_window($a000,0,0,320,70,0);

     tancar_virtual(vscr);
     tancar_virtual(vscr2);
end;

end.