
%% SCAN database
fileNoah=[kPath.DBSCAN,'CONUS\LSOIL_0-10.csv'];
fileSCAN=[kPath.DBSCAN,'CONUS\soilM_SCAN_2.csv'];
tSCAN=csvread([kPath.DBSCAN,'CONUS\time.csv']);
crdSCAN=csvread([kPath.DBSCAN,'CONUS\crd.csv']);

dataNoah=csvread(fileNoah);
dataNoah(dataNoah==-9999)=nan;
dataNoah=(dataNoah/100)';
dataSCAN=csvread(fileSCAN);
dataSCAN(dataSCAN==-9999)=nan;
dataSCAN=(dataSCAN/100)';

statSCAN=statCal(dataNoah,dataSCAN);

[rmseOrd,indOrd]=sort(statSCAN.rmse);
ind=indOrd(2)

%% NLDAS database
dataName='1516v12f1';
crdNoah=csvread([kPath.DBNLDAS,dataName,'\crd.csv']);
tNoah=csvread([kPath.DBNLDAS,dataName,'\time.csv']);
dist=sqrt((crdSCAN(ind,1)-crdNoah(:,1)).^2+(crdSCAN(ind,2)-crdNoah(:,2)).^2);
[minV,indNoah]=min(dist);

[yNoah,yNoahStat,yNoahNorm]=readDatabaseNLDAS(dataName,'LSOIL_0-10');
yNoah=yNoah/100;
meanNoah=yNoahStat(3);
stdNoah=yNoahStat(4);
dirOut='H:\Kuai\rnnSMAP\output_NLDASgrid\';
predFile=[dirOut,'1516v12f1\test_',dataName,'_epoch',num2str(500),'.csv'];
yLSTM=csvread(predFile);
yLSTM=(yLSTM.*stdNoah+meanNoah)/100;



%% plot
plot(tSCAN,dataNoah(:,ind),'-b');hold on
plot(tSCAN,dataSCAN(:,ind),'-r');hold on
plot(tNoah,yNoah(:,indNoah),'-g');hold on
plot(tNoah,yLSTM(:,indNoah),'-k');hold off
datetick('x')