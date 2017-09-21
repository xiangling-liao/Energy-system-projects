function Pe=evmodel(PG,PL,PB,n)    %n-30 for ev
global T
global Ee        %initial SOC 
ta=8;       %time needed for full capacity-8h

Em=n*0.9*20;      %Em=540;upper limit fro SOC;usually, it should be 20%-90%,
de=Em/ta;         %charge rate per hour 
if T==1     %initialize the SOC for ev battery
    Ee(T)=0.6*20*n;  %
    Pe=-de;
elseif T>=2&&T<=6   %charge time
    if Ee(T-1)>=Em   
        Pe=0;   %the needed charge 
        Ee(T)=Em;   
    elseif Ee(T-1)+de>Em&&Ee(T-1)<Em
        Pe=-(Em-Ee(T-1));
        Ee(T)=Em;
    elseif Ee(T-1)+de<Em
        Pe=-de;
        Ee(T)=Ee(T-1)-Pe;
    end
elseif T==7         %consumed energy for going to work
    Ee(T)=0.73*20*n;  %???0.73
    Pe=0;
elseif T>=8&&T<=18  %discharge time
    if PL-(PG+PB)>0      %load is heaby, the grid need more power in addition to generation and battery
        if Ee(T-1)-de>=n*20*0.33    %guarantee for regular use
            Pe=de;     
            Ee(T)=Ee(T-1)-Pe;
        elseif Ee(T-1)>n*20*0.33&&Ee(T-1)-de<n*20*0.33 ;
            Pe=Ee(T-1)-n*20*0.33;
            Ee(T)=Ee(T-1)-Pe;
        elseif Ee(T-1)<=n*20*0.33;
            Pe=0;
            Ee(T)=Ee(T-1);
        end
    else PL-(PG+PB)<=0;
        Pe=0;
        Ee(T)=Ee(T-1);
    end
elseif T==19                %the SOC when back to home
    Ee(T)=Ee(T-1)-n*20*0.1; %assume 10% comsumption for going home
    Pe=0;
elseif T>=20        %charge
    if Ee(T-1)>=Em   
        Pe=0;  
        Ee(T)=Em;  
    elseif Ee(T-1)+de>Em&&Ee(T-1)<Em
        Pe=-(Em-Ee(T-1));
        Ee(T)=Em;
    elseif Ee(T-1)+de<Em
        Pe=-de;
        Ee(T)=Ee(T-1)+Pe;
    end
end
end 
