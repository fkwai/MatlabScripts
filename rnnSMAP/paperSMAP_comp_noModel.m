

figFolder='H:\Kuai\rnnSMAP\paper\';
stat='rmse';
switch stat
    case 'rmse'
        yRangeT=[0,0.1];
        yRangeS=[0,0.1];
        yLabelStr='RMSE';
    case 'bias'
        yRangeT=[-0.05,0.05];
        yRangeS=[-0.05,0.05];
        yLabelStr='Bias';
end

suffix = '.eps';

%% temporal test
global kPath
outName='CONUSs4f1_noModel';
trainName='CONUSs4f1';
testNameT='CONUSs4f1';
epoch=500;

[outTrainT,outT,covT]=testRnnSMAP_readData(outName,trainName,testNameT,epoch,'varLst','varLst_noModel');
statSel=statCal(outT.yLSTM,outT.ySMAP);
ind=find(statSel.rmse<0.1);

statTrain_LSTM=statCal(outTrainT.yLSTM(:,ind),outTrainT.ySMAP(:,ind));
statT_LSTM=statCal(outT.yLSTM(:,ind),outT.ySMAP(:,ind));
statTrain_NLDAS=statCal(outTrainT.yGLDAS(:,ind),outTrainT.ySMAP(:,ind));
statT_NLDAS=statCal(outT.yGLDAS(:,ind),outT.ySMAP(:,ind));
statTrain_LR=statCal(outTrainT.yLR(:,ind),outTrainT.ySMAP(:,ind));
statT_LR=statCal(outT.yLR(:,ind),outT.ySMAP(:,ind));
statTrain_NN=statCal(outTrainT.yNN(:,ind),outTrainT.ySMAP(:,ind));
statT_NN=statCal(outT.yNN(:,ind),outT.ySMAP(:,ind));
statTrain_LRpbp=statCal(outTrainT.yLRpbp(:,ind),outTrainT.ySMAP(:,ind));
statT_LRpbp=statCal(outT.yLRpbp(:,ind),outT.ySMAP(:,ind));
statTrain_NNpbp=statCal(outTrainT.yNNpbp(:,ind),outTrainT.ySMAP(:,ind));
statT_NNpbp=statCal(outT.yNNpbp(:,ind),outT.ySMAP(:,ind));

nTrain=length(statTrain_LSTM.(stat));
nT=length(statT_LSTM.(stat));
dataLst=[statTrain_LSTM.(stat);statT_LSTM.(stat);...
    statTrain_NN.(stat);statT_NN.(stat);...
    statTrain_LR.(stat);statT_LR.(stat);...
    statTrain_NNpbp.(stat);statT_NNpbp.(stat);...
    statTrain_LRpbp.(stat);statT_LRpbp.(stat);...
    statTrain_NLDAS.(stat);statT_NLDAS.(stat);];

labelLst1=[repmat({'Train'},nTrain,1);repmat({'Test'},nT,1);...
    repmat({'Train'},nTrain,1);repmat({'Test'},nT,1);...
    repmat({'Train'},nTrain,1);repmat({'Test'},nT,1);...
    repmat({'Train'},nTrain,1);repmat({'Test'},nT,1);...
    repmat({'Train'},nTrain,1);repmat({'Test'},nT,1);...
    repmat({'Train'},nTrain,1);repmat({'Test'},nT,1);];
labelLst2=[repmat({'LSTM'},nTrain+nT,1);...
    repmat({'NN'},nTrain+nT,1);...
    repmat({'LR'},nTrain+nT,1);...
    repmat({'NNp'},nTrain+nT,1);...
    repmat({'LRp'},nTrain+nT,1);...
    repmat({'Noah'},nTrain+nT,1);];

figure('Position',[1,1,800,600])
bh=boxplot(dataLst, {labelLst2,labelLst1},'colorgroup',labelLst1,...
    'factorgap',9,'factorseparator',1,'color','rk','Symbol','+','Widths',0.75);
ylabel(yLabelStr);
ylim(yRangeT)
set(gca,'xtick',1.5:3:19.5)
set(gca,'xticklabel',{'LSTM','NN','LR','NNp','LRp','Noah'})
set(bh,'LineWidth',2)
box_vars = findall(gca,'Tag','Box');
hLegend = legend(box_vars([2,1]), {'Train','Test'},'location','northwest');
if strcmp(stat,'bias')
    hline=refline([0,0]);
    set(hline,'color',[0.2 0.2 0.2],'LineWidth',1.5,'LineStyle','-.')
end
title([yLabelStr,' of Temporal Generalization Test'])

fname=[figFolder,'\','boxplot_noModel_',stat,'_Temporal'];
% fixFigure([],[fname,suffix]);
% saveas(gcf, [fname]);

%% spatial test
global kPath
outName='CONUSs4f1_noModel';
trainName='CONUSs4f1';
testNameS='CONUSs4f2';
epoch=500;

[outTrainS,outS,covS]=testRnnSMAP_readData(outName,trainName,testNameS,epoch,'timeOpt',3,'varLst','varLst_noModel');
statSel=statCal(outS.yLSTM,outS.ySMAP);
ind=find(statSel.rmse<0.1);

statTrain_LSTM=statCal(outTrainS.yLSTM(:,ind),outTrainS.ySMAP(:,ind));
statS_LSTM=statCal(outS.yLSTM(:,ind),outS.ySMAP(:,ind));
statTrain_NLDAS=statCal(outTrainS.yGLDAS(:,ind),outTrainS.ySMAP(:,ind));
statS_NLDAS=statCal(outS.yGLDAS(:,ind),outS.ySMAP(:,ind));
statTrain_LR=statCal(outTrainS.yLR(:,ind),outTrainS.ySMAP(:,ind));
statS_LR=statCal(outS.yLR(:,ind),outS.ySMAP(:,ind));
statTrain_NN=statCal(outTrainS.yNN(:,ind),outTrainS.ySMAP(:,ind));
statS_NN=statCal(outS.yNN(:,ind),outS.ySMAP(:,ind));

nTrain=length(statTrain_LSTM.(stat));
nT=length(statT_LSTM.(stat));
nS=length(statS_LSTM.(stat));

dataLst=[statTrain_LSTM.(stat);statS_LSTM.(stat);...
    statTrain_NN.(stat);statS_NN.(stat);...
    statTrain_LR.(stat);statS_LR.(stat);...
    statTrain_NLDAS.(stat);statS_NLDAS.(stat);];

labelLst1=[repmat({'Train'},nTrain,1);repmat({'Test'},nS,1);...
    repmat({'Train'},nTrain,1);repmat({'Test'},nS,1);...
    repmat({'Train'},nTrain,1);repmat({'Test'},nS,1);...
    repmat({'Train'},nTrain,1);repmat({'Test'},nS,1);];
labelLst2=[repmat({'LSTM'},nTrain+nS,1);...
    repmat({'NN'},nTrain+nS,1);...
    repmat({'LR'},nTrain+nS,1);...
    repmat({'Noah'},nTrain+nS,1);];

figure('Position',[1,1,800,600])
bh=boxplot(dataLst, {labelLst2,labelLst1},'colorgroup',labelLst1,...
    'factorgap',9,'factorseparator',1,'color','rk','Symbol','+','Widths',0.75);
ylabel(yLabelStr);
ylim(yRangeS)
set(bh,'LineWidth',2)
set(gca,'xtick',1.7:2.6:15)
set(gca,'xticklabel',{'LSTM','NN','LR','Noah'});
box_vars = findall(gca,'Tag','Box');
hLegend = legend(box_vars([2,1]), {'Train','Test'},'location','northwest');
if strcmp(stat,'bias')
    hline=refline([0,0]);
    set(hline,'color',[0.2 0.2 0.2],'LineWidth',1.5,'LineStyle','-.')
end
title([yLabelStr,' of Regular Spatial Generalization Test'])

fname=[figFolder,'\','boxplot_noModel_',stat,'_Spatial'];
% fixFigure([],[fname,suffix]);
% saveas(gcf, [fname]);

%% regional hold out - see paperSMAP_region
%{
global kPath
% outName1='regionCase1';
% outName2='regionCase1_oneModel';
% outName3='regionCase1_noModel';
% trainName='regionACDs2';
% testName='regionBs2';
outName1='regionCase2';
outName2='regionCase2_oneModel';
outName3='regionCase2_noModel';
trainName='regionBCDs2';
testName='regionAs2';
epoch=500;

stat='rmse';
yRange=[0,0.1];
yLabelStr='RMSE';

[outTrain1,out1,cov]=testRnnSMAP_readData(outName1,trainName,testName,epoch,'timeOpt',3);
[outTrain2,out2,cov2]=testRnnSMAP_readData(outName2,trainName,testName,epoch,...
    'varLst','varLst_oneModel','timeOpt',3);
[outTrain3,out3,cov3]=testRnnSMAP_readData(outName3,trainName,testName,epoch,...
    'varLst','varLst_noModel','timeOpt',3);

statTrain1_LSTM=statCal(outTrain1.yLSTM,outTrain1.ySMAP);
stat1_LSTM=statCal(out1.yLSTM,out1.ySMAP);
stat2_LSTM=statCal(out2.yLSTM,out2.ySMAP);
stat3_LSTM=statCal(out3.yLSTM,out3.ySMAP);

statTrain1_GLDAS=statCal(outTrain1.yGLDAS,outTrain1.ySMAP);
stat1_GLDAS=statCal(out1.yGLDAS,out1.ySMAP);
stat2_GLDAS=statCal(out2.yGLDAS,out2.ySMAP);
stat3_GLDAS=statCal(out3.yGLDAS,out3.ySMAP);

statTrain1_LR=statCal(outTrain1.yLR,outTrain1.ySMAP);
stat1_LR=statCal(out1.yLR,out1.ySMAP);
stat2_LR=statCal(out2.yLR,out2.ySMAP);
stat3_LR=statCal(out3.yLR,out3.ySMAP);

statTrain1_NN=statCal(outTrain1.yNN,outTrain1.ySMAP);
stat1_NN=statCal(out1.yNN,out1.ySMAP);
stat2_NN=statCal(out2.yNN,out2.ySMAP);
stat3_NN=statCal(out3.yNN,out3.ySMAP);

nTrain=length(statTrain1_LSTM.(stat));
nT=length(stat1_LSTM.(stat));

dataLst=[statTrain1_LSTM.(stat);stat1_LSTM.(stat);stat2_LSTM.(stat);stat3_LSTM.(stat);...
    statTrain1_GLDAS.(stat);stat1_GLDAS.(stat);stat2_GLDAS.(stat);stat3_GLDAS.(stat);...
    statTrain1_LR.(stat);stat1_LR.(stat);stat2_LR.(stat);stat3_LR.(stat);...
    statTrain1_NN.(stat);stat1_NN.(stat);stat2_NN.(stat);stat3_NN.(stat);];
labelLst1=[repmat({'Train'},nTrain,1);repmat({'ensemble'},nT,1);repmat({'one'},nT,1);repmat({'no'},nT,1);...
    repmat({'Train'},nTrain,1);repmat({'ensemble'},nT,1);repmat({'one'},nT,1);repmat({'no'},nT,1);...
    repmat({'Train'},nTrain,1);repmat({'ensemble'},nT,1);repmat({'one'},nT,1);repmat({'no'},nT,1);...
    repmat({'Train'},nTrain,1);repmat({'ensemble'},nT,1);repmat({'one'},nT,1);repmat({'no'},nT,1);];
labelLst2=[repmat({'LSTM'},nTrain+nT*3,1);...
    repmat({'NOAH'},nTrain+nT*3,1);...
    repmat({'LR'},nTrain+nT*3,1);...
    repmat({'NN'},nTrain+nT*3,1);];

figure('Position',[1,1,800,600])
bh=boxplot(dataLst, {labelLst2,labelLst1},'colorgroup',labelLst1,...
    'factorgap',9,'factorseparator',1,'color','rkbg','Symbol','+','Widths',0.75);
ylabel(yLabelStr);
ylim(yRange)
set(bh,'LineWidth',2)
% set(gca,'xtick',2.25:4:15)
% set(gca,'xticklabel',{'LSTM','NOAH','LR','NN'});


fname=[figFolder,'\','boxplot_',stat,'_Region'];
fixFigure([],[fname,suffix]);
saveas(gcf, [fname]);

%}


