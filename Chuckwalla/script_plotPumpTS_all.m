
%outFolder='E:\Kuai\chuckwalla\GMS\chuckwalla\output\simNewMount11\';
outFolder='E:\Kuai\chuckwalla\GMS\chuckwalla\output\test\';

wellNameLst={'Desert Sunlight','Desert Harvest','Eagle Moutain','Palen','Genesis'};
nP=length(wellNameLst);

%caseLst={'f3','f4','f5','f6','f7'};
caseLst={'f5','new'};
%nameLst={'sy15_ss1e6.csv';'sy15_ss5e6.csv';'sy15_ss5e5.csv'};
nameLst={'sy05_ss5e6.csv';'sy15_ss5e6.csv';'sy20_ss5e6.csv'};
figFolder=[outFolder];

out=[];
for j=1:length(caseLst)
    temp=csvread([outFolder,caseLst{1},'_',nameLst{1}]);
    t=temp(:,1);
    
    mat=zeros(length(t),nP,length(nameLst));
    for i=1:length(nameLst)
        file=[outFolder,caseLst{j},'_',nameLst{i}];
        temp=csvread(file);
        for k=1:5
            mat(:,k,i)=temp(:,k*2);
        end
        mat(mat==-888)=nan;
    end
    out(j).t=t;
    out(j).data=mat;    
end

%%

legLst=caseLst;

cmap=jet;
close all
cmap=cmap([1:round(64/length(out)):64],:);
%cmap(1,:)=[0,0,0];
for k=1:5
    f=figure('Position',[100,100,1000,600]);
    legItem=[];
    for i=1:length(out)
        t=[out(i).t];
        h1=out(i).data(1,k,1);
        h2=out(i).data(1,k,2);
        h3=out(i).data(1,k,3);
        v1=[out(i).data(:,k,1)-h1];
        v2=[out(i).data(:,k,2)-h2];
        v3=[out(i).data(:,k,3)-h3];
        plot(t/365,v1,'--','color',getS(i,'l'),'LineWidth',1);hold on
        l=plot(t/365,v2,'color',getS(i,'l'),'LineWidth',2);hold on
        plot(t/365,v3,'--','color',getS(i,'l'),'LineWidth',1);hold on
        legItem(i)=l;
    end
    hold off
    xlim([0 9200]/365)
    ylabel('Negative drawdown (m)')
    xlabel('Years after pumping')
    title(['Drawdown at ',wellNameLst{k},'m'])    

    h=legend(legItem,legLst,'Location','northeastoutside');    
    htitle = get(h,'Title');
    set(htitle,'String','sim')
    
    suffix = '.eps';
    fname=[figFolder,'drawWell',num2str(k)];
    fixFigure([],[fname,suffix]);
    saveas(gcf, fname);
    close(f)
end
