mapfolder='E:\Kuai\SSRS\paper\mB\predmap\';
figfolder='E:\Kuai\SSRS\paper\mB\';
datafolder='E:\Kuai\SSRS\data\';
dataname='mB_4949';
shapefile=[datafolder,'gages_',dataname,'.shp'];
shpUSA=shaperead('Y:\Maps\USA.shp');
dataset=load([datafolder,'dataset_',dataname,'.mat']);
field=fieldNameChange(dataset.field);

%%
doSolo=1;
ind=[28,10,46,5,30,42,47,51,31,32];
shape=shaperead(shapefile);
predDataLst=dataset.dataset(:,ind);
predLst=field(ind);

% add dominant HGroup
HG=dataset.dataset(:,34:39);
[maxHG,domHG]=max(HG,[],2);
predDataLst=[predDataLst,domHG];
predLst=[predLst;'HGroup'];

%color range
maxPred=max(predDataLst);
minPred=min(predDataLst);
rangePred=[minPred;maxPred];
tickFormat={'%0.1f|','%0.0f|','%0.1f|',...
    '%0.0f|','%0.0f|','%0.0f|',...
    '%0.2f|','%0.1f|','%0.0f|',...
    '%0.0f|','%0.0f|'};
unitStr={'g/cm^3','%','','%','in','%','','','%','%',''};
xlabelLst={'(a)','(b)','(c)','(d)','(e)','(f)','(g)','(h)','(i)','(j)','(k)'};
rangePred(:,1)=[0.9,1.7];
rangePred(:,2)=[0,40];
rangePred(:,3)=[0.3,1.9];
rangePred(:,4)=[30,90];
rangePred(:,5)=[10,70];
rangePred(:,6)=[0,40];
rangePred(:,7)=[0.8,0.85];
rangePred(:,8)=[-1,1];
rangePred(:,9)=[0,50];
rangePred(:,10)=[0,75];



%%
if doSolo==0
    f=figure('Position',[1,1,2000,1000]);
end
for i=1:length(predLst)
    i
    if doSolo==0
        subplot(3,3,i)
        ix=mod(i-1,3)+1;
        iy=ceil(i/3);
        posX=0.05+0.3*(ix-1);
        posY=1-0.05-0.3*iy;
        set(gca,'Position',[posX,posY,0.25,0.3])
    else
        f=figure('Position',[1,1,800,600]);
    end
    
    pred=predLst{i};
    predData=predDataLst(:,i);
   
    colormap jet
    scatter([shape.X],[shape.Y],[],predData);hold on
    axis equal
    xlim([-126,-66])
    ylim([25,50])
    title(pred)
    xlabel(xlabelLst{i});
    h=colorbar;
    fixColorAxis(h,rangePred(:,i),5,unitStr{i},tickFormat{i});
    if i==length(predLst) % change color label for hydro group
        set(h,'YTickLabel',{'HGA','HGB','HGAD','HGC','HGD'})
    end

    for j=1:length(shpUSA)
        plot(shpUSA(j).X,shpUSA(j).Y,'--k')
    end
    colormap jet
    hold off
    
    if doSolo==1
        pred=strrep(pred,'\','-');
        pred=strrep(pred,'/','-');
        fname=[mapfolder,pred];
        fixFigure([],[fname,'.eps']);
        saveas(gcf, fname);
        close(f)
    end
end

if doSolo==0
    fname=[figfolder,'predMap'];
    fixFigure([],[fname,'.eps']);
    saveas(gcf, fname);
    close(f)
end