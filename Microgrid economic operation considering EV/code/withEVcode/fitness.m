function f=fitness(x)
global T;
%global Et;
global C3;
PM=x(1,1)+x(1,2)+x(1,3)+x(1,4)+x(1,5)+x(1,6);    %6 gas turbine-electricity output
QM=1.36*PM;
r=0.06;     %yearly interest rate
cf1=1000000;     %penalty parameter for p-electricity
cf2=5000;    %penalty parameter for Q-heat
cf3=5000000;  %penalty parameter for output power limit
x1=1.06^15;    %(1+r)^Ni=(1+0.06)^15
x2=r*x1/(x1-1);
C1=(9*(25000*x2+1250)+5*(20000*x2+1000)+6*(25000*x2+1500)+20*(1000*x2+50))/8760;%wind,solar,gas,battery-hourly operation cost
C2=gasturbine(PM);     %hourly rate for GT
PG=PM+5*solarpower(T)+9*windpower(T);   %total generation amount
[PL,QL]=load(T);
PB=battery(PG,PL);
PE=evmodel(PG,PL,PB,30);
if PG+PB+PE>=PL            %sell
    C3=-(PG+PB+PE-PL)*0.05;
else                    %buy from grid
    C3=-(PG+PB+PE-PL)*0.07;     %0.05-sell price;0.07-buy price
end   
%-----------------penalty function-----------------------
Cf1=cf1*(PG+PB+PE-PL)^2+cf2*(QL-QM)^2;        
Cf2=cf3*(min(0,x(1,1)-1)^2+min(0,65-x(1,1))^2+min(0,x(1,2)-1)^2+min(0,65-x(1,2))^2+min(0,x(1,3)-1)^2+min(0,65-x(1,3))^2+min(0,x(1,4)-1)^2+min(0,65-x(1,4))^2+min(0,x(1,5)-1)^2+min(0,65-x(1,5))^2+min(0,65-x(1,6))^2+min(0,x(1,6)-1)^2);
f=C1+C2+C3+Cf1+Cf2;
end
