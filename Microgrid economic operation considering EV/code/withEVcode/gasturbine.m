function Cmt=gasturbine(P)  
Qd=35880;      
eff=0.7088;    %efficiency
Q=1.36*P;     %heat-electricity ratio=1.36
F=(P+Q)/(eff*Qd); %consumption of fuel
Cmt=F*0.5;          %cost for fuel
end
