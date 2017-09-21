%data
cc=[9000	10000	1100	1120	1800	340	520	60	60	60];
hc=[4500	5000	550	560	900	170	260	30	30	30];
coeff=[1000	970	700	680	450	370	480	660	665	670;
16.19	17.26	16.6	16.5	19.7	22.26	27.74	25.92	27.27	27.79;
0.00048	0.00031	0.002	0.00211	0.00398	0.00712	0.0079	0.00413	0.00222	0.00173];
initial=[8	8	-5	-5	-6	-3	-3	-1	-1	-1];
load=[700	750	850	950	1000	1100	1150	1200	1300	1400	1450	1500	1400	1300	1200	1050	1000	1100	1200	1400	1300	1100	900	800];
mindown=[8	8	5	5	6	3	3	1	1	1];
minup=[8	8	5	5	6	3	3	1	1	1];
Pmax=[455	455	130	130	162	80	85	55	55	55];
Pmin=[150	150	20	20	25	20	25	10	10	10];
tcold=[5 5 4 4 4 2 2 0 0 0];


A=[];
N=10;              %10台机组
T=24;             %24个时间段
status=binvar(N,T,'full');   %生成了N*T=10*24的0,1二进制矩阵
state=binvar(N,T+1,'full');

P=sdpvar(N,T);
cu=sdpvar(N,T);
x=zeros(N,1); 
  
%get the initial status and put the result into the matrix state 
 for h=1:T
     for m=1:N
         if initial(1,m)<0
             x(m,1)=0;
         else x(m,1)=1;
         end
          end
 end
 state=[x,status];
 



Constraints1=[];
Constraints2=[];
Constraints3=[];
for k=1:T
    Constraints1=[Constraints1,status(:,k).*(Pmin)'<=P(:,k)<=status(:,k).*(Pmax)'];  %lower and upper power limit
    Constraints2=[Constraints2,sum(P(:,k))>=load(1,k)];                     %power banlance
    Constraints3=[Constraints3,sum(status(:,k).*(Pmax)')>=1.1*load(1,k)];  %spinning reserve=10%Demand 
end

%minup&mindown constraints
Constraints4=[];
for k = 1:T

 for unit = 1:N
  % indicator will be 1 only when switched on
  indicator = state(unit,k+1)-state(unit,k);
  range = (k+1):min(T+1,k+minup(unit));
  % Constraints will be redundant unless indicator = 1
  Constraints4 = [Constraints4, state(unit,range) >= indicator];
 end
end
Constraints5=[];
for k = 1:T
 for unit = 1:N
  % indicator will be 1 only when switched off
  indicator = state(unit,k)-state(unit,k+1);
  range = (k+1):min(T+1,k+mindown(unit));
  % Constraints will be redundant unless indicator = 1
  Constraints5 = [Constraints5, state(unit,range) <= 1-indicator];
 end
end
%don not take the ramp rate constraints

%linearize the fuel cost function 
A=[];
for m=1:N
    A(1,m)=coeff(3,m)*(Pmin(1,m))^2+coeff(2,m)*(Pmin(1,m))+coeff(1,m);
end
Pint=[];
MA=[];
MB=[];
   
   for m=1:N
    Pint(1,m)=((Pmax(1,m)+Pmin(1,m))/2);
    MA(1,m)=(coeff(3,m)*((Pint(1,m))^2-Pmin(1,m)^2)+coeff(2,m)*(Pint(1,m)-Pmin(1,m)))/(Pint(1,m)-Pmin(1,m));
    MB(1,m)=(coeff(3,m)*((Pmax(1,m))^2-Pint(1,m)^2)+coeff(2,m)*(Pmax(1,m)-Pint(1,m)))/(Pmax(1,m)-Pint(1,m));
   end
Constraints6=[];
   Constraints7=[];
   Constraints8=[];
 ga=sdpvar(N,T);
 gb=sdpvar(N,T);  
       for h=1:T
      Constraints6=[Constraints6,P(:,h)==ga(:,h)+gb(:,h)+(Pmin)'.*status(:,h)];
      Constraints7=[Constraints7,0<=ga(:,h)<=((Pint)'-(Pmin)').*status(:,h)];
      Constraints8=[Constraints8,0<=gb(:,h)<=((Pmax)'-(Pint)').*status(:,h)];
       end
       
%startup cost
Constraints9=[];
Constraints10=[];
for m=1:N
    length(1,m)=tcold(1,m)+mindown(1,m);
    for t=1:length(1,m)
        for h=1:T
            Constraints9=[Constraints9,cu(m,h)>=hc(1,m)*(state(m,h+1)-sum(state(m,max(h-t+1,1):h)))];
            Constraints10=[Constraints10,cu(m,h)>=cc(1,m)*(state(m,h+1)-sum(state(m,max(h-t,1):h)))];
        end
    end
end

%objective function
   objective=0;
    for h=1:T
    objective=objective+sum(A'.*status(:,h)+MA'.*ga(:,h)+MB'.*gb(:,h)+cu(:,h));    
    end 
    
optimize(Constraints1+Constraints2+Constraints3+Constraints4+Constraints5+Constraints6+Constraints7+Constraints8+Constraints9+Constraints10,objective);
stairs(value(P)');
xlabel('Time period/h');
ylabel('P/MW');
legend('Unit 1','Unit 2','Unit 3','Unit 4','Unit 5','Unit 6','Unit 7','Unit 8','Unit 9','Unit 10');  
P=double(P);
status=double(status);
objective=double(objective);


