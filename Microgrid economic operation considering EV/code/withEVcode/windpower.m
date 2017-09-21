function P=windpower(T)       %Pf????????????????V????24h???????
Vci=3;   %cut-in speed-m/s
Vco=25;   %cut-out speed-m/s
Vn=11;    %rated speedm/s
Pn=60;    %rated power-KW
Pf=zeros(1,24);
for i=1:24
    %V=random('wbl',6.78,1.94);      %??????V
    V=random('wbl',6.78,1.94);
    if (V<Vci)&&(V>=Vco)
        Pf(i)=0;               
    elseif (V>=Vci)&&(V<Vn)
        Pf(i)=Pn*(V^3-Vci^3)/(Vn^3-Vci^3);
    elseif (V>=Vn)&&(V<Vco)
        Pf(i)=Pn;
    end
end
t=1:24;
plot(t,Pf);
P=Pf(T);
end
