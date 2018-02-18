dirDB='H:\Kuai\rnnSMAP\Database_NLDASgrid\';
dirOut='H:\Kuai\rnnSMAP\output_NLDASgrid\';

outName='1516v12f1_Noise';
trainName='1516v12f1';
testName='0514v12f1';
obsVar='LSOIL_0-10_Noise';
load('H:\Kuai\rnnSMAP\LongTerm\yARMA_0514_Noise')


%% read Obs

[yNoah0,yNoahStat0,yNoahNorm0]=readDatabaseNLDAS(trainName,obsVar);
[yNoah1,yNoahStat1,yNoahNorm1]=readDatabaseNLDAS(testName,obsVar);
yNoah0=yNoah0/100;
yNoah1=yNoah1/100;
meanNoah=yNoahStat0(3);
stdNoah=yNoahStat0(4);


%% read Pred
predFile0=[dirOut,outName,'\test_',trainName,'_epoch500.csv'];
predFile1=[dirOut,outName,'\test_',testName,'_epoch500.csv'];
yLSTM0=csvread(predFile0);
yLSTM1=csvread(predFile1);
yLSTM0=(yLSTM0.*stdNoah+meanNoah)/100;
yLSTM1=(yLSTM1.*stdNoah+meanNoah)/100;

statLSTM0=statCal(yLSTM0,yNoah0);
statLSTM1=statCal(yLSTM1,yNoah1);
statARMA0=statCal(yARMA0,yNoah0);
statARMA1=statCal(yARMA1,yNoah1);

%% plot
f=figure('Position',[1,1,1600,300]);

ind=181
tnum=datenumMulti(20050101):datenumMulti(20161231);
tSep=datenumMulti(20150101);
v1=[yNoah1(:,ind);yNoah0(:,ind)];
v2=[yLSTM1(:,ind);yLSTM0(:,ind)];
v3=[yARMA1(:,ind);yARMA0(:,ind)];

plot([tSep,tSep],[0,1],'--k','LineWidth',2);hold on
plot(tnum,v1,'b-','LineWidth',2);hold on
plot(tnum,v2,'m--','LineWidth',2);hold on
plot(tnum,v3,'k-','LineWidth',2);hold off
datetick('x','mm/yy','keepticks')
maxY=max([v1;v2;v3]);
minY=max(0,min([v1;v2;v3]));
ylim([minY,minY+(maxY-minY)*1.15])
xlim([datenumMulti(20100101),datenumMulti(20161231)])

% px0=0.05+0.48*(col-1);
% py0=0.1+(3-row)*0.3;
width=0.45;
heigth=0.25;
set(gca,'Position',[0.05,0.1,0.9,0.75])
text(tSep+40,maxY,'Train','fontSize',18,'Margin',6)
text(tSep-200,maxY,'Test','fontSize',18,'Margin',6)

title('Proof-of-concept Long-term Hindcast w/ Noah as target')
fname=[figFolder,'\','timeSeries_longTerm'];
fixFigure([],[fname,suffix]);
saveas(gcf, [fname]);
