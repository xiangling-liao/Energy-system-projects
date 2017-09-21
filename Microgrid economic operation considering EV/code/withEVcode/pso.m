function [xm,fv]=pso(fitness,N,c1,c2,w,M,D)
%%D-6-number of gas turbine
%M-iteration time=500
%N=20 number of particle
%c1=2,c2=2,update parameter
%----------------------initialize v&x-------------------
%global T;
%[PL,QL]=fuhe(T);            %load

global Cf1;
global Cf2;
ParticleScope=[10 65;10 65;10 65;10 65;10 65;10 65];
x=rand(N,D);  %[N*D]0-1 random number
v=rand(N,D);
E=10;
for k=1:D   %for each coulumn
    v(:,k)=v(:,k)*(ParticleScope(k,2)-ParticleScope(k,1))+ParticleScope(k,1);%ParticleScope(k,2)-ParticleScope(k,1)=upper limit-low limit
    x(:,k)=x(:,k)*(ParticleScope(k,2)-ParticleScope(k,1))+ParticleScope(k,1);
end
%initialize the fitness for every particle
for i=1:N
    p(i)=fitness(x(i,:));      
    y(i,:)=x(i,:);   %initialize the best of each particle
end 
pg=x(N,:);           %pg is global best(initial value)
for i=1:N-1
    if fitness(x(i,:))<fitness(pg)
        pg=x(i,:);    %update pg
    end
end
%---------------------update v&x---------------------
for k=1:M                    %for each iteration
    for i=1:N                %for each particle
        v(i,:)=w*v(i,:)+c1*rand*(y(i,:)-v(i,:))+c2*rand*(pg-v(i,:));
        
        for j=1:D           %update v
        vmax(j)=0.8*(ParticleScope(j,2)-ParticleScope(j,1)); 
              if v(i,j)>vmax(j)
          v(i,j)=rand*vmax(j);  
              elseif v(i,j)<(-vmax(j))
                v(i,j)=rand*(-vmax(j));
             end
        end
        
        x(i,:)=x(i,:)+v(i,:);          %update x
        for j=1:D
             if x(i,j)>ParticleScope(j,2)
                 x(i,j)=rand*ParticleScope(j,2);
             end
            if x(i,j)<ParticleScope(j,1)
                  x(i,j)=0.1*ParticleScope(j,1)+ParticleScope(j,1);
             end
       end
        if fitness(x(i,:))<p(i)         %update pbest and global best
            p(i)=fitness(x(i,:));
            y(i,:)=x(i,:);          
        end
        if p(i)<fitness(pg)
            pg=y(i,:);
        end
    end
    pbest(k)=fitness(pg);
end
xm=pg';           %optimal unit commitment
fv=fitness(pg);   %optimal cost
end
