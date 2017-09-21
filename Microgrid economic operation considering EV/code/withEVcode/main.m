clear all
global T;        %time period
global Et;       %battery SOC
global Ee;       %ev SOC
global C3;       %cost for exchange with grid
sum=0;
r=0.06;          %yearly interest rate
x1=1.06^15;      %15 years
x2=r*x1/(x1-1);
C1=(9*(25000*x2+1250)+5*(20000*x2+1000)+6*(25000*x2+1500)+20*(1000*x2+50))/8760;
%---pso---%
Pgas=zeros(1,24);         %total output power of gas turbine each hour
peach=zeros(6,24); %optimal output power of each gas turbine each hour
f=zeros(1,24);     %hourly cost for all sources
for T=1:24
    [xm,fv]=pso(@fitness,20,2,2,0.8,500,6); 
    p=0;
    sum=0;
    for i=1:6
        p=xm(i)+p;
    end   
    Pgas(T)=p;        %hourly total power output for gt
    peach(:,T)=xm;
    f(T)=C1+gasturbine(p)+C3;         %cost for each hour 
    sum=sum+f;     %!!total cost for 24 hours
end
        
%----------------------??-------------------
PB=zeros(1,24);             %battery
PE=zeros(1,24);             %ev
PW=zeros(1,24);             %windpower
PL=zeros(1,24);             %electricity load
QL=zeros(1,24);             %heat load
PG=zeros(1,24);             %all power generarted 
for t=1:24
    if t==1
        PB(t)=180-Et(t);       %intial soc of battery=180
        PE(t)=-67.5       %initial SOC of ev=360
    else 
        PB(t)=Et(t-1)-Et(t);
        PE(t)=Ee(t-1)-Ee(t);
    end
    PW(t)=9*windpower(t);
    PS(t)=5*solarpower(t);
    [pl,ql]=load(t);
    PL(t)=pl;
    QL(t)=ql;
end
PG=PB+PE+PW+PS+Pgas;
t=1:24;
plot(t,PG,'-*');   %total generation
hold on
plot(t,PL,'ro');   %load
plot(t,QL,'k+');   %
plot(t,Pgas,'bd');   %gas-electricity
plot(t,1.36*Pgas,'gs');  %gas-heat
plot(t,PW,'gv');   %wind
plot(t,PS,'cx');   %solar
plot(t,PB,'mv');%   battery
plot(t,PE,'k<'); %ev
