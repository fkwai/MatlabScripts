function [outMat,statMat,crdMat,optLst]=postRnnSMAP_jobHead(jobHead,varargin)
%read LSTM results of given jobHead.

% input
% jobHead - 

% output
% dataMat -
% statMat -
% crdMat -
% optLst - 

% example
%{
rootOut='E:\Kuai\rnnSMAP_outputs\hucv2n2\';
rootDB='E:\Kuai\rnnSMAP_inputs\hucv2n2\';
jobHead='hucv2n2';
postRnnSMAP_jobHead(jobHead,'rootOut',rootOut,'rootDB',rootDB)
%}

global kPath
pnames={'rootOut','rootDB','timeOpt'};
dflts={kPath.OutSMAP_L3,kPath.DBSMAP_L3,[1,2],[]};
[rootOut,rootDB,timeOpt]=...
    internal.stats.parseArgs(pnames, dflts, varargin{:});

%% init
[outNameLst,optLst]=findJobHead(jobHead,rootOut);

%% read case results
nCase=length(outNameLst);
nT=length(timeOpt);
crdMat=cell(nCase,1);

for k=1:nCase
    for iT=1:length(timeOpt)
        outName=outNameLst{k};
        % default following options. May be change later.
        trainName=optLst(k).train; % test on train set
        nEpoch=optLst(k).nEpoch; % test on max epoch
        out=postRnnSMAP_load(outName,trainName,timeOpt(iT),nEpoch,...
            'rootOut',rootOut,'rootDB',rootDB);
        
        crdFile=[rootDB,filesep,trainName,filesep,'crd.csv'];
        crdTemp=csvread(crdFile);
        crdMat{k}=crdTemp;
        
        % init outMat
        if k==1 && iT==1
            fieldLst=fieldnames(out);
            for iField=1:length(fieldLst)
                outMat.(fieldLst{iField})=cell(nCase,nT);
            end
        end
        
        % fill in outMat
        for iField=1:length(fieldLst)
            outMat.(fieldLst{iField}){k,iT}=out.(fieldLst{iField});
        end
    end
end

%% calculate stat between yLSTM and ySMAP
for k=1:nCase
    for iT=1:length(timeOpt)
        stat=statCal(outMat.yLSTM{k,iT},outMat.ySMAP{k,iT});
        
        % init statMat
        if k==1 && iT==1
            fieldLst=fieldnames(stat);
            for iField=1:length(fieldLst)
                statMat.(fieldLst{iField})=cell(nCase,nT);
            end
        end
        
        % fill in statMat
        for iField=1:length(fieldLst)
            statMat.(fieldLst{iField}){k,iT}=stat.(fieldLst{iField});
        end
    end
end

%% save a matfile
saveMatFile=[rootOut,filesep,jobHead,'.mat'];
save(saveMatFile,'outMat','statMat','crdMat','optLst')


end

