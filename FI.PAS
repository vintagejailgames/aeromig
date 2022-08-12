 unit fi;

interface
procedure final;

implementation

uses grafix,motor2dv,utils,crt;

type store_frases=array[1..6] of byte;

procedure init_frases(var v_frases:store_frases);
var i:byte;
begin
     for i:=1 to 6 do v_frases[i]:=1;
end;

var vscr,vscr2:ptr_pantalla;
    vaddr,vaddr2,time:word;
    select,num_frase,res,i:byte;
    frases:store_frases;
    paleta:t_paleta;

procedure select_page;
begin
   if (time=0) and (num_frase<>6) then
     begin
       res:=1;
       num_frase:=0;
       while res<>0 do
       begin
        inc(num_frase);
        res:=frases[num_frase];
       end;
     case num_frase of
      1:begin
         cls(0,vaddr2);
         pinta_cadena(vaddr2,'BACK',vaddr,141,40,40,12);
         pinta_cadena(vaddr2,'DESIGNER',vaddr,141,96,40,12);
         pinta_cadena(vaddr2,'JAIL',vaddr,141,80,80,12);
         pinta_cadena(vaddr2,'GAMER',vaddr,141,135,80,12);
         frases[num_frase]:=1;
         frases[num_frase+1]:=0;
        end;
      2:begin
         cls(0,vaddr2);
         pinta_cadena(vaddr2,'PROGRAM',vaddr,141,40,40,12);
         pinta_cadena(vaddr2,'JAIL',vaddr,141,80,80,12);
         pinta_cadena(vaddr2,'GAMER',vaddr,141,135,80,12);
         pinta_cadena(vaddr2,'JAIL',vaddr,141,80,100,12);
         pinta_cadena(vaddr2,'programmer',vaddr,141,135,100,12);
         frases[num_frase]:=1;
         frases[num_frase+1]:=0;
        end;
      3:begin
         cls(0,vaddr2);
         pinta_cadena(vaddr2,'BUG',vaddr,141,40,40,12);
         pinta_cadena(vaddr2,'CHECKER',vaddr,141,86,40,12);
         pinta_cadena(vaddr2,'JAIL',vaddr,141,80,80,12);
         pinta_cadena(vaddr2,'STAFF',vaddr,141,135,80,12);
         frases[num_frase]:=1;
         frases[num_frase+1]:=0;
        end;
      4:begin
         cls(0,vaddr2);
         pinta_cadena(vaddr2,'SPECIAL',vaddr,141,70,70,12);
         pinta_cadena(vaddr2,'thanks',vaddr,141,162,70,12);
         pinta_cadena(vaddr2,'TO',vaddr,141,145,90,12);
         pinta_cadena(vaddr2,'JAIL',vaddr,141,110,110,12);
         pinta_cadena(vaddr2,'STAFF',vaddr,141,165,110,12);
         frases[num_frase]:=1;
         frases[num_frase+1]:=0;
        end;
      5:begin
         cls(0,vaddr2);
         pinta_cadena(vaddr2,'PRODUCED',vaddr,141,100,70,12);
         pinta_cadena(vaddr2,'BY',vaddr,141,137,90,12);
         pinta_cadena(vaddr2,'JAIL',vaddr,141,95,110,12);
         pinta_cadena(vaddr2,'GAMER',vaddr,141,150,110,12);
         frases[num_frase]:=1;
         frases[num_frase+1]:=0;
        end;
      6:begin
         frases[num_frase]:=1;
         frases[num_frase+1]:=0;
        end;
     end;
     end;
end;



procedure pagina0;
begin
    cls(2,$a000);
    put_sprite(vaddr2,$a000,320*56+70,242,55,50,70);
    delay(2000);
    fadedown(0,0,0,0);
    cls(0,$a000);
end;

procedure pagina1;
var fila,columna:byte;
begin
    blackout;

    fila:=0;
    columna:=4;
    put_sprite(vaddr,$a000,320*(fila*63)+(columna*50),50,63,30,10);
    pinta_cadena($a000,'Masterjail',vaddr2,120,90,43,10);

    fila:=1;
    columna:=0;
    put_sprite(vaddr,$a000,320*(fila*63)+(columna*50),50,63,220,65);
    pinta_cadena($a000,'Jail[Sleeper',vaddr2,120,80,95,10);

    fila:=1;
    columna:=1;
    put_sprite(vaddr,$a000,320*(fila*63)+(columna*50),50,63,30,130);
    pinta_cadena($a000,'Jail[Webmaster',vaddr2,120,90,160,10);

    fadeup(paleta,0);
    delay(2000);
end;

procedure pagina2;
var fila,columna:byte;
begin
    blackout;

    fila:=1;
    columna:=4;
    put_sprite(vaddr,$a000,320*(fila*63)+(columna*50),50,63,30,10);
    pinta_cadena($a000,'Jail[Merchandaiser',vaddr2,120,90,43,10);

    fila:=0;
    columna:=0;
    put_sprite(vaddr,$a000,320*(fila*63)+(columna*50),50,63,220,65);
    pinta_cadena($a000,'Jail[Designer',vaddr2,120,80,95,10);

    fila:=0;
    columna:=3;
    put_sprite(vaddr,$a000,320*(fila*63)+(columna*50),50,63,30,130);
    pinta_cadena($a000,'Jail[Gamer',vaddr2,120,90,160,10);

    fadeup(paleta,0);
    delay(2000);
end;

procedure pagina3;
var fila,columna:byte;
begin
    blackout;

    fila:=0;
    columna:=2;
    put_sprite(vaddr,$a000,320*(fila*63)+(columna*50),50,63,30,10);
    pinta_cadena($a000,'jail[Doctor',vaddr2,120,90,43,10);

    fila:=1;
    columna:=2;
    put_sprite(vaddr,$a000,320*(fila*63)+(columna*50),50,63,220,65);
    pinta_cadena($a000,'Jail[Hacker',vaddr2,120,80,95,10);

    fila:=1;
    columna:=3;
    put_sprite(vaddr,$a000,320*(fila*63)+(columna*50),50,63,30,130);
    pinta_cadena($a000,'Jail[programer',vaddr2,120,90,160,10);

    fadeup(paleta,0);
    delay(2000);
end;

procedure pagina4;
var fila,columna:byte;
begin
    blackout;

    fila:=0;
    columna:=5;
    put_sprite(vaddr,$a000,320*(fila*63)+(columna*50),50,63,30,10);
    pinta_cadena($a000,'jail[hardwarer',vaddr2,120,90,43,10);

    fila:=0;
    columna:=1;
    put_sprite(vaddr,$a000,320*(fila*63)+(columna*50),50,63,220,65);
    pinta_cadena($a000,'Jail[Arounder',vaddr2,120,80,95,10);

    fila:=1;
    columna:=5;
    put_sprite(vaddr,$a000,320*(fila*63)+(columna*50),50,63,30,130);
    pinta_cadena($a000,'Jail[friend',vaddr2,120,90,160,10);

    fadeup(paleta,0);
    delay(2000);
end;

procedure select_out;
begin
    select:=random(10)+1;
    case select of
     1:out1(0);
     2:out2(0);
     3:out3(0);
     4:out4(0);
     5:out5(0);
     6:out6(0);
     7:out7(0);
     8:out8(0);
     9:out9(0);
     10:out10(0,20,3);
    end;
end;

procedure final;

procedure credits;
begin
     time:=0;
     init_frases(frases);
     setmode($13);
     cls(0,vaddr2);
     load_pcx('font_6.pcx',vaddr);

     pinta_cadena(vaddr2,'SPRITE',vaddr,141,40,40,12);
     pinta_cadena(vaddr2,'DESIGNER',vaddr,141,120,40,12);
     pinta_cadena(vaddr2,'JAIL',vaddr,141,80,80,12);
     pinta_cadena(vaddr2,'GAMER',vaddr,141,135,80,12);
     frases[1]:=0;
     num_frase:=1;
     repeat
      for i:=1 to 3 do espera_vga;
      volcar_pantalla(vaddr2,$a000);
      inc(time);
      time:=time mod 60;
      select_page;
     until num_frase=6;
end;


begin
    setmode($13);
    setup_virtual(vscr,vaddr);
    load_pcx('mini_j.pcx',vaddr);
    get_paleta(paleta);
    setup_virtual(vscr2,vaddr2);
    load_pcx('font_6.pcx',vaddr2);
    randomize;

    pagina0;

    pagina1;
    select_out;

    pagina2;
    select_out;

    pagina3;
    select_out;

    pagina4;
    select_out;

    tancar_virtual(vscr);
    tancar_virtual(vscr2);
    credits;
end;

end.