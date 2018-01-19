function dataOut= readRnnPred(outName,dataName,epoch,timeOpt,varargin)
% read prediction from testRnnSMAP.lua into a matrix

global kPath

pnames={'rootOut','drBatch','rootDB','target'};
dflts={kPath.OutSMAP_L3,0,kPath.DBSMAP_L3,'SMAP'};
[rootOut,drBatch,rootDB,target]=...
    internal.stats.parseArgs(pnames, dflts, varargin{:});

if drBatch==0
    dataFile=['test_',dataName,'_t',num2str(timeOpt),'_epoch',num2str(epoch),'.csv'];
    data=csvread([rootOut,outName,filesep,dataFile]);
else
    disp('read LSTM dropout batch')
    batchName=['test_',dataName,'_t',num2str(timeOpt),'_epoch',num2str(epoch),'_drM',num2str(drBatch)];
    batchMatFile=[rootOut,outName,filesep,batchName,'.mat'];
    if exist([rootOut,outName,filesep,batchName,'.mat'],'file')
        batchMat=load(batchMatFile);
        data=batchMat.yLSTM_batch;
    else
        disp('--> one by one for the first time')
        dataFile=[rootOut,outName,filesep,batchName,filesep,'drEm_1.csv'];
        temp=csvread(dataFile);
        data=zeros([size(temp),drBatch]);
        for k=2:drBatch
            dataFile=[rootOut,outName,filesep,batchName,filesep,'drEm_',num2str(k),'.csv'];
            temp=csvread(dataFile);
            data(:,:,k)=temp;
        end
        yLSTM_batch=data;
        save(batchMatFile,'yLSTM_batch','-v7.3')
    end
end

%% transfer back
statFile=[rootDB,'CONUS',filesep,target,'_stat.csv'];
statSMAP=csvread(statFile);
meanSMAP=statSMAP(3);
stdSMAP=statSMAP(4);    
dataOut=(data).*stdSMAP+meanSMAP;

end

