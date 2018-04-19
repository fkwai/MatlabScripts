function [inputMat,outputMat]=readSelfPred(outName,dataName,varargin)

global kPath

varinTab={'epoch',[];...
    'timeOpt',2;...
    'rootOut',kPath.OutSelf_L3;...
    'rootDB',kPath.DBSMAP_L3;...
    'drMode',0;...
    };

[epoch,timeOpt,rootOut,rootDB,drMode]=internal.stats.parseArgs(varinTab(:,1),varinTab(:,2), varargin{:});

%% read option
opt = readRnnOpt( outName,rootOut );
varLst=readVarLst([rootDB,'Variable',filesep,opt.var,'.csv']);
if isempty(epoch)
    epoch=opt.nEpoch;
end

%% read predictors
inputMat=[];
for k=1:length(varLst)
    var=varLst{k};
    [xData,xStat,xDataNorm] = readDB_SMAP(dataName,var);
    if timeOpt==1
        temp=xDataNorm(1:366,:);
    elseif timeOpt==2
        temp=xDataNorm(367:732,:);
    elseif timeOpt==3
        temp=xDataNorm(1:732,:);
    elseif timeOpt==0
        temp=xDataNorm;
    end
    inputMat=cat(3,inputMat,temp);
end
[nt,ngrid,nx]=size(inputMat);

%% read predictions
if drMode==0
    outputMat=zeros(nt,ngrid,nx).*nan;
else
    outputMat=zeros(nt,ngrid,nx,drMode).*nan;
end


if drMode==0
    for k=1:length(varLst)
        var=varLst{k};
        outFile=[rootOut,filesep,outName,filesep,'test_',dataName,'_',var,'_t',num2str(timeOpt),...
            '_epoch',num2str(epoch),'.csv'];
        temp=csvread(outFile);
        outputMat(:,:,k)=temp;
    end
else
    outMatFile=[rootOut,filesep,outName,filesep,'test_',dataName,'_t',num2str(timeOpt),...
        '_epoch',num2str(epoch),'_drM',num2str(drMode),'.mat'];
    if exist(outMatFile,'file')
        temp=load(outMatFile);
        outputMat=temp.outputMat;
    else
        disp('read dropout ensemble')
        for k=1:length(varLst)
            var=varLst{k};
            outFolder=[rootOut,filesep,outName,filesep,'test_',dataName,'_t',num2str(timeOpt),...
                '_epoch',num2str(epoch),'_drM',num2str(drMode),filesep];
            for kk=1:drMode
                disp(['var ',var,' batch ',num2str(kk)])
                outFile=[outFolder,var,'_drEm_',num2str(kk),'.csv'];
                temp=csvread(outFile);
                outputMat(:,:,k,kk)=temp;
            end
        end
        save(outMatFile,'outputMat');
    end
    
    
    %%
    % ix=5;
    % ig=randi([1,size(inputNormMat,2)]);
    % plot(1:size(inputNormMat,1),inputNormMat(:,ig,ix),'b');hold on
    % plot(1:size(outputNormMat,1),outputNormMat(:,ig,ix),'r');hold off
    % corr(inputNormMat(:,ig,ix),outputNormMat(:,ig,ix))
    
    %outStat=mean((outputNormMat-inputNormMat).^2,3).^0.5;
end