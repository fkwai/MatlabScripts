function dataOut= readRnnPred(outName,dataName,epoch,timeOpt,varargin)
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
        dataFile=['test_',dataName,'_t',num2str(timeOpt),'_epoch',num2str(epoch),'.csv'];
    end
    data=csvread([rootOut,outName,filesep,dataFile]);
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
        data=batchMat.yLSTM_batch;
    else
        disp('--> one by one for the first time')
        dataFile=[rootOut,outName,filesep,batchName,filesep,'drMC_0.csv'];
        temp=csvread(dataFile);
        data=zeros([size(temp),drBatch]);
        data(:,:,1)=temp;
        for k=1:drBatch-1
            dataFile=[rootOut,outName,filesep,batchName,filesep,'drMC_',num2str(k),'.csv'];
            temp=csvread(dataFile);
            data(:,:,k)=temp;
        end
        yLSTM_batch=data;
        save(batchMatFile,'yLSTM_batch','-v7.3')
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
dataOut=(data).*stdSMAP+meanSMAP;

end


