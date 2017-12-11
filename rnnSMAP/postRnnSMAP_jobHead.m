function [outMat,statMat,crdMat,optLst]=postRnnSMAP_jobHead(jobHead,varargin)
%read LSTM results of given jobHead.

% input
% jobHead - a common head of jobs to read
% varargin
% rootDB - input folder. Default to be kPath.DBSMAP_L3
% rootOut - output folder. Default to be kPath.OutSMAP_L3
% timeOpt - [1,2] will read both t1 and t2, and output matrixs will
% contains #timeOpt rows. 
% saveName - this function will save a matfile in output folder. saveName
% is the name of this matfile. Default to be jobhead + options. 
% 

% outputContains
% dataMat - matrix of LSTM outputs from postRnnSMAP_load.  all
% fields from postRnnSMAP_load will be dataMat.(field), and it is a cell of
% {#cases, #timeOpt}, and each cell is a matrix of size [#t, #cell]
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
pnames={'rootOut','rootDB','timeOpt','saveName','rmStd','testName','saveTS'};
dflts={kPath.OutSMAP_L3,kPath.DBSMAP_L3,[1,2],[],0,[],1};
[rootOut,rootDB,timeOpt,saveName,rmStd,testNameUni,saveTS]=...
    internal.stats.parseArgs(pnames, dflts, varargin{:});

%% init
[outNameLst,optLst]=findJobHead(jobHead,rootOut);

% save matfile name
if isempty(saveName)
    saveName=jobHead;
end
if ~isempty(testNameUni)
    saveName=[saveName,'_',testNameUni];    
end
if rmStd~=0
    saveName=[saveName,'_rmStd',num2str(rmStd)];
end

%% read case results
nCase=length(outNameLst);
nT=length(timeOpt);
crdMat=cell(nCase,1);

for k=1:nCase
    for iT=1:length(timeOpt)
        outName=outNameLst{k};
        % default following options. May be change later.
        if isempty(testNameUni)
            testName=optLst(k).train; % test on train set
        else
            testName=testNameUni;
        end
        nEpoch=optLst(k).nEpoch; % test on max epoch
        out=postRnnSMAP_load(outName,testName,timeOpt(iT),...
            'rootOut',rootOut,'rootDB',rootDB);
        
        crdFile=[rootDB,filesep,testName,filesep,'crd.csv'];
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
        stat=statCal(outMat.yLSTM{k,iT},outMat.ySMAP{k,iT},'rmStd',rmStd);
        
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

%% calculate stat between yGLDAS and ySMAP
for k=1:nCase
    for iT=1:length(timeOpt)
        stat=statCal(outMat.yGLDAS{k,iT},outMat.ySMAP{k,iT},'rmStd',rmStd);
        
        % init statMat
        if k==1 && iT==1
            fieldLst=fieldnames(stat);
            for iField=1:length(fieldLst)
                statModelMat.(fieldLst{iField})=cell(nCase,nT);
            end
        end
        
        % fill in statMat
        for iField=1:length(fieldLst)
            statModelMat.(fieldLst{iField}){k,iT}=stat.(fieldLst{iField});
        end
    end
end

%% calculate stat between yLSTM and yGLDAS
for k=1:nCase
    for iT=1:length(timeOpt)
        stat=statCal(outMat.yLSTM{k,iT},outMat.yGLDAS{k,iT},'rmStd',rmStd);
        
        % init statMat
        if k==1 && iT==1
            fieldLst=fieldnames(stat);
            for iField=1:length(fieldLst)
                statSelfMat.(fieldLst{iField})=cell(nCase,nT);
            end
        end
        
        % fill in statMat
        for iField=1:length(fieldLst)
            statSelfMat.(fieldLst{iField}){k,iT}=stat.(fieldLst{iField});
        end
    end
end



%% save a matfile
if saveTS
    saveMatFile=[rootOut,filesep,saveName,'.mat'];
    save(saveMatFile,'outMat','statMat','statModelMat','statSelfMat','crdMat','optLst','-v7.3')
else
    saveMatFile=[rootOut,filesep,saveName,'_stat.mat'];
    save(saveMatFile,'statMat','statModelMat','statSelfMat','crdMat','optLst')
end
    


end

