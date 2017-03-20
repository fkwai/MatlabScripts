function [statGLDAS,statLSTM,statLR,statNN]=combineExtropolate_SMAP()
% combine extroplated result trained in single region and tested in
% others. Do an average of stats.

% example:
rootFolder='Y:\Kuai\rnnSMAP\output\CONUS_div\';
regionNameLst={};
for k=1:7
    regionNameLst=[regionNameLst,['div_sub4_',num2str(k)]];
end
epoch=500;
doAnorm=1;



nt=4160;
indCombo=[];

%% start
for k=1:length(regionNameLst)
    testName=regionNameLst{k};
    trainNameLst=setdiff(regionNameLst,testName);
    disp(['working on region ',num2str(k)]);
    indFile=[rootFolder,testName,'.csv'];    
    ind=csvread(indFile);
    indCombo=[indCombo;ind];

    
    %% read SMAP and GLDAS
    disp('read SMAP and GLDAS')
    tic
    SMAPmatFile=[rootFolder,'outSMAP_',testName,'.mat'];
    SMAPmat=load(SMAPmatFile);
    ySMAP=SMAPmat.ySMAP;
    lbSMAP=SMAPmat.lbSMAP;
    ubSMAP=SMAPmat.ubSMAP;
    
    GLDASmatFile=[rootFolder,'outGLDAS_',testName,'.mat'];
    GLDASmat=load(GLDASmatFile);
    yGLDAS=GLDASmat.yGLDAS;
    yGLDAS=yGLDAS/100;
    toc
    
    %% read LSTM data
    disp('read LSTM')
    tic
    dataLSTM=[];
    for i=1:length(trainNameLst)
        trainName=trainNameLst{i};
        temp=readRnnPred(rootFolder,trainName,testName,epoch);
        if doAnorm~=0
            yTemp=(ySMAP-lbSMAP)./(ubSMAP-lbSMAP)*2-1;
            yMean=nanmean(yTemp);
            yLSTM=(temp+repmat(yMean,[nt,1])+1).*(ubSMAP-lbSMAP)./2+lbSMAP;
            %yLSTM=(dataLSTM+repmat(yMean,[nt,1])+1).*(ubSMAP)./2+lbSMAP;
        else
            yLSTM=(temp+1).*(ubSMAP-lbSMAP)./2+lbSMAP;
            %yLSTM=(dataLSTM+1).*(ubSMAP)./2+lbSMAP;
        end
        
        dataLSTM=cat(3,dataLSTM,yLSTM);
    end
    toc
    
    %% read LR data
    disp('read LR')
    tic
    dataLR=[];
    for i=1:length(trainNameLst)
        trainName=trainNameLst{i};
        fileLR=[rootFolder,'outLR_',trainName,'_',testName,'.mat'];
        LRmat=load(fileLR);
        temp=LRmat.yLR;
        dataLR=cat(3,dataLR,temp);
    end
    toc
    
    %% read NN data
    disp('read NN')
    tic
    dataNN=[];
    for i=1:length(trainNameLst)
        trainName=trainNameLst{i};
        fileNN=[rootFolder,'outNN_',trainName,'_',testName,'.mat'];
        NNmat=load(fileNN);
        temp=NNmat.yNN;
        dataNN=cat(3,dataNN,temp);
    end
    toc
    
    %% calculate stat
    for i=1:length(trainNameLst)
        statLSTMtemp(i)=statCal(dataLSTM(:,:,i),ySMAP);
        statLRtemp(i)=statCal(dataLR(:,:,i),ySMAP);
        statNNtemp(i)=statCal(dataNN(:,:,i),ySMAP);
    end
    statGLDASall(k)=statCal(yGLDAS,ySMAP);
    statGLDASall(k).bias=abs(statGLDASall(k).bias); % when average bias should be abs-ed
    statLSTMall(k)=statAverage(statLSTMtemp);
    statLRall(k)=statAverage(statLRtemp);
    statNNall(k)=statAverage(statNNtemp);
end

dlmwrite([rootFolder,'indExtro.csv'],indCombo,'precision',8); 
statGLDAS=statCombine(statGLDASall);
statLSTM=statCombine(statLSTMall);
statLR=statCombine(statLRall);
statNN=statCombine(statNNall);
save([rootFolder,'statExtro.mat'],'statGLDAS','statLSTM','statLR','statNN');
end

function outStat=statAverage(stat)
nash=[];
rsq=[];
bias=[];
rmse=[];
for i=1:length(stat)
    nash=cat(3,nash,stat(i).nash);
    rsq=cat(3,rsq,stat(i).rsq);
    bias=cat(3,bias,stat(i).bias);
    rmse=cat(3,rmse,stat(i).rmse);
end
outStat.nash=nanmean(nash,3);
outStat.rsq=nanmean(rsq,3);
outStat.bias=nanmean(abs(bias),3);
outStat.rmse=nanmean(rmse,3);
end

function outStat=statCombine(stat)
nash=[];
rsq=[];
bias=[];
rmse=[];
for i=1:length(stat)
    nash=cat(1,nash,stat(i).nash);
    rsq=cat(1,rsq,stat(i).rsq);
    bias=cat(1,bias,stat(i).bias);
    rmse=cat(1,rmse,stat(i).rmse);
end
outStat.nash=nash;
outStat.rsq=rsq;
outStat.bias=bias;
outStat.rmse=rmse;
end

