
figFolder='H:\Kuai\rnnSMAP\paper\';
suffix = '.jpg';

global kPath
Alphabet=char('A'+(1:26)-1)';
hucLst='ABHK';
hucIndLst=double(hucLst)-64;
trainName='hucABHKs4';
outName1=trainName;
outName2=[trainName,'_oneModel'];
outName3=[trainName,'_noModel'];
epoch=100;

stat='bias';
switch stat
    case 'rmse'
        yRange=[0,0.1];
        yLabelStr='RMSE';
    case 'bias'
        yRange=[-0.1,0.1];
        yLabelStr='Bias';
end

%% init
ySMAP=[];
yLSTM1_train=[];
yLSTM2_train=[];
yLSTM3_train=[];
yLSTM1=[];
yLSTM2=[];
yLSTM3=[];
yLR1_train=[];
yLR2_train=[];
yLR3_train=[];
yLR1=[];
yLR2=[];
yLR3=[];
yNN1_train=[];
yNN2_train=[];
yNN3_train=[];
yNN1=[];
yNN2=[];
yNN3=[];
yNOAH_train=[];
yVIC_train=[];
yMOS_train=[];
yNOAH=[];
yVIC=[];
yMOS=[];
nHUC=12;
tTest=1:366;

%% read data
for k=1:nHUC
    if ~ismember(k,hucIndLst)
        testName=['huc',Alphabet(k),'s2'];
        [outTrain1,out1,cov1]=testRnnSMAP_readData(outName1,trainName,testName,epoch,...
            'timeOpt',3,'readData',0);
        [outTrain2,out2,cov2]=testRnnSMAP_readData(outName2,trainName,testName,epoch,...
            'varLst','varLst_oneModel','timeOpt',3,'readData',0);
        [outTrain3,out3,cov3]=testRnnSMAP_readData(outName3,trainName,testName,epoch,...
            'varLst','varLst_noModel','timeOpt',3,'readData',0);
        
        ySMAP=[ySMAP,out1.ySMAP];
        yLSTM1_train=[yLSTM1_train];
        yLSTM1=[yLSTM1,out1.yLSTM];
        yLSTM2=[yLSTM2,out2.yLSTM];
        yLSTM3=[yLSTM3,out3.yLSTM];
        
        yNN1=[yNN1,out1.yNN];
        yNN2=[yNN2,out2.yNN];
        yNN3=[yNN3,out3.yNN];
        
        yLR1=[yLR1,out1.yLR];
        yLR2=[yLR2,out2.yLR];
        yLR3=[yLR3,out3.yLR];
        
        [dataTest,dataStat] = readDatabaseSMAP(testName,'LSOIL');
        yNOAH=[yNOAH,dataTest(tTest,:)/100];
        [dataTest,dataStat] = readDatabaseSMAP(testName,'LOIL_VIC');
        yVIC=[yVIC,dataTest(tTest,:)/100];
        [dataTest,dataStat] = readDatabaseSMAP(testName,'SOILM_MOS');
        yMOS=[yMOS,dataTest(tTest,:)/100];
    end
end

%% calculate stat
stat_LSTM1=statCal(yLSTM1,ySMAP);
stat_LSTM2=statCal(yLSTM2,ySMAP);
stat_LSTM3=statCal(yLSTM3,ySMAP);

stat_LR1=statCal(yLR1,ySMAP);
stat_LR2=statCal(yLR2,ySMAP);
stat_LR3=statCal(yLR3,ySMAP);

stat_NN1=statCal(yNN1,ySMAP);
stat_NN2=statCal(yNN2,ySMAP);
stat_NN3=statCal(yNN3,ySMAP);

stat_NOAH=statCal(yNOAH,ySMAP);
stat_VIC=statCal(yVIC,ySMAP);
stat_MOS=statCal(yMOS,ySMAP);

%% plot
nT=length(stat_LSTM1.(stat));
dataLst=[stat_LSTM1.(stat);stat_LSTM2.(stat);stat_LSTM3.(stat);...
    stat_LR1.(stat);stat_LR2.(stat);stat_LR3.(stat);...
    stat_NN1.(stat);stat_NN2.(stat);stat_NN3.(stat);...
    stat_NOAH.(stat);stat_VIC.(stat);stat_MOS.(stat)];
labelLst1=[repmat({'ensemble'},nT,1);repmat({'Noah'},nT,1);repmat({'no'},nT,1);...
    repmat({'ensemble'},nT,1);repmat({'Noah'},nT,1);repmat({'no'},nT,1);...
    repmat({'ensemble'},nT,1);repmat({'Noah'},nT,1);repmat({'no'},nT,1);...
    repmat({'Noah_model'},nT,1);repmat({'VIC'},nT,1);repmat({'MOS'},nT,1)];

labelLst2=[repmat({'LSTM'},nT*3,1);...
    repmat({'LR'},nT*3,1);...
    repmat({'NN'},nT*3,1);...
    repmat({'Model'},nT*3,1);];

figure('Position',[1,1,800,600])
labelStr={'','LSTM','','','LR','','','NN','','Noah','VIC','MOS'};
bh=boxplot(dataLst, {labelLst2,labelLst1},'colorgroup',labelLst1,...
    'factorgap',9,'factorseparator',1,'color','rkbrkbrkbkkk','Symbol','+','Widths',0.75,...
    'Labels',labelStr);
ylabel(yLabelStr);
ylim(yRange)
set(bh,'LineWidth',2)
txt = findobj(gca,'Type','text');
set(txt,'FontSize',16)
set(txt(1:3),'FontSize',12)
set(txt,'VerticalAlignment', 'Middle');

fname=[figFolder,'\','boxplot_',stat,'_Region'];
fixFigure([],[fname,suffix]);
%saveas(gcf, [fname]);