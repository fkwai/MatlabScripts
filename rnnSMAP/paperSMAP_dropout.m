
global kPath
trainName='CONUSs4f1';
testName='CONUSs4f1';
epoch=500;
outName0='CONUSs4f1_dr0';
outName1='CONUSs4f1';
outName2='CONUSs4f1_dr075';
outName3='CONUSs4f1_dr025';
outName0G='CONUSs4f1_dr0_Gal';
outName1G='CONUSs4f1_dr050_Gal';
outName2G='CONUSs4f1_dr075_Gal';

%% read data
% [outTrain0,out0]=testRnnSMAP_readData(outName0,trainName,testName,epoch,'readCov',0);
% [outTrain1,out1]=testRnnSMAP_readData(outName1,trainName,testName,epoch,'readCov',0);
% [outTrain2,out2]=testRnnSMAP_readData(outName2,trainName,testName,epoch,'readCov',0);
% [outTrain3,out3]=testRnnSMAP_readData(outName3,trainName,testName,epoch,'readCov',0);
% 
% [outTrain0G,out0G]=testRnnSMAP_readData(outName0G,trainName,testName,epoch,'readCov',0);
% [outTrain1G,out1G]=testRnnSMAP_readData(outName1G,trainName,testName,epoch,'readCov',0);
% [outTrain2G,out2G]=testRnnSMAP_readData(outName2G,trainName,testName,epoch,'readCov',0);
% 
% statTrain0=statCal(outTrain0.yLSTM,outTrain0.ySMAP);
% stat0=statCal(out0.yLSTM,out0.ySMAP);
% statTrain1=statCal(outTrain1.yLSTM,outTrain1.ySMAP);
% stat1=statCal(out1.yLSTM,out1.ySMAP);
% statTrain2=statCal(outTrain2.yLSTM,outTrain2.ySMAP);
% stat2=statCal(out2.yLSTM,out2.ySMAP);
% statTrain3=statCal(outTrain3.yLSTM,outTrain3.ySMAP);
% stat3=statCal(out3.yLSTM,out3.ySMAP);
% 
% statTrain0G=statCal(outTrain0G.yLSTM,outTrain0G.ySMAP);
% stat0G=statCal(out0G.yLSTM,out0G.ySMAP);
% statTrain1G=statCal(outTrain1G.yLSTM,outTrain1G.ySMAP);
% stat1G=statCal(out1G.yLSTM,out1G.ySMAP);
% statTrain2G=statCal(outTrain2G.yLSTM,outTrain2G.ySMAP);
% stat2G=statCal(out2G.yLSTM,out2G.ySMAP);

%% plot
figFolder='H:\Kuai\rnnSMAP\paper\';
stat='bias';
yRange=[-0.05,0.05];
yLabelStr='Bias';
suffix = '.jpg';

nTrain=length(statTrain0.(stat));
nT=length(stat0.(stat));
dataLst=[statTrain0.(stat);stat0.(stat);...
    statTrain1.(stat);stat1.(stat);...
    statTrain2.(stat);stat2.(stat);];
labelLst1=[repmat({'Train'},nTrain,1);repmat({'Test'},nT,1);...
    repmat({'Train'},nTrain,1);repmat({'Test'},nT,1);...
    repmat({'Train'},nTrain,1);repmat({'Test'},nT,1);];
labelLst2=[repmat({'Dr = 0'},nTrain+nT,1);...    
    repmat({'Dr = 0.5'},nTrain+nT,1);...
    repmat({'Dr = 0.75'},nTrain+nT,1);];

figure('Position',[1,1,800,600])
bh=boxplot(dataLst, {labelLst2,labelLst1},'colorgroup',labelLst1,...
    'factorgap',9,'factorseparator',1,'color','rk','Symbol','+','Widths',0.75);
ylim(yRange)
ylabel(yLabelStr)
%xlabel('Dropout Rate')
set(gca,'xtick',1.65:2.45:19.5)
set(gca,'xticklabel',{'0','0.5','0.75'})
set(bh,'LineWidth',2)

fname=[figFolder,'\','boxplot_',stat,'_Dropout'];
fixFigure([],[fname,suffix]);
saveas(gcf, [fname]);

%%
nTrain=length(statTrain0.(stat));
nT=length(stat0.(stat));
dataLst=[statTrain0G.(stat);stat0G.(stat);...
    statTrain1G.(stat);stat1G.(stat);...
    statTrain2G.(stat);stat2G.(stat);];
labelLst1=[repmat({'Train'},nTrain,1);repmat({'Test'},nT,1);...
    repmat({'Train'},nTrain,1);repmat({'Test'},nT,1);...
    repmat({'Train'},nTrain,1);repmat({'Test'},nT,1);];
labelLst2=[repmat({'Dr = 0'},nTrain+nT,1);...    
    repmat({'Dr = 0.5'},nTrain+nT,1);...
    repmat({'Dr = 0.75'},nTrain+nT,1);];

figure('Position',[1,1,800,600])
bh=boxplot(dataLst, {labelLst2,labelLst1},'colorgroup',labelLst1,...
    'factorgap',9,'factorseparator',1,'color','rk','Symbol','+','Widths',0.75);
ylim(yRange)
ylabel(yLabelStr)
%xlabel('Dropout Rate')
set(gca,'xtick',1.65:2.45:19.5)
set(gca,'xticklabel',{'0','0.5','0.75'})
set(bh,'LineWidth',2)

fname=[figFolder,'\','boxplot_',stat,'_Dropout_Gal'];
fixFigure([],[fname,suffix]);
saveas(gcf, [fname]);

