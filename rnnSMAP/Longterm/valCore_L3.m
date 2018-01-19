
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

%% plot time series
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

%% sumarize stat to table
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




