% 

outFolder='Y:\Kuai\rnnPAWS\extended\';
iterList=200:200:1000;

saveSingleFig=0;
F=load('Y:\Kuai\rnnPAWS\F.mat');
dataFolder='Y:\Kuai\rnnPAWS\';
figfolder='Y:\Kuai\rnnPAWS\figure';
mkdir(figfolder)

statFile=[dataFolder,'\statObs.csv'];
stat=csvread(statFile);
lb=stat(1);
ub=stat(2);
t=F.obs.t;
y=F.obs.v;
tTrain=1127;

if saveSingleFig==0
    f=figure('Position',[100,200,1800,400]);
    c=flipud(autumn(length(iterList)));
    plot(t,y,'b');hold on
    legendstr={'PAWS'};
end

for k=1:length(iterList)
    iter=iterList(k);
    outfile=[outFolder,'out_',num2str(iter),'.csv'];
    outNorm=csvread(outfile);
    yp=(outNorm+1).*(ub-lb)./2+lb;
    y1=y(1:tTrain-1);
    y2=y(tTrain:end);
    yp1=yp(1:tTrain-1);
    yp2=yp(tTrain:end);
    nash1=1-nansum((yp1-y1).^2)./nansum((y1-repmat(nanmean(y1),[tTrain-1,1])).^2);
    nash2=1-nansum((yp2-y2).^2)./nansum((y2-repmat(nanmean(y2),[length(t)-tTrain+1,1])).^2);
    if saveSingleFig==1
        f=figure('Position',[100,200,1800,400])
        plot(t,y,'b');hold on
        plot(t,yp,'r');hold off
        legend('PAWS',['iter',num2str(iter),' ',num2str(nash1,'%.2f'),' ',num2str(nash2,'%.2f')]);
        datetick('x','yyyymm');
        title(['Extended Learning iter',num2str(iter)])
        saveas(f,[figfolder,'\extended_iter',num2str(iter),'.fig'])

    else
        plot(t,yp,'-','color',c(k,:))
        legendstr=[legendstr,['iter',num2str(iter),' ',num2str(nash1,'%.2f'),' ',num2str(nash2,'%.2f')]];
    end 
end

if saveSingleFig==0    
    datetick('x','yyyymm');
    legend(legendstr)
    title('Extended Learning')
    saveas(f,[figfolder,'\extended.fig'])
end