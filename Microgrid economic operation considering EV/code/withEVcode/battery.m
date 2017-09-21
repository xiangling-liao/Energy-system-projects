function P=battery(EG,EL)   
global Et;
global T;
Emax=240;
dE=EL-EG;  
n=0.793; %battery charging efficiency
if T==1
    Et0=180;          %initial SOC of battery
    if dE>0    %heavy load-discharge
        if Et0<dE   
            P=Et0;    
        else Et0>=dE;
            P=dE;      
        end
    else dE<=0;  %charge
        if Et0-dE*n<=Emax
            P=dE*n;  
        else
            P=-n*(Emax-Et0);
        end
    end
    Et(T)=Et0-P;
else T>=2;                    %T?2-24??
    if dE>0                  %discharging
        if Et(T-1)-dE<0
            P=Et(T-1);           %????
        else Et(T-1)-dE>0;
            P=dE;            %???????
        end
    else dE<=0;               %charging
        if Et(T-1)-dE*n<=Emax
            P=dE*n;  
        else Et(T-1)-dE*n>Emax;
            P=-n*(Emax-Et(T-1));
        end 
    end
    Et(T)=Et(T-1)-P;       %p????????????
end
end