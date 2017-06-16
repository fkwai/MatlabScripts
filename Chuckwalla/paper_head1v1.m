% Observed vs. simulated groundwater head 
% load('E:\Kuai\chuckwalla\Chuckwalla_kuai\matfile_V6_10yr\chuck_newsoil2.mat')

usgsShp='E:\Kuai\chuckwalla\GMS\chuckwalla\data\observation\usgs_mid_sel.shp';
fieldObs='obsH';
shapeObs=shaperead(usgsShp);

caseLst={'f3','f4','f5','f6','f7'};
outDir='E:\Kuai\chuckwalla\GMS\chuckwalla\output\';

%% read data
selID=[4,4;5,2;5,5;6,3;11,2];  
sel=4;
hobsAll=[];
hsimAll=[];
legStr={};
for k=1:size(selID,1)
    simK=selID(k,1);
    caliK=selID(k,2);
    outFolder=[outDir,'simNewMount',num2str(simK),'\'];
    gridMat=load([outFolder,'grid.mat']);
    legStr{k}=['rch',num2str(simK),'-c',num2str(caliK)];
    
    hobs=[];
    hsim=[];
    for i=1:length(shapeObs)
        X=shapeObs(i).X;
        Y=shapeObs(i).Y;
        ind=round(([Y,X]-g.DM.origin)./g.DM.d+1);
        IY=ind(1);IX=ind(2);
        hobs=[hobs;shapeObs(i).(fieldObs)];
        hsim=[hsim;gridMat.grid(caliK).H1(IY,IX)];
    end
    hobsAll(:,k)=hobs;
    hsimAll(:,k)=hsim;
end

%% plot
f=figure('Position',[1,1,800,600]);
n=size(selID,1);
cmap={'m','g','c','b'};
kc=0;
for k=1:n
    if k~=sel
        kc=kc+1;
        if k<sel
            plot(hobsAll(:,k),hsimAll(:,k),'o','color',cmap{kc});hold on
        elseif k>sel
            plot(hobsAll(:,k),hsimAll(:,k),'s','color',cmap{kc});hold on
        end
    else
        plot(hobsAll(:,k),hsimAll(:,k),'*','color','r',...
            'markers',10,'LineWidth',2);hold on
    end
end

title('Observed vs. Simulated Groundwater Head ');
xlabel('Observed Head (m)')
ylabel('Simulated Head (m)')
axis equal
xlim([70,180]);
ylim([70,180]);
plot121Line;
h=legend(legStr,'Location','southeast');

suffix = '.eps';
fname=['E:\Kuai\chuckwalla\paper\Fig_head1v1'];
fixFigure([],[fname,suffix]);
saveas(gcf, fname);
close(f)



