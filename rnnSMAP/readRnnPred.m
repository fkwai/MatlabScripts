function dataOut= readRnnPred(outName,dataName,epoch,timeOpt,varargin)
% read prediction from testRnnSMAP.lua into a matrix

global kPath

pnames={'rootOut','drBatch'};
dflts={kPath.OutSMAP_L3,0};
[rootOut,drBatch]=...
    internal.stats.parseArgs(pnames, dflts, varargin{:});

if drBatch==0
    dataFile=['test_',dataName,'_t',num2str(timeOpt),'_epoch',num2str(epoch),'.csv'];
    data=csvread([rootOut,outName,filesep,dataFile]);
else
    disp('read LSTM dropout batch')
    dataFolder=['test_',dataName,'_t',num2str(timeOpt),'_epoch',num2str(epoch),'_drM',num2str(drBatch)];
    dataFile=[rootOut,outName,filesep,dataFolder,filesep,'drEm_1.csv'];
    temp=csvread(dataFile);
    data=zeros([size(temp),drBatch]);
    for k=2:drBatch
        dataFile=[rootOut,outName,filesep,dataFolder,filesep,'drEm_',num2str(k),'.csv'];
        temp=csvread(dataFile);
        data(:,:,k)=temp;
    end
end

%% transfer back
statFile=[kPath.DBSMAP_L3_CONUS,filesep,'SMAP_stat.csv'];
statSMAP=csvread(statFile);
meanSMAP=statSMAP(3);
stdSMAP=statSMAP(4);    
dataOut=(data).*stdSMAP+meanSMAP;

end

