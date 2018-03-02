% compare SMAP long term hindcast and SCAN

global kPath
siteName='CRN';
productName='rootzone';

%% load LSTM,m SMAP and Noah
if strcmp(productName,'L3')
    rootOut=kPath.OutSMAP_L3;
    rootDB=kPath.DBSMAP_L3;
    outName='fullCONUS_Noah2yr';
    target='SMAP';
    dataName='CONUS';
    testLst={'LongTerm8595','LongTerm9505','LongTerm0515','CONUS'};
    modelName='SOILM_0-10';
elseif strcmp(productName,'rootzone')
    rootOut=kPath.OutSMAP_L4;
    rootDB=kPath.DBSMAP_L4;
    outName='CONUSv4f1_rootzone';
    target='SMGP_rootzone';
    dataName='CONUSv4f1';
    testLst={'LongTerm8595v4f1','LongTerm9505v4f1','LongTerm0515v4f1','CONUSv4f1'};
    modelName='SOILM_0-100';
end

% read SMAP
SMAP.v=readDB_SMAP(dataName,target,rootDB);
SMAP.t=csvread([rootDB,dataName,filesep,'time.csv']);
SMAP.crd=csvread([rootDB,dataName,filesep,'crd.csv']);

% read LSTM
LSTM.v=[];
LSTM.t=[];
LSTM.crd=csvread([rootDB,testLst{1},filesep,'crd.csv']);
for k=1:length(testLst)
    tic
    vTemp=readRnnPred(outName,testLst{k},500,0,'rootOut',rootOut,'rootDB',rootDB,'target',target);
    tTemp=csvread([rootDB,testLst{k},filesep,'time.csv']);
    if k>1
        LSTM.v=[LSTM.v;vTemp(2:end,:)];
        LSTM.t=[LSTM.t;tTemp(2:end)];
    else
        LSTM.v=vTemp;
        LSTM.t=tTemp;
    end
    toc
end

% Model
Noah.v=[];
Noah.t=[];
Noah.crd=csvread([rootDB,testLst{end},filesep,'crd.csv']);
for k=1:length(testLst)
    tic
    vTemp=readDB_SMAP(testLst{k},modelName,rootDB);
    if strcmp(productName,'L3')
        vTemp=vTemp./100;
    elseif strcmp(productName,'rootzone')
        vTemp=vTemp./1000;
    end
    tTemp=csvread([rootDB,testLst{k},filesep,'time.csv']);
    if k>1
        Noah.v=[Noah.v;vTemp(2:end,1:size(Noah.crd,1))];
        Noah.t=[Noah.t;tTemp(2:end)];
    else
        Noah.v=vTemp;
        Noah.t=tTemp;
    end
    toc
end


%% load site
maxDist=0.4;
if strcmp(siteName,'CRN')
    matCRN=load([kPath.CRN,filesep,'Daily',filesep,'siteCRN.mat']);
    siteMat=matCRN.siteCRN;
end

% find index of smap and LSTM
indGrid=zeros(length(siteMat),1);
dist=zeros(length(siteMat),1);
for k=1:length(siteMat)
    [C,indTemp]=min(sum(abs(SMAP.crd-[siteMat(k).lat,siteMat(k).lon]),2));
    if C>maxDist
        indGrid(k)=0;
    else
        indGrid(k)=indTemp;
    end
    dist(k)=C;
end

% remove out of bound sites
siteMat=siteMat(indGrid~=0);
indGrid(indGrid==0)=[];
nSite=length(siteMat);

%% plot site map
%{
shapeUS=shaperead('/mnt/sdb1/Kuai/map/USA.shp');
for k=1:length(shapeUS)
    plot(shapeUS(k).X,shapeUS(k).Y,'k-');hold on
end
for k=1:nSite
    plot(siteMat(k).lon,siteMat(k).lat,'r*');hold on
    text(siteMat(k).lon+0.1,siteMat(k).lat+0.1,num2str(siteMat(k).ID,'%05d'),'fontsize',12);hold on
end
hold off
daspect([1,1,1])
%}

%% plot time series for each sites
for k=1:nSite
    k
    tic
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
    tsSMAP.t=SMAP.t; tsSMAP.v=SMAP.v(:,ind);
    tsNoah.t=Noah.t; tsNoah.v=Noah.v(:,ind);
    
    [outLSTM,outSite,outSMAP] = findTsOverlap(tsLSTM,tsSite,tsSMAP);
    [outNoah,~,~] = findTsOverlap(tsNoah,tsSite,tsSMAP);
    
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

%% calculate drought percentile for sites
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


%% calculate and plot sens slope for each site
%{
slopeMat=zeros(nSite,2)*nan;
yearMat=zeros(nSite,2)*nan;
doPlot=0;
for k=1:nSite
    k
    tic
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
    vLSTM=LSTM.v(:,ind);
    tLSTM=LSTM.t;
    vSMAP=SMAP.v(:,ind);
    tSMAP=SMAP.t;
    
    if ~isempty(tSiteValid)
        tt1=datenumMulti(year(tSiteValid(1))*10000+401);
        if tSiteValid(1)<=tt1
            t1=tt1;
        else
            t1=datenumMulti((year(tSiteValid(1))+1)*10000+401);
        end
        tt2=datenumMulti(year(tSiteValid(end))*10000+401);
        if tSiteValid(end)>=tt2
            t2=tt2;
        else
            t2=datenumMulti((year(tSiteValid(end))-1)*10000+401);
        end
        if t1<t2
            v2LSTM=vLSTM(tLSTM>=t1&tLSTM<=t2);
            v2Site=vSite(tSite>=t1&tSite<=t2);
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
                figFolder=['/mnt/sdb1/Kuai/rnnSMAP_result/crn/',productName,'/'];
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
        end
    end
    toc
end
siteIdLst=[siteMat.ID]';
outMat=[siteIdLst,yearMat,slopeMat];
saveFolder='/mnt/sdb1/Kuai/rnnSMAP_result/crn/';
dlmwrite([saveFolder,'sensSlope_',productName,'.csv'],outMat,'precision',5)

outMat=csvread([saveFolder,'sensSlope_',productName,'.csv']);
slopeSite=outMat(:,4);
slopeLSTM=outMat(:,5);
f=figure();
plot(outMat(:,4),outMat(:,5),'*')
plot121Line
xlabel('Sens Slope of Site')
ylabel('Sens Slope of LSTM')
saveas(f,[figFolder,'sensSlope','_',productName,'.fig'])
%}

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