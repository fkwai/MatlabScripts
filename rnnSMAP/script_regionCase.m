%% split dataset by HUC2

% Alphabet=char('A'+(1:26)-1)';
% nHUC=12;
% hucFolder='H:\Kuai\map\HUC\';
% trainLst={};
% trainLst{1}={[hucFolder,'hucA.shp'];[hucFolder,'hucD.shp'];...
%     [hucFolder,'hucF.shp'];[hucFolder,'hucL.shp']};
% trainLst{2}={[hucFolder,'hucA.shp'];[hucFolder,'hucB.shp'];...
%     [hucFolder,'hucH.shp'];[hucFolder,'hucK.shp']};
% trainLst{3}={[hucFolder,'hucB.shp'];[hucFolder,'hucK.shp'];...
%     [hucFolder,'hucH.shp'];[hucFolder,'hucL.shp']};
% testLst=[];
% for k=1:nHUC
%     testLst{k}={[hucFolder,'huc',Alphabet(k),'.shp']};
% end
% 
% for k=1:length(trainLst)
%     splitSubset(['huc',trainNameLst{k},'s2'],'shape',2,1,trainLst{k})
% end
% 
% for k=1:length(testLst)
%     splitSubset(['huc',Alphabet(k),'s2'],'shape',2,1,testLst{k})
% end
% 
% %another subset
% trainLst={[hucFolder,'hucA.shp'];[hucFolder,'hucB.shp'];...
%     [hucFolder,'hucG.shp'];[hucFolder,'hucI.shp']};
% splitSubset(['hucABGIs4'],'shape',4,1,trainLst)



%% plot
global kPath
Alphabet=char('A'+(1:26)-1)';
trainName='hucGHIJs4';
outName1=trainName;
outName2=[trainName,'_oneModel'];
outName3=[trainName,'_noModel'];
tTrain=1:366;
tTest=1:366;
epoch=500;

stat='bias';
switch stat
    case 'rmse'
        yRange=[0,0.1];
        yRangeModel=[0,0.2];
        yLabelStr='RMSE';
    case 'bias'
        yRange=[-0.05,0.05];
        yRangeModel=[-0.2,0.2];
        yLabelStr='Bias';
end

%%
ySMAP_All=[];
yLSTM1_All=[];
yLSTM2_All=[];
yLSTM3_All=[];
yNOAH_All=[];
yVIC_All=[];
yMOS_All=[];

nHUC=12;

figFolder=['H:\Kuai\rnnSMAP\regionCase\',trainName,'_',num2str(epoch),'\'];
mkdir(figFolder);
for k=1:nHUC+1
    if k<=nHUC
        
        testName=['huc',Alphabet(k),'s2'];
        figName=[figFolder,testName,'_',stat,'.jpg'];
        
        outFolder1=[kPath.OutSMAP_L3,outName1,kPath.s];
        outFolder2=[kPath.OutSMAP_L3,outName2,kPath.s];
        outFolder3=[kPath.OutSMAP_L3,outName3,kPath.s];
        
        %% SMAP
        [dataTrain,dataStat] = readDatabaseSMAP(trainName,'SMAP');
        [dataTest,dataStat] = readDatabaseSMAP(testName,'SMAP');
        ySMAP_train=dataTrain(tTrain,:);
        ySMAP=dataTest(tTest,:);
        meanSMAP=dataStat(3);
        stdSMAP=dataStat(4);
        
        %% LSTM
        [dataTrain,dataTest]=readRnnPred(outFolder1,trainName,testName,epoch);
        yLSTM1_train=(dataTrain(tTrain,:)).*stdSMAP+meanSMAP;
        yLSTM1=(dataTest(tTest,:)).*stdSMAP+meanSMAP;
        
        [dataTrain,dataTest]=readRnnPred(outFolder2,trainName,testName,epoch);
        yLSTM2_train=(dataTrain(tTrain,:)).*stdSMAP+meanSMAP;
        yLSTM2=(dataTest(tTest,:)).*stdSMAP+meanSMAP;
        
        [dataTrain,dataTest]=readRnnPred(outFolder3,trainName,testName,epoch);
        yLSTM3_train=(dataTrain(tTrain,:)).*stdSMAP+meanSMAP;
        yLSTM3=(dataTest(tTest,:)).*stdSMAP+meanSMAP;
        
        %% Model
        [dataTrain,dataStat] = readDatabaseSMAP(trainName,'LSOIL');
        yNOAH_train=dataTrain(tTrain,:)/100;
        [dataTrain,dataStat] = readDatabaseSMAP(trainName,'LOIL_VIC');
        yVIC_train=dataTrain(tTrain,:)/100;
        [dataTrain,dataStat] = readDatabaseSMAP(trainName,'SOILM_MOS');
        yMOS_train=dataTrain(tTrain,:)/100;
        
        [dataTest,dataStat] = readDatabaseSMAP(testName,'LSOIL');
        yNOAH=dataTest(tTrain,:)/100;
        [dataTest,dataStat] = readDatabaseSMAP(testName,'LOIL_VIC');
        yVIC=dataTest(tTrain,:)/100;
        [dataTest,dataStat] = readDatabaseSMAP(testName,'SOILM_MOS');
        yMOS=dataTest(tTrain,:)/100;
        
        %% add to All
        ySMAP_All=[ySMAP_All,ySMAP];
        yLSTM1_All=[yLSTM1_All,yLSTM1];
        yLSTM2_All=[yLSTM2_All,yLSTM2];
        yLSTM3_All=[yLSTM3_All,yLSTM3];
        yNOAH_All=[yNOAH_All,yNOAH];
        yVIC_All=[yVIC_All,yVIC];
        yMOS_All=[yMOS_All,yMOS];
    else
        ySMAP=ySMAP_All;
        yLSTM1=yLSTM1_All;
        yLSTM2=yLSTM2_All;
        yLSTM3=yLSTM3_All;
        yNOAH=yNOAH_All;
        yVIC=yVIC_All;
        yMOS=yMOS_All;
    end
    
    %% stat
    statTrain_LSTM1=statCal(yLSTM1_train,ySMAP_train);
    statTrain_LSTM2=statCal(yLSTM2_train,ySMAP_train);
    statTrain_LSTM3=statCal(yLSTM3_train,ySMAP_train);
    
    stat_LSTM1=statCal(yLSTM1,ySMAP);
    stat_LSTM2=statCal(yLSTM2,ySMAP);
    stat_LSTM3=statCal(yLSTM3,ySMAP);
    
    statTrain_NOAH=statCal(yNOAH_train,ySMAP_train);
    statTrain_VIC=statCal(yVIC_train,ySMAP_train);
    statTrain_MOS=statCal(yMOS_train,ySMAP_train);
    
    stat_NOAH=statCal(yNOAH,ySMAP);
    stat_VIC=statCal(yVIC,ySMAP);
    stat_MOS=statCal(yMOS,ySMAP);   
    
    nTrain=length(statTrain_LSTM1.(stat));
    nT=length(stat_LSTM1.(stat));
    
    dataLst=[statTrain_LSTM1.(stat);statTrain_LSTM2.(stat);statTrain_LSTM3.(stat);...
        stat_LSTM1.(stat);stat_LSTM2.(stat);stat_LSTM3.(stat);];
    labelLst1=[repmat({'ensemble'},nTrain,1);repmat({'one'},nTrain,1);repmat({'no'},nTrain,1);...
        repmat({'ensemble'},nT,1);repmat({'one'},nT,1);repmat({'no'},nT,1);];
    labelLst2=[repmat({'Train'},nTrain*3,1);...
        repmat({'Test'},nT*3,1);];
    
    dataLstModel=[statTrain_NOAH.(stat);statTrain_VIC.(stat);statTrain_MOS.(stat);...
        stat_NOAH.(stat);stat_VIC.(stat);stat_MOS.(stat);];
    labelLstModel1=[repmat({'NOAH'},nTrain,1);repmat({'VIC'},nTrain,1);repmat({'MOS'},nTrain,1);...
        repmat({'NOAH'},nT,1);repmat({'VIC'},nT,1);repmat({'MOS'},nT,1);];
    labelLstModel2=[repmat({'Train'},nTrain*3,1);...
        repmat({'Test'},nT*3,1);];
    
    figure('Position',[1,1,800,600])
    subplot(1,2,1)
    bh=boxplot(dataLst, {labelLst2,labelLst1},'colorgroup',labelLst1,...
        'factorgap',9,'factorseparator',1,'color','rkbg','Symbol','+','Widths',0.75);
    if strcmp(stat,'bias')
        hline=refline(0,0);
    end
    ylabel(yLabelStr);
    ylim(yRange)
    set(bh,'LineWidth',2)
    
    subplot(1,2,2)
    bh=boxplot(dataLstModel, {labelLstModel2,labelLstModel1},'colorgroup',labelLst1,...
        'factorgap',9,'factorseparator',1,'color','rkbg','Symbol','+','Widths',0.75);
    if strcmp(stat,'bias')
        hline=refline(0,0);
    end
    ylabel(yLabelStr);
    ylim(yRangeModel)
    set(bh,'LineWidth',2)
    
    if k<=nHUC
        suptitle(testName)
        saveas(gcf,figName)
    else        
        suptitle('All HUCs')
        figName=[figFolder,'hucALL_',stat,'.jpg'];
        saveas(gcf,figName)
    end
end
%% Sample Scripts - splitsubset shapefile
% sLstACD={'H:\Kuai\map\physio_shp\rnnSMAP\regionA.shp';...
%     'H:\Kuai\map\physio_shp\rnnSMAP\regionC.shp';...
%     'H:\Kuai\map\physio_shp\rnnSMAP\regionD.shp'};
% sLstBCD={'H:\Kuai\map\physio_shp\rnnSMAP\regionB.shp';...
%     'H:\Kuai\map\physio_shp\rnnSMAP\regionC.shp';...
%     'H:\Kuai\map\physio_shp\rnnSMAP\regionD.shp'};
% sLstA={'H:\Kuai\map\physio_shp\rnnSMAP\regionA.shp';};
% sLstB={'H:\Kuai\map\physio_shp\rnnSMAP\regionB.shp';};
% splitSubset('regionACDs2','shape',2,1,sLstACD)
% splitSubset('regionBCDs2','shape',2,1,sLstBCD)
% splitSubset('regionAs2','shape',2,1,sLstA)
% splitSubset('regionBs2','shape',2,1,sLstB)
%