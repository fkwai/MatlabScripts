
global kPath
dirCoreSite=[kPath.SMAP_VAL,'coresite',filesep];

%% load site
resStr='36';
load([dirCoreSite,'siteMat',filesep,'sitePix_',resStr,'.mat']);
indRM=[];
versionLst=[];
for k=1:length(sitePixel)
    if strcmp(sitePixel(k).ID(1:4),'2701') % 2701 is out of bound
        indRM=[indRM,k];
    end
    if k>1
        versionLst(k)=sum(ismember({sitePixel(1:k-1).ID},sitePixel(k).ID));
    end
end
for k=1:length(sitePixel)
    if versionLst(k)>0
        sitePixel(k).ID=[sitePixel(k).ID,'0',num2str(versionLst(k)+1)];
    end
end
sitePixel(indRM)=[];

%% fine SMAP CONUS index
maskSMAP=load(kPath.maskSMAP_CONUS);
indSMAPLst=[];
for k=1:length(sitePixel)
    [C1,indX]=min(abs(maskSMAP.lon-sitePixel(k).crdC(2)));
    [C2,indY]=min(abs(maskSMAP.lat-sitePixel(k).crdC(1)));
    disp([sitePixel(k).ID,': ',num2str(C1,3),' ',num2str(C2,3)])
    indSMAP=maskSMAP.maskInd(indY,indX);
    indSMAPLst=[indSMAPLst;indSMAP];
end
indSubset=unique(indSMAPLst);


%% do subset of those pixels and run test
%{
indSubset=unique(indSMAPLst);
rootNameLst={'CONUS','LongTerm8595','LongTerm9505','LongTerm0515'};
for k=1:length(rootNameLst)
    rootName=rootNameLst{k};
    subsetFile=[kPath.DBSMAP_L3,'Subset',filesep,rootName,'site.csv'];
    dlmwrite(subsetFile,rootName,'');
    dlmwrite(subsetFile,indSubset,'-append');
end

for k=1:length(rootNameLst)
    rootName=rootNameLst{k};
    subsetName=[rootName,'site'];
    if strcmp(rootName,'CONUS')
        subsetSplit(subsetName,'dirRoot',kPath.DBSMAP_L3);
    else
        subsetSplit(subsetName,'dirRoot',kPath.DBSMAP_L3,'varLst','varLst_Noah');
    end
end
%}

% run testLSTM on those pixels then
%{
CUDA_VISIBLE_DEVICES=0 th testLSTM_SMAP.lua -gpu 1 -out fullCONUS_Noah2yr -test CONUSsite -timeOpt 0
CUDA_VISIBLE_DEVICES=0 th testLSTM_SMAP.lua -gpu 1 -out fullCONUS_Noah2yr -test LongTerm8595site -timeOpt 0
CUDA_VISIBLE_DEVICES=0 th testLSTM_SMAP.lua -gpu 1 -out fullCONUS_Noah2yr -test LongTerm9505site -timeOpt 0
CUDA_VISIBLE_DEVICES=0 th testLSTM_SMAP.lua -gpu 1 -out fullCONUS_Noah2yr -test LongTerm0515site -timeOpt 0
%}

%% read SMAP and LSTM
rootOut=kPath.OutSMAP_L3;
rootDB=kPath.DBSMAP_L3;
outName='fullCONUS_Noah2yr';
target='SMAP';
dataName='CONUSsite';
SMAP.v=readDatabaseSMAP(dataName,target,rootDB);
SMAP.t=csvread([rootDB,dataName,filesep,'time.csv']);
SMAP.crd=csvread([rootDB,dataName,filesep,'crd.csv']);

testLst={'LongTerm8595site','LongTerm9505site','LongTerm0515site','CONUSsite'};
LSTM.v=[];
LSTM.t=[];
for k=1:length(testLst)
    vTemp=readRnnPred(outName,testLst{k},500,0,'rootOut',rootOut,'rootDB',rootDB,'target',target);
    tTemp=csvread([rootDB,testLst{k},filesep,'time.csv']);
    if k>1
        LSTM.v=[LSTM.v;vTemp(2:end,:)];
        LSTM.t=[LSTM.t;tTemp(2:end,:)];
    end
end
LSTM.crd=csvread([rootDB,testLst{1},filesep,'crd.csv']);


%% find index of smap and LSTM
nSite=length(sitePixel);
indTest=zeros(nSite,1);
for k=1:nSite
    [C,indTemp]=min(sum(abs(SMAP.crd-sitePixel(k).crdC),2));
    if C>0.3
        error(['check if corresponding pixel is found: ',num2str(k)])
    end
    indTest(k)=indTemp;
end

%% calculate stats
figFolder='/mnt/sdb1/Kuai/rnnSMAP_result/insitu/L3/';
rateLst=[0,0.25,0.5,0.75,1];
outAll=[];
for j=1:length(rateLst)
    rate=rateLst(j);
    siteIDvec=[];
    out=struct('rmse',[],'bias',[],'rsq',[],'ubrmse',[]);
    fieldLst=fieldnames(out);
    for k=1:nSite
        ind=indTest(k);
        tsSite.v=sitePixel(k).v(:,1);
        tsSite.r=sitePixel(k).r(:,1);
        tsSite.t=sitePixel(k).t;
        tsSite.v(tsSite.r<rate)=nan;
        tsLSTM.v=LSTM.v(:,ind);
        tsLSTM.t=LSTM.t;
        tsSMAP.v=SMAP.v(:,ind);
        tsSMAP.t=SMAP.t;
        temp = statCal_hindcast( tsSite,tsLSTM,tsSMAP);
        for i=1:length(fieldLst)
            out.(fieldLst{i})=[out.(fieldLst{i});temp.(fieldLst{i})];
        end
    end
    outAll=[outAll;out];
end

%pick site and rate
pSite=[1;3;6;9;13;18;22;23;26];
pRate=[1;3;1;1;3;1;3;3;3];
pLabel={{'Reynolds';'Creek'},'Carman',{'Walnut';'Gulch'},...
    {'Little';'Washita'},{'Fort';'Cobb'},{'Little';'River'},...
    {'St.';'Josephs'},{'South';'Fork'},'TxSON'};
pName={'Reynolds Creek','Carman','Walnut Gulch',...
    'Little Washita','Fort Cobb','Little River',...
    'St. Josephs','South Fork','TxSON'};


%% plot stat in bar plot
figFolder='/mnt/sdb1/Kuai/rnnSMAP_result/insitu/';
barMat=zeros(length(pSite),3);
xLabel=cell(length(pSite),1);
statLst={'rmse','rsq','ubrmse'};
titleStrLst={'RMSE','Correlation','Unbiased RMSE'}
for i=1:length(statLst)
    stat=statLst{i};
    f=figure('Position',[1,1,1000,500]);
    for k=1:length(pSite)
        indSite=pSite(k);
        indR=pRate(k);
        barMat(k,:)=outAll(indR).(stat)(indSite,:);
    end
    clr=[1,0,0;...
        0,1,0.5;...
        0,0,1];
    colormap(clr)
    bar(barMat)
    legend('hindcast LSTM vs in-situ',...
        'training LSTM vs in-situ',...
        'training SMAP vs in-situ','location','best')
    title(titleStrLst{i});
    xTickText(1:length(pSite),pLabel,'fontsize',16);
    fixFigure
    saveas(f,[figFolder,'barPlot_',stat,'_L3.fig'])
end

%% plot time series - picked
figFolder='/mnt/sdb1/Kuai/rnnSMAP_result/insitu/L3_pick/';
for k=1:length(pSite)
    f=figure('Position',[1,1,1500,400]);
    lineW=2;
    indSite=pSite(k);
    ind=indTest(indSite);    
    sdTrain=SMAP.t(1);
    sdSite=sitePixel(indSite).t(1);
    sdLSTM=find(LSTM.t==sdSite);
    
    % site
    rate=sitePixel(indSite).r(:,1);
    siteV=sitePixel(indSite).v(:,1);
    siteV(rate<rateLst(pRate(k)))=nan;
    hold on
    plot(sitePixel(indSite).t,siteV,'-r','LineWidth',lineW);    
    plot(LSTM.t(sdLSTM:end),LSTM.v(sdLSTM:end,ind),'-b','LineWidth',lineW);
    plot(SMAP.t,SMAP.v(:,ind),'ko','LineWidth',lineW);
    plot([sdTrain,sdTrain], ylim,'k-','LineWidth',lineW);
    hold off
    datetick('x','yy/mm')
    xlim([sdSite,SMAP.t(end)])
    title(['Hindcast of site: ', pName{k},' ',sitePixel(indSite).ID(1:4)])
    legend('in-situ','LSTM','SMAP')
    fixFigure
    saveas(f,[figFolder,sitePixel(indSite).ID(1:4),'.fig'])    
    close(f)
end

%% for 1640
figFolder='/mnt/sdb1/Kuai/rnnSMAP_result/insitu/L3_pick/';
k=6
f=figure('Position',[1,1,1500,400]);
lineW=2;
indSite=pSite(k);
ind=indTest(indSite);
sdTrain=SMAP.t(1);
sdSite=sitePixel(indSite).t(1);
sdLSTM=find(LSTM.t==sdSite);

tLSTM=LSTM.t(sdLSTM:end);
vLSTM=LSTM.v(sdLSTM:end,ind);
siteV2=siteV-nanmean(siteV)+nanmean(vLSTM);

% site
rate=sitePixel(indSite).r(:,1);
siteV=sitePixel(indSite).v(:,1);
siteV(rate<rateLst(pRate(k)))=nan;
hold on
plot(sitePixel(indSite).t,siteV2,'-r','LineWidth',lineW);
plot(tLSTM,vLSTM,'-b','LineWidth',lineW);
plot(SMAP.t,SMAP.v(:,ind),'ko','LineWidth',lineW);
plot([sdTrain,sdTrain], ylim,'k-','LineWidth',lineW);
hold off
datetick('x','yy/mm')
xlim([sdSite,SMAP.t(end)])
title(['Hindcast of site: ', pName{k},' ',sitePixel(indSite).ID(1:4)])
legend('in-situ','LSTM','SMAP')
fixFigure
saveas(f,[figFolder,sitePixel(indSite).ID(1:4),'_fix.fig'])

%% plot time series - different rate
figFolder='/mnt/sdb1/Kuai/rnnSMAP_result/insitu/L3/';
for k=1:nSite
    f=figure('Position',[1,1,1500,400]);
    lineW=2;
    ind=indTest(k);
    sdTrain=SMAP.t(1);
    sdSite=sitePixel(k).t(1);
    
    % site
    rate=sitePixel(k).r(:,1);
    rateLst=[0,0.25,0.5,0.75,1];
    cLst=flipud(autumn(length(rateLst)));
    hold on
    for kk=1:length(rateLst)
        siteV=sitePixel(k).v(:,1);
        siteV(rate<rateLst(kk),1)=nan;
        if rateLst(kk)==1
            plot(sitePixel(k).t,siteV,'*-','LineWidth',lineW,'Color',cLst(kk,:));
        else
            plot(sitePixel(k).t,siteV,'-','LineWidth',lineW,'Color',cLst(kk,:));
        end
    end
    
    plot(LSTM.t,LSTM.v(:,ind),'-b','LineWidth',lineW);
    plot(SMAP.t,SMAP.v(:,ind),'ko','LineWidth',lineW);
    plot([sdTrain,sdTrain], ylim,'k-','LineWidth',lineW);
    hold off
    datetick('x','yy/mm')
    xlim([sdSite,SMAP.t(end)])
    title(['Hindcast of site: ', sitePixel(k).ID])
    legend('insitu 0%','insitu 25%','insitu 50%','insitu 75%','insitu 100%','LSTM','SMAP')
    saveas(f,[figFolder,sitePixel(k).ID,'.fig'])
    close(f)
end

%% sumarize stat to table -- need modify if need in paper
figFolder='/mnt/sdb1/Kuai/rnnSMAP_result/insitu/L3/';
rateLst=[0,0.5,0.8,1];
for j=1:length(rateLst)
    rate=rateLst(j);
    siteIDvec=[];
    out=struct('rmse',[],'bias',[],'rsq',[],'ubrmse',[]);
    fieldLst=fieldnames(out);
    for k=1:nSite
        ind=indTest(k);
        tsSite.v=sitePixel(k).v(:,1);
        tsSite.r=sitePixel(k).r(:,1);
        tsSite.t=sitePixel(k).t;
        tsSite.v(tsSite.r<rate)=nan;
        tsLSTM.v=LSTM.v(:,ind);
        tsLSTM.t=LSTM.t;
        tsSMAP.v=SMAP.v(:,ind);
        tsSMAP.t=SMAP.t;
        temp = statCal_hindcast( tsSite,tsLSTM,tsSMAP);
        for i=1:length(fieldLst)
            out.(fieldLst{i})=[out.(fieldLst{i});temp.(fieldLst{i})];
        end
        siteIDvec=[siteIDvec;str2num(sitePixel(k).ID)];
    end
    for i=1:length(fieldLst)
        dlmwrite([figFolder,fieldLst{i},'Tab_',num2str(rate*100),'.csv'],[siteIDvec,out.(fieldLst{i})],'precision',10)
    end
end


%% calculate sensSlope
slopeMat=zeros(nSite,2);
figFolder='/mnt/sdb1/Kuai/rnnSMAP_result/insitu/L3/';
for k=1:nSite
    ind=indTest(k);
    tsSite.v=sitePixel(k).v(:,1);
    tsSite.r=sitePixel(k).r(:,1);
    tsSite.t=sitePixel(k).t;
    tsLSTM.v=LSTM.v(:,ind);
    tsLSTM.t=LSTM.t;
    tsSMAP.v=SMAP.v(:,ind);
    tsSMAP.t=SMAP.t;
    
    tSiteValid=tsSite.t(~isnan(tsSite.v));
    if tSiteValid(1)<datenumMulti(20130401)
        t1=datenumMulti(20130401);
    elseif tSiteValid(1)<datenumMulti(20140401)
        t1=datenumMulti(20140401);
    elseif tSiteValid(1)<datenumMulti(20150401)
        t1=datenumMulti(20150401);
    end
    t2=tsSMAP.t(1);
    t3=min(tsLSTM.t(end),tsSite.t(end));
    vLSTM=tsLSTM.v(tsLSTM.t>=t1&tsLSTM.t<=t3);
    vSite=tsSite.v(tsSite.t>=t1&tsSite.t<=t3);
    
    f=figure('Position',[1,1,1500,300]);
    plot([t1:t3],vSite,'r-','LineWidth',1);hold on
    plot([t1:t3],vLSTM,'b-','LineWidth',1);hold on
    out1=sensSlope( vSite,[t1:t3]','doPlot',1,'color','r');hold on
    out2=sensSlope( vLSTM,[t1:t3]','doPlot',1,'color','b');hold on
    plot([t2,t2], ylim,'k-');hold off
    datetick('x','yy/mm')
    xlim([t1,t3])
    title(['Hindcast of site: ', sitePixel(k).ID])
    saveas(f,[figFolder,sitePixel(k).ID,'_slope.fig'])
    close(f)
    slopeMat(k,:)=[out1.sen,out2.sen];
end




