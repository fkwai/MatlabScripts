function BudykoGrid( Evpgrid,PEVPRgrid,ARAINgrid,ASNOWgrid,option )
%BUDYKOGRID Summary of this function goes here
%   Detailed explanation goes here

[ny,nx,nt]=size(EVPgrid);

% put data into points
if(option==1)    %all average
    E=reshape(mean(EVPgrid,3),ny*nx,1);
    Ep=reshape(mean(PEVPRgrid,3),ny*nx,1);
    P=reshape(mean(ARAINgrid+ASNOWgrid,3),ny*nx,1);
elseif(option ==2)  %annual
    E=[];Ep=[];P=[];
    for i=1:12:nt
        E=[E;reshape(mean(Evpgrid(:,:,i:i+11),3),ny*nx,1)];
        Ep=[Ep;reshape(mean(PEVPRgrid(:,:,i:i+11),3),ny*nx,1)];
        P=[P;reshape(mean(ARAINgrid(:,:,i:i+11)+ASNOWgrid(:,:,i:i+11),3),ny*nx,1)];
    end
elseif(option ==3)    
    E=[];Ep=[];P=[];
    
end

E=E(E>0);
Ep=Ep(Ep>0);
P=P(P>0);


% plot
x=Ep./P;
y=E./P;
plot(x,y,'.')
hold on
xx=[0,1,max(x(~isinf(x)))];
yy=[0,1,1];
plot(xx,yy,'r','linewidth',2)
xlim([0,max(x(~isinf(x)))]);
ylim([0,1.5]);
hold off
end

