% compare SMAP long term hindcast and insitu network

global kPath
siteName='CRN';
productName='rootzonev4f1';

%% load data
if strcmp(siteName,'CRN')
    temp=load([kPath.CRN,filesep,'Daily',filesep,'siteCRN.mat']);
    siteMat=temp.siteCRN;
    saveFolder='/mnt/sdb1/Kuai/rnnSMAP_result/crn/';
end
%[SMAP,LSTM,Noah]=readHindcastCONUS(productName,'readModel',1);
%[SMAP,LSTM,Noah] = readHindcastSite( siteName,productName,'pred',{'SOILM_0-100'});
[SMAP,LSTM,Noah] = readHindcastSite( siteName,productName,'pred',{'APCP'});



%% find index of SMAP and LSTM
indGrid=zeros(length(siteMat),1);
dist=zeros(length(siteMat),1);
for k=1:length(siteMat)
    [C,indTemp]=min(sum(abs(SMAP.crd-[siteMat(k).lat,siteMat(k).lon]),2));
    indGrid(k)=indTemp;
    dist(k)=C;
end
indRM=find(dist>1);
siteMat(indRM)=[];
indGrid(indRM)=[];
dist(indRM)=[];

% plot site map
%{
shapeUS=shaperead('/mnt/sdb1/Kuai/map/USA.shp');
for k=1:length(shapeUS)
    plot(shapeUS(k).X,shapeUS(k).Y,'k-');hold on
end
for k=1:nSite
    plot(siteMat(k).lon,siteMat(k).lat,'r*');hold on
    text(siteMat(k).lon+0.1,siteMat(k).lat+0.1,num2str(siteMat(k).ID,'%05d'),'fontsize',12);hold on
end
plot(SMAP.crd(:,2),SMAP.crd(:,1),'b.')
hold off
daspect([1,1,1])
%}

%% plot time series for each sites
for k=1:length(siteMat)
    k
    tic
    ind=indGrid(k);
    if strcmp(productName,'surface')
        tsSite.v=siteMat(k).soilM(:,1);
    elseif strcmp(productName,'rootzone') || strcmp(productName,'rootzonev4f1')
        weight=d2w_rootzone(siteMat(k).depth./100);
        weight=VectorDim(weight,1);
        tsSite.v=siteMat(k).soilM*weight;
    end
    tsSite.t=siteMat(k).tnum;
    tsLSTM.t=LSTM.t; tsLSTM.v=LSTM.v(:,ind);
    tsSMAP.t=SMAP.t; tsSMAP.v=SMAP.v(:,ind);
    tsNoah.t=Noah.t; tsNoah.v=Noah.v(:,ind)./1000;
    
    [outSite,outLSTM,outSMAP ] = splitSiteTS(tsSite,tsLSTM,tsSMAP);
    [~,outNoah,~] = splitSiteTS(tsSite,tsNoah,tsSMAP);
    
    if ~isempty(outLSTM)
        f=figure('Position',[1,1,1500,400]);
        plot(outLSTM.t,outLSTM.v,'b-');hold on
        plot(outSite.t,outSite.v,'r-');hold on
        plot(outNoah.t,outNoah.v,'g-');hold on
        plot(outSMAP.t,outSMAP.v,'ko');hold off
        title([productName,' ',num2str(siteMat(k).ID,'%05d')])
        legend('LSTM','In-situ','Noah','SMAP')
        datetick('x','yy/mm')
        figFolder=['/mnt/sdb1/Kuai/rnnSMAP_result/crn/',productName,'/'];
        saveas(f,[figFolder,num2str(siteMat(k).ID,'%05d'),'.fig'])
        close(f)
    end
    toc
end

%% calculate stat
initMat=zeros(length(siteMat),3)*nan;
statStr=struct('bias',initMat,'rmse',initMat,'ubrmse',initMat,'rho',initMat);
fieldLst=fieldnames(statStr);
for k=1:length(siteMat)
    if strcmp(productName,'surface')
        tsSite.v=siteMat(k).soilM(:,1);
    elseif strcmp(productName,'rootzone') || strcmp(productName,'rootzonev4f1')
        weight=d2w_rootzone(siteMat(k).depth./100);
        weight=VectorDim(weight,1);
        tsSite.v=siteMat(k).soilM*weight;
    end
    tsSite.t=siteMat(k).tnum;
    
    ind=indGrid(k);
    tsLSTM.t=LSTM.t; tsLSTM.v=LSTM.v(:,ind);
    tsSMAP.t=SMAP.t; tsSMAP.v=SMAP.v(:,ind);
    
    out = statCal_hindcast(tsSite,tsLSTM,tsSMAP);
    if ~isempty(out)
        for j=1:length(fieldLst)
            field=fieldLst{j};
            statStr.(field)(k,:)=[out.(field)];
        end
    end
end

%% calculate drought percentile for sites
%{
ind=indGrid(k);
if strcmp(productName,'L3')
    tsSite.v=siteMat(k).soilM(:,1);
elseif strcmp(productName,'rootzone')
    weight=d2w_rootzone(siteMat(k).depth);
    weight=VectorDim(weight,1);
    tsSite.v=siteMat(k).soilM*weight;
end
tsSite.t=siteMat(k).tnum;
tsLSTM.t=LSTM.t; tsLSTM.v=LSTM.v(:,ind);
tsSMAP.t=SMAP.t; tsSMAP.v=LSTM.v(:,ind);
tsNoah.t=Noah.t; tsNoah.v=Noah.v(:,ind);

[outLSTM,outSite,outSMAP] = findTsOverlap(tsLSTM,tsSite,tsSMAP);
[outNoah,~,~] = findTsOverlap(tsNoah,tsSite,tsSMAP);

if ~isempty(outLSTM)
    [dtLSTM,dtT]=droughtCal( outLSTM.v,outLSTM.t);
    [dtSite,~]=droughtCal( outSite.v,outLSTM.t);
    %[dtNoah,~]=droughtCal( outNoah.v,outLSTM.t);
    figure
    dtLSTM(dtLSTM>0.3)=nan;
    dtSite(dtSite>0.3)=nan;
    plot(dtT,dtLSTM,'b*-');hold on
    plot(dtT,dtSite,'r-*');hold off
    datetick('x','yy/mm')
    
    figure
    plot(outLSTM.t,outLSTM.v,'b-');hold on
    plot(outSite.t,outSite.v,'r-');hold off
    datetick('x','yy/mm')
end

%plot(dtT,dtNoah,'g-');hold off

corr(dtLSTM,dtSite)
%}

%% map of sites
shapeUS=shaperead('/mnt/sdb1/Kuai/map/USA.shp');
statLst={'bias','rmse','ubrmse','rho'};
statStrLst={'Bias','RMSE','Unbiased RMSE','Pearson Correlation'};
titleLst={'hindcast LSTM vs in-situ','training LSTM vs in-situ','training SMAP vs in-situ'};
yRangeLst=[-0.3,0.3;0,0.2;0,0.1;0,1];

f=figure('Position',[1,1,1800,1000])
for i=1:length(statLst)
    for j=1:3
        subplot(4,3,(i-1)*3+j)
        for k=1:length(shapeUS)
            plot(shapeUS(k).X,shapeUS(k).Y,'k-');hold on
        end
        colormap jet
        scatter([siteMat.lon],[siteMat.lat],80,statStr.(statLst{i})(:,j),'filled')
        colorbar
        caxis(yRangeLst(i,:))
        xlim([-126,-66])
        ylim([25,50])
        title([statStrLst{i},' of ',titleLst{j}])
        hold off
        daspect([1,1,1])
    end
end
fixFigure
saveas(f,[saveFolder,'mapStat_',productName,'.fig'])



%% calculate and plot sens slope for each site
nSite=length(siteMat);
slopeMat=zeros(nSite,2)*nan;
yearMat=zeros(nSite,2)*nan;
siteIdLst=zeros(nSite,1)*nan;
rateLst=zeros(nSite,1)*nan;
doPlot=0;
for k=1:nSite
    k
    tic
    ind=indGrid(k);
    if strcmp(productName,'surface')
        vSite=siteMat(k).soilM(:,1);
    elseif strcmp(productName,'rootzone')  || strcmp(productName,'rootzonev4f1')
        weight=d2w_rootzone(siteMat(k).depth./100);
        weight=VectorDim(weight,1);
        vSite=siteMat(k).soilM*weight;
    end
    
    tSite=siteMat(k).tnum;
    tSiteValid=tSite(~isnan(vSite));
    vLSTM=LSTM.v(:,ind);
    tLSTM=LSTM.t;
    vSMAP=SMAP.v(:,ind);
    tSMAP=SMAP.t;
    
    if ~isempty(tSiteValid)
        t1=tSiteValid(1);
        nd=t1-datenum(year(t1),1,1);
        eYr=year(tSiteValid(end));
        tt2=datenum(eYr,1,1)+nd;
        if tSiteValid(end)<tt2
            eYr=eYr-1;
            t2=datenum(eYr,1,1)+nd;
        else
            t2=tt2;
        end
        while(t2>tLSTM(end))
            eYr=eYr-1;
            t2=datenum(eYr,1,1)+nd;
        end
        if t1<t2
            v2LSTM=vLSTM(tLSTM>=t1&tLSTM<=t2);
            v2Site=vSite(tSite>=t1&tSite<=t2);
            rSite=sum(~isnan(v2Site))./length(v2Site);
            if doPlot==1
                f=figure('Position',[1,1,1500,400]);
                plot(t1:t2,v2LSTM,'b-');hold on
                plot(t1:t2,v2Site,'r-');hold on
                plot(tSMAP,vSMAP,'ko');hold on
                sensLSTM=sensSlope(v2LSTM,[t1:t2]','doPlot',1,'color','b');hold on
                sensSite=sensSlope(v2Site,[t1:t2]','doPlot',1,'color','r');hold off
                title([productName,' ',num2str(siteMat(k).ID,'%05d')])
                legend(['LSTM ', num2str(sensLSTM.sen*365*100,'%0.3f')],...
                    ['CRN ', num2str(sensSite.sen*365*100,'%0.3f')])
                datetick('x','yy/mm')
                figFolder=[saveFolder,filesep,productName,'/'];
                saveas(f,[figFolder,num2str(siteMat(k).ID,'%05d'),'_sensSlope.fig'])
                close(f)
            else
                sensLSTM=sensSlope(v2LSTM,[t1:t2]');
                sensSite=sensSlope(v2Site,[t1:t2]');
            end
            slopeLSTM=sensLSTM.sen*365*100;
            slopeSite=sensSite.sen*365*100;
            slopeMat(k,:)=[slopeSite,slopeLSTM];
            yearMat(k,:)=[year(t1),year(t2)];
            siteIdLst(k)=[siteMat(k).ID];
            rateLst(k)=rSite;
        end
    end
    toc
end
saveFolder='/mnt/sdb1/Kuai/rnnSMAP_result/crn/';
save([saveFolder,'sensSlope_',productName,'.mat'],'siteIdLst','yearMat','slopeMat','rateLst')

f=figure();
%indPick=find(rateLst>0.9 & abs(slopeMat(:,1))>0.5);
indPick=find(rateLst>0.9);
%plot(slopeMat(indPick,1),slopeMat(indPick,2),'*')
scatter(slopeMat(indPick,1),slopeMat(indPick,2),80,statStr.ubrmse(indPick,3),'fill')

corr(slopeMat(indPick,1),slopeMat(indPick,2))
xlabel('Sens Slope of Site')
ylabel('Sens Slope of LSTM')
xlim([-4,3])
ylim([-4,3])
plot121Line
saveas(f,[saveFolder,'sensSlope','_',productName,'.fig'])

[a,b]=min(abs(slopeMat(:,1)--2.207))
siteIdLst(b)
dist(b)


%% spearman correlation
%{
rhoLst=zeros(nSite,3)*nan;
rhoSLst=zeros(nSite,3)*nan;
doPlot=0;
doWeek=1;
for k=1:nSite
    k
    ind=indGrid(k);
    if strcmp(productName,'L3')
        vSite=siteMat(k).soilM(:,1);
    elseif strcmp(productName,'rootzone')
        weight=d2w_rootzone(siteMat(k).depth);
        weight=VectorDim(weight,1);
        vSite=siteMat(k).soilM*weight;
    end
    tSite=siteMat(k).tnum;
    tSiteValid=tSite(~isnan(vSite));
    if ~isempty(tSiteValid)
        t1=max(tSiteValid(1),LSTM.t(1));
        t2=SMAP.t(1);
        t3=min(SMAP.t(end),tSiteValid(end));
        if t1<t2 & t2<t3
            % seperate dataset
            tTrain=t2:t3;
            tTest=t1:t2;
            tAll=t1:t2;
            v1LSTM=LSTM.v(LSTM.t>=t1&LSTM.t<=t2,ind);
            v2LSTM=LSTM.v(LSTM.t>=t2&LSTM.t<=t3,ind);
            v1Site=vSite(tSite>=t1&tSite<=t2);
            v2Site=vSite(tSite>=t2&tSite<=t3);
            v2SMAP=SMAP.v(SMAP.t>=t2&SMAP.t<=t3,ind);
            
            if doWeek==1
                % convert to weekly
                tTestW=[tTest(1)+3:tTest(end)-3]';
                tTrainW=[tTrain(1)+3:tTrain(end)-3]';
                v1LSTM_temp=zeros(length(tTestW),7);
                v1Site_temp=zeros(length(tTestW),7);
                v2LSTM_temp=zeros(length(tTrainW),7);
                v2SMAP_temp=zeros(length(tTrainW),7);
                v2Site_temp=zeros(length(tTrainW),7);
                for kk=1:7
                    v1LSTM_temp(:,kk)=v1LSTM(kk:end-7+kk);
                    v1Site_temp(:,kk)=v1Site(kk:end-7+kk);
                    v2LSTM_temp(:,kk)=v2LSTM(kk:end-7+kk);
                    v2SMAP_temp(:,kk)=v2SMAP(kk:end-7+kk);
                    v2Site_temp(:,kk)=v2Site(kk:end-7+kk);
                end
                v1LSTM_week=nanmean(v1LSTM_temp,2);
                v1Site_week=nanmean(v1Site_temp,2);
                v2LSTM_week=nanmean(v2LSTM_temp,2);
                v2SMAP_week=nanmean(v2SMAP_temp,2);
                v2Site_week=nanmean(v2Site_temp,2);
                aLst={v1LSTM_week,v2LSTM_week,v2SMAP_week};
                bLst={v1Site_week,v2Site_week,v2Site_week};
            else
                aLst={v1LSTM,v2LSTM,v2SMAP};
                bLst={v1Site,v2Site,v2Site};
            end
            
            if doPlot==1
                f=figure('Position',[1,1,1500,400]);
                symLst={'ro','bo','ko'};
                titleLst={'hindcast Rank LSTM vs in-situ',...
                    'training Rank LSTM vs in-situ',...
                    'training Rank SMAP vs in-situ'};
                for kk=1:3
                    subplot(1,3,kk)
                    a=aLst{kk};
                    b=bLst{kk};
                    indV=find(~isnan(a)&~isnan(b));
                    nV=length(indV);
                    plot(tiedrank(a(indV))./nV,tiedrank(b(indV))./nV,symLst{kk});
                    r=corr(a(indV),b(indV),'type','Spearman');
                    plot121Line
                    title([titleLst{kk},' corr=',num2str(r,'%0.2f')]);
                end
                figFolder=['/mnt/sdb1/Kuai/rnnSMAP_result/crn/',productName,'/'];
                saveas(f,[figFolder,num2str(siteMat(k).ID,'%05d'),'_rank.fig'])
                close(f)
            else
                for kk=1:3
                    a=aLst{kk};
                    b=bLst{kk};
                    aa=a(~isnan(a)&~isnan(b));
                    bb=b(~isnan(a)&~isnan(b));
                    rhoLst(k,kk)=corr(aa,bb);
                    rhoSLst(k,kk)=corr(aa,bb,'type','Spearman');
                end
            end
        end
    end
end

plotMat=cell(2,3);
for k=1:3
    plotMat{1,k}=rhoLst(:,k);
    plotMat{2,k}=rhoSLst(:,k);
end
labelX={'hindcast LSTM vs in-situ',...
    'training LSTM vs in-situ',...
    'training SMAP vs in-situ'};
labelY={'Pearson','Spearman'};
f=plotBoxSMAP(plotMat,labelX,labelY)
ylim([0,1])
fixFigure()
figFolder=['/mnt/sdb1/Kuai/rnnSMAP_result/crn/'];
siteIdLst=[siteMat.ID]';
outMat=[siteIdLst,rhoLst,rhoSLst];
if doWeek==1
    dlmwrite([saveFolder,'corr_',productName,'_weekly.csv'],outMat,'precision',5)
    saveas(f,[figFolder,'boxCorr','_',productName,'_weekly.fig'])
    close(f)
else
    dlmwrite([saveFolder,'corr_',productName,'.csv'],outMat,'precision',5)
    saveas(f,[figFolder,'boxCorr','_',productName,'.fig'])
    close(f)
end
%}