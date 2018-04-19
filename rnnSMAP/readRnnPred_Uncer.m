function [dataPred,dataSig]= readRnnPred_Uncer(outName,dataName,epoch,timeOpt,varargin)
% read prediction from testRnnSMAP.lua into a matrix

global kPath

pnames={'rootOut','rootDB','drBatch','targetName'};
dflts={[],[],0,[]};
[rootOut,rootDB,drBatch,targetName]=...
    internal.stats.parseArgs(pnames, dflts, varargin{:});

%% deal with global database or conus database
if length(timeOpt)==1
    doGlobal=0;
    if isempty(rootOut)
        rootOut=kPath.OutSMAP_L3;
    end
    if isempty(rootDB)
        rootDB=kPath.DBSMAP_L3;
    end
    if isempty(targetName)
        targetName='SMAP';
    end
else
    doGlobal=1;
    syr=timeOpt(1);
    eyr=timeOpt(2);
    if isempty(rootOut)
        rootOut=kPath.OutSMAP_L3_Global;
    end
    if isempty(rootDB)
        rootDB=kPath.DBSMAP_L3_Global;
    end
    if isempty(targetName)
        targetName='SMAP_AM';
    end
end

%% start
if drBatch==0
    if doGlobal
        dataFile=['test_',dataName,'_',num2str(syr),'_',num2str(eyr),'_ep',num2str(epoch),'.csv'];
    else
        dataFile1=['test_',dataName,'_t',num2str(timeOpt),'_epoch',num2str(epoch),'.csv'];
        dataFile2=['testSigma_',dataName,'_t',num2str(timeOpt),'_epoch',num2str(epoch),'.csv'];
    end
    data1=csvread([rootOut,outName,filesep,dataFile1]);
    data2=csvread([rootOut,outName,filesep,dataFile2]);
else
    disp('read LSTM dropout batch')
    if doGlobal
        batchName=['test_',dataName,'_',num2str(syr),'_',num2str(eyr),'_ep',num2str(epoch),'_drM',num2str(drBatch)];
    else
        batchName=['test_',dataName,'_t',num2str(timeOpt),'_epoch',num2str(epoch),'_drM',num2str(drBatch)];
    end
    batchMatFile=[rootOut,outName,filesep,batchName,'.mat'];
    if exist([rootOut,outName,filesep,batchName,'.mat'],'file')
        batchMat=load(batchMatFile);
        data1=batchMat.yLSTM_batch;
        data2=batchMat.sigLSTM_batch;
    else
        disp('--> one by one for the first time')
        dataFile1=[rootOut,outName,filesep,batchName,filesep,'drEm_1.csv'];
        temp1=csvread(dataFile1);
        data1=zeros([size(temp1),drBatch]);
        data1(:,:,1)=temp1;
        dataFile2=[rootOut,outName,filesep,batchName,filesep,'drEmSigma_1.csv'];
        temp2=csvread(dataFile2);
        data2=zeros([size(temp2),drBatch]);
        data2(:,:,1)=temp2;
        for k=2:drBatch
            dataFile1=[rootOut,outName,filesep,batchName,filesep,'drEm_',num2str(k),'.csv'];
            temp1=csvread(dataFile1);
            data1(:,:,k)=temp1;
            dataFile2=[rootOut,outName,filesep,batchName,filesep,'drEmSigma_',num2str(k),'.csv'];
            temp2=csvread(dataFile2);
            data2(:,:,k)=temp2;
        end
        yLSTM_batch=data1;
        sigLSTM_batch=data2;
        save(batchMatFile,'yLSTM_batch','sigLSTM_batch','-v7.3')
    end
end

%% transfer back
if doGlobal
    statFile=[rootDB,'Statistics',filesep,targetName,'_stat.csv'];
else
    statFile=[rootDB,'CONUS',filesep,targetName,'_stat.csv'];
end
statSMAP=csvread(statFile);

meanSMAP=statSMAP(3);
stdSMAP=statSMAP(4);
dataPred=(data1).*stdSMAP+meanSMAP;
dataSig=data2;

end


