
sd=20150401;
ed=20170401;
sdn=datenumMulti(sd,1);
edn=datenumMulti(ed,1);
tnum=[sdn:edn]';

indName='indDouble';
epoch=500;
global kPath
dataFolder=[kPath.DBSCAN,'CONUS',kPath.s];
outFolder=[kPath.OutSCAN,indName,kPath.s];
%outFolder=[kPath.OutSCAN,indName,'_noModel',kPath.s];

indLst=csvread([dataFolder,indName,'.csv']);
nSite=length(indLst);

trainFile=[outFolder,'out_CONUS_CONUS_',num2str(epoch),kPath.s,sprintf('%06d',2),'_train.csv'];
testFile=[outFolder,'out_CONUS_CONUS_',num2str(epoch),kPath.s,sprintf('%06d',2),'_test.csv'];
xData1=csvread(trainFile);
xData2=csvread(testFile);
xData=[xData1;xData2];

for k=1:nSite
siteInd=indLst(k);

yField='soilM_SCAN_40';
yData=csvread([dataFolder,yField,'.csv']);
yStat=csvread([dataFolder,yField,'_stat.csv']);
yMean=yStat(3);
yStd=yStat(4);
y=yData(siteInd,:);
x=xData(:,k)*yStd+yMean;

yField='LSOIL_40-100';
yData=csvread([dataFolder,yField,'.csv']);
y1=yData(siteInd,:)./6;

yField='LSOIL_100-200';
yData=csvread([dataFolder,yField,'.csv']);
y2=yData(siteInd,:)./10;

subplot(2,1,k)
plot(tnum,x,'-r');hold on
plot(tnum,y,'-b');hold on
plot(tnum,y1,'--k');hold on
plot(tnum,y2,'-k');hold off

legend('LSTM','SCAN 100 cm','NOAH 40-100 cm','NOAH 100-120 cm','location','northwest')
end