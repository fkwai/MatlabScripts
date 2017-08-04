
sd=20150401;
ed=20170401;
sdn=datenumMulti(sd,1);
edn=datenumMulti(ed,1);
tnum=[sdn:edn]';

siteInd=32;
epoch=500;
global kPath
outFolder=[kPath.OutSCAN,'site',num2str(siteInd),kPath.s];
%outFolder=[kPath.OutSCAN,'site',num2str(siteInd),'_noModel',kPath.s];
dataFolder=[kPath.DBSCAN,'CONUS',kPath.s];

yField='soilM_SCAN_40';
yData=csvread([dataFolder,yField,'.csv']);
yStat=csvread([dataFolder,yField,'_stat.csv']);
yMean=yStat(3);
yStd=yStat(4);
y=yData(siteInd,:);
trainFile=[outFolder,'out_CONUS_CONUS_',num2str(epoch),'\000001_train.csv'];
testFile=[outFolder,'out_CONUS_CONUS_',num2str(epoch),'\000001_test.csv'];
xData1=csvread(trainFile);
xData2=csvread(testFile);
x=[xData1;xData2]*yStd+yMean;

yField='LSOIL_40-100';
yData=csvread([dataFolder,yField,'.csv']);
y1=yData(siteInd,:)./6;

yField='LSOIL_100-200';
yData=csvread([dataFolder,yField,'.csv']);
y2=yData(siteInd,:)./10;

figure('Position',[1,1,1200,400])
plot(tnum,x,'-r','LineWidth',2);hold on
plot(tnum,y,'-b','LineWidth',2);hold on
plot(tnum,y1,'--k','LineWidth',2);hold on
plot(tnum,y2,'-k','LineWidth',2);hold off
datetick('x','yy/mm')
xlim([tnum(1),tnum(end)])
ylabel('Soil Moisture [%]')
xlabel('Time')
legend('LSTM','SCAN 100 cm','NOAH 40-100 cm','NOAH 100-200 cm','Location','northwest')

suffix = '.eps';
fname=['H:\Kuai\rnnGAGE\outputSCAN\','site',num2str(siteInd)];
fixFigure([],[fname,suffix]);
saveas(gcf, fname);


