% calculate Komnogorov-Smirnov distance for each regional cases

global kPath
Alphabet=char('A'+(1:26)-1)';

caseLst={'ABFL','ABGI','ABGL','ABHK','ACGK','ADFL','BKHL','GHIJ'};
nCase=length(caseLst);
d1Lst=zeros(nCase,1);
d2Lst=zeros(nCase,1);
d3Lst=zeros(nCase,1);
statLSTM_train=cell(nCase,3);
statLSTM_test=cell(nCase,3);
statModel_train=cell(nCase,3);
statModel_test=cell(nCase,3);
statDiff_train=cell(nCase,1);
statDiff_test=cell(nCase,1);

tTrain=1:366;
tTest=1:366;
epoch=100;
for kCase=1:nCase
    hucLst=caseLst{kCase};
    disp(hucLst)
    tic
    hucIndLst=double(hucLst)-64;
    trainName=['huc',hucLst,'s4'];
    outName1=trainName;
    outName2=[trainName,'_oneModel'];
    outName3=[trainName,'_noModel'];
    
    %% Start
    ySMAP_test=[];
    yLSTM1_test=[];
    yLSTM2_test=[];
    yLSTM3_test=[];
    
    yLR1_test=[];
    yLR2_test=[];
    yLR3_test=[];
    
    yNN1_test=[];
    yNN2_test=[];
    yNN3_test=[];
    
    yNOAH_test=[];
    yVIC_test=[];
    yMOS_test=[];
    
    nHUC=12;
    
    for k=1:nHUC
        testName=['huc',Alphabet(k),'s2'];
        
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
        
        %% LR and NN
        [outTrain1,out1,cov1]=testRnnSMAP_readData(outName1,trainName,testName,epoch,...
            'timeOpt',3,'readData',0);
        [outTrain2,out2,cov2]=testRnnSMAP_readData(outName2,trainName,testName,epoch,...
            'varLst','varLst_oneModel','timeOpt',3,'readData',0);
        [outTrain3,out3,cov3]=testRnnSMAP_readData(outName3,trainName,testName,epoch,...
            'varLst','varLst_noModel','timeOpt',3,'readData',0);
        yLR1_train=outTrain1.yLR;
        yLR2_train=outTrain2.yLR;
        yLR3_train=outTrain3.yLR;
        yLR1=out1.yLR;
        yLR2=out2.yLR;
        yLR3=out3.yLR;
        
        yNN1_train=outTrain1.yNN;
        yNN2_train=outTrain2.yNN;
        yNN3_train=outTrain3.yNN;
        yNN1=out1.yNN;
        yNN2=out2.yNN;
        yNN3=out3.yNN;
        
        %% add to All
        if ~ismember(k,hucIndLst)
            ySMAP_test=[ySMAP_test,ySMAP];
            yLSTM1_test=[yLSTM1_test,yLSTM1];
            yLSTM2_test=[yLSTM2_test,yLSTM2];
            yLSTM3_test=[yLSTM3_test,yLSTM3];
            yLR1_test=[yLR1_test,yLR1];
            yLR2_test=[yLR2_test,yLR2];
            yLR3_test=[yLR3_test,yLR3];
            yNN1_test=[yNN1_test,yNN1];
            yNN2_test=[yNN2_test,yNN2];
            yNN3_test=[yNN3_test,yNN3];
            yNOAH_test=[yNOAH_test,yNOAH];
            yVIC_test=[yVIC_test,yVIC];
            yMOS_test=[yMOS_test,yMOS];
        end
    end
    
    %% stat
    statTrain_LSTM1=statCal(yLSTM1_train,ySMAP_train);
    statTrain_LSTM2=statCal(yLSTM2_train,ySMAP_train);
    statTrain_LSTM3=statCal(yLSTM3_train,ySMAP_train);
    
    statTest_LSTM1=statCal(yLSTM1_test,ySMAP_test);
    statTest_LSTM2=statCal(yLSTM2_test,ySMAP_test);
    statTest_LSTM3=statCal(yLSTM3_test,ySMAP_test);
    
    statTrain_LR1=statCal(yLR1_train,ySMAP_train);
    statTrain_LR2=statCal(yLR2_train,ySMAP_train);
    statTrain_LR3=statCal(yLR3_train,ySMAP_train);
    
    statTest_LR1=statCal(yLR1_test,ySMAP_test);
    statTest_LR2=statCal(yLR2_test,ySMAP_test);
    statTest_LR3=statCal(yLR3_test,ySMAP_test);
    
    statTrain_NN1=statCal(yNN1_train,ySMAP_train);
    statTrain_NN2=statCal(yNN2_train,ySMAP_train);
    statTrain_NN3=statCal(yNN3_train,ySMAP_train);
    
    statTest_NN1=statCal(yNN1_test,ySMAP_test);
    statTest_NN2=statCal(yNN2_test,ySMAP_test);
    statTest_NN3=statCal(yNN3_test,ySMAP_test);
    
    statTrain_NOAH=statCal(yNOAH_train,ySMAP_train);
    statTrain_VIC=statCal(yVIC_train,ySMAP_train);
    statTrain_MOS=statCal(yMOS_train,ySMAP_train);
    
    statTest_NOAH=statCal(yNOAH_test,ySMAP_test);
    statTest_VIC=statCal(yVIC_test,ySMAP_test);
    statTest_MOS=statCal(yMOS_test,ySMAP_test);
    
    statTrain_Diff=statCal(yNOAH_train,yLSTM2_train);
    statTest_Diff=statCal(yNOAH_test,yLSTM2_test);
    
    %% dist
    stat='bias';
    [h,p,D] = kstest2(statTrain_NOAH.(stat),statTest_NOAH.(stat));
    d1Lst(kCase)=D;
    [h,p,D] = kstest2(statTrain_VIC.(stat),statTest_VIC.(stat));
    d2Lst(kCase)=D;
    [h,p,D] = kstest2(statTrain_MOS.(stat),statTest_MOS.(stat));
    d3Lst(kCase)=D;
    statLSTM_train(kCase,:)={statTrain_LSTM1,statTrain_LSTM2,statTrain_LSTM3};
    statLSTM_test(kCase,:)={statTest_LSTM1,statTest_LSTM2,statTest_LSTM3};    
    statLR_train(kCase,:)={statTrain_LR1,statTrain_LR2,statTrain_LR3};
    statLR_test(kCase,:)={statTest_LR1,statTest_LR2,statTest_LR3};
    statNN_train(kCase,:)={statTrain_NN1,statTrain_NN2,statTrain_NN3};
    statNN_test(kCase,:)={statTest_NN1,statTest_NN2,statTest_NN3};
    statModel_train(kCase,:)={statTrain_NOAH,statTrain_VIC,statTrain_MOS};
    statModel_test(kCase,:)={statTest_NOAH,statTest_VIC,statTest_MOS};
    statDiff_train(kCase,:)={statTrain_Diff};
    statDiff_test(kCase,:)={statTest_Diff};
    toc
end


save('H:\Kuai\rnnSMAP\regionCase\distMat.mat','d1Lst','d2Lst','d3Lst','caseLst',...
    'statLSTM_train','statLSTM_test','statModel_train','statModel_test',...
    'statDiff_train','statDiff_test','statLR_train','statLR_test',...
    'statNN_train','statNN_test')




