unit motor2dv;

interface
   procedure scroll(mem_orig,mem_dest,desplasament:word);
   FUNCTION test_colisio(x1,y1,w1,h1, x2,y2,w2,h2 :integer):boolean;
   procedure parallax_scroll(mem_orig,mem_dest,desplasament:word);
   procedure put_sprite(mem_orig,mem_dest,m_offset,ample,alt,posx,posy:word);

implementation

 FUNCTION test_colisio(x1,y1,w1,h1, x2,y2,w2,h2 :integer):boolean;
  VAR xd,yd : boolean;
  BEGIN
    ASM
      mov xd,false
      mov yd,false
    END;
    if ((x1 <=x2) and (x1+w1>=x2)) then xd:=true else
      if ((x1 <=x2+w2) and (x1+w1>=x2+w2)) then xd:=true else
        if ((x1 >=x2) and (x1+w1<=x2+w2)) then xd:=true;
    if ((y1 <=y2) and (y1+h1>=y2)) then yd:=true else
      if ((y1 <=y2+h2) and (y1+h1>=y2+h2)) then  yd:=true else
        if ((y1 >=y2) and (y1+h1<=y2+h2)) then yd:=true;
    test_colisio:=xd and yd;
  END;

 procedure _scroll(mem_orig,mem_dest,desplasament:word);
   begin
     move(mem[mem_orig:0],mem[mem_dest:desplasament],64000-desplasament);
     move(mem[mem_dest:64000-desplasament],mem[mem_orig:0],desplasament);
   end;

 procedure scroll(mem_orig,mem_dest,desplasament:word);assembler;
 asm
       push ds;
       {inicialitzar l'acces a les memories orige i desti}
       mov ax,mem_orig;
       mov ds,ax;
       xor si,si;

       mov ax,mem_dest;
       mov es,ax;
       mov di,desplasament;

       mov cx,64000;            {bytes en una pantalla}
       sub cx,desplasament;     {bytes a copiar}
       shr cx,1;                {words a copiar}
       {comen‡ar a copiar primer tros}
       rep movsw;

       mov cx,desplasament;
       shr cx,1;
       xor di,di;
       {comen‡ar a copiar segon tros}
       rep movsw;

       pop ds;
 end;

 procedure parallax_scroll(mem_orig,mem_dest,desplasament:word);assembler;
 asm
       push ds;
       {inicialitzar l'acces a les memories orige i desti}
       mov ax,mem_orig;
       mov ds,ax;
       xor si,si;

       mov ax,mem_dest;
       mov es,ax;
       mov di,desplasament;

       {comen‡ar a copiar primer tros}
       mov cx,64000;            {bytes en una pantalla}
       sub cx,desplasament;     {bytes a copiar}
       shr cx,1;                {words a copiar}
       jz @part2;

@pintar1:
       mov ax,ds:[si];
       or al,00h;
       jz @next1;
       mov es:[di],al;
@next1:
       inc di;
       or ah,00h;
       jz @next2;
       mov es:[di],ah;
@next2:
       inc si;
       inc di;
       inc si;
       loop @pintar1;

@part2:
       {comen‡ar a copiar segon tros}
       mov cx,desplasament;
       shr cx,1;
       jz @fi;
       xor di,di;

@pintar2:
       mov ax,ds:[si];
       or al,00h;
       jz @next3;
       mov es:[di],al;
@next3:
       inc di;
       or ah,00h;
       jz @next4;
       mov es:[di],ah;
@next4:
       inc si;
       inc di;
       inc si;
       loop @pintar2;

@fi:   pop ds;
 end;

 procedure put_sprite(mem_orig,mem_dest,m_offset,ample,alt,posx,posy:word);
   begin
    asm
       push ds;

       mov si,m_offset;

       mov ax,mem_orig;
       mov ds,ax;        {memoria orige}
       mov ax,mem_dest;
       mov es,ax;        {memoria desti}

       mov   di,posx;      {DI = X}
       mov   dx,posy;      {DX = Y}
       shl   dx,8;      {DX = 256*Y}
       add   di,dx;     {DI = 256*Y+BX}
       shr   dx,2;      {DX = 64*Y}
       add   di,dx;     {DI = 320*Y+X}

       mov cx,alt;     {guarde el alt}

   @1: push cx;        {guarde el alt}
       push di;        {guarde el offset desti}
       push si;        {guarde el offset orige}

       mov cx,ample;   {carregue el ample}

   @nou_pixel:
       mov al,ds:[si]       {color del pixel orige en al}
       or al,00h;           {AL=0?}
       jnz @paint;
       jmp @new;            {altre pixel}

   @paint:
       mov es:[di],al;      {pintar pixel}

   @new:
       inc di;              {augmentar punter pantalla}
       inc si;              {augmentar punter font}
       loop @nou_pixel;     {mentres no siga l'ample continuar}
       pop si;              {recuperem l'offset orige}
       pop di;              {recuperem l'offset desti}
       add si,320;          {segent linia orige}
       add di,320;          {segent linia desti}
       pop cx;              {recuperem l'alt}
       dec cx;              {una linia menys}
       cmp cx,0;            {Queden linies?}
       jnz @1;              {Si.Anar a @1}
       pop ds;
    end;
end;
end.