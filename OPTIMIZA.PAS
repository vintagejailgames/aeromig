unit optimiza;


interface
 uses dos;

 function gettemps:word;

implementation
 function gettemps:word;
 var h,m,s,c:word;
 begin
     gettime(h,m,s,c);
     gettemps:=h*60*60*100+m*60*100+s*100+c;
 end;

end.