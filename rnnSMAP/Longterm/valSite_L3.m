% compare SMAP long term hindcast and SCAN

global kPath
siteName='CRN';

%% load LSTM
rootOut=kPath.OutSMAP_L3;
rootDB=kPath.DBSMAP_L3;
outName='fullCONUS_Noah2yr';
target='SMAP';
dataName='CONUS';
SMAP.v=readDatabaseSMAP(dataName,target,rootDB);
SMAP.t=csvread([rootDB,dataName,filesep,'time.csv']);
SMAP.crd=csvread([rootDB,dataName,filesep,'crd.csv']);
% read LSTM
testLst={'LongTerm8595','LongTerm9505','LongTerm0515','CONUS'};
LSTM.v=[];
LSTM.t=[];
for k=1:length(testLst)
    tic
    vTemp=readRnnPred(outName,testLst{k},500,0,'rootOut',rootOut,'rootDB',rootDB,'target',target);
    tTemp=csvread([rootDB,testLst{k},filesep,'time.csv']);
    if k>1
        LSTM.v=[LSTM.v;vTemp(2:end,:)];
        LSTM.t=[LSTM.t;tTemp(2:end,:)];
    else
        LSTM.v=vTemp;
        LSTM.t=tTemp;
    end
    toc
end
LSTM.crd=csvread([rootDB,testLst{1},filesep,'crd.csv']);

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

%% calculate sens slope
slopeMat=zeros(nSite,2)*nan;
yearMat=zeros(nSite,2)*nan;
for k=1:nSite
    k
    tic
    ind=indGrid(k);
    vSite=siteMat(k).soilM(:,1);
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
        if t1~=t2
            v2LSTM=vLSTM(tLSTM>=t1&tLSTM<=t2);
            v2Site=vSite(tSite>=t1&tSite<=t2);
            sensLSTM=sensSlope(v2LSTM,[t1:t2]');
            sensSite=sensSlope(v2Site,[t1:t2]');
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
dlmwrite([saveFolder,'sensSlope_L3.csv'],outMat,'precision',4)

%% plot time series
for k=1:nSite  
    ind=indGrid(k);
    vSite=siteMat(k).soilM(:,1);
    tSite=siteMat(k).tnum;
    tSiteValid=tSite(~isnan(vSite));
    vLSTM=LSTM.v(:,ind);
    tLSTM=LSTM.t;
    vSMAP=SMAP.v(:,ind);
    tSMAP=SMAP.t;
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
        f=figure('Position',[1,1,1500,400]);
        plot(t1:t2,v2LSTM,'b-');hold on
        plot(t1:t2,v2Site,'r-');hold on
        plot(tSMAP,vSMAP,'ko');hold on
        sensLSTM=sensSlope(v2LSTM,[t1:t2]','doPlot',1,'color','b');hold on
        sensSite=sensSlope(v2Site,[t1:t2]','doPlot',1,'color','r');hold off
        title(num2str(siteMat(k).ID,'%04d'))
        legend(['LSTM ', num2str(sensLSTM.sen*365*100,'%0.3f')],...
            ['CRN ', num2str(sensSite.sen*365*100,'%0.3f')])
        datetick('x','yy/mm')
        
        figFolder='/mnt/sdb1/Kuai/rnnSMAP_result/crn/L3/';
        saveas(f,[figFolder,num2str(siteMat(k).ID,'%05d'),'.fig'])
        close(f)
    end
end

slopeSite=outMat(:,4);
slopeLSTM=outMat(:,5);
ind=find(abs(slopeSite)<0.5);
plot(outMat(ind,4),outMat(ind,5),'*')

