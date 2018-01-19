% compare SMAP long term hindcast and SCAN

global kPath

%% read data
% SCAN
matFileSCAN=[kPath.SCAN,filesep,'siteSCAN_CONUS.mat'];
load(matFileSCAN,'siteSCAN');
% read SMAP
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


%% find index of smap and LSTM
nSite=length(siteSCAN);
indTest=zeros(nSite,1);
for k=1:nSite
    [C,indTemp]=min(sum(abs(SMAP.crd-siteSCAN(k).crd),2));
    if C>0.6
        error(['check if corresponding pixel is found: ',num2str(k)])
    end
    indTest(k)=indTemp;
end

%% calculate sens slope
slopeMat=zeros(nSite,2)*nan;
yearMat=zeros(nSite,2)*nan;
for k=1:nSite
    k
    tic
    ind=indTest(k);
    vSCAN=siteSCAN(k).soilM(:,1);
    tSCAN=siteSCAN(k).tnum;
    tSCANvalid=tSCAN(~isnan(vSCAN));
    vLSTM=LSTM.v(:,ind);
    tLSTM=LSTM.t;
    vSMAP=SMAP.v(:,ind);
    tSMAP=SMAP.t;
    
    if ~isempty(tSCANvalid)
        tt1=datenumMulti(year(tSCANvalid(1))*10000+401);
        if tSCANvalid(1)<=tt1
            t1=tt1;
        else
            t1=datenumMulti((year(tSCANvalid(1))+1)*10000+401);
        end
        tt2=datenumMulti(year(tSCANvalid(end))*10000+401);
        if tSCANvalid(end)>=tt2
            t2=tt2;
        else
            t2=datenumMulti((year(tSCANvalid(end))-1)*10000+401);
        end
        if t1~=t2
            v2LSTM=vLSTM(tLSTM>=t1&tLSTM<=t2);
            v2SCAN=vSCAN(tSCAN>=t1&tSCAN<=t2);
            sensLSTM=sensSlope(v2LSTM,[t1:t2]');
            sensSCAN=sensSlope(v2SCAN,[t1:t2]');
            slopeLSTM=sensLSTM.sen*365*1000;
            slopeSCAN=sensSCAN.sen*365*1000;
            slopeMat(k,:)=[slopeSCAN,slopeLSTM];
            yearMat(k,:)=[year(t1),year(t2)];
        end
    end
    toc
end
siteIdLst=[siteSCAN.ID]';
outMat=[siteIdLst,yearMat,slopeMat];
saveFolder='/mnt/sdb1/Kuai/rnnSMAP_result/scan/';
dlmwrite([saveFolder,'Tab_sensSlope.csv'],outMat,'precision',4)

%% plot time series
k=36
ind=indTest(k);
vSCAN=siteSCAN(k).soilM(:,1);
tSCAN=siteSCAN(k).tnum;
tSCANvalid=tSCAN(~isnan(vSCAN));
vLSTM=LSTM.v(:,ind);
tLSTM=LSTM.t;
vSMAP=SMAP.v(:,ind);
tSMAP=SMAP.t;

tt1=datenumMulti(year(tSCANvalid(1))*10000+401);
if tSCANvalid(1)<=tt1
    t1=tt1;
else
    t1=datenumMulti((year(tSCANvalid(1))+1)*10000+401);
end
tt2=datenumMulti(year(tSCANvalid(end))*10000+401);
if tSCANvalid(end)>=tt2
    t2=tt2;
else
    t2=datenumMulti((year(tSCANvalid(end))-1)*10000+401);
end

v2LSTM=vLSTM(tLSTM>=t1&tLSTM<=t2);
v2SCAN=vSCAN(tSCAN>=t1&tSCAN<=t2);
f=figure('Position',[1,1,1500,400]);
plot(t1:t2,v2LSTM,'b*');hold on
plot(t1:t2,v2SCAN,'r*');hold on
plot(tSMAP,vSMAP,'ko');hold on
sensLSTM=sensSlope(v2LSTM,[t1:t2]','doPlot',1,'color','b');hold on
sensSCAN=sensSlope(v2SCAN,[t1:t2]','doPlot',1,'color','r');hold off
title(num2str(siteSCAN(k).ID,'%04d'))
legend(['LSTM ', num2str(sensLSTM.sen*365*1000,'%0.3f')],...
    ['SCAN ', num2str(sensSCAN.sen*365*1000,'%0.3f')])
datetick('x','yy/mm')



